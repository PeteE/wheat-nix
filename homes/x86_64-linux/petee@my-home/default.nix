{
    # Snowfall Lib provides a customized `lib` instance with access to your flake's library
    # as well as the libraries available from your flake's inputs.
    lib,
    # An instance of `pkgs` with your overlays and packages applied is also available.
    pkgs,
    # You also have access to your flake's inputs.
    inputs,

    # Additional metadata is provided by Snowfall Lib.
    namespace, # The namespace used for your flake, defaulting to "internal" if not set.
    home, # The home architecture for this host (eg. `x86_64-linux`).
    target, # The Snowfall Lib target for this home (eg. `x86_64-home`).
    format, # A normalized name for the home target (eg. `home`).
    virtual, # A boolean to determine whether this home is a virtual target using nixos-generators.
    host, # The host name for this home.

    # All other arguments come from the home home.
    config,
    ...
}:
{
    # Your configuration.
}
{
    lib,
    pkgs,
    inputs,
    namespace,
    home,
    target,
    format,
    virtual,
    host,
    config,
    ...
}:
{
  # home.packages = with pkgs; [
  #   fasd
  #   zoxide
  #   xdotool
  #   tmux-fingers
  #   azure-storage-azcopy
  #   openbao
  #   usql
  #   presenterm
  #   kubectx
  #   asciinema
  #   cargo
  #   just
  #   postgresql_13
  #   oras
  #   git-credential-manager
  #   fd
  #   nodejs_22
  #   uv
  #   thumbs
  #   podman
  #   skopeo
  #   openssl
  #   # attic-server
  #   attic-client
  #   # clusterctl
  #   github-cli
  #   # mpv
  #   # clapper
  #   # nitrogen
  #   bc
  #   pinentry-rofi
  #   yazi
  #   niv
  #   nix-index
  #   devspace
  #   openvpn3
  #   lua5_3
  #   stylua
  #   firefox
  #   kubectl
  #   kubernetes-helm
  #   docker
  #   yadm
  #   ipcalc
  #   wireshark
  #   yq-go
  #   glow
  #   aria2
  #   nix-output-monitor
  #   lazygit
  #   nodePackages.eslint
  #   lua-language-server
  #   nixd
  #   rust-analyzer
  #   helm-ls
  #   yaml-language-server
  #   # python312Packages.jedi-language-server
  #   pyright
  # ];
  #
  # programs.firefox.enable = true;
  #
  # programs.awscli = {
  #   enable = true;
  #   settings = {
  #     "default" = {
  #       region = "us-east-1";
  #       # credential_process = "${pkgs.pass}/bin/pass show aws";  # TODO -would be nice
  #     };
  #   };
  # };
  # programs.rbw = {
  #   enable = true;
  #   settings = {
  #     email = "pete.perickson@gmail.com";
  #     base_url = "https://vault.wheat-dn42.net";
  #     pinentry = pkgs.pinentry-curses;
  #   };
  # };
  # programs.btop = {
  #   enable = true;
  #   settings = {
  #     # net_iface = "enp1s0";
  #     color_theme = "catppuccin_mocha";
  #     vim_keys = true;
  #     proc_sorting = "cpu responsive";
  #   };
  # };
  #
  # xdg.configFile."btop/themes/catppuccin_mocha.theme".text = ''
  #   # Main background, empty for terminal default, need to be empty if you want transparent background
  #   theme[main_bg]="#1E1E2E"
  #
  #   # Main text color
  #   theme[main_fg]="#CDD6F4"
  #
  #   # Title color for boxes
  #   theme[title]="#CDD6F4"
  #
  #   # Highlight color for keyboard shortcuts
  #   theme[hi_fg]="#89B4FA"
  #
  #   # Background color of selected item in processes box
  #   theme[selected_bg]="#45475A"
  #
  #   # Foreground color of selected item in processes box
  #   theme[selected_fg]="#89B4FA"
  #
  #   # Color of inactive/disabled text
  #   theme[inactive_fg]="#7F849C"
  #
  #   # Color of text appearing on top of graphs, i.e uptime and current network graph scaling
  #   theme[graph_text]="#F5E0DC"
  #
  #   # Background color of the percentage meters
  #   theme[meter_bg]="#45475A"
  #
  #   # Misc colors for processes box including mini cpu graphs, details memory graph and details status text
  #   theme[proc_misc]="#F5E0DC"
  #
  #   # CPU, Memory, Network, Proc bppox outline colors
  #   theme[cpu_box]="#cba6f7" #Mauve
  #   theme[mem_box]="#a6e3a1" #Green
  #   theme[net_box]="#eba0ac" #Maroon
  #   theme[proc_box]="#89b4fa" #Blue
  #
  #   # Box divider line and small boxes line color
  #   theme[div_line]="#6C7086"
  #
  #   # Temperature graph color (Green -> Yellow -> Red)
  #   theme[temp_start]="#a6e3a1"
  #   theme[temp_mid]="#f9e2af"
  #   theme[temp_end]="#f38ba8"
  #
  #   # CPU graph colors (Teal -> Lavender)
  #   theme[cpu_start]="#94e2d5"
  #   theme[cpu_mid]="#74c7ec"
  #   theme[cpu_end]="#b4befe"
  #
  #   # Mem/Disk free meter (Mauve -> Lavender -> Blue)
  #   theme[free_start]="#cba6f7"
  #   theme[free_mid]="#b4befe"
  #   theme[free_end]="#89b4fa"
  #
  #   # Mem/Disk cached meter (Sapphire -> Lavender)
  #   theme[cached_start]="#74c7ec"
  #   theme[cached_mid]="#89b4fa"
  #   theme[cached_end]="#b4befe"
  #
  #   # Mem/Disk available meter (Peach -> Red)
  #   theme[available_start]="#fab387"
  #   theme[available_mid]="#eba0ac"
  #   theme[available_end]="#f38ba8"
  #
  #   # Mem/Disk used meter (Green -> Sky)
  #   theme[used_start]="#a6e3a1"
  #   theme[used_mid]="#94e2d5"
  #   theme[used_end]="#89dceb"
  #
  #   # Download graph colors (Peach -> Red)
  #   theme[download_start]="#fab387"
  #   theme[download_mid]="#eba0ac"
  #   theme[download_end]="#f38ba8"
  #
  #   # Upload graph colors (Green -> Sky)
  #   theme[upload_start]="#a6e3a1"
  #   theme[upload_mid]="#94e2d5"
  #   theme[upload_end]="#89dceb"
  #
  #   # Process box color gradient for threads, mem and cpu usage (Sapphire -> Mauve)
  #   theme[process_start]="#74C7EC"
  #   theme[process_mid]="#89DCEB"
  #   theme[process_end]="#cba6f7"
  # '';
  # home.programs.fzf = {
  #   enable = true;
  #   enableZshIntegration = true;
  #   defaultCommand = "${pkgs.ripgrep}/bin/rg --hidden";
  #   colors = { };
  # };
  # home.programs.zsh = {
  #   initExtraBeforeCompInit = ''
  #     # catppuccin theme for fzf
  #     export FZF_DEFAULT_OPTS=" \
  #       --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
  #       --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
  #       --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
  #   '';
  #   initExtra = ''
  #     export FZF_CTRL_R_OPTS="--preview 'echo {} |sed -e \"s/^ *\([0-9]*\) *//\" -e \"s/.\{$COLUMNS\}/&\n/g\"' --preview-window down:3"
  #   '';
  # };
  # programs.k9s = {
  #   enable = true;
  #   # plugin = {
  #   #   kubeshark = {
  #   #     shortCut = "F1";
  #   #     description = "kubeshark";
  #   #     scopes:
  #   #   };
  #   # };
  #   aliases = {
  #     aliases = {
  #       ds = "daemonset";
  #       dp = "deployment";
  #       sec = "secret";
  #       jo = "job";
  #       cr = "clusterroles";
  #       crb = "clusterrolebindings";
  #       ro = "roles";
  #       rb = "rolebindings";
  #       np = "networkpolicies";
  #     };
  #   };
  #   settings = {
  #     k9s = {
  #       refreshRate = 2;
  #       ui = {
  #         headless = true;
  #         logoless = true;
  #       };
  #       skipLatestRevCheck = true;
  #       logger = {
  #         tail = 100;
  #         buffer = 5000;
  #         fullScreen = true;
  #         textWrap = true;
  #       };
  #     };
  #   };
  # };
  # programs.kitty = {
  #   enable = true;
  #   font = {
  #     name = "Fira Code";
  #     size = 10.0;
  #   };
  #   theme = "Catppuccin-Mocha";
  #   settings = {
  #     cursor_shape = "underline";
  #     strip_trailing_spaces = "smart";
  #     copy_on_select = "yes";
  #     enable_audio_bell = "no";
  #     disable_ligatures = "cursor";
  #     cursor_blink_interval = 0;
  #     dynamic_background_opacity = "no";
  #     background_opacity = "0.9";
  #   };
  # };
  #
  # programs.zsh.shellAliases = {
  #   v = "nvim";
  #   vi = "nvim";
  #   vim = "nvim";
  # };
  # programs.neovim = {
  #   enable = true;
  #   defaultEditor = true;
  #   plugins = with pkgs.vimPlugins; [
  #     {
  #       plugin = nvim-surround;
  #       type = "lua";
  #       config = ''
  #         require('nvim-surround').setup({ })
  #       '';
  #     }
  #     {
  #       plugin = workspaces-nvim;
  #       type = "lua";
  #     }
  #     {
  #       plugin = cmp-fuzzy-path;
  #       type = "lua";
  #     }
  #     {
  #       plugin = cmp-fuzzy-buffer;
  #       type = "lua";
  #     }
  #     {
  #       plugin = mini-nvim;
  #       type = "lua";
  #     }
  #     {
  #       plugin = CopilotChat-nvim;
  #       type = "lua";
  #     }
  #     {
  #       plugin = copilot-lua;
  #       type = "lua";
  #     }
  #     {
  #       plugin = copilot-lualine;
  #       type = "lua";
  #     }
  #     {
  #       plugin = snacks-nvim;
  #       type = "lua";
  #     }
  #     {
  #       plugin = markview-nvim;
  #       type = "lua";
  #       config = ''
  #         require("markview.extras.checkboxes").setup();
  #         require("markview.extras.headings").setup();
  #         require("markview.extras.editor").setup();
  #       '';
  #     }
  #     {
  #       plugin = vim-terraform;
  #       type = "lua";
  #       config = ''
  #         vim.cmd([[silent! autocmd! filetypedetect BufRead,BufNewFile *.tf]])
  #         vim.cmd([[autocmd BufRead,BufNewFile *.hcl set filetype=hcl]])
  #         vim.cmd([[autocmd BufRead,BufNewFile .terraformrc,terraform.rc set filetype=hcl]])
  #         vim.cmd([[autocmd BufRead,BufNewFile *.tf,*.tfvars set filetype=terraform]])
  #         vim.cmd([[autocmd BufRead,BufNewFile *.tfstate,*.tfstate.backup set filetype=json]])
  #
  #         vim.cmd([[let g:terraform_fmt_on_save=1]])
  #         vim.cmd([[let g:terraform_align=1]])
  #       '';
  #     }
  #     {
  #       plugin = kulala-nvim;
  #       type = "lua";
  #     }
  #     {
  #       plugin = yaml-companion-nvim;
  #       type = "lua";
  #       config = ''
  #       '';
  #     }
  #     # markdown-preview-nvim
  #     vim-commentary
  #     vim-unimpaired
  #     vim-repeat
  #     vim-go
  #     vim-tmux-navigator
  #     supertab
  #     cmp-nvim-lsp
  #     cmp-buffer
  #     cmp-path
  #     cmp-cmdline
  #     cmp-tmux
  #     cmp-git
  #     vim-python-pep8-indent
  #     nvim-treesitter.withAllGrammars
  #     nvim-treesitter-parsers.just
  #     nvim-treesitter-parsers.rust
  #     rustaceanvim
  #     nvim-dap
  #     undotree
  #     zoxide-vim
  #     telescope-vim-bookmarks-nvim
  #     telescope-symbols-nvim
  #     vim-fugitive
  #     vim-tmux-navigator
  #     vim-terminator     # execute shell commands
  #     fzf-lsp-nvim
  #     telescope-zoxide
  #     lazy-nvim
  #     vim-helm
  #     vim-indentwise
  #     {
  #       plugin = lazygit-nvim;
  #       type = "lua";
  #       config = ''
  #         require('telescope').load_extension('lazygit')
  #         vim.keymap.set('n', '<space>gg', '<cmd>LazyGit<CR>')
  #         vim.keymap.set('n', '<space>dw', "<cmd>lua require('telescope').extensions.lazygit.lazygit()<CR>")
  #       '';
  #     }
  #     {
  #       plugin = lualine-nvim;
  #       type = "lua";
  #       config = ''
  #         require('lualine').setup(
  #           {
  #             theme = 'onedark',
  #             -- TODO: - needs rework
  #             -- sections = {
  #             --   lualine_c = {
  #             --     'lsp_progress',
  #             --   },
  #             --   lualine_x = {
  #             --     'filename',
  #             --   }
  #             -- },
  #           }
  #         )
  #       '';
  #
  #     }
  #     {
  #       plugin = dashboard-nvim;
  #       type = "lua";
  #     }
  #     {
  #       plugin = persistence-nvim;
  #       type = "lua";
  #     }
  #     # {
  #     #   plugin = lualine-lsp-progress;
  #     # }
  #     {
  #       plugin = catppuccin-nvim;
  #       config = ''
  #         colorscheme catppuccin-mocha
  #       '';
  #     }
  #     {
  #       plugin = nvim-lspconfig;
  #       type = "lua";
  #       config = ''
  #         require('lspconfig').lua_ls.setup({
  #           capabilities = require('cmp_nvim_lsp').default_capabilities()
  #         })
  #         require('lspconfig').nixd.setup({})
  #         require('lspconfig').terraformls.setup({})
  #         require('lspconfig').tflint.setup({})
  #       '';
  #     }
  #     {
  #       plugin = diaglist-nvim;
  #       type = "lua";
  #       config = ''
  #         require("diaglist").init({
  #           debug = false,
  #           -- increase for noisy servers
  #           debounce_ms = 50,
  #         })
  #         vim.keymap.set("n", "<space>dw", "<cmd>lua require('diaglist').open_all_diagnostics()<cr>")
  #         vim.keymap.set("n", "<space>d0", "<cmd>lua require('diaglist').open_all_diagnostics()<cr>")
  #       '';
  #     }
  #     # {
  #     #   plugin = jedi-vim;
  #     #   type = "lua";
  #     #   config = ''
  #     #     require('lspconfig').jedi_language_server.setup({
  #     #       capabilities = require('cmp_nvim_lsp').default_capabilities()
  #     #     })
  #     #   '';
  #     # }
  #     {
  #       plugin = nvim-cmp;
  #       type = "lua";
  #       config = ''
  #         local cmp = require('cmp')
  #         cmp.setup({
  #           window = {
  #             completion = cmp.config.window.bordered(),
  #             documentation = cmp.config.window.bordered(),
  #           },
  #           mapping = cmp.mapping.preset.insert({
  #             ['<C-b>'] = cmp.mapping.scroll_docs(-4),
  #             ['<C-f>'] = cmp.mapping.scroll_docs(4),
  #             ['<C-Space>'] = cmp.mapping.complete(),
  #             ['<C-e>'] = cmp.mapping.abort(),
  #             ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  #           }),
  #           matching = {
  #             disallow_fuzzy_matching = false,
  #           },
  #           sources = cmp.config.sources(
  #             {
  #               { name = 'nvim_lsp' },
  #             },
  #             {
  #               { name = 'fuzzy_buffer' }
  #             }
  #           )
  #         })
  #
  #         -- Set configuration for specific filetype.
  #         cmp.setup.filetype('gitcommit', {
  #           sources = cmp.config.sources(
  #             {
  #               { name = 'git' },
  #             },
  #             {
  #               { name = 'fuzzy_buffer' },
  #             }
  #           )
  #         })
  #
  #         cmp.setup.filetype('yaml', {
  #           sources = cmp.config.sources(
  #             {
  #               { name = 'nvim_lsp' },
  #             },
  #             {
  #               { name = 'git' },
  #             }, {
  #               { name = 'fuzzy_buffer' },
  #             }
  #           )
  #         })
  #         cmp.setup.filetype('py', {
  #           sources = cmp.config.sources(
  #             {
  #               { name = 'nvim_lsp' },
  #             },
  #             {
  #               { name = 'fuzzy_buffer' },
  #             }
  #           )
  #         })
  #
  #
  #         -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
  #         cmp.setup.cmdline({ '/', '?' }, {
  #           mapping = cmp.mapping.preset.cmdline(),
  #           sources = {
  #             { name = 'fuzzy_buffer' }
  #           }
  #         })
  #
  #         -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  #         cmp.setup.cmdline(':', {
  #           mapping = cmp.mapping.preset.cmdline(),
  #           sources = cmp.config.sources(
  #            {
  #              { name = 'fuzzy_path' }
  #            },
  #            {
  #             { name = 'cmdline' }
  #            }
  #           )
  #         })
  #       '';
  #     }
  #     {
  #       plugin = trouble-nvim;
  #       type = "lua";
  #       config = ''
  #         vim.keymap.set("n", "<space>t", "<cmd>TroubleToggle<CR>")
  #       '';
  #     }
  #     {
  #       plugin = telescope-nvim;
  #       type = "lua";
  #     }
  #     {
  #       plugin = telescope-fzf-native-nvim;
  #       type = "lua";
  #       config = ''
  #         require('telescope').load_extension('fzf')
  #       '';
  #
  #     }
  #     {
  #       plugin = telescope-file-browser-nvim;
  #       type = "lua";
  #       config = ''
  #         -- require('telescope').load_extension('file_browser')
  #         -- vim.keymap.set("n", "<space>f", "<cmd>Telescope file_browser select_buffer=true<CR>")
  #       '';
  #     }
  #     {
  #       plugin = telescope-undo-nvim;
  #       type = "lua";
  #       config = ''
  #         require('telescope').load_extension('undo')
  #         vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<CR>")
  #       '';
  #     }
  #     {
  #        plugin = fzf-lua;
  #        type = "lua";
  #        config = ''
  #          require("fzf-lua").setup({ "fzf-vim" })
  #        '';
  #     }
  #     {
  #       plugin = lspkind-nvim;
  #       type = "lua";
  #       config = ''
  #         local lspkind = require('lspkind')
  #         cmp.setup {
  #           formatting = {
  #             format = lspkind.cmp_format({
  #               mode = 'symbol_text', -- show only symbol annotations
  #               maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
  #                              -- can also be a function to dynamically calculate max width such as
  #                              -- maxwidth = function() return math.floor(0.45 * vim.o.columns) end,
  #               ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
  #               show_labelDetails = true, -- show labelDetails in menu. Disabled by default
  #
  #               -- The function below will be called before any actual modifications from lspkind
  #               -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
  #               -- before = function (entry, vim_item)
  #               --  ...
  #               --  return vim_item
  #               --end
  #             })
  #           }
  #         }
  #       '';
  #     }
  #     {
  #       plugin = nvim-tree-lua;
  #       type = "lua";
  #       config = ''
  #         require("nvim-tree").setup()
  #       '';
  #     }
  #     nvim-web-devicons
  #     # {
  #     #   plugin = null-ls-nvim;
  #     #   type = "lua";
  #     #   # config = ''
  #     #   #   local null_ls = require("null-ls")
  #     #   #   null_ls.setup({
  #     #   #       sources = {
  #     #   #           null_ls.builtins.formatting.stylua,
  #     #   #           null_ls.builtins.diagnostics.eslint,
  #     #   #           null_ls.builtins.completion.spell,
  #     #   #       },
  #     #   #   })
  #     #   # '';
  #     # }
  #     {
  #       plugin = vim-gitgutter;
  #       config = ''
  #         let g:gitgutter_enabled=1
  #         let g:gitgutter_terminal_reports_focus=0
  #         let g:gitgutter_grep = 'rg'
  #         let g:gitgutter_map_keys = 1
  #         highlight GitGutterAdd    guifg=#a6e3a1 ctermfg=2
  #         highlight GitGutterChange guifg=#fab387 ctermfg=3
  #         highlight GitGutterDelete guifg=#f38ba8 ctermfg=1
  #       '';
  #     }
  #     {
  #       plugin = vim-better-whitespace;
  #     }
  #   ];
  #   withPython3 = true;
  #   withNodeJs = true;
  #   extraLuaConfig = ''
  #     vim.o.clipboard = "unnamedplus"
  #     vim.g.mapleader = ","
  #     vim.o.syntax = 'on'
  #     vim.o.number = true
  #     vim.o.ruler = true
  #     vim.o.relativenumber = true
  #     vim.o.ts = 2
  #     vim.o.sw = 2
  #     vim.o.et = true
  #     --  vim.o.autochdir = true
  #     vim.o.incsearch = true
  #     vim.o.hlsearch = true
  #     vim.o.ignorecase = true
  #     vim.o.spelllang = 'en_us'
  #     -- vim.o.spellsuggest = 'base,9'
  #     vim.o.laststatus = 2
  #     vim.o.updatetime = 150
  #     vim.o.guifont = 'Fira Code:h10'
  #
  #     vim.api.nvim_create_autocmd("FileType", {
  #       pattern = "nix",
  #       callback = function(args)
  #         vim.opt.commentstring = "# %s"
  #       end
  #     })
  #
  #     -- remap Y to yy
  #     vim.keymap.set('n', 'Y', 'yy')
  #     vim.keymap.set('n', '<C-n>', '<Cmd>NvimTreeToggle<CR>')
  #     -- vim.keymap.set('n', '<leader>r', '<Cmd>NvimTreeRefresh<CR>')
  #     -- vim.keymap.set('n', '<leader>n', '<Cmd>NvimTreeFindFile<CR>')
  #     -- vim.keymap.set('n', '<leader>rg', 'yiw:Rg<Space><C-r>0<CR>')
  #     -- vim.keymap.set('n', '<space>rg', '<Cmd>Telescope live_grep<CR>')
  #
  #     local prefix = vim.env.XDG_CONFIG_HOME or vim.fn.expand("~/.config")
  #     vim.opt.undodir = { prefix .. "/nvim/.undodir//"}
  #     vim.opt.backupdir = {prefix .. "/nvim/.backup//"}
  #     vim.opt.directory = { prefix .. "/nvim/.swp//"}
  #
  #     local local_init = vim.fn.expand("~/.config/nvim/init-local.lua")
  #     if vim.fn.filereadable(local_init) == 1 then
  #       dofile(local_init)
  #     end
  #   '';
  # };
  #
  #
  # programs.rofi = {
  #   enable = true;
  #   terminal = "kitty";
  #   package = with pkgs; (rofi.override {
  #     plugins = [
  #       rofi-emoji
  #       rofi-rbw
  #       rofi-mpd
  #       rofi-calc
  #       rofi-systemd
  #       rofi-file-browser
  #     ];
  #   });
  # };
  # # xdg.configFile."rofi/colors.rasi" = {
  # #   source = ./rofi/colors.rasi;
  # # };
  # # xdg.configFile."rofi/font.rasi" = {
  # #   source = ./rofi/font.rasi;
  # # };
  # # xdg.configFile."rofi/runner.rasi" = {
  # #   source = ./rofi/runner.rasi;
  # # };
  # # xdg.configFile."rofi/launcher.rasi" = {
  # #   source = ./rofi/launcher.rasi;
  # # };
  # # xdg.configFile."rofi/clipboard.rasi" = {
  # #   source = ./rofi/clipboard.rasi;
  # # };
  # # xdg.configFile."rofi/rbw.rasi" = {
  # #   source = ./rofi/rbw.rasi;
  # # };
  # sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  # programs.zoxide = {
  #   enable = true;
  #   enableZshIntegration = true;
  #   options = [
  #     "--no-aliases"
  #   ];
  # };
  #
  # programs.zsh = {
  #   enable = true;
  #   oh-my-zsh = {
  #     enable = true;
  #     # theme = "robbyrussell";
  #     theme = "powerlevel10k/powerlevel10k";
  #     custom = "$HOME/.oh-my-zsh/custom";
  #     plugins = [
  #       "aws"
  #       "vi-mode"
  #       "git"
  #       "rbw"
  #       "aliases"
  #       "aws"
  #       "azure"
  #       "common-aliases"
  #       "direnv"
  #       "docker"
  #       "dotenv"
  #       "emoji"
  #       "encode64"
  #       "extract"
  #       "zoxide"
  #       "fzf"
  #       "systemd"
  #       "nmap"
  #       "sudo"
  #     ];
  #   };
  #   shellAliases = {
  #     vim = "nvim";
  #     ll = "ls -l";
  #     nos-update = "sudo nixos-rebuild switch";
  #     nos-list = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
  #     nos-delete = "sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system $@";
  #     k = "kubectl";
  #     gd = "git diff";
  #     gs = "git status";
  #     nd = "nix develop -c zsh";
  #   };
  #   plugins = [
  #     {
  #       name = "zsh-histdb";
  #       src = pkgs.fetchFromGitHub {
  #         owner = "larkery";
  #         repo = "zsh-histdb";
  #         rev = "90a6c104d0fcc0410d665e148fa7da28c49684eb";
  #         hash = "sha256-vtG1poaRVbfb/wKPChk1WpPgDq+7udLqLfYfLqap4Vg=";
  #       };
  #     }
  #   ];
  #   enableCompletion = true;
  #   autocd = true;
  #   syntaxHighlighting = {
  #     enable = true;
  #   };
  #   initExtra = ''
  #     ENABLE_CORRECTION="true"
  #     COMPLETION_WAITING_DOTS="true"
  #     HIST_STAMPS="yyyy-mm-dd"
  #
  #     if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
  #       source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
  #     fi
  #
  #     HISTIGNORE='\&:fg:bg:ls:pwd:cd ..:cd ~-:cd -:cd:jobs:set -x:ls -l:ls -l'
  #     if [[ -f "$HOME/.zsh/plugins/zsh-histdb/histdb-interactive.zsh" ]]; then
  #       source "$HOME/.zsh/plugins/zsh-histdb/histdb-interactive.zsh"
  #     fi
  #
  #     if [[ -f "$HOME/.zsh/plugins/zsh-histdb/histdb-interactive.zsh" ]]; then
  #       source "$HOME/.zsh/plugins/zsh-histdb/histdb-interactive.zsh"
  #     fi
  #     bindkey '^r' _histdb-isearch
  #     bindkey -M histdb-isearch '^[;' _histdb-isearch-cd
  #     #autoload -Uz add-zsh-hook
  #     #add-zsh-hook precmd histdb-update-outcome
  #
  #     _zsh_autosuggest_strategy_histdb_top_here() {
  #         local query="select commands.argv from
  #     history left join commands on history.command_id = commands.rowid
  #     left join places on history.place_id = places.rowid
  #     where places.dir LIKE '$(sql_escape $PWD)%'
  #     and commands.argv LIKE '$(sql_escape $1)%'
  #     group by commands.argv order by count(*) desc limit 1"
  #         suggestion=$(_histdb_query "$query")
  #     }
  #     ZSH_AUTOSUGGEST_STRATEGY=histdb_top_here
  #
  #     setopt nocorrectall
  #     setopt correct
  #
  #     [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
  #
  #     export PATH=$HOME/bin:$PATH
  #     #export KUBECONFIG=$HOME/.config/sops-nix/secrets/kubeconfig-wheat
  #     export OPENAI_API_KEY=$(cat $HOME/.config/sops-nix/secrets/openaiApiKey)
  #     export ASSEMBLYAI_API_KEY=$(cat $HOME/.config/sops-nix/secrets/assemblyAiApiKey)
  #     export GITHUB_PERSONAL_ACCESS_TOKEN=$(cat $HOME/.config/sops-nix/secrets/peteeGptGithubToken)
  #     export OPAQUE_GITHUB_TOKEN=$(cat $HOME/.config/sops-nix/secrets/opaqueGithubToken)
  #     export JIRA_API_TOKEN=$(cat $HOME/.config/sops-nix/secrets/jira-api-token)
  #     export JIRA_USER=pete@opaque.co
  #     export JIRA_DOMAIN=opaque-systems.atlassian.net
  #     export AWS_PROFILE=wheat
  #     export AWS_DEFAULT_PROFILE=wheat
  #     export AWS_DEFAULT_REGION=us-east-1
  #     export AWS_SHARED_CREDENTIALS_FILE=$HOME/.config/sops-nix/secrets/aws-credentials
  #     autoload bashcompinit && bashcompinit
  #     autoload -Uz compinit && compinit
  #     complete -C /etc/profiles/per-user/petee/bin/aws_completer aws
  #   '';
  #    envExtra = ''
  #      EDITOR=nvim
  #      AWS_CLI_AUTO_PROMPT=on
  #      PYTHONWARNINGS="ignore:Unverified HTTPS request"
  #    '';
  # };
  #
  # programs.tmux = {
  #   enable = true;
  #   tmuxp.enable = true;
  #   # tmuxinator.enable = true;
  #   plugins = with pkgs.tmuxPlugins; [
  #       {
  #         plugin = tmux-super-fingers;
  #         extraConfig = ''
  #           # set -g @super-fingers-key f
  #           # set -g @fingers-show-copied-notification 1
  #           # set -g @fingers-main-action 'xsel -i -b'
  #         '';
  #
  #       }
  #       { plugin = tmux-fzf; }
  #       { plugin = urlview; }
  #       # { plugin = fuzzback; }
  #       {
  #         plugin = extrakto;
  #       }
  #       {
  #           plugin = tmux-thumbs;
  #           extraConfig = ''
  #             set -g @thumbs-key f
  #           '';
  #       }
  #       yank
  #       open
  #       copycat
  #       sensible
  #       resurrect
  #       catppuccin
  #       {
  #           plugin = continuum;
  #           #extraConfig = "set -g @continuum-boot-options 'kitty'";
  #       }
  #       better-mouse-mode
  #       vim-tmux-navigator
  #       session-wizard
  #       prefix-highlight
  #   ];
  #   # extraConfig = builtins.readFile ./tmux.conf;
  # };
  # # xdg.configFile."tmuxinator/" = {
  # #     source = ./tmuxinator;
  # # };
  # # programs.zsh.shellAliases.mux = "tmuxinator";
  # # programs.zsh.initExtraBeforeCompInit = ''
  # #   source ${pkgs.tmuxinator}/share/zsh/site-functions/_tmuxinator
  # # '';
  #
  # virtualisation.memorySize = 2048;
  #
}
