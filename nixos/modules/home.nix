# ===========================================================================
# Home Manager — enlaza los dotfiles de ESTE repo (~/Skyrdow) a ~/.config
#
# Usa mkOutOfStoreSymlink: los enlaces apuntan directamente al repo, así que
# puedes editar ~/Skyrdow/hypr/*.lua y aplicarlo sin rebuild (ideal para un
# dotfiles repo). Si prefieres copias inmutables en /nix/store (rebuild para
# cada cambio), sustituye `dot` por rutas normales: source = ../../hypr;
# ===========================================================================

{ config, pkgs, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";

    users.skyrdow = { config, pkgs, ... }:
      let
        dot = p: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Skyrdow/${p}";
      in
      {
        home.stateVersion = "26.05";
        home.username = "skyrdow";
        home.homeDirectory = "/home/skyrdow";

        xdg.enable = true;
        xdg.configFile = {
          # --- Hyprland (config en Lua, tal cual la tienes) -----------------
          "hypr".source                     = dot "hypr";

          # --- Shell / terminal --------------------------------------------
          "fish".source                     = dot "fish";
          "starship.toml".source            = dot "starship.toml";
          "kitty".source                    = dot "kitty";

          # --- Editores / TUI -----------------------------------------------
          "helix".source                    = dot "helix";
          "yazi/yazi.toml".source           = dot "yazi.toml";
          "zed".source                      = dot "zed";
          "fastfetch".source                = dot "fastfetch";
        };
      };
  };
}
