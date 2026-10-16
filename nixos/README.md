# NixOS para `exarch` — réplica de Fedora 44 (KDE) + Hyprland + LiDM

Config declarativa que reproduce tu Fedora 44 en **NixOS 26.05 "Yarara"**
(la última release estable, 30-may-2026), con **LiDM** como display manager
en vez del `plasmalogin` que usabas.

## Qué hay aquí

| Archivo | Contenido |
|---|---|
| `flake.nix` | Entradas: `nixpkgs/nixos-26.05`, `home-manager/release-26.05`, `lidm`, `noctalia-shell` |
| `configuration.nix` | Base: red, audio, usuarios, impresión, servicios, locale/teclado |
| `modules/hardware.nix` | btrfs/ext4/ESP, systemd-boot, NVIDIA + PRIME Optimus, zram, microcode AMD |
| `modules/desktop.nix` | Hyprland + uwsm, **LiDM**, fuentes (incl. **CaskaydiaCove Nerd Font**), IBus, portales |
| `modules/packages.nix` | Todos los paquetes que tenías (CLI, apps KDE, podman, dev…) |
| `modules/home.nix` | Home Manager enlazando los dotfiles de este repo |

## Resumen del análisis (Fedora → NixOS)

- **Base**: Fedora 44 "KDE Plasma Desktop Edition", host `exarch`, usuario `skyrdow`.
- **Sesión real**: Hyprland (Wayland) vía **uwsm**, barra **Noctalia**, con config
  en **Lua** (`hyprland.lua`, `keybinds.lua`, `animations.lua`, `hyprmon.lua`,
  `noctalia.lua`, `windowrules.lua`) — se reutiliza tal cual.
- **DM**: era `plasmalogin`; ahora **LiDM 2.0.2** (TUI en tty7). Ya tenías
  `lidm 2.0.0` instalado desde el copr `celestelove/lidm`.
- **HW**: Ryzen 5 5600H + Radeon Vega (iGPU) + **RTX 3060 Mobile** (Optimus mux-less),
  ~13 GiB RAM, NVMe WD SN730 1T, panel eDP 165 Hz + HDMI 165 Hz.
- **FS**: btrfs `root`/`home` (`compress=zstd:1`), ext4 `/boot`, vfat ESP, **sin LUKS**.
- **Audio** PipeWire/WirePlumber · **Red** NetworkManager (+ VPNs) · **Firewall** activo.
- **No replicable**: SELinux (no existe en NixOS) y los cobros de copr/rpmfusion
  (ahora son inputs del flake y `allowUnfree`). Secure Boot ya estaba deshabilitado.

## Instalación

```sh
# 1) Arranca el ISO de NixOS 26.05 y particiona.
#    Si reutilizas tus subvols btrfs actuales, los UUID del hardware.nix valen.
#    Si no, genera el hardware automatizado:
nixos-generate-config --root /mnt      # y copia el fileSystems que salga

# 2) Clona tus dotfiles y copia la config:
git clone https://github.com/Skyrdow/Skyrdow ~/Skyrdow
#    (si vas a instalar desde el ISO, clona a /mnt/home/skyrdow/Skyrdow)

# 3) ⚠️ Falta un archivo en el repo: copia tu starship.toml
cp ~/.config/starship.toml ~/Skyrdow/starship.toml

# 4) Instala:
sudo nixos-install --flake ~/Skyrdow/nixos#exarch
```

Después, para reconstruir:

```sh
sudo nixos-rebuild switch --flake ~/Skyrdow/nixos#exarch
nix flake update           # actualizar nixpkgs/HM/lidm/noctalia
```

## Notas / cosas a revisar

- **LiDM**: se usa el módulo oficial del repo (`assets/pkg/nix/module.nix`) más
  `services.displayManager.enable = true` y `systemd.services.lidm.enable = true`.
  El arranque de sesión por defecto queda comentado; pon
  `services.displayManager.defaultSession = "hyprland-uwsm";`.
- **Noctalia**: si `pkgs.noctalia-shell` ya existe en 26.05 puedes borrar el input
  y cambiar `noctaliaPkg` (ver comentario en `packages.nix`). El alias `noctalia`
  existe porque tu `hyprland.lua` ejecuta `noctalia`.
- **NVIDIA**: `prime.offload` (sesión en iGPU, RTX bajo demanda). Como tu HDMI
  suele ir cableado a la RTX, si no detecta el monitor externo prueba
  `prime.sync`/`reverseSync` (comentado en `hardware.nix`).
- **Kernel**: `linuxPackages_latest` para acercarte a tu 7.2 de Fedora; si el
  driver NVIDIA falla, quita esa línea.
- **zram**: 8G como tu `zram-generator`.
- **fprintd** (lector de huellas) queda comentado por si lo quieres.
- **KDE PIM** (kmail/kontact/korganizer) queda comentado por peso.
- `toolbox` no existe en nixpkgs → se puso `distrobox` como equivalente.

## Fuentes (versiones verificadas)

- NixOS 26.05 "Yarara" — <https://nixos.org/blog/announcements/2026/nixos-2605/>
- LiDM v2.0.2 — <https://github.com/javalsai/lidm/releases>
- Noctalia Shell — <https://github.com/noctalia-dev/noctalia-shell>
