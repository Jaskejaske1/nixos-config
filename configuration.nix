{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./core.nix
    ./desktop.nix
  ];

  # System state version tracker. Do not alter this value.
  system.stateVersion = "26.05";
}
