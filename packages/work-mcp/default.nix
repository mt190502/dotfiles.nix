{
  lib,
  stdenv,
  makeWrapper,
  fetchurl,
  pkgs-unstable,
  ...
}:

let
  # The SDK needs httpx2>=2.5.0 (mcp 2.x imports it even at startup) while
  # stable nixpkgs ships 2.3.0, so the whole interpreter env comes from
  # nixpkgs-unstable. Both the flake perSystem callPackage and the home
  # module inject pkgs-unstable here.
  python3 = pkgs-unstable.python3;

  # mcp Python SDK pinned to the 2.x line the server code targets (PEP 723
  # pin in mcp_server.py). nixpkgs does not ship the 2.x SDK (nor its
  # version-locked mcp-types companion), so both wheels are fetched from
  # PyPI. mcp 2 renamed FastMCP to MCPServer and swapped httpx for httpx2.
  mcpTypes = python3.pkgs.buildPythonPackage {
    pname = "mcp-types";
    version = "2.2.0";
    format = "wheel";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/8f/d7/6ffba5d8cd5dd9b8a19478875c50e04945314ba5074e84d749283f27f62d/mcp_types-2.2.0-py3-none-any.whl";
      hash = "sha256-6kdrc+6GcJq1q8lFI4XtNswFkH5YI1ViLilFlcmgTxM=";
    };
    propagatedBuildInputs = with python3.pkgs; [
      pydantic
      typing-extensions
    ];
    meta = {
      license = lib.licenses.mit;
    };
  };

  mcpSdk = python3.pkgs.buildPythonPackage {
    pname = "mcp";
    version = "2.2.0";
    format = "wheel";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/1b/ff/8e7eade68b8a28f7da0ed1085544341b51f9c935dbf6b95c76b7edfea6a0/mcp-2.2.0-py3-none-any.whl";
      hash = "sha256-vemCWJRzoGCuFF40BumlMz/lOMlyKbqEH1p/kr4AT4E=";
    };

    propagatedBuildInputs = with python3.pkgs; [
      anyio
      cryptography
      httpx2
      jsonschema
      mcpTypes
      opentelemetry-api
      pydantic
      pyjwt
      python-multipart
      sse-starlette
      starlette
      typing-extensions
      typing-inspection
      uvicorn
    ];

    meta = {
      license = lib.licenses.mit;
    };
  };

  pythonEnv = python3.withPackages (_: [ mcpSdk ]);
in

stdenv.mkDerivation {
  pname = "work-mcp";
  version = "1.0.0";

  src = ./.;
  dontBuild = true;
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ pythonEnv ];

  installPhase = ''
    runHook preInstall
    install -Dm0755 mcp_server.py $out/bin/work-mcp
    wrapProgram $out/bin/work-mcp \
      --prefix PATH : ${lib.makeBinPath [ pythonEnv ]}
    runHook postInstall
  '';

  meta = {
    description = "Local FastMCP server exposing per-customer Markdown spaces (roberto-style .mcp folders) under a configurable workRoot";
    longDescription = ''
      Filesystem-backed, multi-customer replacement of the SilverBullet MCP
      sidecar. Serves list/read/meta/write/delete page tools plus
      list_customers over Streamable HTTP on loopback. With customer
      discovery enabled (default) the agent resolves the customer from its
      working directory (<workRoot>/<customer>/) or by asking the user,
      and every write goes to <customer>/.mcp/ with ETag-guarded concurrency
      semantics copied from the SilverBullet sidecar. With discovery disabled
      a single shared space at <workRoot>/.mcp/ is used instead.
    '';
    license = lib.licenses.mit;
    mainProgram = "work-mcp";
    platforms = lib.platforms.unix;
  };
}
