{
  description = "NixOS configuration for shinne";

  inputs = {
    # Follow the unstable channel as in the original configuration.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager follows the exact same nixpkgs revision as the system.
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      # This config targets a standard 64-bit Intel/AMD PC.
      system = "x86_64-linux";
    in {
      # The host is intentionally named "nixos" so the existing rebuild alias can remain simple.
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          # Main system configuration.
          ./configuration.nix

          # Home Manager is integrated into the NixOS configuration.
          home-manager.nixosModules.home-manager

          {
            # Reuse the same nixpkgs package set inside Home Manager.
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            # User-specific Home Manager configuration.
            home-manager.users.shinne = import ./home.nix;

            # Preserve existing files when Home Manager replaces them.
            home-manager.backupFileExtension = "backup";
          }
        ];
      };
    };
}
