# MyProject

Development environment generated with `setup-devenv`.

## Requirements

- [Nix](https://nixos.org/download) with flakes enabled
- Optional: [direnv](https://direnv.net/)

## Usage

```sh
nix develop          # enter the development shell
# or, with direnv installed:
direnv allow
```

The shell exposes `build-*` aliases (for example `build-setup`, `build-run`,
`build-test`, `build-clean`). Run `alias | grep build-` inside the shell to list
them.

## Layout

- `flake.nix` / `shell.nix` - development environment definition
- `src/` or `cmd/` - project sources

## License

See `LICENSE`.
