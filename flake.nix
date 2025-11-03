{
  description = "Impure NixOS flake for mobile02";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";  # adjust if needed
    hardwareConfig = import /etc/nixos/hardware-configuration.nix;
  in
  {
    nixosConfigurations.mobile02 = nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        ./configuration.nix
        hardwareConfig
      ];
    };
  };
}

