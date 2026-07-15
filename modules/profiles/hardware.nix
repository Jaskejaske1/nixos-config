{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ picocom ];

  users.users.jaske.extraGroups = [ "dialout" ];
}
