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
    alsa-lib
    bat
    cmake
    dbus
    php83Packages.composer
    eza
    fnm
    fzf
    gcc13
    gl3w
    lazygit
    libdrm
    libffi
    libGL
    libGL.dev
    libdecor
    libpulseaudio
    libxkbcommon
    mesa
    ninja
    nodejs_24
    obsidian
    php83
    picocom
    pkg-config
    powershell
    python3
    ripgrep
    sdl3
    sdl3.dev
    systemd
    uv
    wayland
    wayland-protocols
    libx11
    libxcb
    libxcb.dev
    libxcursor
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxscrnsaver
    libxxf86vm
    pipewire
    xcbutil
    xcbutil.dev
    zoxide
  ];

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  users.users.jaske.extraGroups = [
    "dialout"
    "wireshark"
  ];
}
