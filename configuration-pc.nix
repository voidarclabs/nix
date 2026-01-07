{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  networking.hostName = "HACKSTATION";

  # Opengl and vulkan
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Wake on Lan
  networking.interfaces.enp5s0.wakeOnLan.enable = true;
  networking.firewall.enable = false;

  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "user01";
    sddm = {
      enable = true;
    };
  };

  # Local User
  users.users.user01 = {
    extraGroups = [ "docker" ];
    packages = with pkgs; [
      bottles
      ferdium
      inputs.hyprfloat.packages.${pkgs.system}.default
      delfin
      docker
      jellyfin-tui
    ];
  };

  virtualisation.docker = {
    enable = true;
  };
}
