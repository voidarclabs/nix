{ config, lib, pkgs, inputs, ... }:

{
	networking.hostName = "HACKSTATION"; # Define your hostname.


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
		autoLogin.enable = true;
		autoLogin.user = "user01";
 	};

services.getty.autologinUser = "user01";

# Catppuccin sddm theme
#		(pkgs.catppuccin-sddm.override {
#		 flavor = "mocha";
#		 font = "Fira Mono Nerd Font";
#		 fontSize = "11";
#		 background = null;
#		 })

# Local User
	users.users.user01 = {
		extraGroups = [ ];
		packages = with pkgs; [
# Ricing

# Terminal

# Apps
	bottles
				];
	};

}
