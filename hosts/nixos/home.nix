{ config, pkgs, ... }:

{
  home.username = "a";
  home.homeDirectory = "/home/a";

  home.stateVersion = "26.05";


  # --------------------------------------------------
  # Packages (user-only tools)
  # --------------------------------------------------
  home.packages = with pkgs; [
    cbonsai
      neovim
  git
  ripgrep
  fd
  gcc
  nodejs
  lazygit
  ];

home.file.".config/nvim" = {
  source = ./modules/nvim;
  recursive = true;
};
  # --------------------------------------------------
  # Let Home Manager manage itself
  # --------------------------------------------------
  programs.home-manager.enable = true;

  # --------------------------------------------------
  # Neovim (fully reproducible Tree-sitter)
  # --------------------------------------------------
  # programs.neovim = {
  #   enable = true;
  #   plugins = [
  #     pkgs.vimPlugins.nvim-treesitter
  #   ];
  # };

 # home.file.".config/nvim/init.lua".text = ''
 #    require("config.lazy")
 #  '';
  # --------------------------------------------------
  # Zsh (clean + Nix-safe Powerlevel10k)
  # --------------------------------------------------

  # --------------------------------------------------
  # Environment variables (optional)
  # --------------------------------------------------
  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
