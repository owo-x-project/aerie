{
  description = "Nix development environment for the Aerie Workspace Harness";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      # The harness requires its Truth layer, and Owlspec publishes no
      # Intel-macOS build, so x86_64-darwin cannot carry a complete harness and
      # is not offered. Re-add it here only once upstream ships that build.
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

      leanCtxRelease = "3.9.13";

      owlspecRelease = "0.2.0";

      # One entry per supported system. The lookup below throws rather than
      # falling back, so adding a system without its asset fails loudly.
      owlspecAssets = {
        x86_64-linux = {
          name = "owlspec-v${owlspecRelease}-x86_64-unknown-linux-gnu.tar.gz";
          hash = "sha256-s3RSljoT1pkbzaNnBYhKONTk29wHJpO9Xzr9Mwic3lo=";
        };
        aarch64-linux = {
          name = "owlspec-v${owlspecRelease}-aarch64-unknown-linux-gnu.tar.gz";
          hash = "sha256-IHJwdUkl/xxnO5bK06vHyXtyMEvLyFyzEqUO2gjTlfc=";
        };
        aarch64-darwin = {
          name = "owlspec-v${owlspecRelease}-aarch64-apple-darwin.tar.gz";
          hash = "sha256-MMJ6RIvfiuLRGqeJP0FwEz6mWtqiubbDk9E28iWZgdo=";
        };
      };

      leanCtxAssets = {
        x86_64-linux = {
          name = "lean-ctx-x86_64-unknown-linux-gnu.tar.gz";
          hash = "sha256-jbTS+ZgQzUEow11Az3P///h4P6W/JaGzNezHSV7KhLU=";
        };
        aarch64-linux = {
          name = "lean-ctx-aarch64-unknown-linux-gnu.tar.gz";
          hash = "sha256-RGcFdTrwgowtCPvl9YltwBlk+t+gR86MaF/5xpRZ87k=";
        };
        x86_64-darwin = {
          name = "lean-ctx-x86_64-apple-darwin.tar.gz";
          hash = "sha256-PPaigYUozTnV6S18ta7kC6p4PBZdhpCy35lWw7KRAcE=";
        };
        aarch64-darwin = {
          name = "lean-ctx-aarch64-apple-darwin.tar.gz";
          hash = "sha256-EsAgZIgKti8VmERiT6Nt+nVvmKdlG79ILiFreuDX21Y=";
        };
      };
    in
    {
      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfreePredicate = package:
              builtins.elem (nixpkgs.lib.getName package) [ "claude-code" ];
          };

          apm = pkgs.python3Packages.buildPythonApplication {
            pname = "apm-cli";
            version = "0.26.0";
            format = "wheel";

            src = pkgs.fetchurl {
              url = "https://files.pythonhosted.org/packages/c5/0f/3933d628daa030902147503fcae88333c39f6c5ac9f42950bb226a4162d2/apm_cli-0.26.0-py3-none-any.whl";
              hash = "sha256-dikMQqn5QS466OqY0grL379L7m3DLpUfYW/qubyC560=";
            };

            dependencies = with pkgs.python3Packages; [
              click
              colorama
              pyyaml
              requests
              truststore
              python-frontmatter
              llm
              tomli
              toml
              tomlkit
              rich
              rich-click
              watchdog
              gitpython
              ruamel-yaml
              filelock
              websockets
            ];

            # The optional GitHub Models provider is not needed by the harness
            # and is not available in the pinned Nixpkgs set.
            dontCheckRuntimeDeps = true;
            doCheck = false;
          };

          lean-ctx = let
            asset = leanCtxAssets.${system};
          in
            pkgs.stdenvNoCC.mkDerivation {
              pname = "lean-ctx";
              version = leanCtxRelease;

              src = pkgs.fetchurl {
                url = "https://github.com/yvgude/lean-ctx/releases/download/v${leanCtxRelease}/${asset.name}";
                inherit (asset) hash;
              };

              nativeBuildInputs = pkgs.lib.optionals pkgs.stdenv.isLinux [
                pkgs.autoPatchelfHook
              ];
              buildInputs = pkgs.lib.optionals pkgs.stdenv.isLinux [
                pkgs.glibc
                pkgs.stdenv.cc.cc.lib
              ];

              dontUnpack = true;
              installPhase = ''
                mkdir -p "$TMPDIR/lean-ctx-source"
                tar -xzf "$src" -C "$TMPDIR/lean-ctx-source"
                install -d "$out/bin"
                install -m 0755 "$(find "$TMPDIR/lean-ctx-source" -type f -name lean-ctx -print -quit)" "$out/bin/lean-ctx"
              '';
            };

          owlspec = let
            asset = owlspecAssets.${system} or (throw ''
              owlspec publishes no release build for ${system}.
              Upstream ships x86_64-linux, aarch64-linux and aarch64-darwin only,
              and the harness requires its Truth layer, so this system is unsupported.
            '');
          in
            pkgs.stdenvNoCC.mkDerivation {
              pname = "owlspec";
              version = owlspecRelease;

              src = pkgs.fetchurl {
                url = "https://github.com/owo-x-project/owlspec/releases/download/v${owlspecRelease}/${asset.name}";
                inherit (asset) hash;
              };

              nativeBuildInputs = pkgs.lib.optionals pkgs.stdenv.isLinux [
                pkgs.autoPatchelfHook
              ];
              buildInputs = pkgs.lib.optionals pkgs.stdenv.isLinux [
                pkgs.glibc
                pkgs.stdenv.cc.cc.lib
              ];

              dontUnpack = true;
              installPhase = ''
                mkdir -p "$TMPDIR/owlspec-source"
                tar -xzf "$src" -C "$TMPDIR/owlspec-source"
                install -d "$out/bin"
                install -m 0755 "$(find "$TMPDIR/owlspec-source" -type f -name owlspec -print -quit)" "$out/bin/owlspec"
              '';
            };

          harnessPackages = [
            pkgs.git
            pkgs.jq
            apm
            owlspec
            lean-ctx
            pkgs.beads
            pkgs.vcs2l
            pkgs.codex
            pkgs.claude-code
          ];
        in
        {
          default = pkgs.mkShell {
            packages = harnessPackages;

            shellHook = ''
              export WORKSPACE_HARNESS_ACTIVE=1
              export LEAN_CTX_HEADLESS=1
              export LEAN_CTX_RULES_INJECTION=dedicated
              export LEAN_CTX_DATA_DIR="''${LEAN_CTX_DATA_DIR:-$PWD/.state/lean-ctx}"

              missing_tools=""
              non_store_tools=""
              for tool in apm owlspec lean-ctx bd vcs codex claude; do
                resolved="$(command -v "$tool" 2>/dev/null || true)"
                if [ -z "$resolved" ]; then
                  missing_tools="$missing_tools $tool"
                elif [ "''${resolved#/nix/store/}" = "$resolved" ]; then
                  non_store_tools="$non_store_tools $tool=$resolved"
                fi
              done

              if [ -n "$missing_tools" ] || [ -n "$non_store_tools" ]; then
                echo "Workspace Harness: refusing to start because a required tool is not provided by Nix." >&2
                if [ -n "$missing_tools" ]; then
                  echo "  missing:$missing_tools" >&2
                fi
                if [ -n "$non_store_tools" ]; then
                  echo "  outside /nix/store:$non_store_tools" >&2
                fi
                echo "  Add the tool to flake.nix; global PATH entries are intentionally unsupported." >&2
                unset missing_tools non_store_tools resolved
                exit 1
              fi
              unset missing_tools non_store_tools resolved
            '';
          };
        }
      );
    };
}
