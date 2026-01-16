{
  description = "A flake for running the Chataigne AppImage with necessary patched dependencies.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # Modern Nixpkgs
    
    # Pinned Nixpkgs for compatibility (the commit that fixes the CURL_GNUTLS_3 issue)
    pinned-nixpkgs = {
      url = "github:NixOS/nixpkgs/5171d7b0a9fbaaf216c873622eb5115b6db97957";
      flake = false; # Treat as a tarball input, not a flake
    };
  };

  outputs = { self, nixpkgs, pinned-nixpkgs, ... }:
  let
    # Supported systems
    supportedSystems = [ "x86_64-linux" ];

    # The main package definition logic is imported as a function
    chataigne-appimage-runner = import ./chataigne.nix;

    # Function to generate the package set for each system
    forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
  in
  {
    packages = forAllSystems (system:
      let
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
        pinnedPkgs = import pinned-nixpkgs { inherit system; };
      in
      {
        chataigne = chataigne-appimage-runner { 
          inherit pkgs pinnedPkgs; 
        };
        
        # Also expose the default package for convenience
        default = self.packages.${system}.chataigne;
      }
    );
  };
}
