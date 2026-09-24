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
  ];

  # The only vmware-specific bit: everything else lives in ../common.
  virtualisation.vmware.guest.enable = true;

  home-manager = {
    extraSpecialArgs = { inherit inputs username; };
    useGlobalPkgs = true;
    useUserPackages = true;

    users = {
      "${username}" = import ./home.nix;
    };
  };

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
