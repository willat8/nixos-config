{ pkgs, lib, options, inputs, ... }:

let
  jagex-launcher = inputs.jagex-launcher.packages.${pkgs.system}.default; 
in
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  networking.networkmanager.enable = true;
  
  time.timeZone = "Australia/Sydney";
  
  i18n.defaultLocale = "en_AU.UTF-8";
  
  hardware.graphics.enable = true;
  hardware.bluetooth.enable = true;
  
  users.users.will = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "input" "dialout" "networkmanager" "disk" "podman" ];
  };
  
  environment.systemPackages = with pkgs; [
    kubectl
    kubernetes-helm
    mutt
    git
    gphoto2fs
    texlive.combined.scheme-full
    alacritty
    waybar
    firefox
    fuzzel
    xwayland-satellite
    jagex-launcher
  ];
  
  environment.sessionVariables = rec {
    XDG_CACHE_HOME  = "\${HOME}/.cache";
    XDG_CONFIG_HOME = "\${HOME}/.config";
    XDG_BIN_HOME    = "\${HOME}/.local/bin";
    XDG_DATA_HOME   = "\${HOME}/.local/share";
  
    PATH = [
      "\${HOME}/.local/bin"
    ];
  
    HISTSIZE = "";
    HISTFILESIZE = "";

    _JAVA_AWT_WM_NONREPARENTING="1";
  };
  
  programs.niri.enable = true;
  
  programs.vim.enable = true;
  programs.vim.defaultEditor = true;
  
  services.dbus.enable = true;
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  nixpkgs.overlays = [
    (final: prev: {
      gphoto2fs = prev.gphoto2fs.overrideAttrs (old: {
       src = pkgs.fetchFromGitHub {
         owner = "willat8";
         repo = "gphotofs";
         rev = "lumix";
         sha256 = "JrLXIPY5DQfzWqIscxskzgmgBXVoaE43cvpQkRk4CCw=";
        };
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.autoreconfHook ];
      });
    })
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: pkg.pname == jagex-launcher.pname;
  
  virtualisation.podman.enable = true;
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  boot.binfmt.preferStaticEmulators = true;
  
  system.stateVersion = "22.05";
}
