{
  config,
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [ picocom ];

  users.users.${config.tacos.username}.extraGroups = [ "dialout" ];
}
