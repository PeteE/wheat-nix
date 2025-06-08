# vim: ts=2:sw=2:et
{ pkgs, home, ... }:
{
  programs.kitty = {
    enable = true;
    #font = {
    #  name = "Fira Code";
    #  size = 10.0;
    #};
    theme = "Catppuccin-Mocha";
    settings = {
      cursor_shape = "underline";
      strip_trailing_spaces = "smart";
      copy_on_select = "yes";
      enable_audio_bell = "no";
      disable_ligatures = "cursor";
      cursor_blink_interval = 0;
      dynamic_background_opacity = "no";
      background_opacity = "0.9";
    };
  };

  home.packages = with pkgs; [
    kitty-themes
  ];
}
