{
  description = "Impure NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    elephant.url = "github:abenz1267/elephant";
    chataigne.url = "./chataigne";
    doot.url = "github:voidarclabs/nixos.doot";
		way-edges.url = "github:way-edges/way-edges";

    walker = {
        url = "github:abenz1267/walker";
        inputs.elephant.follows = "elephant";
    };
  };

  outputs = { self, doot, chataigne, nixpkgs, ... }@inputs: let
    stdenv.hostPlatform.system = "x86_64-linux";
    system = stdenv.hostPlatform.system;
    hardwareConfig = import /etc/nixos/hardware-configuration.nix;
  in
  {
    nixosConfigurations.mobile02 = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs;};

      modules = [
        ./configuration-laptop.nix
				./common.nix
        hardwareConfig
        {
          nixpkgs.config.allowUnfree = true;
        }
      ];
    };
    nixosConfigurations.hackstation = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs;};

      modules = [
        ./configuration-pc.nix
				./common.nix
        hardwareConfig
        {
          nixpkgs.config.allowUnfree = true;
        }
      ];
    };
  };
}

