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
    mako
    wl-clipboard
    waybar
    codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
