# vim: ts=2:sw=2:et
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
with lib; let
  cfg = config.wheat.nushell;
in {
  options.wheat.nushell = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nufmt
      skim
      nushell
    ];
    programs.carapace = {
      enable = true;
      enableNushellIntegration = true;
    };
    programs.nushell = {
      enable = true;
      plugins = with pkgs; [
        nushellPlugins.skim
        nushellPlugins.query
        nushellPlugins.polars
        nushellPlugins.highlight
        nushellPlugins.hcl
        nushellPlugins.units
        nushellPlugins.query
      ];
      settings = {
        edit_mode = "vi";
        buffer_editor = "nvim";
        history = {
          file_format = "sqlite";
          max_size = 10000000;
        };
        show_banner = false;
        completions = {
        };
      };
      extraConfig = ''
         let carapace_completer = {|spans|
           carapace $spans.0 nushell ...$spans | from json
         }
         $env.config = {
          completions: {
            case_sensitive: false # case-sensitive completions
            quick: true    # set to false to prevent auto-selecting completions
            partial: true    # set to false to prevent partial filling of the prompt
            algorithm: "fuzzy"    # prefix or fuzzy
            external: {
            # set to false to prevent nushell looking into $env.PATH to find more suggestions
                enable: false
            # set to lower can improve completion performance at the cost of omitting some options
                max_results: 100
                completer: $carapace_completer # check 'carapace_completer'
            }
          }
         }
         $env.PATH = (
           $env.PATH |
           split row (char esep) |
           append /usr/bin/env
         )
      '';
    };
  };
}
