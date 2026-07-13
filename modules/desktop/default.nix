{
  pkgs,
  codex-cli-nix,
  ...
}:

{
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.displayManager.defaultSession = "sway";

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  services.xserver.xkb = {
    layout = "be";
    variant = "";
  };
  console.keyMap = "be-latin1";

  environment.etc."sway/config.d/10-input.conf".text = ''
    input * {
      xkb_layout be
    }

    input "type:touchpad" {
      tap enabled
      natural_scroll enabled
      middle_emulation enabled
    }
  '';

  environment.etc."sway/config.d/20-session.conf".text = ''
    exec ${pkgs.mako}/bin/mako
    exec ${pkgs.waybar}/bin/waybar
    exec ${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent

    bindsym $mod+d exec ${pkgs.fuzzel}/bin/fuzzel

    bindsym XF86AudioRaiseVolume exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
    bindsym XF86AudioLowerVolume exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
    bindsym XF86AudioMute exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    bindsym XF86MonBrightnessUp exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%+
    bindsym XF86MonBrightnessDown exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%-

    bindsym --to-code $mod+1 workspace number 1
    bindsym --to-code $mod+2 workspace number 2
    bindsym --to-code $mod+3 workspace number 3
    bindsym --to-code $mod+4 workspace number 4
    bindsym --to-code $mod+5 workspace number 5
    bindsym --to-code $mod+6 workspace number 6
    bindsym --to-code $mod+7 workspace number 7
    bindsym --to-code $mod+8 workspace number 8
    bindsym --to-code $mod+9 workspace number 9
    bindsym --to-code $mod+0 workspace number 10
  '';

  services.printing.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users."jaske" = {
    isNormalUser = true;
    description = "Jaske";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  nixpkgs.config.allowUnfree = true;
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    wget
    git
    neovim
    nixfmt
    nix-output-monitor
    nixd
    vscode
    zed-editor
    ripgrep
    brightnessctl
    fuzzel
    lxqt.lxqt-policykit
    mako
    wl-clipboard
    waybar
    codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
