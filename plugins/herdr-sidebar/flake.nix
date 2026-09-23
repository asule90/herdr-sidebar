{
  description = "VS Code-style sidebar for herdr: file explorer + source control in one pane";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = "herdr-sidebar";
          version = "0.13.0";

          src = ./.;

          cargoLock = {
            lockFile = ./Cargo.lock;
          };

          nativeBuildInputs = with pkgs; [
            pkg-config
          ];

          nativeCheckInputs = with pkgs; [
            git
          ];

          preCheck = ''
            # Tests such as picker_starts_on_current_branch expect to run inside a git repo
            export HOME=$(mktemp -d)
            git init -b main
            git config user.email "test@example.com"
            git config user.name "test"
            git commit --allow-empty -m "initial commit"
          '';

          buildInputs = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin (
            with pkgs.darwin.apple_sdk.frameworks; [
              Security
              SystemConfiguration
            ]
          );
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            rustc
            cargo
            clippy
            rustfmt
            rust-analyzer
            pkg-config
            git
          ] ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin (
            with pkgs.darwin.apple_sdk.frameworks; [
              Security
              SystemConfiguration
            ]
          );

          shellHook = ''
            echo "herdr-sidebar development environment loaded"
            echo "rustc: $(rustc --version)"
            echo "cargo: $(cargo --version)"
          '';
        };
      });
}
