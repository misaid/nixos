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

  # Login manager (stock SDDM) + GNOME. SDDM itself runs on X11: its Wayland
  # greeter gets an invisible/broken cursor on VMware SVGA (and is flaky on
  # NVIDIA too). An X11 greeter can still launch Wayland sessions fine.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = false;
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
    # REQUIRED: autostart.lua uses `uwsm app -- ...` everywhere, which only
    # works inside a uwsm-managed session. You must then pick
    # "Hyprland (uwsm-managed)" (hyprland-uwsm.desktop) in SDDM —
    # plain "Hyprland" runs without the uwsm scope and all autostart
    # entries + caelestia break. Do NOT also set
    # programs.uwsm.waylandCompositors — withUWSM already handles it.
    withUWSM = true;
    xwayland.enable = true;
  };
  # Portal for Hyprland is pulled in by the module above; gtk portal is
  # still needed for file pickers / flatpak.
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };
  security.polkit.enable = true;
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };

  hardware.graphics.enable = true;

  # Fonts (registered with fontconfig — systemPackages would not register).
  fonts.packages = with pkgs; [ meslo-lgs-nf ];

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
    # NOTE: no `uwsm` here — programs.hyprland.withUWSM above provides the
    # uwsm integration (PAM/systemd entries). A raw package install does not.
    # Runtime deps backing autostart.lua / bind.lua (nm-applet, hypridle,
    # wl-paste, cliphist, clipse, polkit agent). Without these the
    # compositor starts but the session looks dead.
    hypridle
    hyprlock
    hyprpolkitagent
    networkmanagerapplet
    wl-clipboard
    cliphist
    clipse
    zsh-powerlevel10k
    # NOTE: tmuxPlugins.* don't belong here — they're tmux plugin
    # derivations, inert as system packages. To manage them declaratively,
    # enable programs.tmux and list them under programs.tmux.plugins
    # (kept out for now: tmux config is stowed from dotfiles).
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
      # NOTE: no firefox here — programs.firefox above already installs it.
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
