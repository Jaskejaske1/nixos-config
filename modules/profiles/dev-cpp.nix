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
    cmake
    dbus
    gcc13
    gl3w
    libdrm
    libffi
    libGL
    libGL.dev
    libdecor
    libpulseaudio
    libxkbcommon
    mesa
    ninja
    pkg-config
    pipewire
    python3
    sdl3
    sdl3.dev
    systemd
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
    xcbutil
    xcbutil.dev
  ];
}
