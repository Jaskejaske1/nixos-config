{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "tacos-validate" ''
      set -euo pipefail

      repo_root="$(${pkgs.git}/bin/git rev-parse --show-toplevel)"
      cd "$repo_root"

      echo "==> Formatting Nix files"
      mapfile -t nix_files < <(
        {
          printf '%s\n' flake.nix
          ${pkgs.findutils}/bin/find hosts modules -type f -name '*.nix'
        } | ${pkgs.coreutils}/bin/sort
      )
      ${pkgs.nixfmt}/bin/nixfmt "''${nix_files[@]}"

      echo "==> Evaluating tacos system derivation"
      ${pkgs.nix}/bin/nix eval .#nixosConfigurations.tacos.config.system.build.toplevel.drvPath

      echo
      echo "Validation completed without activating the system."
    '')

    (pkgs.writeShellScriptBin "tacos-stage" ''
      set -euo pipefail

      repo_root="$(${pkgs.git}/bin/git rev-parse --show-toplevel)"
      cd "$repo_root"

      echo "==> Staging repository changes"
      ${pkgs.git}/bin/git add .

      echo
      echo "Current staged state:"
      ${pkgs.git}/bin/git status --short

      echo
      echo "Review the staged diff, then commit explicitly:"
      echo "  git commit -m \"describe the configuration change\""
    '')

    (pkgs.writeShellScriptBin "tacos-switch" ''
      set -euo pipefail

      repo_root="$(${pkgs.git}/bin/git rev-parse --show-toplevel)"
      cd "$repo_root"

      if [ -n "$(${pkgs.git}/bin/git status --short)" ]; then
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

      exec sudo nixos-rebuild switch --flake .#tacos
    '')

    (pkgs.writeShellScriptBin "tacos-build" ''
      set -euo pipefail

      repo_root="$(${pkgs.git}/bin/git rev-parse --show-toplevel)"
      cd "$repo_root"

      if [ -n "$(${pkgs.git}/bin/git status --short)" ]; then
        echo "Refusing to build from a dirty Git tree."
        echo "Commit or discard changes first so self.rev stays accurate."
        exit 1
      fi

      /run/current-system/sw/bin/tacos-validate

      echo
      echo "==> Building tacos system derivation"
      exec ${pkgs.nix}/bin/nix build .#nixosConfigurations.tacos.config.system.build.toplevel
    '')
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
  };

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    glibc
    openssl
  ];
}
