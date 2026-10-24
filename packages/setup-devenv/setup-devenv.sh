#!/usr/bin/env bash
# Scaffold a flake-based development environment from a bundled template.
set -euo pipefail

die() {
  printf 'setup-devenv: %s\n' "$*" >&2
  exit 1
}

list_templates() {
  for dir in "$TEMPLATES"/*/; do
    basename "$dir"
  done
}

usage() {
  cat <<'EOF'
Usage: setup-devenv [template] [directory] [options]

Create a flake-based development environment in <directory> (default: .) from
one of the bundled templates. Existing files are only overwritten with --force.

Options:
  -n, --name <name>   project name written into flake.nix, Cargo.toml,
                      package.json and go.mod (default: directory name)
  -f, --force         overwrite existing files
  -l, --list          list available templates
  -h, --help          show this help

Templates:
EOF
  list_templates | sed 's/^/  /'
}

template=""
directory="."
name=""
force=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h | --help)
      usage
      exit 0
      ;;
    -l | --list)
      list_templates
      exit 0
      ;;
    -f | --force)
      force=1
      shift
      ;;
    -n | --name)
      [[ $# -ge 2 ]] || die "--name requires a value"
      name="$2"
      shift 2
      ;;
    -*)
      die "unknown option '$1' (try --help)"
      ;;
    *)
      if [[ -z "$template" ]]; then
        template="$1"
      elif [[ "$directory" == "." ]]; then
        directory="$1"
      else
        die "unexpected argument '$1' (try --help)"
      fi
      shift
      ;;
  esac
done

[[ -n "$template" ]] || {
  usage
  exit 1
}

template_dir="$TEMPLATES/$template"
[[ -d "$template_dir" ]] || die "unknown template '$template' (try --list)"

mkdir -p "$directory"
target="$(cd "$directory" && pwd)"
[[ -n "$name" ]] || name="$(basename "$target")"
name="${name//[^A-Za-z0-9._-]/-}"

created=()
skipped=()

while IFS= read -r -d "" file; do
  relative="${file#"$template_dir"/}"
  destination="$target/$relative"
  if [[ -e "$destination" && "$force" -eq 0 ]]; then
    skipped+=("$relative")
    continue
  fi
  mkdir -p "$(dirname "$destination")"
  cp "$file" "$destination"
  created+=("$relative")
done < <(find "$template_dir" -type f -print0)

# Shared files that every generated project gets (README, LICENSE, ...).
for shared in "$TEMPLATES"/README.md "$TEMPLATES"/LICENSE; do
  [[ -f "$shared" ]] || continue
  relative="$(basename "$shared")"
  destination="$target/$relative"
  if [[ -e "$destination" && "$force" -eq 0 ]]; then
    skipped+=("$relative")
    continue
  fi
  cp "$shared" "$destination"
  created+=("$relative")
done

for relative in ${created[@]+"${created[@]}"}; do
  file="$target/$relative"
  [[ "$relative" == "LICENSE" ]] && continue
  grep -Iq . "$file" || continue
  sed -i \
    -e "s/MyProject/$name/g" \
    -e "s/^name = \"test\"\$/name = \"$name\"/" \
    -e "s/\"name\": \"test\"/\"name\": \"$name\"/" \
    -e "s#github.com/mt190502/test#github.com/mt190502/$name#g" \
    -e "s#github.com/mt190502/go#github.com/mt190502/$name#g" \
    "$file"
done

if ! git -C "$target" rev-parse --git-dir >/dev/null 2>&1; then
  git -C "$target" init --quiet
  # Stage the generated files so `nix develop` sees them in a git flake.
  git -C "$target" add --all
  printf 'setup-devenv: initialised a git repository and staged the files in %s\n' "$target"
fi

if [[ ${#created[@]} -eq 0 ]]; then
  printf 'setup-devenv: nothing created in %s (all files exist, use --force)\n' "$target"
else
  printf 'setup-devenv: created %d file(s) in %s\n' "${#created[@]}" "$target"
  printf '  template: %s, project: %s\n' "$template" "$name"
  printf '\nNext steps:\n  cd %s\n  nix develop        # or: direnv allow\n' "$target"
fi

if [[ ${#skipped[@]} -gt 0 ]]; then
  printf '\nsetup-devenv: skipped %d existing file(s), use --force to overwrite:\n' "${#skipped[@]}"
  printf '  %s\n' "${skipped[@]}"
fi
