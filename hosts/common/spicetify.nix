# Spicetify via spicetify-nix, shared by all hosts. Theme matches the
# tokyonight desktop. Do NOT install pkgs.spotify anywhere — this module
# builds and installs its own wrapped copy.
# NOTE: marketplace browsing works, but installing from it does not work
# with this flake — declare extensions/themes here instead.
{ config, pkgs, inputs, ... }:

{
  imports = [ inputs.spicetify-nix.homeManagerModules.spicetify ];

  programs.spicetify =
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};
    in
    {
      enable = true;
      theme = spicePkgs.themes.tokyonight;
      enabledExtensions = with spicePkgs.extensions; [
        shuffle
        hidePodcasts
        beautifulLyrics
      ];
    };
}
