{
  description = "Multi-host NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = {

        nixos = nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = { inherit inputs system; };

          modules = [
            ./hosts/nixos/configuration.nix
            inputs.home-manager.nixosModules.default
          ];
        };

        work = nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = { inherit inputs system; };

          modules = [
            ./hosts/work/configuration.nix
            inputs.home-manager.nixosModules.default
          ];
        };

      };
    };
}
