# vmware host: VMware VM. Shared base lives in ../common.
{
  config,
  pkgs,
  inputs,
  username,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../common
    ./modules/zsh.nix
  ];

  virtualisation.vmware.guest.enable = true;

  # Enable Flatpak
  services.flatpak.enable = true;

  home-manager = {
    extraSpecialArgs = { inherit inputs username; };
    useGlobalPkgs = true;
    useUserPackages = true;

    users = {
      "${username}" = import ./home.nix;
    };
  };

  # Enable Oh-my-zsh
  users.defaultUserShell = pkgs.zsh;
  environment.shells = [ pkgs.zsh ]; # https://wiki.nixos.org/wiki/Zsh#GDM_does_not_show_user_when_zsh_is_the_default_shell
  environment.loginShellInit = ''
    # equivalent to .profile
    # https://search.nixos.org/options?show=environment.loginShellInit
  '';

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

  # Neovim is provided declaratively by nvf (see ../common/nvf-configuration.nix).

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
}
