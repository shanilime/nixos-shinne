{ config, pkgs, ... }:

let
  # The repository is expected to live in ~/nixos-dotfiles.
  # The actual config files are stored in its /config directory.
  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";

  # Keep dotfiles outside the Nix store so they can be edited directly in the Git repository.
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;

  # Configuration directories that should be linked into ~/.config/.
  configs = {
    nvim = "nvim";
    alacritty = "alacritty";
    mpv = "mpv";
  };
in

{
  # ---------------------------------------------------------------------------
  # Home Manager basics
  # ---------------------------------------------------------------------------

  home.username = "shinne";
  home.homeDirectory = "/home/shinne";

  # Match the NixOS system state version used by this configuration.
  home.stateVersion = "26.05";

  # ---------------------------------------------------------------------------
  # Dotfiles
  # ---------------------------------------------------------------------------

  # Link Neovim, Alacritty and mpv configs directly from the repository.
  xdg.configFile = builtins.mapAttrs
    (name: subpath: {
      source = create_symlink "${dotfiles}/${subpath}";
      recursive = true;
    })
    configs;

  # ---------------------------------------------------------------------------
  # Git
  # ---------------------------------------------------------------------------

  # Git itself is installed system-wide, but no identity/signing settings are
  # configured here. The user can configure name, email and signing manually later.

  # ---------------------------------------------------------------------------
  # Zsh
  # ---------------------------------------------------------------------------

  programs.zsh = {
    enable = true;

    # Global npm packages are installed in ~/.npm-global/bin.
    envExtra = ''
      export PATH=$HOME/.npm-global/bin:$PATH
    '';

    # Shortcut for rebuilding the system from this flake.
    shellAliases = {
      nrs = "sudo nixos-rebuild switch --flake ~/nixos-dotfiles#nixos";
    };

    # Oh My Zsh provides the prompt and useful shell plugins.
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "git"
        "history-substring-search"
      ];
    };

    # Highlight valid/invalid shell syntax as commands are typed.
    syntaxHighlighting.enable = true;

    # Suggest previous commands while typing.
    autosuggestion.enable = true;
  };

  # ---------------------------------------------------------------------------
  # Shell utilities
  # ---------------------------------------------------------------------------

  # Fuzzy finder for command-line workflows.
  programs.fzf.enable = true;

  # Replace the normal cd command with zoxide's smarter directory jumper.
  programs.zoxide = {
    enable = true;
    options = [ "--cmd cd" ];
  };

  # GitHub CLI is available for GitHub-related tasks; authentication is configured manually.
  programs.gh.enable = true;

  # ---------------------------------------------------------------------------
  # User applications
  # ---------------------------------------------------------------------------

  # Keep the full original application set. Unused applications can be removed later.
  home.packages = with pkgs; [
    (kdePackages.spectacle.override {
      tesseractLanguages = [
        "eng"
        "rus"
        "ukr"
      ];
    })
    # Editors / development tools
    neovim
    ripgrep
    nil
    nixpkgs-fmt
    nodejs
    gcc
    vscode
    recaf-launcher
    claude-code
    tree-sitter
    jdk25
    android-tools
    python3
    lua51Packages.luarocks
    gnumake
    cmake
    gradle_9
    rustup
    bore-cli

    # Browsers / media
    firefox
    chromium
    mpv

    # Desktop / graphics
    alacritty
    obs-studio
    qimgv
    gimp
    obsidian

    # Communication
    telegram-desktop
    vesktop
    anydesk
    rustdesk
    localsend

    # Minecraft / gaming
    prismlauncher

    # Android / device tools
    scrcpy

    # Utilities
    unzip
    zip
    btop
    fastfetch
    keepassxc
    qbittorrent
    baobab
    conntrack-tools
    kdePackages.kdialog
  ];
}
