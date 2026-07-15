{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    bat
    eza
    fnm
    fzf
    lazygit
    nodejs_24
    obsidian
    php83
    php83Packages.composer
    powershell
    ripgrep
    uv
    zoxide
  ];
}
