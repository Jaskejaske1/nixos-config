{
  config,
  lib,
  pkgs,
  ...
}:

let
  repoRoot = config.tacos.repoPath;
  flakeRef = "${repoRoot}#tacos";
  flakeDrvAttr = "${repoRoot}#nixosConfigurations.tacos.config.system.build.toplevel.drvPath";
  flakeBuildAttr = "${repoRoot}#nixosConfigurations.tacos.config.system.build.toplevel";
in

{
  options.tacos.repoPath = lib.mkOption {
    type = lib.types.str;
    default = "/home/jaske/Projects/nixos-config";
    description = "Absolute path to the local tacos NixOS flake repository.";
  };

  config = {
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "tacos-validate" ''
        set -euo pipefail

        repo_root=${lib.escapeShellArg repoRoot}

        echo "==> Formatting Nix files"
        mapfile -t nix_files < <(
          {
            printf '%s\n' "$repo_root/flake.nix"
            ${pkgs.findutils}/bin/find "$repo_root/hosts" "$repo_root/modules" -type f -name '*.nix'
          } | ${pkgs.coreutils}/bin/sort
        )
        ${pkgs.nixfmt}/bin/nixfmt "''${nix_files[@]}"

        echo "==> Evaluating tacos system derivation"
        ${pkgs.nix}/bin/nix eval ${lib.escapeShellArg flakeDrvAttr}

        echo
        echo "Validation completed without activating the system."
      '')

      (pkgs.writeShellScriptBin "tacos-stage" ''
        set -euo pipefail

        repo_root=${lib.escapeShellArg repoRoot}

        echo "==> Staging repository changes"
        ${pkgs.git}/bin/git -C "$repo_root" add .

        echo
        echo "Current staged state:"
        ${pkgs.git}/bin/git -C "$repo_root" status --short

        echo
        echo "Review the staged diff, then commit explicitly:"
        echo "  git -C $repo_root commit -m \"describe the configuration change\""
      '')

      (pkgs.writeShellScriptBin "tacos-switch" ''
        set -euo pipefail

        repo_root=${lib.escapeShellArg repoRoot}

        if [ -n "$(${pkgs.git}/bin/git -C "$repo_root" status --short)" ]; then
          echo "Refusing to rebuild from a dirty Git tree."
          echo "Commit or discard changes first so self.rev stays accurate."
          exit 1
        fi

        /run/current-system/sw/bin/tacos-validate

        echo
        printf 'Run sudo nixos-rebuild switch --flake .#tacos? [y/N] '
        read -r reply

        case "$reply" in
          [yY]|[yY][eE][sS]) ;;
          *)
            echo "Aborted before system activation."
            exit 0
            ;;
        esac

        exec sudo nixos-rebuild switch --flake ${lib.escapeShellArg flakeRef}
      '')

      (pkgs.writeShellScriptBin "tacos-build" ''
        set -euo pipefail

        repo_root=${lib.escapeShellArg repoRoot}

        if [ -n "$(${pkgs.git}/bin/git -C "$repo_root" status --short)" ]; then
          echo "Refusing to build from a dirty Git tree."
          echo "Commit or discard changes first so self.rev stays accurate."
          exit 1
        fi

        /run/current-system/sw/bin/tacos-validate

        echo
        echo "==> Building tacos system derivation"
        exec ${pkgs.nix}/bin/nix build --no-link ${lib.escapeShellArg flakeBuildAttr}
      '')

      (pkgs.writeShellScriptBin "swiss-grab" ''
        set -euo pipefail

        if [ "$#" -eq 0 ]; then
          echo "Usage: swiss-grab <url> [aria2c args...]"
          exit 1
        fi

        exec ${pkgs.aria2}/bin/aria2c -x 16 -s 16 -j 16 "$@"
      '')
    ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.kernelParams = [
      "quiet"
      "udev.log_level=3"
      "systemd.show_status=auto"
      "rd.udev.log_level=3"
    ];

    networking.networkmanager.enable = true;

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

    services.btrfs.autoScrub = {
      enable = true;
      interval = "weekly";
    };

    services.fstrim.enable = true;

    services.journald.extraConfig = "SystemMaxUse=100M";

    services.syncthing = {
      enable = true;
      user = "jaske";
      dataDir = "/home/jaske/.local/share/syncthing";
      configDir = "/home/jaske/.config/syncthing";
      openDefaultPorts = true;
    };

    services.logind.settings.Login.HandleLidSwitch = "suspend";
    services.logind.settings.Login.HandleLidSwitchExternalPower = "suspend";

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };

    programs.bash = {
      interactiveShellInit = ''
        # Initialize zoxide shell hook
        eval "$(${pkgs.zoxide}/bin/zoxide init bash)"

        # Set up custom AZERTY aliases
        alias ewa="eza -lah --git"
        alias obs="obsidian --enable-features=UseOzonePlatform --ozone-platform=wayland"
      '';
    };

    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      glibc
      openssl
    ];
  };
}
