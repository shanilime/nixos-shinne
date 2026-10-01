{ config, lib, pkgs, ... }:

{
  # Hardware configuration is generated on the target PC.
  # Keep this file local to the machine because it contains disk UUIDs and hardware-specific settings.
  imports = [
    ./hardware-configuration.nix
  ];

  # ---------------------------------------------------------------------------
  # Boot
  # ---------------------------------------------------------------------------

  # Use systemd-boot for UEFI systems.
  #
  # Windows is expected to be installed on a separate SSD/EFI partition.
  # The Windows EFI device handle is hardware-specific, so it must be filled
  # in once after installation. See the comments below for the exact value.
  boot.loader = {
    # Allow NixOS to create/update its UEFI boot entry.
    efi.canTouchEfiVariables = true;

    systemd-boot = {
      enable = true;

      # Add Windows from a separate EFI System Partition.
      #
      # After installing both operating systems, boot the EDK2 UEFI Shell
      # from the systemd-boot menu and run:
      #
      #   map -c
      #
      # Find the HD... device whose EFI partition contains:
      #
      #   EFI\Microsoft\Boot\bootmgfw.efi
      #
      # Then replace REPLACE_ME below with that HD... device handle.
      # Example: efiDeviceHandle = "HD0d1";
      windows = {
        windows = {
          title = "Windows";
          efiDeviceHandle = "REPLACE_ME";
          sortKey = "y_windows";
        };
      };

      # Keep an EDK2 UEFI Shell available for finding the Windows EFI
      # device handle and for UEFI-level troubleshooting.
      edk2-uefi-shell = {
        enable = true;
        sortKey = "z_edk2";
      };
    };
  };

  # ---------------------------------------------------------------------------
  # Basic system settings
  # ---------------------------------------------------------------------------

  # Computer name visible on the local network and in the shell prompt.
  networking.hostName = "nixos";

  # NetworkManager handles Ethernet and Wi-Fi connections.
  networking.networkmanager.enable = true;

  # Moscow time zone.
  time.timeZone = "Europe/Moscow";

  # Allow proprietary packages such as the NVIDIA driver.
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.nvidia.acceptLicense = true;

  # Enable the modern Nix CLI and flakes.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # ---------------------------------------------------------------------------
  # Desktop: KDE Plasma 6
  # ---------------------------------------------------------------------------

  # Enable the X11 service required by the current Plasma/display-manager setup.
  services.xserver.enable = true;

  # Use the Ly display/login manager.
  services.displayManager.ly.enable = true;

  # Enable KDE Plasma 6.
  services.desktopManager.plasma6.enable = true;

  # NixOS documentation is disabled to keep the installed system smaller.
  documentation.nixos.enable = false;

  # Do not install the old XTerm package alongside Plasma.
  services.xserver.excludePackages = with pkgs; [
    xterm
  ];

  # Do not install KDE applications that are not used in this setup.
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    qrca          # QR-code scanner
    konsole       # Terminal emulator; Alacritty is used instead.
    discover      # KDE software center
    okular        # PDF/document viewer
    elisa         # Music player
    khelpcenter   # KDE help center
    gwenview      # Image viewer
  ];

  # JetBrains Mono Nerd Font is used by the shell/editor configuration.
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # ---------------------------------------------------------------------------
  # NVIDIA graphics
  # ---------------------------------------------------------------------------

  # The PC uses an NVIDIA RTX 5060 Ti, so use the regular modern NVIDIA driver.
  # Blackwell-era GPUs use the open NVIDIA kernel modules.
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    # Kernel modesetting is required/recommended for modern NVIDIA desktop setups.
    modesetting.enable = true;

    # RTX 5060 Ti is a modern GPU supported by NVIDIA's open kernel modules.
    open = true;

    # Leave the driver package unset so nixpkgs selects its current stable package.
  };

  # ---------------------------------------------------------------------------
  # Audio
  # ---------------------------------------------------------------------------

  # PipeWire provides modern Linux audio with PulseAudio compatibility.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # ---------------------------------------------------------------------------
  # User account
  # ---------------------------------------------------------------------------

  users.users.shinne = {
    isNormalUser = true;
    shell = pkgs.zsh;

    # wheel          -> sudo access
    # networkmanager -> manage network connections
    # input/uinput   -> applications that need input-device access
    extraGroups = [
      "wheel"
      "networkmanager"
      "input"
      "uinput"
    ];
  };

  # ---------------------------------------------------------------------------
  # Virtual machines
  # ---------------------------------------------------------------------------

  # Keep the current QEMU/libvirt setup enabled.
  virtualisation.libvirtd = {
    enable = true;

    # Software TPM support for virtual machines that need a TPM 2.0 device.
    qemu.swtpm.enable = true;
  };

  # Give the main user access to libvirt without requiring root every time.
  users.groups.libvirtd.members = [ "shinne" ];

  # GUI for managing QEMU/libvirt virtual machines.
  programs.virt-manager.enable = true;

  # Guest agent support for VMs where the agent is installed inside the guest.
  services.qemuGuest.enable = true;

  # Improved clipboard/display integration with SPICE guests.
  services.spice-vdagentd.enable = true;

  # Allow USB redirection to SPICE virtual machines.
  virtualisation.spiceUSBRedirection.enable = true;

  # ---------------------------------------------------------------------------
  # KDE Connect
  # ---------------------------------------------------------------------------

  # Enable KDE Connect for communication with Android/iOS devices.
  programs.kdeconnect.enable = true;

  # KDE Connect uses TCP/UDP ports 1714-1764.
  networking.firewall = {
    allowedTCPPortRanges = [
      { from = 1714; to = 1764; }
    ];
    allowedUDPPortRanges = [
      { from = 1714; to = 1764; }
    ];

    # Trust the libvirt bridge so virtual machines can communicate normally.
    trustedInterfaces = [ "virbr0" ];
  };

  # ---------------------------------------------------------------------------
  # Shell
  # ---------------------------------------------------------------------------

  # Enable Zsh system-wide; the actual shell configuration is in home.nix.
  programs.zsh.enable = true;

  # ---------------------------------------------------------------------------
  # Basic system utilities
  # ---------------------------------------------------------------------------

  environment.systemPackages = with pkgs; [
    vim             # Basic text editor available even before Home Manager loads.
    wget             # Command-line HTTP/HTTPS downloader.
    git              # Needed for cloning the configuration; Git identity is configured manually by the user.
    pciutils         # lspci and related hardware inspection tools.
    tree             # Directory tree viewer.
    dnsmasq          # Lightweight DNS/DHCP utility.
    xclip            # X11 clipboard integration for terminal applications.
  ];

  # ---------------------------------------------------------------------------
  # Running prebuilt/non-Nix binaries
  # ---------------------------------------------------------------------------

  # nix-ld helps unpackaged dynamically linked Linux binaries find their libraries.
  # programs.nix-ld.enable = true;
   # fontconfig
   # libxcb
   # libX11
   # libxrender
   # libXext
   # libxkbcommon
   # libGL
 # ];

  # ---------------------------------------------------------------------------
  # Throne
  # ---------------------------------------------------------------------------

  # Keep Throne enabled as in the original configuration.
  programs.throne.enable = true;

  # Enable TUN mode so Throne can route traffic through its virtual interface.
  programs.throne.tunMode.enable = true;

  # Allow FUSE mounts to be used with the "allow_other" option.
  programs.fuse.userAllowOther = true;

  # ---------------------------------------------------------------------------
  # System maintenance / logging
  # ---------------------------------------------------------------------------

  # Store only warning-level and more severe messages in journald.
  services.journald.settings.Journal.MaxLevelStore = "warning";

  # Enable nftables as the firewall backend.
  networking.nftables.enable = true;

  # This version is the initial state version for this configuration.
  # Do not change it just because nixpkgs is updated.
  system.stateVersion = "26.05";
}
