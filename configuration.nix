{
  config,
  pkgs,
  self,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./core.nix
    ./desktop.nix
  ];

  # Explicitly tell NixOS to read the Git commit hash from the Flake
  system.configurationRevision =
    if (self ? rev) then self.rev else throw "Commit your changes first!";

  system.stateVersion = "26.05";
}
