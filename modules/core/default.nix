{
  config,
  lib,
  pkgs,
  ...
}:

let
  repoRoot = config.tacos.repoPath;
  username = config.tacos.username;
  homeDir = "/home/${username}";
  flakeRef = "${repoRoot}#tacos";
  flakeDrvAttr = "${repoRoot}#nixosConfigurations.tacos.config.system.build.toplevel.drvPath";
  flakeBuildAttr = "${repoRoot}#nixosConfigurations.tacos.config.system.build.toplevel";
  btrfs = "${pkgs.btrfs-progs}/bin/btrfs";
in

{
  options.tacos.repoPath = lib.mkOption {
    type = lib.types.str;
    default = "/home/${config.tacos.username}/Projects/nixos-config";
    description = "Absolute path to the local tacos NixOS flake repository.";
  };

  options.tacos.username = lib.mkOption {
    type = lib.types.str;
    default = "jaske";
    description = "Primary local username for host-scoped services and access control.";
  };

  config = {
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "tacos-status" ''
        set -euo pipefail

        repo_root=${lib.escapeShellArg repoRoot}

        echo "==> tacos repository"
        echo "$repo_root"

        echo
        echo "==> git revision"
        ${pkgs.git}/bin/git -C "$repo_root" rev-parse --short HEAD

        echo
        echo "==> working tree"
        if [ -n "$(${pkgs.git}/bin/git -C "$repo_root" status --short)" ]; then
          ${pkgs.git}/bin/git -C "$repo_root" status --short
        else
          echo "clean"
        fi
      '')

      (pkgs.writeShellScriptBin "tacos-fmt" ''
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
      '')

      (pkgs.writeShellScriptBin "tacos-eval" ''
        set -euo pipefail

        echo "==> Evaluating tacos system derivation"
        exec ${pkgs.nix}/bin/nix eval ${lib.escapeShellArg flakeDrvAttr}
      '')

      (pkgs.writeShellScriptBin "tacos-validate" ''
        set -euo pipefail

        echo "warning: tacos-validate is deprecated; use tacos-eval" >&2
        echo "==> Evaluating tacos system derivation"
        exec ${pkgs.nix}/bin/nix eval ${lib.escapeShellArg flakeDrvAttr}
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

        printf 'Run sudo nixos-rebuild switch --flake %s? [y/N] ' ${lib.escapeShellArg flakeRef}
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
    networking.firewall.enable = true;

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

    system.activationScripts.ensureSnapperSubvolumes.text = ''
      ensure_snapshot_subvolume() {
        local path="$1"

        if ${btrfs} subvolume show "$path" >/dev/null 2>&1; then
          return 0
        fi

        if [ -e "$path" ]; then
          echo "Refusing to continue: $path exists but is not a Btrfs subvolume." >&2
          exit 1
        fi

        ${btrfs} subvolume create "$path"
      }

      ensure_snapshot_subvolume "/.snapshots"
      ensure_snapshot_subvolume "/home/.snapshots"
    '';

    services.snapper = {
      snapshotRootOnBoot = true;
      persistentTimer = true;
      configs = {
        root = {
          SUBVOLUME = "/";
          ALLOW_USERS = [ username ];
          TIMELINE_CREATE = true;
          TIMELINE_CLEANUP = true;
          TIMELINE_LIMIT_HOURLY = 8;
          TIMELINE_LIMIT_DAILY = 7;
          TIMELINE_LIMIT_WEEKLY = 4;
          TIMELINE_LIMIT_MONTHLY = 3;
        };
        home = {
          SUBVOLUME = "/home";
          ALLOW_USERS = [ username ];
          TIMELINE_CREATE = true;
          TIMELINE_CLEANUP = true;
          TIMELINE_LIMIT_HOURLY = 8;
          TIMELINE_LIMIT_DAILY = 7;
          TIMELINE_LIMIT_WEEKLY = 4;
          TIMELINE_LIMIT_MONTHLY = 3;
        };
      };
    };

    services.syncthing = {
      enable = true;
      user = username;
      dataDir = "${homeDir}/.local/share/syncthing";
      configDir = "${homeDir}/.config/syncthing";
      guiAddress = "127.0.0.1:8384";
      openDefaultPorts = false;
      settings.options.localAnnounceEnabled = false;
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
