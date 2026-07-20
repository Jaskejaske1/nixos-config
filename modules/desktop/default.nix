{
  pkgs,
  codex-cli-nix,
  ...
}:

{
  imports = [ ./kde.nix ];

  # Force Chromium and Electron apps (Discord, Obsidian) to run natively on Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  services.xserver.enable = true;
  services.xserver.desktopManager.xterm.enable = false;

  services.xserver.xkb = {
    layout = "be";
    variant = "";
  };
  console.keyMap = "be-latin1";

  services.printing.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  nixpkgs.config.allowUnfree = true;
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    aria2
    wget
    git
    discord
    gnome-maps
    gpxsee
    neovim
    nixfmt
    nix-output-monitor
    nixd
    zed-editor
    brightnessctl
    gsettings-desktop-schemas
    wl-clipboard
    codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Chromium with DRM support enabled
    (chromium.override { enableWideVine = true; })
  ];
}
