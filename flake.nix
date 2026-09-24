{
  description = "Multi-host NixOS flake with nvf";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
  let
    system = "x86_64-linux";

    commonModules = [
      inputs.home-manager.nixosModules.default
      inputs.nvf.nixosModules.default
    ];
  in
  {
    formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;

    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = { inherit inputs system; };

        modules = commonModules ++ [
          ./hosts/nixos/configuration.nix
        ];
      };

      work = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = { inherit inputs system; };

        modules = commonModules ++ [
          ./hosts/work/configuration.nix
        ];
      };
    };
  };
}
