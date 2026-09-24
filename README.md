# nixos

Multi-host NixOS flake (Home Manager + nvf). Shared config lives in
`hosts/common/`; each machine gets `hosts/<name>/`.

## Install on a new machine (UEFI only — the shared base uses systemd-boot)

```bash
# 1. Install NixOS from the installer ISO, then back up the stock config
#    (it holds this machine's generated hardware-configuration.nix).
sudo mv /etc/nixos /etc/nixos.bak

# 2. Clone this repo (git isn't installed yet, so run it via nix-shell).
nix-shell -p git --run "sudo git clone -b systemd-boot https://github.com/misaid/nixos /etc/nixos"

# 3. Generate this machine's hardware config. It is gitignored on purpose:
#    disk UUIDs differ per install and a stale copy will not boot.
sudo nixos-generate-config --show-hardware-config \
  > /etc/nixos/hosts/<name>/hardware-configuration.nix
# (or: sudo cp /etc/nixos.bak/hardware-configuration.nix /etc/nixos/hosts/<name>/)

# 4. Sanity check: the file from step 3 must contain a fileSystems."/boot"
#    entry (vfat ESP). If not, the machine was installed BIOS/MBR — reinstall
#    with UEFI enabled, this config will not boot otherwise.

# 5. Build and switch. <name> matches a hosts/<name>/ directory.
sudo nixos-rebuild switch --flake /etc/nixos#<name>

# 6. Set the login password.
sudo passwd a
```

## Add a new machine

1. `mkdir hosts/<name>` with `configuration.nix`, `home.nix`, and a locally
   generated `hardware-configuration.nix` (see install step 3 — never copy
   one from another machine).
2. Add one line to the `hosts` table in `flake.nix`:
   `<name> = "x86_64-linux";` (or `"aarch64-linux"` for ARM).
3. The hostname is set automatically from the table key — don't set
   `networking.hostName` in the host config.
