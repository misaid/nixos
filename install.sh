#!/usr/bin/env bash
# Fresh-machine installer for this flake. Run on the target machine:
#   sudo curl -o /tmp/install.sh https://raw.githubusercontent.com/misaid/nixos/systemd-boot/install.sh
#   sudo bash /tmp/install.sh <hostname>
# <hostname> must match a hosts/<hostname>/ directory (today: vmware, nixos).
# NOTE: the branch in the URL above must match the branch this file is on.
set -euo pipefail

HOST="${1:?usage: install.sh <hostname>  (e.g. install.sh vmware)}"
REPO="https://github.com/misaid/nixos"
BRANCH="systemd-boot"
DEST="/etc/nixos"

if [ "$EUID" -ne 0 ]; then exec sudo bash "$0" "$@"; fi

# 0. UEFI required (the shared base uses systemd-boot).
if [ ! -d /sys/firmware/efi ]; then
  echo "ERROR: booted in BIOS mode. Enable UEFI firmware and reboot." >&2
  exit 1
fi

# 1. Back up the stock config (holds the generated hardware-configuration.nix).
if [ -d "$DEST" ] && [ ! -e "$DEST/.git" ]; then
  mv "$DEST" /etc/nixos.bak
  echo "Backed up stock config to /etc/nixos.bak"
fi

# 2. Clone. git comes via nix-shell until the first rebuild installs it.
if [ ! -e "$DEST/.git" ]; then
  nix-shell -p git --run "git clone -b $BRANCH $REPO $DEST"
fi
cd "$DEST"

# 3. Validate the hostname against real host directories.
AVAILABLE=$(find hosts -maxdepth 2 -name configuration.nix -printf '%h\n' | sed 's|^hosts/||' | tr '\n' ' ')
if [ ! -f "hosts/$HOST/configuration.nix" ]; then
  echo "ERROR: unknown host '$HOST'. Available: $AVAILABLE" >&2
  exit 1
fi

# 4. Generate this machine's hardware config (gitignored: UUIDs differ per install).
nixos-generate-config --show-hardware-config > "hosts/$HOST/hardware-configuration.nix"

# 5. Sanity check: the ESP must be mounted at /boot.
if ! grep -q 'fileSystems."/boot"' "hosts/$HOST/hardware-configuration.nix"; then
  echo "ERROR: no /boot ESP in hardware config — reinstall with UEFI enabled." >&2
  exit 1
fi

# 6. Stage it so the flake can see it. Flakes only evaluate git-tracked
#    files — but NEVER commit this file (it would publish your disk UUIDs).
nix-shell -p git --run "git -C $DEST add -f hosts/$HOST/hardware-configuration.nix"

# 7. Build and switch (still wrapped: git lands on the system only now).
nix-shell -p git --run "nixos-rebuild switch --flake $DEST#$HOST"

# 8. Login password (user a has none until now).
passwd a

echo "Done. Reboot, pick the newest generation, remove /etc/nixos.bak when happy."
