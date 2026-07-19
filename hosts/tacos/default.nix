{
  config,
  self,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/core
    ../../modules/desktop
    ../../modules/profiles/dev-web.nix
    ../../modules/profiles/dev-cpp.nix
    ../../modules/profiles/net-lab.nix
    ../../modules/profiles/hardware.nix
    ../../modules/profiles/road-trip.nix
    ../../modules/profiles/vpn-mullvad.nix
  ];

  system.configurationRevision =
    if (self ? rev) then self.rev else throw "Commit your changes first!";

  tacos.username = "jaske";

  users.users.${config.tacos.username} = {
    isNormalUser = true;
    description = "Jaske";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  networking.hostName = "tacos";
  system.stateVersion = "26.05";
}
