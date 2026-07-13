{
  pkgs,
  codex-cli-nix,
  ...
}:

{
  services.xserver.enable = true;
  services.xserver.desktopManager.xterm.enable = false;
  services.displayManager.gdm.enable = false;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.lightdm.greeters.pantheon.enable = true;
  services.displayManager.defaultSession = "pantheon-wayland";
  services.desktopManager.pantheon.enable = true;
  services.pantheon.apps.enable = true;

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
  services.udev.packages = [ pkgs.gnome-settings-daemon ];

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
    aria2
    wget
    git
    gnome-maps
    gpxsee
    neovim
    nixfmt
    nix-output-monitor
    nixd
    zed-editor
    ripgrep
    brightnessctl
    bat
    eza
    fzf
    gsettings-desktop-schemas
    lazygit
    pantheon.elementary-icon-theme
    wl-clipboard
    zoxide
    codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
