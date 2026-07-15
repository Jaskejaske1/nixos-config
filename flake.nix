{
  description = "Jasper's AI-Ready NixOS Flake Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    codex-cli-nix = {
      url = "github:sadjow/codex-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      codex-cli-nix,
      ...
    }:
    {
      nixosConfigurations = {
        tacos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit self codex-cli-nix; };
          modules = [
            ./hosts/tacos
          ];
        };
      };
    };
}
