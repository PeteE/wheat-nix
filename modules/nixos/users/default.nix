 {
    lib,
    pkgs,
    inputs,
    namespace, # The namespace used for your flake, defaulting to "internal" if not set.
    system, # The system architecture for this host (eg. `x86_64-linux`).
    target, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
    format, # A normalized name for the system target (eg. `iso`).
    virtual, # A boolean to determine whether this system is a virtual target using nixos-generators.
    systems, # An attribute map of your defined hosts.
    config,
    ...
}:
{
  users.users.petee = {
    isNormalUser = true;
    description = "petee";
    shell = pkgs.zsh;
    hashedPassword = "$y$j9T$u3UjEvsXkdk4AxzFSYg7L0$1Yg9xzafdDTg/BAZKtzXngrpaVrxUk9nkGcKBRax9Y/";
    group = "petee";
    extraGroups = [
      "wheel"
    ];
  };
  users.groups.petee = {};

  environment.systemPackages = with pkgs; [
    catppuccin-gtk
  ];

  programs.zsh.enable = true;
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  security.rtkit.enable = true;
  security.polkit.enable = true;

  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  services.gnome.gnome-keyring.enable = true;
  services.printing.enable = true;
  services.libinput.enable = true;
  services.tailscale.enable = true;
  services.openssh.enable = true;
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  networking.firewall.enable = false;

  system.stateVersion = "25.11"; # Did you read the comment?
}
