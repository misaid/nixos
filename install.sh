#!/usr/bin/env bash
# Fresh-machine installer for this flake. Run on the target machine:
#   sudo curl -o /tmp/install.sh https://raw.githubusercontent.com/misaid/nixos/systemd-boot/install.sh
#   sudo bash /tmp/install.sh <hostname> [username]
# <hostname> must match a hosts/<hostname>/ directory (today: vmware, nixos);
# [username] must match its hosts-table username (default: nixmo).
#
# Already set up and just want the dotfiles re-synced (no rebuild)?
#   bash /tmp/install.sh --sync-only [username]   (no sudo needed)
# NOTE: the branch in the URL above must match the branch this file is on.
set -euo pipefail

REPO="https://github.com/misaid/nixos"
BRANCH="systemd-boot"
DEST="/etc/nixos"
DOTFILES_REPO="https://github.com/misaid/dotfiles"
# Everything except nvim, zsh, avante.nvim and spicetify (owned by the flake).
STOW_PKGS="alacritty btop caelestia cava fastfetch ghostty hypr hyprpanel jrnl kitty lazygit mpv neofetch qBittorrent tmux vlc wallpapers zathura zed"

# --sync-only / --dotfiles-only: skip the NixOS install, just (re)stow dotfiles.
SYNC_ONLY=0
ARGS=()
for a in "$@"; do
  case "$a" in
    --sync-only|--dotfiles-only) SYNC_ONLY=1 ;;
    *) ARGS+=("$a") ;;
  esac
done
if [ "${#ARGS[@]}" -gt 0 ]; then set -- "${ARGS[@]}"; else set --; fi

# Run a command as $1 (the login user). No-op wrapper when already unprivileged.
as_user() {
  local user="$1"; shift
  if [ "$EUID" -ne 0 ]; then "$@"; else sudo -u "$user" "$@"; fi
}

# Shared dotfiles sync: clone-or-pull, then restow. Safe to re-run any time.
sync_dotfiles() {
  local user="$1" user_home="$2"
  if [ ! -d "$user_home/dotfiles/.git" ]; then
    as_user "$user" git clone "$DOTFILES_REPO" "$user_home/dotfiles"
  else
    as_user "$user" git -C "$user_home/dotfiles" pull --ff-only
  fi
  as_user "$user" mkdir -p "$user_home/.config"
  # shellcheck disable=SC2086
  as_user "$user" sh -c "stow -R -d '$user_home/dotfiles' -t '$user_home' $STOW_PKGS"
}

# Sync-only mode: no root, no hostname, no rebuild — dotfiles only.
if [ "$SYNC_ONLY" = 1 ]; then
  USERNAME="${1:-${SUDO_USER:-${USER:-nixmo}}}"
  if [ "$EUID" -ne 0 ]; then
    sync_dotfiles "$USERNAME" "$HOME"
  else
    sync_dotfiles "$USERNAME" "/home/$USERNAME"
  fi
  echo "Dotfiles synced for $USERNAME."
  exit 0
fi

HOST="${1:?usage: install.sh <hostname> [username] [--sync-only]  (e.g. install.sh vmware)}"
# Must match the username in the flake's hosts table for this host.
USERNAME="${2:-nixmo}"

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

# 8. Dotfiles (stow, as the user — never as root). The flake owns nvim, zsh,
#    avante.nvim and spicetify, so those stay unstowed; everything else in
#    the repo is fair game. Binaries backing these configs live in
#    home.packages.
sync_dotfiles "$USERNAME" "/home/$USERNAME"

# 9. Login password — only if the user has none yet. A password set in the
#    graphical installer survives the rebuild (mutableUsers keeps /etc/shadow),
#    so this is a no-op on the normal path.
if passwd --status "$USERNAME" 2>/dev/null | grep -q " P "; then
  echo "User $USERNAME already has a password — keeping it."
else
  passwd "$USERNAME"
fi

echo "Done. Reboot, pick the newest generation, remove /etc/nixos.bak when happy."
