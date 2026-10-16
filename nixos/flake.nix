{
  description = "NixOS 26.05 'Yarara' para exarch — réplica de Fedora 44 + Hyprland + LiDM";

  inputs = {
    # Última release estable de NixOS (30 may 2026). La siguiente será 26.11 "Zokor".
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # LiDM 2.0.2 (última: 25-feb-2026) — no está en nixpkgs, usa su flake.
    # Trae el paquete y el módulo NixOS (assets/pkg/nix/module.nix).
    lidm.url = "github:javalsai/lidm";

    # Noctalia Shell — tu barra/panel. Se usa por si la versión de 26.05 no
    # está en nixpkgs; si lo está puedes cambiar a pkgs.noctalia-shell y borrar
    # este input (ver módulo packages.nix).
    noctalia-shell.url = "github:noctalia-dev/noctalia-shell";
  };

  outputs = { self, nixpkgs, home-manager, lidm, noctalia-shell, ... }: {
    nixosConfigurations.exarch = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit lidm noctalia-shell; };

      modules = [
        ./configuration.nix
        ./modules/hardware.nix
        ./modules/desktop.nix
        ./modules/packages.nix
        ./modules/home.nix
        home-manager.nixosModules.home-manager
      ];
    };
  };
}
