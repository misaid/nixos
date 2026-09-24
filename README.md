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

One-shot (does every step below, with checks):

```bash
sudo curl -o /tmp/install.sh https://raw.githubusercontent.com/misaid/nixos/systemd-boot/install.sh
sudo bash /tmp/install.sh <name>   # vmware for the VM, nixos for the physical box
```

Manual equivalent:

```bash
# 1. Back up the stock config (it holds this machine's generated
#    hardware-configuration.nix).
sudo mv /etc/nixos /etc/nixos.bak

# 2. Clone this repo (git isn't installed yet, so run it via nix-shell).
nix-shell -p git --run "sudo git clone -b systemd-boot https://github.com/misaid/nixos /etc/nixos"

# 3. Generate this machine's hardware config. It is gitignored on purpose:
#    disk UUIDs differ per install and a stale copy will not boot.
#    NOTE: bare `sudo ... > /etc/...` fails (the redirect isn't privileged).
#    Run it under `sudo -i`, or pipe through sudo tee:
sudo nixos-generate-config --show-hardware-config \
  | sudo tee /etc/nixos/hosts/<name>/hardware-configuration.nix > /dev/null
# (or: sudo cp /etc/nixos.bak/hardware-configuration.nix /etc/nixos/hosts/<name>/)

# 4. Sanity check: the file from step 3 must contain a fileSystems."/boot"
#    entry (vfat ESP). If not, reinstall with UEFI enabled.

# 5. Stage the hardware config so the flake can see it. Flakes only evaluate
#    git-tracked files, so this force-add is REQUIRED — but never commit the
#    file (that would publish your disk UUIDs). Like clone, git itself comes
#    via nix-shell until the first rebuild installs it system-wide.
nix-shell -p git --run 'sudo env PATH="$PATH" git -C /etc/nixos add -f hosts/<name>/hardware-configuration.nix'

# 6. Build and switch. <name> matches a hosts/<name>/ directory
#    (today: vmware for the VMware VM, nixos for the physical box).
#    Still wrapped: this first build runs before git exists on the system.
nix-shell -p git --run "sudo nixos-rebuild switch --flake /etc/nixos#<name>"

# 7. Set the login password (the flake-table user has none until you do).
sudo passwd nixmo   # replace nixmo with your hosts-table username
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

## Web development (Node/npm)

- **Project deps just work:** `nodejs` (plus `gcc`/`python3` for `node-gyp`)
  is installed, so plain `npm install` inside a project dir behaves like
  any other distro — `node_modules` stays local and impure.
- **Never `npm install -g`** into the store. Need a global tool? Prefer the
  nix package; otherwise set `prefix=$HOME/.npm-global`.
- **Per-project Node versions:** add a `flake.nix` + `.envrc` in the project
  pinning e.g. `nodejs_22` and enter with `nix develop` (use `direnv` +
  `nix-direnv` to auto-enter). No nvm needed.
- **`pnpm`/`yarn`:** same pattern — binary via nix, deps in the workspace.
- **Downloaded binaries fail?** Prisma engines, Playwright browsers, etc.
  die with "No such file or directory" (unpatched interpreter). Fix:
  enable `programs.nix-ld` in `hosts/common`.
- **Packaging a JS app as a Nix package** is a separate job for
  `dream2nix`/`npmlock2nix` — not daily dev, don't conflate them.

## Dotfiles (stow sister repo)

`install.sh` step 8 clones `github.com/misaid/dotfiles` to `~/dotfiles`
and stows everything **except** `nvim`, `zsh` and `avante.nvim` — those
are owned by this flake (nvf / the omz module) and stowing them would
fight it. The binaries backing the stowed configs live in
`home.packages` on both hosts.

Notes:

- The flake enables Hyprland but ships no Hyprland config of its own —
  stowing `hypr/` fills that gap. Eyeball it on first launch: it was
  written for Arch, so absolute paths and monitor names may need edits
  (especially on the NVIDIA box).
- `hyprpanel/` is stowed but nixpkgs has no `hyprpanel` binary, so that
  config stays dormant until you source the program another way.
- `spicetify/` is stowed, but theming still needs the `spicetify-nix`
  flake input wired up (see the web-dev section's pointer).
- Re-stow after pulling dotfile updates:
  `cd ~/dotfiles && stow -t ~ <package>`.
  Never stow `nvim`, `zsh` or `avante.nvim`.

## Add a new machine

1. `mkdir hosts/<name>` with `configuration.nix`, `home.nix`, and a locally
   generated `hardware-configuration.nix` (see install step 3 — never copy
   one from another machine).
2. Add one entry to the `hosts` table in `flake.nix`:
   `<name> = { system = "x86_64-linux"; username = "<login-user>"; };`
   (or `"aarch64-linux"` for ARM). Use the SAME username you create in
   the graphical installer, or that installer user lingers unmanaged.
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
- **Login loop / no password:** run `sudo passwd <your-username>`.
- **Stray installer-made user:** if the username you created in the
  graphical installer differs from the flake table's `username`, the
  installer one lingers unmanaged (wrong shell, no Home Manager). Either
  match the table to it, or remove it with `sudo userdel -r <name>`.
- **Flake input errors after months away:** `nix flake update`, then rebuild.
- **`hardware-configuration.nix` invisible to the flake:** covered by
  install step 5 (`git add -f`, never commit). If a rebuild ever complains
  the file "is not tracked by Git", re-run that step.
