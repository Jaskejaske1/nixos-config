{
  pkgs,
  codex-cli-nix,
  ...
}:

{
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

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
    codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
