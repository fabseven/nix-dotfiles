{ config, lib, ... }: 

let
  wallpaper = ../digital.jpg;
in {
  home.file.".config/swaylock/config".text = ''
    daemonize
    font=JetBrains Mono
    color=1e1e2e
    bs-hl-color=f5e0dc
    caps-lock-bs-hl-color=f5e0dc
    caps-lock-key-hl-color=a6e3a1
    image=${wallpaper}
    scaling=fill
    inside-color=00000000
    inside-clear-color=00000000
    inside-caps-lock-color=00000000
    inside-ver-color=00000000
    inside-wrong-color=00000000
    key-hl-color=a6e3a1
    layout-bg-color=00000000
    layout-border-color=00000000
    layout-text-color=cdd6f4
    line-color=00000000
    line-clear-color=00000000
    line-caps-lock-color=00000000
    line-ver-color=00000000
    line-wrong-color=00000000
    ring-color=b4befe
    ring-clear-color=f5e0dc
    ring-caps-lock-color=fab387
    ring-ver-color=89b4fa
    ring-wrong-color=eba0ac
    separator-color=00000000
    text-color=cdd6f4
    text-clear-color=f5e0dc
    text-caps-lock-color=fab387
    text-ver-color=89b4fa
    text-wrong-color=eba0ac
  '';  
}
