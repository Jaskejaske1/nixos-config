{ pkgs, ... }:

{
  environment.pathsToLink = [
    "/include"
    "/lib/cmake"
    "/lib/pkgconfig"
    "/share/pkgconfig"
  ];

  environment.variables = {
    CMAKE_PREFIX_PATH = "/run/current-system/sw";
    CPATH = "/run/current-system/sw/include";
    LIBRARY_PATH = "/run/current-system/sw/lib";
    PKG_CONFIG_PATH = "/run/current-system/sw/lib/pkgconfig:/run/current-system/sw/share/pkgconfig";
  };

  environment.systemPackages = with pkgs; [
    bat
    cmake
    eza
    fnm
    fzf
    gcc13
    gl3w
    lazygit
    libGL
    libGL.dev
    mesa
    ninja
    nodejs_24
    obsidian
    php83
    picocom
    pkg-config
    powershell
    ripgrep
    sdl3
    sdl3.dev
    uv
    zoxide
  ];

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark-qt;
  };

  users.users.jaske.extraGroups = [
    "dialout"
    "wireshark"
  ];
}
