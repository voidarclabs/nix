{
  description = "My NixOS system configuration";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

  outputs = { self, nixpkgs, ... }@inputs:
    {
      nixosConfigurations.mobile02 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          /etc/nixos/hardware-configuration.nix
        ];
      };
    };
}

