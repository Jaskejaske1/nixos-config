{ pkgs, ... }:

{
  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };

  # Mullvad VPN currently requires systemd-resolved to route DNS correctly on NixOS
  services.resolved.enable = true;

  # Autostart the GUI application on login
  environment.systemPackages = [
    (pkgs.makeAutostartItem {
      name = "mullvad-vpn";
      package = pkgs.mullvad-vpn;
    })
  ];
}
