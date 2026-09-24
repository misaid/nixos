# nixos

Multi-host NixOS flake (Home Manager + nvf). Shared config lives in
`hosts/common/`; each machine gets `hosts/<name>/`.

> No installer ever asks you for a hostname here. The name you pass to
> `nixos-rebuild switch --flake /etc/nixos#<name>` selects the config,
> and the hostname is set automatically from that same `<name>`
> (flake `hosts` table → `networking.hostName`). Pick an existing
> `<name>` and you're done.

## Prerequisites

- NixOS installed from the installer ISO **in UEFI mode** with an EFI
  system partition mounted at `/boot` (the shared base uses
  systemd-boot; a BIOS/MBR install will not boot this config).
- Network access (first build downloads nixpkgs, Home Manager, nvf).
- 600MB+ ESP recommended — every generation stores a UKI/kernel there.

## Install on a new machine

```bash
# 1. Back up the stock config (it holds this machine's generated
#    hardware-configuration.nix).
sudo mv /etc/nixos /etc/nixos.bak

# 2. Clone this repo (git isn't installed yet, so run it via nix-shell).
nix-shell -p git --run "sudo git clone -b systemd-boot https://github.com/misaid/nixos /etc/nixos"

# 3. Generate this machine's hardware config. It is gitignored on purpose:
#    disk UUIDs differ per install and a stale copy will not boot.
sudo nixos-generate-config --show-hardware-config \
  > /etc/nixos/hosts/<name>/hardware-configuration.nix
# (or: sudo cp /etc/nixos.bak/hardware-configuration.nix /etc/nixos/hosts/<name>/)

# 4. Sanity check: the file from step 3 must contain a fileSystems."/boot"
#    entry (vfat ESP). If not, reinstall with UEFI enabled.

# 5. Build and switch. <name> matches a hosts/<name>/ directory
#    (today: nixos for the VMware VM, work for the physical box).
sudo nixos-rebuild switch --flake /etc/nixos#<name>

# 6. Set the login password (user a has none until you do).
sudo passwd a
```

## Everyday use (run from /etc/nixos)

```bash
# Rebuild after editing any .nix file:
sudo nixos-rebuild switch --flake .#<name>

# Dry-run first if you're unsure:
sudo nixos-rebuild dry-build --flake .#<name>

# Update all inputs (nixpkgs, home-manager, nvf) then rebuild:
nix flake update
sudo nixos-rebuild switch --flake .#<name>

# Format nix files:
nix fmt

# Roll back to the previous generation (also available in the boot menu):
sudo nixos-rebuild switch --rollback
```

## Add a new machine

1. `mkdir hosts/<name>` with `configuration.nix`, `home.nix`, and a locally
   generated `hardware-configuration.nix` (see install step 3 — never copy
   one from another machine).
2. Add one line to the `hosts` table in `flake.nix`:
   `<name> = "x86_64-linux";` (or `"aarch64-linux"` for ARM).
3. The hostname is set automatically from the table key — don't set
   `networking.hostName` in the host config.
4. `sudo nixos-rebuild switch --flake .#<name>`.

## Troubleshooting

- **"No space left on device" on /boot:** old generations pile up UKIs.
  `sudo nix-collect-garbage -d`, rebuild, and keep
  `boot.loader.systemd-boot.configurationLimit` small.
- **Boots to the wrong entry / won't boot:** you switched disk layouts
  without regenerating `hardware-configuration.nix` (step 3). The file
  must match the machine it's on.
- **Login loop / no password:** run `sudo passwd a`.
- **Flake input errors after months away:** `nix flake update`, then rebuild.
