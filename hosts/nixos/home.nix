{ config, pkgs, ... }:

{
  home.username = "a";
  home.homeDirectory = "/home/a";

  home.stateVersion = "26.05";


  # --------------------------------------------------
  # Packages (user-only tools)
  # Neovim itself comes from nvf (system-wide); these are its CLI helpers.
  # --------------------------------------------------
  home.packages = with pkgs; [
    cbonsai # used by the snacks dashboard terminal section
    git
    ripgrep
    fd
    gcc
    nodejs
    lazygit
    zathura # vimtex viewer (vimtex_view_method in nvf-configuration.nix)
    # For LaTeX compilation also add a texlive set, e.g.
    # (texlive.combine { inherit (texlive) scheme-medium latexmk; })
  ];

  # --------------------------------------------------
  # Let Home Manager manage itself
  # --------------------------------------------------
  programs.home-manager.enable = true;
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
