{
  description = "A Nix-flake-based C# development environment";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            (with dotnetCorePackages; combinePackages [ sdk_6_0 sdk_7_0 sdk_8_0 ])
            (buildDotnetGlobalTool {
              pname = "Nuke.GlobalTool";
              version = "6.2.1"; # Update to the desired version
              nugetName = "Nuke.GlobalTool";
              nugetHash = "sha256-<hash>"; # Replace <hash> with the actual hash obtained after the first build
              meta = {
                description = "Nuke build automation tool for C# and .NET.";
                homepage = "https://nuke.build/";
                license = pkgs.lib.licenses.mit;
                platforms = pkgs.lib.platforms.all;
              };
            })
          ];

          shellHook = ''
            export DOTNET_ROOT=$(dirname $(realpath $(which dotnet)))
            export PATH="$HOME/.dotnet/tools:$PATH"
          '';
        };
      });
    };
}
