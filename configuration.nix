{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [
      /etc/nixos/hardware-configuration.nix
      inputs.walker.nixosModules.default
    ];

  # Allow Nix command and flakes (ofc)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

# Allow unfree packages
  nixpkgs = {
	  config = {
		  allowUnfree = true;
		  packageOverrides = pkgs: {
			  unstable = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {};
		  };
	  };
  };

# Boot
  boot = {
    loader = {
	timeout = 2;
  	  efi = {
  		  canTouchEfiVariables = true;
  	  };
  	  grub = {
  		  efiSupport = true;
  		  device = "nodev";
  		  theme = pkgs.catppuccin-grub;
  	  };
    };
    plymouth = {
	enable = true;
      theme = "catppuccin-mocha";
      themePackages = with pkgs; [
        # By default we would install all themes
        (catppuccin-plymouth.override {
          variant = "mocha";
        })
      ];
    };
  };

# Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Networking settings
  networking.hostName = "mobile02"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Opengl and vulkan
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-vaapi-driver
      libva-vdpau-driver
    ];
  };

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Locale
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Windowing Systems
  services.xserver.enable = true;

  services.displayManager.sddm = {
    enable = true;
    theme = "catppuccin-mocha-mauve";
    package = pkgs.kdePackages.sddm;
  };

  programs.hyprland.enable = true;
  security.polkit.enable = true;

  # Keymap
  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };
  console.keyMap = "uk";

  # Pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Local User
  users.users.user01 = {
    isNormalUser = true;
   shell = pkgs.zsh;
    description = "user01";
    extraGroups = [ "input" "bluetooth" "networkmanager" "docker" "wheel" ];
    packages = with pkgs; [
        # Ricing
        bibata-cursors
        catppuccin-gtk
	(builtins.getFlake "/etc/nixos/way-edges").packages.${pkgs.system}.default
	waybar
    hyprlock
	swaynotificationcenter
    wlogout
        wpaperd
        kando
        oh-my-posh

        # Terminal
        carapace
        kitty
        github-cli
        light
	    bluetuith
        wget
	    playerctl
        git
        fastfetch
        lsd
	juce
        stow
	fzf
	ripgrep
        zsh-autocomplete
        nodejs
        lazygit
        tailscale

        # Thunar stuff
        xfce.thunar
        xfce.thunar-volman
        xfce.thunar-vcs-plugin
        xfce.thunar-archive-plugin

        # Apps
        pavucontrol
        firefox
        tor-browser
	gotify-desktop
	techmino
        mpv
        prismlauncher
        delfin
        libreoffice-qt6
        syncthing
	xremap
        blueman
    ];
  };

# Zsh
  programs.zsh = {
	  enable = true;
	  enableCompletion = true;
	  enableBashCompletion = true;
	  autosuggestions.enable = true;
	  syntaxHighlighting.enable = true;
	  histSize = 10000;
	  ohMyZsh = {
		  enable = true;
		  plugins = [ "git" "dirhistory" "history" ];
	  };
  };

# User programs
  programs.steam.enable = true;
  programs.walker.enable = true;

# User Services
  services.gvfs.enable = true;
  services.tailscale.enable = true;
  services.printing.enable = true;
  services.upower.enable = true;
  services.openssh.enable = true;
  services.elephant.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
	  nerd-fonts.fira-mono
  ];

  fonts.fontconfig.defaultFonts.serif = [ "Fira Mono Nerd Font" ];
   environment.systemPackages = with pkgs; [

      # Catppuccin sddm theme
      (pkgs.catppuccin-sddm.override {
        flavor = "mocha";
        font = "Fira Mono Nerd Font";
        fontSize = "11";
        background = null;
      })
      # Terminal things
      (pkgs.symlinkJoin {
      name = "nvim-with-lsp";
      paths = [ pkgs.neovim ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/nvim \
          --prefix PATH : ${pkgs.lib.makeBinPath [
            pkgs.lua-language-server
	    pkgs.vscode-langservers-extracted
	    pkgs.emmet-ls
	    pkgs.ripgrep
        pkgs.nil
            pkgs.typescript-language-server
            pkgs.tailwindcss-language-server
	    pkgs.stylua
          ]}
      '';
    })
      vim
      unzip
      python310 # Its python like come on

      # Graphics Drivers
      mesa
      vulkan-tools

      # FileSystem Dependancies
      gvfs

      # C copmpiler
      clang

      # XDG Desktop Portal Etc
      xdg-desktop-portal
      xdg-desktop-portal-hyprland

      # Other things (from gnome)
      glib
      gnutls
      appimage-run
      libnotify
      gsettings-desktop-schemas
   ];

  # The comment
  system.stateVersion = "25.05"; # Did you read the comment?

}
