{ config, pkgs, username, ... }:

{
  imports = [ ../common/spicetify.nix ../common/caelestia.nix ];

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
    fastfetch
    # caelestia-shell comes from its flake (see ../common/caelestia.nix).
    # hyprpanel: config is stowed, but nixpkgs carries no binary for it.
  ];

  # --------------------------------------------------
  # Hyprland env override (vmware VM only). The stowed environment.lua
  # hardcodes the NVIDIA backend (GBM_BACKEND=nvidia-drm etc.) for the
  # physical box, which crashes Hyprland on the VM's virtual GPU. This
  # replaces just that file (force swaps the stow symlink) with the same
  # generic vars minus NVIDIA, plus AQ_DRM_DISABLE_ATOMIC=1 — atomic
  # modesetting hangs/dies on vmwgfx (log stops at "slot N crtc N
  # unassigned" with no error). Monitors are untouched.
  # --------------------------------------------------
  xdg.configFile."hypr/environment.lua" = {
    force = true;
    text = ''
      local environment = {
        QT_QPA_PLATFORMTHEME = "qt6ct",
        XDG_CURRENT_DESKTOP = "Hyprland",
        XCURSOR_SIZE = "24",
        HYPRCURSOR_SIZE = "24",
        XDG_SESSION_TYPE = "wayland",
        ELECTRON_OZONE_PLATFORM_HINT = "wayland",
        ELECTRON_DISABLE_GPU = "true",
        ELECTRON_ENABLE_OZONE = "true",
        AQ_DRM_DISABLE_ATOMIC = "1",
      }

      for name, value in pairs(environment) do
        hl.env(name, value)
      end
    '';
  };

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
