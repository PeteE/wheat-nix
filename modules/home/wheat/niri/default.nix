# vim: ts=2:sw=2:et
{
  lib,
  pkgs,
  config,
  options,
  ...
}:
with lib;
let
  cfg = config.wheat.niri;
  inherit (pkgs.stdenv) isDarwin;
  hasNiri = options ? programs && options.programs ? niri;
in
{
  options.wheat.niri = {
    enable = mkEnableOption "Enable niri window manager home configuration";
  };

  config = mkIf (cfg.enable && !isDarwin && hasNiri) (
    optionalAttrs hasNiri {
      programs.niri.settings = {
        input = {
          keyboard = {
            xkb = { };
            numlock = true;
          };
          touchpad = {
            tap = true;
            natural-scroll = false;
          };
          mouse = { };
          trackball = {
            natural-scroll = true;
            accel-speed = 0.2;
            accel-profile = "flat";
            middle-emulation = true;
          };
          trackpoint = { };
        };

        outputs."DP-1" = {
          scale = 1.0;
        };
        outputs."eDP-1" = {
          scale = 1.2;
        };
        layout = {
          gaps = 16;
          center-focused-column = "never";
          preset-column-widths = [
            { proportion = 0.33333; }
            { proportion = 0.5; }
            { proportion = 0.66667; }
          ];
          default-column-width = {
            proportion = 0.5;
          };
          focus-ring = {
            width = 4;
            active.color = "#7fc8ff";
            inactive.color = "#505050";
          };
          border = {
            enable = false;
            width = 4;
            active.color = "#ffc87f";
            inactive.color = "#505050";
            urgent.color = "#9b0000";
          };
          shadow = {
            enable = false;
          };
        };

        spawn-at-startup = [
          { command = [ "noctalia" ]; }
          { command = [ "xwayland-satellite" ]; }
          { command = [ "kitty" ]; }
        ];

        hotkey-overlay = {
          skip-at-startup = true;
        };

        screenshot-path = "~/scrot/screen-%Y%m%dT%H%M%SZ.png";

        animations.enable = false;

        window-rules = [
          {
            matches = [ { app-id = "^org\\.wezfurlong\\.wezterm$"; } ];
            default-column-width = { };
          }
          {
            matches = [
              {
                app-id = "firefox$";
                title = "^Picture-in-Picture$";
              }
            ];
            open-floating = true;
          }
          {
            matches = [ { app-id = "^thunar$"; } ];
            open-floating = true;
          }
          {
            matches = [ { app-id = "^zoom$"; } ];
            open-floating = true;
          }
          {
            matches = [ { app-id = "com\\.gabm\\.satty$"; } ];
            open-floating = true;
          }
          {
            geometry-corner-radius = {
              top-left = 12.0;
              top-right = 12.0;
              bottom-left = 12.0;
              bottom-right = 12.0;
            };
            clip-to-geometry = true;
          }
        ];

        binds = {
          "Mod+Shift+Slash".action.show-hotkey-overlay = { };
          "Mod+Return".action.spawn = "kitty";
          "Super+Alt+L".action.spawn = "swaylock";
          "Mod+Shift+Q".action.spawn = "thunar";
          "Mod+Shift+C".action.close-window = { };
          "Mod+Shift+A".action.spawn = "rofi-clipboard";
          "Mod+Shift+R".action.spawn = "rofi-launcher";
          "Super+Alt+S".action.spawn = [
            "sh"
            "-c"
            "pkill orca || exec orca"
          ];

          # Volume keys
          "XF86AudioRaiseVolume".action.spawn = [
            "sh"
            "-c"
            "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+"
          ];
          "XF86AudioLowerVolume".action.spawn = [
            "sh"
            "-c"
            "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"
          ];
          "XF86AudioMute".action.spawn = [
            "sh"
            "-c"
            "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ];
          "XF86AudioMicMute".action.spawn = [
            "sh"
            "-c"
            "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          ];

          # Brightness keys
          "XF86MonBrightnessUp".action.spawn = [
            "brightnessctl"
            "--class=backlight"
            "set"
            "+10%"
          ];
          "XF86MonBrightnessDown".action.spawn = [
            "brightnessctl"
            "--class=backlight"
            "set"
            "10%-"
          ];

          # Overview
          "Mod+O".action.toggle-overview = { };

          # Focus navigation
          "Mod+Left".action.focus-column-left = { };
          "Mod+Down".action.focus-window-down = { };
          "Mod+Up".action.focus-window-up = { };
          "Mod+Right".action.focus-column-right = { };
          "Mod+H".action.focus-column-left = { };
          "Mod+J".action.focus-window-down = { };
          "Mod+K".action.focus-window-up = { };
          "Mod+L".action.focus-column-right = { };

          # Move windows
          "Mod+Shift+Left".action.move-column-left = { };
          "Mod+Shift+Down".action.move-window-down = { };
          "Mod+Shift+Up".action.move-window-up = { };
          "Mod+Shift+Right".action.move-column-right = { };
          "Mod+Shift+H".action.move-column-left = { };
          "Mod+Shift+J".action.move-window-down = { };
          "Mod+Shift+K".action.move-window-up = { };
          "Mod+Shift+L".action.move-column-right = { };

          # Column navigation
          "Mod+Home".action.focus-column-first = { };
          "Mod+End".action.focus-column-last = { };
          "Mod+Ctrl+Home".action.move-column-to-first = { };
          "Mod+Ctrl+End".action.move-column-to-last = { };

          # Monitor navigation
          "Mod+Ctrl+Left".action.focus-monitor-left = { };
          "Mod+Ctrl+Down".action.focus-monitor-down = { };
          "Mod+Ctrl+Up".action.focus-monitor-up = { };
          "Mod+Ctrl+Right".action.focus-monitor-right = { };
          "Mod+Ctrl+H".action.focus-monitor-left = { };
          "Mod+Ctrl+J".action.focus-monitor-down = { };
          "Mod+Ctrl+K".action.focus-monitor-up = { };
          "Mod+Ctrl+L".action.focus-monitor-right = { };

          # Move to monitor
          "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = { };
          "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = { };
          "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = { };
          "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = { };
          "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = { };
          "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = { };
          "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = { };
          "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = { };

          # Workspace navigation
          "Mod+Page_Down".action.focus-workspace-down = { };
          "Mod+Page_Up".action.focus-workspace-up = { };
          "Mod+U".action.focus-workspace-down = { };
          "Mod+I".action.focus-workspace-up = { };
          "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = { };
          "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = { };
          "Mod+Ctrl+U".action.move-column-to-workspace-down = { };
          "Mod+Ctrl+I".action.move-column-to-workspace-up = { };

          # Move workspace
          "Mod+Shift+Page_Down".action.move-workspace-down = { };
          "Mod+Shift+Page_Up".action.move-workspace-up = { };
          "Mod+Shift+U".action.move-workspace-down = { };
          "Mod+Shift+I".action.move-workspace-up = { };

          # Mouse wheel bindings
          "Mod+WheelScrollDown".action.focus-workspace-down = { };
          "Mod+WheelScrollUp".action.focus-workspace-up = { };
          "Mod+Ctrl+WheelScrollDown".action.move-column-to-workspace-down = { };
          "Mod+Ctrl+WheelScrollUp".action.move-column-to-workspace-up = { };
          "Mod+WheelScrollRight".action.focus-column-right = { };
          "Mod+WheelScrollLeft".action.focus-column-left = { };
          "Mod+Ctrl+WheelScrollRight".action.move-column-right = { };
          "Mod+Ctrl+WheelScrollLeft".action.move-column-left = { };
          "Mod+Shift+WheelScrollDown".action.focus-column-right = { };
          "Mod+Shift+WheelScrollUp".action.focus-column-left = { };
          "Mod+Ctrl+Shift+WheelScrollDown".action.move-column-right = { };
          "Mod+Ctrl+Shift+WheelScrollUp".action.move-column-left = { };

          # Workspace by index
          "Mod+1".action.focus-workspace = 1;
          "Mod+2".action.focus-workspace = 2;
          "Mod+3".action.focus-workspace = 3;
          "Mod+4".action.focus-workspace = 4;
          "Mod+5".action.focus-workspace = 5;
          "Mod+6".action.focus-workspace = 6;
          "Mod+7".action.focus-workspace = 7;
          "Mod+8".action.focus-workspace = 8;
          "Mod+9".action.focus-workspace = 9;
          "Mod+Shift+1".action.move-column-to-workspace = 1;
          "Mod+Shift+2".action.move-column-to-workspace = 2;
          "Mod+Shift+3".action.move-column-to-workspace = 3;
          "Mod+Shift+4".action.move-column-to-workspace = 4;
          "Mod+Shift+5".action.move-column-to-workspace = 5;
          "Mod+Shift+6".action.move-column-to-workspace = 6;
          "Mod+Shift+7".action.move-column-to-workspace = 7;
          "Mod+Shift+8".action.move-column-to-workspace = 8;
          "Mod+Shift+9".action.move-column-to-workspace = 9;

          # Column management
          "Mod+BracketLeft".action.consume-or-expel-window-left = { };
          "Mod+BracketRight".action.consume-or-expel-window-right = { };
          "Mod+Comma".action.consume-window-into-column = { };
          "Mod+Period".action.expel-window-from-column = { };

          # Window sizing
          "Mod+R".action.switch-preset-column-width = { };
          "Mod+Ctrl+R".action.reset-window-height = { };
          "Mod+F".action.maximize-column = { };
          "Mod+Shift+F".action.fullscreen-window = { };
          "Mod+Ctrl+F".action.expand-column-to-available-width = { };
          "Mod+C".action.center-column = { };
          "Mod+Ctrl+C".action.center-visible-columns = { };
          "Mod+Minus".action.set-column-width = "-10%";
          "Mod+Equal".action.set-column-width = "+10%";
          "Mod+Shift+Minus".action.set-window-height = "-10%";
          "Mod+Shift+Equal".action.set-window-height = "+10%";

          # Floating
          "Mod+Ctrl+Space".action.toggle-window-floating = { };
          "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = { };

          # Tabbed
          "Mod+W".action.toggle-column-tabbed-display = { };

          # Screenshots
          "Mod+Shift+S".action.spawn = [
            "sh"
            "-c"
            ''grim -g "$(slurp -b '#00000080' -c '#17929980' -s '#ffffff10' -B '#ffffffff' -w 3 -d)" - | satty -f -''
          ];
          "Print".action.screenshot = { };
          "Ctrl+Print".action.screenshot-screen = { };
          "Alt+Print".action.screenshot-window = { };

          # System
          "Mod+Escape".action.toggle-keyboard-shortcuts-inhibit = { };
          "Mod+Shift+E".action.quit = { };
          "Ctrl+Alt+Delete".action.quit = { };
          "Mod+Shift+P".action.power-off-monitors = { };
        };
      };
    }
  );
}
