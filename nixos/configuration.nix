# ===========================================================================
# Configuración base del sistema — exarch
# Fedora 44 → NixOS 26.05 "Yarara"
#
# Mapeo de lo que había en Fedora:
#   - SELinux ............. NO existe en NixOS (el sistema es declarativo;
#                           Fedora lo traía enforcing con policy targeted)
#   - Secure Boot ......... deshabilitado en la máquina, así que no hace
#                           falta systemd-boot con firmas o shim
#   - firewalld ........... → networking.firewall (iptables/nftables nativo)
#   - tuned / tuned-ppd ... → services.power-profiles-daemon
#   - chronyd ............. → systemd-timesyncd (por defecto)
#   - dnf coprs/rpmfusion . → allowUnfree + flake inputs (nvidia, etc.)
# ===========================================================================

{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;   # necesario: nvidia, etc.

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    # warn-dirty = false;
  };

  # Identidad (hostname Fedora: "exarch", usuario: skyrdow / Lucas Mesias)
  networking.hostName = "exarch";
  time.timeZone = "America/Santiago";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us-altgr-intl";    # igual que tu "VC Keymap" actual

  # --- Red -----------------------------------------------------------------
  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [             # los VPN que traía Fedora instalados
      networkmanager-openvpn
      networkmanager-openconnect
      networkmanager-l2tp
      networkmanager-vpnc
      networkmanager-pptp
    ];
  };

  hardware.bluetooth.enable = true;
  networking.modemmanager.enable = true; # ModemManager + wwan (lo tenías activo)
  networking.firewall.enable = true;
  # programs.kdeconnect.enable = true;     # abre el firewall para KDE Connect

  # --- Servicios del sistema ----------------------------------------------
  services.openssh.enable = false;       # openssh-server estaba instalado pero
                                         # desactivado; pon true si lo usas
  services.resolved.enable = true;       # systemd-resolved (tu DNS actual)
  services.flatpak.enable = true;        # + flathub remoto Fedora → luego: flatpak remote-add
  services.fwupd.enable = true;          # fwupd (firmware UEFI)
  services.locate = { enable = true; package = pkgs.plocate; };  # plocate
  services.smartd.enable = true;         # smartmontools
  services.power-profiles-daemon.enable = true;  # reemplazo de tuned-ppd
  services.upower.enable = true;
  services.avahi = {                     # descubrimiento mDNS + impresión
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  systemd.oomd.enable = true;            # systemd-oomd estaba habilitado

  # Impresión (cups + hplip, como en Fedora)
  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip ];
  };

  # --- Audio: PipeWire (igual que tu setup actual) ------------------------
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;                 # pipewire-pulseaudio
    jack.enable = true;                  # pipewire-jack
    wireplumber.enable = true;
  };
  security.rtkit.enable = true;

  # --- Escritorio/graphical-session (detalles en modules/desktop.nix) -----
  xdg.portal.enable = true;
  security.polkit.enable = true;

  # --- Usuarios ------------------------------------------------------------
  users.users.skyrdow = {
    isNormalUser = true;
    description = "Lucas Mesias";
    shell = pkgs.fish;                   # en Fedora el default era bash, pero
                                         # usas fish a diario → ahora es el real
    extraGroups = [
      "wheel" "networkmanager" "audio" "video" "input"
      "lp" "scanner" "storage" "i2c"     # i2c para ddcutil
    ];
  };
  programs.fish.enable = true;
  programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # --- Fingerprint (fprintd estaba instalado) -----------------------------
  # Actívalo si quieres usar la lectora de huellas:
  # services.fprintd.enable = true;

  system.stateVersion = "26.05";
}
