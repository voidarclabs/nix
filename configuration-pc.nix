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

  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "user01";
    sddm = {
      enable = true;
    };
  };

  # Local User
  users.users.user01 = {
    extraGroups = [ ];
    packages = with pkgs; [
      bottles
      ferdium
      inputs.hyprfloat.packages.${pkgs.system}.default
      delfin
      jellyfin-tui
    ];
  };

}
