{ pkgs, ... }:

{
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  users.users.jaske.extraGroups = [ "wireshark" ];
}
