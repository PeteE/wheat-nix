{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.wheat.zed-editor;
in
{
  options.wheat.zed-editor = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      extensions = [
        "nix"
        "toml"
        "rust"
        "python"
        "make"
        "just"
      ];
      userSettings = {
        hour_format = "hour24";
        auto_update = false;

        assistant = {
          enabled = true;
          version = "2";
          default_open_ai_model = null;
          # Provider options:
          # - zed.dev models (claude-3-5-sonnet-latest) requires GitHub connected
          # - anthropic models (claude-3-5-sonnet-latest, claude-3-haiku-latest, claude-3-opus-latest) requires API_KEY
          # - copilot_chat models (gpt-4o, gpt-4, gpt-3.5-turbo, o1-preview) requires GitHub connected
          default_model = {
            provider = "zed.dev";
            model = "claude-3-5-sonnet-latest";
          };

          # inline_alternatives = [
          #   {
          #     provider = "copilot_chat";
          #     model = "gpt-3.5-turbo";
          #   }
          # ];
        };

        node = {
          path = lib.getExe pkgs.nodejs_24;
          npm_path = lib.getExe' pkgs.nodejs "npm";
        };

        terminal = {
          alternate_scroll = "off";
          blinking = "off";
          copy_on_select = true;
          dock = "bottom";
          detect_venv = {
            on = {
              directories = [
                ".env"
                "env"
                ".venv"
                "venv"
              ];
              activate_script = "default";
            };
          };
          env = {
            TERM = "kitty";
          };
          font_family = "FiraCode Nerd Font";
          font_features = null;
          font_size = null;
          line_height = "comfortable";
          option_as_meta = false;
          button = false;
          shell = "system";
          # shell = {
          #   program = "zsh";
          # };
          toolbar = {
            title = true;
          };
          working_directory = "current_project_directory";
        };

        lsp = {
          rust-analyzer = {
            binary = {
              # path = lib.getExe pkgs.rust-analyzer;
              path_lookup = true;
            };
          };

          nix = {
            binary = {
              path_lookup = true;
            };
          };
        };

        languages = {
          # "HEEX" = {
          #   language_servers = [ "!lexical" "elixir-ls" "!next-ls" ];
          #   format_on_save = {
          #     external = {
          #       command = "mix";
          #       arguments = [ "format" "--stdin-filename" "{buffer_path}" "-" ];
          #     };
          #   };
          # };
        };

        vim_mode = true;

        # Tell Zed to use direnv and direnv can use a flake.nix environment
        load_direnv = "shell_hook";
        base_keymap = "VSCode";

        theme = {
          mode = "system";
          dark = "catppuccinn";
        };

        show_whitespaces = "all";
        ui_font_size = 16;
        buffer_font_size = 16;
      };
      # userSettings = {
      #   theme = {
      #     mode = "system";
      #     dark = "One Dark";
      #   };
      #   hour_format = "hour24";
      #   vim_mode = true;
      # };
    };
  };
}
