# nixos host: physical machine (RTX 2070 + Ryzen 5 3600).
# Shared base lives in ../common.
{ config, pkgs, lib, inputs, username, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../common
  ];

  home-manager = {
    extraSpecialArgs = { inherit inputs username; };
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      "${username}" = import ./home.nix;
    };
  };

  # NVIDIA RTX 2070 (Turing): proprietary driver with modesetting for
  # Wayland/Hyprland. open = false is the battle-tested pick here;
  # Turing also supports the open modules (open = true) if you prefer.
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable32Bit = true; # Steam/Proton + 32-bit games
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false; # laptops only, must stay off on desktop
    open = false;
    nvidiaSettings = true;
  };
  # Preserve VRAM across suspend so resume doesn't lose the display.
  boot.kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ];

  # Extra Wayland env for NVIDIA (base Wayland vars live in ../common).
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  # Ryzen 5 3600 microcode updates.
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Frame-rate friendly gaming helper (run games with gamemoderun).
  programs.gamemode.enable = true;

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
