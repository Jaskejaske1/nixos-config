{ pkgs, ... }:

{
  # This enables direnv natively in NixOS and sets up the shell hooks automatically
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
