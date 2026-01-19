{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  services.libinput.enable = true;

  services.displayManager.defaultSession = "hyprland";
  services.xserver = {
    enable = true;

    desktopManager = {
      xterm.enable = false;
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu # application launcher most people use
        i3status # gives you the default i3 status bar
        xorg.xinit
      ];
    };
  };
}
