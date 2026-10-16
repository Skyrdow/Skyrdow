# ===========================================================================
# Hardware — exarch (portátil, chasis laptop)
#
#   CPU:  AMD Ryzen 5 5600H (12 hilos, Cezanne iGPU Radeon Vega)
#   GPU:  NVIDIA GA106M RTX 3060 Mobile + AMD iGPU (Optimus mux-less)
#   RAM:  ~13 GiB  → zram de 8G (como el zram-generator de Fedora)
#   NVMe: WDC PC SN730 1T
#     p5  vfat   ESP     → /boot/efi   (AD65-54E1)
#     p6  ext4   /boot   (b3dee95d-…)
#     p7  btrfs  root + home subvols, compress=zstd:1 (2fd2deae-…)
#     p2/p3 ntfs  Windows, p4 exfat 01B6-69E0 (datos, lo monta udisks)
#
#  ⚠ UUIDs copiados de tu instalación actual. Si re-particionas, genera un
#    hardware-configuration.nix nuevo con `nixos-generate-config` y usa ese.
# ===========================================================================

{ config, pkgs, ... }:

{
  # --- Arranque ------------------------------------------------------------
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
    # Tu layout Fedora separa ESP y /boot; si prefieres el esquema NixOS
    # clásico (ESP directo en /boot, sin la ext4 p6), monta AD65-54E1 en
    # /boot y borra la entrada de /boot ext4 + esta línea.
    efiSysMountPoint = "/boot/efi";
  };
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest; # Fedora corría 7.2; si la
    # nvidia proprietary da problemas con el kernel más nuevo, vuelve a
    # quitar esta línea (usa el kernel por defecto de 26.05).

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ "amdgpu" ];  # iGPU temprana para el panel eDP
  boot.kernelModules = [ "kvm-amd" ];
  hardware.cpu.amd.updateMicrocode = true;   # amd-ucode

  boot.plymouth.enable = true;               # tenías plymouth con tema spinner

  # --- Sistemas de archivos (btrfs subvols, sin LUKS — igual que Fedora) --
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/2fd2deae-2bea-41ca-9ada-81ded2cf26f5";
    fsType = "btrfs";
    options = [ "subvol=root" "compress=zstd:1" ];
  };
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/2fd2deae-2bea-41ca-9ada-81ded2cf26f5";
    fsType = "btrfs";
    options = [ "subvol=home" "compress=zstd:1" ];
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/b3dee95d-fd47-4e4e-8f1c-c2b9fc447254";
    fsType = "ext4";
  };
  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/AD65-54E1";
    fsType = "vfat";
    options = [ "umask=0077" "shortname=winnt" ];
  };

  # La partición exfat de datos (01B6-69E0) la seguía montando udisks en
  # /run/media/skyrdow/… y en NixOS udisks2 viene activo. Si la quieres
  # siempre montada en firme, descomenta:
  # fileSystems."/mnt/datos" = {
  #   device = "/dev/disk/by-uuid/01B6-69E0";
  #   fsType = "exfat";
  #   options = [ "rw" "noatime" "uid=1000" "gid=100" "umask=0077" ];
  # };
  # Windows (p2/p3, ntfs) sigue disponible con ntfs3g desde el gestor de archivos.

  # --- zram (tenías zram-generator con 8G) --------------------------------
  services.zramswap = {
    enable = true;
    memoryPercent = 62;   # ≈ 8G de tus ~13G
  };

  # --- Gráficas ------------------------------------------------------------
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;      # nvidia-suspend/hibernate (los tenías)
    powerManagement.finegrained = false;
    open = false;                       # driver propietario, como akmod-nvidia
    nvidiaSettings = true;              # nvidia-settings
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # PRIME Optimus — bus IDs de tu máquina:
    #   NVIDIA  01:00.0 → PCI:1:0:0
    #   AMD iGPU 05:00.0 → PCI:5:0:0
    #
    # offload = sesión en la iGPU (rápida, batería) y la RTX se usa bajo
    # demanda con `nvidia-offload <app>` (equivalente a prime-run de Fedora).
    # Alternativas si el HDMI (cableado a la RTX) te da problemas:
    #   prime.sync.enable = true;          # todo renderizado en la RTX
    #   prime.reverseSync.enable = true;   # iGPU primaria + dGPU offload
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      amdgpuBusId = "PCI:5:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  hardware.switcheroo-control.enable = true;  # "Launch using dedicated GPU"

  # --- Seguridad/arranque extra -------------------------------------------
  # Fedora traía clevis+TPM2 pero tu root no estaba cifrado (sin LUKS en
  # crypttab), así que no se replica nada aquí.
}
