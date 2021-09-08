{ config, lib, pkgs, ... }:
with lib;
let cfg = config.services.kubernetes;
in {
  options.services.kubernetes = {
    enable = mkEnableOption "Kubernetes";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      minikube
      kubernetes-helm
      kubectl
    ];
  };
}
