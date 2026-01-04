{ config, lib, pkgs, inputs, ... }:

{
	networking.hostName = "mobile02"; # Define your hostname.

# Opengl and vulkan
	hardware.graphics = {
		enable = true;
		extraPackages = with pkgs; [
			intel-vaapi-driver
				libva-vdpau-driver
		];
	};

	services.displayManager.sddm = {
		enable = true;
		theme = "catppuccin-mocha-mauve";
		package = pkgs.kdePackages.sddm;
	};

	environment.systemPackages = with pkgs; [
# Catppuccin sddm theme
		(pkgs.catppuccin-sddm.override {
		 flavor = "mocha";
		 font = "Fira Mono Nerd Font";
		 fontSize = "11";
		 background = null;
		 })
]

# Local User
	users.users.user01 = {
		extraGroups = [ ];
		packages = with pkgs; [
# Ricing
				inputs.way-edges.packages.${pkgs.system}.way-edges
				inputs.chataigne.packages.${pkgs.system}.chataigne

# Terminal
				light
# Apps
				];
	};

}
