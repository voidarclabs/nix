{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  networking.hostName = "HACKSTATION";

  # Enable nix-ld to run unpatched binaries
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    libusb1
  ];

  # Add Samsung USB udev rules
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", MODE="0666", GROUP="plugdev"
  '';

  # Opengl and vulkan
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Wake on Lan
  networking.interfaces.enp5s0.wakeOnLan.enable = true;
  networking.firewall.enable = false;

  systemd.services.NetworkManager-wait-online.enable = false;

  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "user01";
    sddm = {
      enable = true;
    };
  };

  # Local User
  users.users.user01 = {
    extraGroups = [
      "adbusers"
      "docker"
    ];
    packages = with pkgs; [
      bottles
      ferdium
      android-tools
      vesktop
      wine64
      delfin
      docker
      jellyfin-tui
      orca-slicer
    ];
  };

  services.wivrn = {
    enable = true;
    package = pkgs.unstable.wivrn;
    openFirewall = true;
    defaultRuntime = true;
  };

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };
}
