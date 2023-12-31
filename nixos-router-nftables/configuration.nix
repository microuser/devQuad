# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  WanDevice = "enp0s3";
  LanDevice = "enp0s10";
  BridgeDevice1 = "enp0s8";
  BridgeDevice2 = "enp0s9";
  LanStaticIp = "192.168.25.1";
  LanSubnet24 = "192.168.25";
  LanNetmask = "255.255.255.0";
  LanDns = "8.8.8.8";

in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.user = {
    isNormalUser = true;
    description = "user";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      kate
    #  thunderbird
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  zellij

  neovim
  geany
  kate
  brave
  git
  kgpg
  gpg-tui

  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?



  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
  };

  networking.hostName = "nixtable25";
  #networking.nameservers = "8.8.8.8";
  networking.firewall.enable = false;

  networking.interfaces = {
    "${WanDevice}".useDHCP = true;
    "${LanDevice}" = {
      useDHCP = false;
      ipv4.addresses = [{
        address = "${LanStaticIp}";
	prefixLength = 24;
      }];
    };
    "${BridgeDevice1}".useDHCP = false;
    "${BridgeDevice2}".useDHCP = false;
  };

  networking.nftables = {
    enable = true;
    ruleset = ''
      table ip filter {
        chain input {
          type filter hook input priority 0; policy drop;

          iifname { "${LanDevice}" } accept comment "Allow local LAN access to router"
          iifname "${WanDevice}" ct state { established, related } accept comment "Allow established traffic to return"
          iifname "${WanDevice}" icmp type { echo-request, destination-unreachable, time-exceeded } counter accept comment "Allow select ICMP"
          iifname "${WanDevice}" counter drop comment "Drop all other unsolicited traffic from WAN"
        }
        chain forward {
          type filter hook forward priority filter; policy drop;
          iifname { "${LanDevice}" } oifname { "${WanDevice}" } accept comment "Allow trusted LAN to WAN"
          iifname { "${WanDevice}" } oifname { "${LanDevice}" } ct state established, related accept comment "Allow estabished back to LAN"
        }
      }

      table ip nat {
        chain postrouting {
          type nat hook postrouting priority 100; policy accept;
          oifname "${WanDevice}}" masquerade
        }
      }

      table ip6 filter {
        chain input {
          type filter hook input priority 0; policy drop;
        }
        chain forward {
          type filter hook forward priority 0; policy drop;
        }
      }
    '';
  };


  services.dhcpd4 = {
    enable = true;
    interfaces = [ "${LanDevice}" ];
    extraConfig = ''
      subnet ${LanSubnet24}.0 netmask ${LanNetmask} {
        option routers = ${LanStaticIp};
        option domain-name-servers ${LanDns};
        option subnet-mask ${LanNetmask};
        interface ${LanDevice};
        range ${LanSubnet24}.10 ${LanSubnet24}.254;
      }
    '';
  };

}
