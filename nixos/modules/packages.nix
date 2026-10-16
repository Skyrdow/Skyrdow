# ===========================================================================
# Paquetes — equivalente a los RPM instalados en Fedora 44
# (solo lo que de verdad usas; todo el KDE base lo aporta Hyprland + deps)
# ===========================================================================

{ pkgs, noctalia-shell, ... }:

let
  # Tu hyprland.lua llama a "noctalia"; en Nix el binario se llama
  # "noctalia-shell". Este alias mantiene tu config sin tocar.
  #
  # Si nixpkgs 26.05 ya trae Noctalia, puedes simplificar:
  #   noctaliaPkg = pkgs.noctalia-shell;
  # y borrar el input `noctalia-shell` del flake.
  noctaliaPkg = noctalia-shell.packages.${pkgs.system}.default
    or noctalia-shell.packages.${pkgs.system}.noctalia-shell;
  noctalia = pkgs.runCommand "noctalia-alias" { } ''
    mkdir -p $out/bin
    ln -s ${noctaliaPkg}/bin/noctalia-shell $out/bin/noctalia
    ln -s ${noctaliaPkg}/bin/noctalia-shell $out/bin/noctalia-shell
  '';
in
{
  environment.systemPackages = with pkgs; [
    fish
    starship
    fastfetch
    fzf
    zoxide
    bat
    fd
    ripgrep
    lazygit
    git
    gh
    neovim
    helix
    yazi
    jq
    tree
    bc
    file
    which
    unzip
    zip
    p7zip
    dos2unix
    wget2
    curl
    rsync
    openssh

    nmap
    socat
    traceroute
    ethtool
    pciutils
    usbutils
    lm_sensors
    ddcutil

    noctalia
    wofi
    nwg-panel
    grim
    slurp
    wl-clipboard
    wlr-randr
    hyprpicker
    hyprpolkitagent
    xwaylandvideobridge
    kitty

    # --- Apps de escritorio -----------------------------------------------
    firefox
    vlc
    kdePackages.dolphin
    ffmpeg
    imagemagick

    # --- Multimedia / extras de tu setup -----------------------------------
    brightnessctl
    playerctl
    cliphist

    # --- Contenedores (podman + skopeo + toolbox→distrobox) ----------------
    # podman
    # skopeo
    # distrobox            # equivalente a toolbox (no hay paquete toolbox en nixpkgs)

    # --- Cifs/NFS/NTFS (montar Windows y shares) ---------------------------
    samba
    cifs-utils
    nfs-utils
    ntfs3g

    # --- Desarrollo --------------------------------------------------------
    gcc
    gnumake
    cmake
    go
    nodejs_22
    python3

    # --- Misc --------------------------------------------------------------
    gnome-keyring
    dconf
  ];

  # --- Servicios/programas del sistema -------------------------------------
  services.gvfs.enable = true;          # MTP/trash/USB en Dolphin
  programs.nix-ld.enable = true;        # ejecutar binarios precompilados sin Nix

  # virtualisation.podman = {
  #   enable = true;
  #   dockerCompat = true;                # alias docker → podman
  #   defaultNetwork.settings.dns_enabled = true;
  # };
}
