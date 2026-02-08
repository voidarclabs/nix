{
  description = "Master flake for Voidarc nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    elephant.url = "github:abenz1267/elephant";
    chataigne.url = "./modules/chataigne";
    doot.url = "github:voidarclabs/nixos.doot";
    way-edges.url = "github:way-edges/way-edges";
    hyprfloat = {
      url = "github:nevimmu/hyprfloat";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    walker = {
      url = "github:abenz1267/walker";
      inputs.elephant.follows = "elephant";
    };

    mesa-davinci.url = "github:nixos/nixpkgs?ref=599ddd2b79331c1e6153e1659bdaab65d62c4c82";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      hardwareConfig = import /etc/nixos/hardware-configuration.nix;
    in
    {
      nixosConfigurations.mobile02 = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };

        modules = [
          ./configs/configuration-laptop.nix
          ./configs/common.nix
          hardwareConfig
          {
            nixpkgs.config.allowUnfree = true;
          }
        ];
      };
      nixosConfigurations.hackstation = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };

        modules = [
          ./configs/configuration-pc.nix
          ./configs/common.nix
          ./modules/davinci/davinci.nix
          ./modules/i3/i3.nix
          hardwareConfig
          {
            nixpkgs.config.allowUnfree = true;
          }
        ];
      };
    };
}
