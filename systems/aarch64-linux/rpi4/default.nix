{
    lib,
    pkgs,
    inputs,
    namespace,
    system,
    target,
    format,
    virtual,
    systems,
    config,
    modulesPath,
    ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (../../../modules/shared/wheat/default.nix)
  ];
  fileSystems = { 
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };
  swapDevices = [ ];

  boot.kernelPackages = pkgs.linuxPackages_rpi4;
  boot.initrd.allowMissingModules = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "usbhid" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.useDHCP = lib.mkDefault true;
  networking.nameservers = [ "127.0.0.1" ];
  networking.firewall.enable = false;
  networking.hostName = "rpi4";
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  time.timeZone = "America/Chicago";

  wheat = {
    enable = true;
    user = {
      name = "petee";
      hashedPassword = "$y$j9T$ysACyCk2sIkE4gjt8JfgK0$ZS1H7jaFrrMbZj1QGX2xm/omN8rGAwl6cAcZbfKQykC";
      extraGroups = [
        "wheel"
        "NetworkManager"
        "dialout"
      ];
    };
    sudo.enable = true;
    wifi.enable = true;

    # SPIRE Server - primary identity provider for wheat-dn42.net
    services.spire = {
      enable = true;
      trustDomain = "wheat-dn42.net";
      server = {
        enable = true;
        bindAddress = "0.0.0.0";
        jwtIssuer = "https://oidc.wheat-dn42.net";
        jwtKeyType = "rsa-2048";  # Azure AD requires RSA (doesn't support EC)
        x509pop = {
          enable = true;
          caBundlePath = "/etc/spire/x509pop-ca-bundle.pem";
        };
        oidcDiscovery = {
          enable = true;
          domain = "oidc.wheat-dn42.net";
          bindPort = 8082;
          healthPort = 8083;
        };
        federation = {
          enable = true;
          bundleEndpoint.port = 8444;  # 8443 is used by Caddy
        };
      };
      agent = {
        enable = true;
        serverAddress = "localhost";
        insecureBootstrap = true;
        x509pop = {
          enable = true;
          privateKeyPath = config.sops.secrets."spire/nodes/rpi4/key".path;
          certificatePath = "/etc/spire/rpi4-cert.pem";
        };
      };
    };

    # Kanidm - user identity provider (OIDC, LDAP)
    services.kanidm = {
      enable = true;
      domain = "idp.wheat-dn42.net";
      bindAddress = "127.0.0.1";
      bindPort = 8445;
      adminPasswordFile = config.sops.secrets."kanidm/admin-password".path;
      idmAdminPasswordFile = config.sops.secrets."kanidm/idm-admin-password".path;

      provision = {
        enable = true;
        groups = {
          homelab-users = {};
          homelab-admins = { members = [ "petee" ]; };
        };
        persons = {
          petee = {
            displayName = "Pete Erickson";
            mailAddresses = [ "pete.perickson@gmail.com" ];
            groups = [ "homelab-users" "homelab-admins" ];
          };
        };
      };
    };
  };
  # Tailscale subnet router and exit node for home network
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";  # enables IP forwarding
    extraUpFlags = [
      "--advertise-routes=192.168.1.0/24"
      "--advertise-exit-node"
    ];
  };

  # SPIRE x509pop CA certificate for node attestation
  environment.etc."spire/x509pop-ca-bundle.pem" = {
    source = ../../x86_64-linux/x1/spire-x509pop-ca.pem;
    mode = "0644";
  };

  # SOPS secrets for SPIRE node credentials
  sops.defaultSopsFile = ../../../modules/home/wheat/secrets/secrets.yaml;
  sops.secrets."spire/nodes/rpi4/key" = {
    mode = "0400";
  };
  sops.secrets."spire/nodes/rpi4/cert" = {
    mode = "0444";
    path = "/etc/spire/rpi4-cert.pem";
  };

  # Kanidm admin passwords
  sops.secrets."kanidm/admin-password" = {
    mode = "0400";
    owner = "kanidm";
  };
  sops.secrets."kanidm/idm-admin-password" = {
    mode = "0400";
    owner = "kanidm";
  };

  # Ensure SPIRE services start after sops secrets are decrypted
  systemd.services.spire-agent.after = [ "sops-nix.service" ];
  systemd.services.spire-agent.wants = [ "sops-nix.service" ];

  # Ensure Kanidm starts after sops secrets are decrypted
  systemd.services.kanidm.after = [ "sops-nix.service" ];
  systemd.services.kanidm.wants = [ "sops-nix.service" ];

  # Cloudflare Dynamic DNS
  sops.age.keyFile = "/home/petee/.config/sops/age/keys.txt";
  wheat.services.cloudflare-dyndns = {
    enable = true;
    domains = [
      "wheat-dn42.net"
      "edge-public.wheat-dn42.net"
    ];
    frequency = "*:0/5";  # every 5 minutes
    ipv4 = true;
    ipv6 = false;
    proxied = false;
  };

  # Caddy reverse proxy with TCP passthrough to K8s ingress
  wheat.services.caddy = {
    enable = true;
    email = "pete.perickson@gmail.com";
    defaultUpstream = "192.168.1.245";
    virtualHosts = {
      "adguard.wheat-dn42.net" = {
        upstream = "localhost:3000";
      };
      "oidc.wheat-dn42.net" = {
        upstream = "localhost:8082";
      };
      "oidc-discovery.op3.wheat-dn42.net" = {
        upstream = "192.168.1.40:443";
        upstreamScheme = "https";
        upstreamTlsInsecure = true;  # SPIRE uses SPIFFE certs, not web PKI
      };
      "spire-bundle.wheat-dn42.net" = {
        upstream = "localhost:8444";
        upstreamScheme = "https";
        upstreamTlsInsecure = true;  # SPIRE uses SPIFFE certs, not web PKI
      };
      "idp.wheat-dn42.net" = {
        upstream = "localhost:8445";
        upstreamScheme = "https";
        upstreamTlsInsecure = true;  # Kanidm uses self-signed cert internally
      };
    };
  };

  # AdGuard Home DNS ad blocker
  wheat.services.adguardhome = {
    enable = true;
    port = 3000;  # web UI
    dnsPort = 53;
    openFirewall = true;
    mutableSettings = true;
    dnsRewrites = [
      # App infrastructure (K8s ingress)
      { domain = "adguard.wheat-dn42.net"; answer = "192.168.1.173"; }
      { domain = "unifi.wheat-dn42.net"; answer = "192.168.1.245"; }
      { domain = "hs.wheat-dn42.net"; answer = "192.168.1.245"; }
      { domain = "reg.wheat-dn42.net"; answer = "192.168.1.245"; }
      { domain = "authentik.wheat-dn42.net"; answer = "192.168.1.245"; }
      { domain = "s3.wheat-dn42.net"; answer = "192.168.1.245"; }
      { domain = "idp.wheat-dn42.net"; answer = "192.168.1.173"; }  # rpi4 - Kanidm
      { domain = "oidc-discovery.op3.wheat-dn42.net"; answer = "192.168.1.40"; }  # Gateway on wheat-k3s cluster
      # Automation
      { domain = "mqtt.wheat-dn42.net"; answer = "192.168.1.245"; }
      # Media
      { domain = "overseerr.wheat-dn42.net"; answer = "192.168.1.245"; }
      # Apps
      { domain = "hastebin.wheat-dn42.net"; answer = "192.168.1.245"; }
      # SPIRE federation (k8s cluster bundle endpoint)
      { domain = "spire-bundle-k8s.wheat-dn42.net"; answer = "192.168.1.245"; }
      { domain = "spire-bundle.wheat-dn42.net"; answer = "192.168.1.173"; }
      # Local network
      { domain = "gw"; answer = "192.168.1.33"; }
      { domain = "freenas.wheat-dn42.net"; answer = "192.168.1.120"; }
      { domain = "nas.wheat-dn42.net"; answer = "192.168.1.120"; }
      { domain = "nas"; answer = "192.168.1.120"; }
      { domain = "hv"; answer = "192.168.1.50"; }
      { domain = "ripper"; answer = "192.168.1.51"; }
    ];
  };

  environment.systemPackages = with pkgs; [
    nodejs_24
    gnumake
    glibc
    cmake
  ];
  system.stateVersion = "25.11";
  nix.settings.trusted-users = [ "root" "petee" "pete" ];
  # nix.settings.substituters = [ "https://nix-cache-dev.corp.tooling.opaque-int.com/opaque" ];
}
