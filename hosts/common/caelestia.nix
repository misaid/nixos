# Caelestia shell via its flake (not nixpkgs — the nixpkgs attr is too new
# for pinned lockfiles to see). Provides the binary, CLI and a user
# systemd unit. Your stowed caelestia/ config still supplies the dotfiles.
{ inputs, ... }:

{
  imports = [ inputs.caelestia-shell.homeManagerModules.default ];

  programs.caelestia = {
    enable = true;
    systemd.enable = true;
    cli.enable = true;
  };
}
