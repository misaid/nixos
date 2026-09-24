{ config, pkgs, username, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";

  home.stateVersion = "25.11";


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
    zathura # vimtex viewer (vimtex_view_method in ../common/nvf-configuration.nix)
    # For LaTeX compilation also add a texlive set, e.g.
    # (texlive.combine { inherit (texlive) scheme-medium latexmk; })

    # Binaries backing the stowed dotfiles (github.com/misaid/dotfiles).
    # nvim/zsh/avante come from the flake itself, not here.
    alacritty
    ghostty
    btop
    cava
    mpv
    vlc
    zed-editor
    jrnl
    qbittorrent
    neofetch
    caelestia-shell
    # hyprpanel: config is stowed, but nixpkgs carries no binary for it.
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
