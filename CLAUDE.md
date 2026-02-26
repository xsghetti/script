# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

**Hyprcrux** is an Arch Linux post-install automation script targeting Hyprland + Nvidia setups. It installs packages, applies dotfiles, configures the bootloader, and sets up a login manager — all via a single entry point.

> Target: Arch Linux + Hyprland + Nvidia (nvidia-dkms / nvidia-utils, post-555 drivers)

## Entry Point & Script Flow

```
install.sh
├── Configures mkinitcpio + Nvidia kernel modules
├── Installs yay AUR helper (from yay-bin/)
├── Installs all packages via yay (src/yay.txt)
├── clone.sh        → clones xsghetti/hyprcrux dotfiles repo and deploys configs
├── zsh.sh          → installs zsh, oh-my-zsh, powerlevel10k, plugins; sets default shell
├── grub.sh         → deploys cyberpunk_arcade GRUB theme + regenerates grub.cfg
└── greetd.sh       → deploys src/config.toml to /etc/greetd/
```

**Run order matters** — scripts must be executed from `~/script/` because paths are hardcoded relative to `~`.

## Key Files & Directories

| Path | Purpose |
|---|---|
| `src/yay.txt` | Full package list installed via `yay -S --needed` |
| `src/mkinitcpio.conf` | Kernel initramfs config (Nvidia modules) |
| `src/nvidia.conf` | `/etc/modprobe.d/nvidia.conf` — Nvidia module options |
| `src/config.toml` | greetd config — auto-starts Hyprland as user `teez` via `start-hyprland` |
| `src/grub` | GRUB defaults file copied to `/etc/default/grub` |
| `src/cyberpunk_arcade/` | Cyberpunk Arcade GRUB theme assets |
| `src/powerlevel10k/` | Powerlevel10k ZSH theme (bundled locally) |

## Hardcoded Assumptions

- **Username**: `teez` (hardcoded in `src/config.toml`)
- **Clone location**: scripts assume the repo is cloned to `~/script/`
- **Dotfiles repo**: `clone.sh` clones `https://github.com/xsghetti/hyprcrux` to `~/hyprcrux/`
- **Shell**: ZSH with oh-my-zsh, zsh-syntax-highlighting, zsh-autosuggestions

## Running the Install

```bash
git clone https://github.com/xsghetti/script
cd script && ./install.sh
```

Do **not** run as root — the script will reject it and exit.

## Modifying the Package List

Edit `src/yay.txt` — one package name per line, compatible with `yay -S --needed - < file`.

## greetd Configuration

`src/config.toml` launches Hyprland directly via `start-hyprland` without a graphical greeter (no login prompt). Both `[default_session]` and `[initial_session]` are configured to auto-start as user `teez`.
