{ config, pkgs, ... }:

{
  # Bootloader configurations
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "tacos"; # My NixOS testing machine
  networking.networkmanager.enable = true;

  # Localization & Time
  time.timeZone = "Europe/Brussels";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_BE.UTF-8";
    LC_IDENTIFICATION = "nl_BE.UTF-8";
    LC_MEASUREMENT = "nl_BE.UTF-8";
    LC_MONETARY = "nl_BE.UTF-8";
    LC_NAME = "nl_BE.UTF-8";
    LC_NUMERIC = "nl_BE.UTF-8";
    LC_PAPER = "nl_BE.UTF-8";
    LC_TELEPHONE = "nl_BE.UTF-8";
    LC_TIME = "nl_BE.UTF-8";
  };

  # Storage Maintenance
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
  };

  # =========================================================================
  # Automated System Maintenance & Profile Cleanup Layer
  # =========================================================================

  # 1. Register a system-wide maintenance command: 'cleanup-tacos'
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "cleanup-tacos" ''
      set -e
      echo "=== Kicking off System Maintenance Profile Purge ==="

      # Clear system generations older than 1 day safely
      echo "-> Purging legacy system profiles..."
      sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +1

      # Collect unreferenced store items
      echo "-> Collecting garbage to free disk blocks..."
      sudo nix-store --gc

      echo "=== System footprint optimization complete ==="
    '')
  ];

  # 2. Automated background systemd maintenance timer (Runs weekly on Monday at 4 AM)
  systemd.services.tacos-maintenance = {
    description = "Automated NixOS Storage Maintenance Engine";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/run/current-system/sw/bin/cleanup-tacos";
    };
  };

  systemd.timers.tacos-maintenance = {
    description = "Timer for Automated NixOS Storage Maintenance Engine";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Mon *-*-* 04:00:00";
      Persistent = true;
    };
  };

  # Nix Package Manager Settings
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
  };

  # Enable nix-ld to run generic unpatched dynamic binaries automatically
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    glibc
    openssl
  ];
}
