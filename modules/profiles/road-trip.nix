{ pkgs, ... }:

{
  services.power-profiles-daemon.enable = false;

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_BOOST_ON_BAT = 0;
    };
  };

  hardware.graphics = {
    enable = true;
    extraPackages = [ pkgs.intel-media-driver ];
  };

  environment.systemPackages = [ pkgs.mpv ];

  environment.etc."mpv/mpv.conf".text = ''
    hwdec=vaapi
    alang=eng,en
    slang=eng,en
    audio-channels=stereo
  '';
}
