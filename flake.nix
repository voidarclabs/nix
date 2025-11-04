{
  description = "Impure NixOS flake for mobile02";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    elephant.url = "github:abenz1267/elephant";

    walker = {
        url = "github:abenz1267/walker";
        inputs.elephant.follows = "elephant";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: let
    stdenv.hostPlatform.system = "x86_64-linux";  # adjust if needed
    system = stdenv.hostPlatform.system;
    hardwareConfig = import /etc/nixos/hardware-configuration.nix;
  in
  {
    nixosConfigurations.mobile02 = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs;};

      modules = [
        ./configuration.nix
        hardwareConfig
      ];
    };
  };
}

