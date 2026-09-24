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

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Pinned theme SOURCE (not a flake): stock SilentSDDM v1.3.4 QML.
    # Your custom lana.conf + lana.mp4/png are overlaid in
    # hosts/common/silent-lana.nix. flake=false so no hashes needed.
    silentSDDM = {
      url = "github:uiriansan/SilentSDDM/v1.3.4";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
  let
    # Add a machine here: <host directory> = { system arch, login user }.
    # The directory must contain configuration.nix (plus home.nix and a
    # locally generated hardware-configuration.nix, which is gitignored).
    # Use the SAME username you create in the graphical installer — otherwise
    # the installer-made user lingers as an unmanaged leftover next to it.
    hosts = {
      vmware = {
        system = "x86_64-linux";
        username = "nixmo";
      };
      nixos = {
        system = "x86_64-linux";
        username = "nixmo";
      };
    };

    systems = nixpkgs.lib.unique (map (h: h.system) (builtins.attrValues hosts));

    commonModules = [
      inputs.home-manager.nixosModules.default
      inputs.nvf.nixosModules.default
    ];

    mkHost = hostname: { system, username }:
      nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = { inherit inputs system hostname username; };

        modules = commonModules ++ [
          ./hosts/${hostname}/configuration.nix
        ];
      };
  in
  {
    formatter = nixpkgs.lib.genAttrs systems
      (system: nixpkgs.legacyPackages.${system}.nixfmt);

    nixosConfigurations = nixpkgs.lib.mapAttrs mkHost hosts;
  };
}
