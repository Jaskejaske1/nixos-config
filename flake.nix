{
  description = "Jasper's AI-Ready NixOS Flake Configuration";

  inputs = {
    # Point to the official unstable or stable NixOS packages channel
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      # This name MUST match your networking.hostName (tacos)
      tacos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
	specialArgs = { inherit self; };
        modules = [
          ./configuration.nix
        ];
      };
    };
  };
}
