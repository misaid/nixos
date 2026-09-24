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
    # Add a machine here: <host directory under ./hosts> = <system arch>.
    # The directory must contain configuration.nix (plus home.nix and a
    # locally generated hardware-configuration.nix, which is gitignored).
    hosts = {
      nixos = "x86_64-linux";
      work = "x86_64-linux";
    };

    systems = nixpkgs.lib.unique (builtins.attrValues hosts);

    commonModules = [
      inputs.home-manager.nixosModules.default
      inputs.nvf.nixosModules.default
    ];

    mkHost = hostname: system:
      nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = { inherit inputs system hostname; };

        modules = commonModules ++ [
          ./hosts/${hostname}/configuration.nix
        ];
      };
  in
  {
    formatter = nixpkgs.lib.genAttrs systems
      (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

    nixosConfigurations = nixpkgs.lib.mapAttrs mkHost hosts;
  };
}
