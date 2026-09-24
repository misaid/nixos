# Shared base for all hosts. Machine-specific bits (hardware, desktop
# extras, extra packages) stay in hosts/<name>/configuration.nix.
# Hostname and username come from the flake's hosts table via specialArgs.
{ config, pkgs, hostname, username, ... }:

{
  imports = [
    ./nvf-configuration.nix
    ./zsh.nix
  ];

  networking.hostName = hostname;

  # Bootloader (UEFI systemd-boot). All hosts are UEFI installs.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Edmonton";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Login manager: SilentSDDM (custom video background) + GNOME.
  # SDDM is only the session picker — GNOME handles screen locking.
  # Upstream removed the "lana" preset, so we use "rei" (identical layout,
  # lavender accents) with your custom video/placeholder injected.
  # Videos live in ./assets (vendored from your Arch setup) and are
  # injected via backgrounds + settings so filenames always line up.
  programs.silentSDDM =
    let
      lanaVideo = pkgs.runCommand "lana.mp4" { } ''
        cp ${./assets/lana.mp4} $out
      '';
      lanaPlaceholder = pkgs.runCommand "lana.png" { } ''
        cp ${./assets/lana.png} $out
      '';
    in
    {
      enable = true;
      theme = "rei";
      backgrounds = {
        inherit lanaVideo lanaPlaceholder;
      };
      settings = {
        General = {
          animated-background-placeholder = lanaPlaceholder.name;
        };
        # SDDM lock screen off — use GNOME locker instead.
        LockScreen = {
          display = false;
        };
        LoginScreen = {
          background = lanaVideo.name;
        };
      };
    };
  services.desktopManager.gnome.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable Flatpak
  services.flatpak.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };

  hardware.graphics.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    stow
    vim
    wget
    kitty
    sl
    gnome-tweaks
    uwsm
    zsh-powerlevel10k
    meslo-lgs-nf
    tmuxPlugins.vim-tmux-navigator
    tmuxPlugins.resurrect
    tmuxPlugins.continuum
    foot
    gcc
    fzf
    python3
    pipenv
    tmux
    zoxide
    tree-sitter
  ];

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    description = "a";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      vim
      firefox
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
