{
  description = "System configuration with Flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    
    jagex-launcher.url = "github:Kahnix/jagex-launcher-nix";
  };

  outputs = { self, nixpkgs, jagex-launcher, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      # This forwards the inputs down so configuration.nix can see them
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        ./hardware-configuration.nix
      ];
    };
  };
}
