{
  description = "Jasper's AI-Ready NixOS Flake Configuration";

  inputs = {
    # Point to the official stable NixOS packages channel
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    # Add the automated Codex CLI Flake repository
    codex-cli-nix.url = "github:sadjow/codex-cli-nix";
  };

  # Added codex-cli-nix into the outputs argument list here
  outputs =
    {
      self,
      nixpkgs,
      codex-cli-nix,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        tacos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          # Pass the flake inputs downstream so desktop.nix can read them
          specialArgs = { inherit self codex-cli-nix; };
          modules = [
            ./configuration.nix
          ];
        };
      };
    };
}
