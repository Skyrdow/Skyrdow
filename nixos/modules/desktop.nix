# ===========================================================================
# Escritorio — Hyprland (Lua) + Noctalia + LiDM como display manager
#
# Tu sesión Fedora era: plasmalogin → hyprland-uwsm.desktop (Hyprland 0.55
# con config en Lua, autostart de noctalia y hyprpolkitagent).
# Aquí el DM es LiDM 2.0.2 (TUI en la tty7, como ya lo tenías instalado
# vía copr celestelove/lidm).
# ===========================================================================

{ config, pkgs, lidm, noctalia-shell, ... }:

{
  # --- Hyprland vía uwsm ---------------------------------------------------
  programs.hyprland = {
    enable = true;
    withUWSM = true;          # genera la sesión hyprland-uwsm (tu sesión actual)
    xwayland.enable = true;
    # El módulo ya activa xdg.portal y registra xdg-desktop-portal-hyprland
    # (+ la sesión para el display manager). No hay opción portal.enable.
  };
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];  # file pickers GTK/Firefox

  # --- LiDM (display manager) ----------------------------------------------
  # Usa el módulo NixOS oficial que viene con el repo (assets/pkg/nix/module.nix).
  imports = [ (lidm + "/assets/pkg/nix/module.nix") ];
  services.displayManager.enable = true;
  systemd.services.lidm.enable = true;       # arranca en la tty7, alias display-manager

  # Sesión por defecto al iniciar (opcional, elige una):
  services.displayManager.defaultSession = "hyprland-uwsm";
  # services.displayManager.defaultSession = "hyprland";

  # Opciones de LiDM (tema/config, igual que /etc/lidm/config en Fedora).
  # Ver `man lidm-config`; puede ser un tema embebido ("cherry") o un attrset:
  # services.lidm.config = {
  #   behavior.include_defshell = true;      # mostrar tu shell por defecto
  #   strings.f_poweroff = "⏻ apagar";
  #   functions.poweroff = "F1";
  # };

  # GNOME Keyring (lo usabas con KDE/kwallet; desbloqueo de llaves al login)
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.lidm.enableGnomeKeyring = true;

  # --- Teclado (XKB: us altgr-intl, igual que localectl) -------------------
  services.xserver.xkb = {
    layout = "us";
    variant = "altgr-intl";
    model = "pc105";
  };

  # --- Fuentes -------------------------------------------------------------
  # Incluye tu Nerd Font: CaskaydiaCove (Cascadia Code + iconos Nerd).
  # Nombres de familia: "CaskaydiaCove Nerd Font", "CaskaydiaCove Mono Nerd Font".
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.caskaydia-cove
      noto-fonts                     # Sans/Serif/Mono base (como en Fedora)
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      noto-fonts-extra
      liberation_ttf
      dejavu_fonts
      hack-font
      crosextra-carlito              # google-carlito-fonts
      crosextra-caladea              # google-caladea-fonts
      cantarell-fonts
      vazirmatn
    ];
    fontconfig.defaultFonts = {
      sansSerif = [ "Noto Sans" "Cantarell" ];
      serif = [ "Noto Serif" ];
      mono = [ "CaskaydiaCove Nerd Font Mono" "Noto Sans Mono" "Hack" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  # --- IBus (tenías anthy, libpinyin, hangul, typing-booster) --------------
  i18n.inputMethod = {
    enable = true;
    type = "ibus";
    ibus.engines = with pkgs.ibus-engines; [
      anthy
      libpinyin
      hangul
      typing-booster
    ];
  };

  # --- Entorno de sesión ---------------------------------------------------
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";        # apps Electron/Chromium nativas en Wayland (Zed!)
    MOZ_ENABLE_WAYLAND = "1";
    XCURSOR_THEME = "Breeze";
    XCURSOR_SIZE = "24";         # = hl.env de tu hyprland.lua
    HYPRCURSOR_SIZE = "24";
    # Si el HDMI (cableado a la RTX) no aparece, fuerza la iGPU como primaria:
    # AQ_DRM_DEVICES = "pci-0000_05_00_0,pci-0000_01_00_0";
  };
}
