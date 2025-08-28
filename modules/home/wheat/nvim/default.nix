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
  cfg = config.wheat.nvim;
in {
  options.wheat.nvim = {
    enable = mkEnableOption "Enable";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      terraform-ls
      nixpkgs-fmt
      lazygit
      nodePackages.eslint
      lua-language-server
      rust-analyzer
      helm-ls
      yaml-language-server
      pyright
      nil
      tflint
      alejandra
      kubectl
    ];

    programs.zsh = {
      shellAliases = {
        v = "nvim";
        vi = "nvim";
        vim = "nvim";
      };
      envExtra = ''
        EDITOR=nvim
      '';
    };

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      plugins = with pkgs.vimPlugins; [
        {
          plugin = nvim-surround;
          type = "lua";
          config = ''
            require('nvim-surround').setup({ })
          '';
        }
        {
          plugin = pkgs.wheat.workspaces-nvim;
          type = "lua";
          config = ''
            require('workspaces').setup({
              cd_type = "tab",
              global_cd = false,
              auto_open = false,
              hooks = {
                open = {
                  "lua Snacks.picker.smart()",
                }
              }
            })
          '';
        }
        {
          plugin = cmp-fuzzy-path;
          type = "lua";
        }
        {
          plugin = cmp-fuzzy-buffer;
          type = "lua";
        }
        {
          plugin = snacks-nvim;
          type = "lua";
          config = ''
            require('snacks').setup({
              indent = { enabled = true },
              terminal = { enabled = true },
              zen = { enabled = true },
              bigfile = { enabled = true },
              bufdelete = { enabled = true },
              dim = { enabled = true },
              debug = { enabled = true },
              layout = { enabled = true },
              notifier = { enabled = true },
              scratch = { enabled = true },
              scroll = { enabled = true },
              statuscolumn = { enabled = true },
              explorer = {
                enabled = true,
                replace_netrw = true,
              },
              picker = {
                sources = {
                  explorer = {
                    hidden = true,
                    ignored = true,
                    git_untracked = true,
                    follow_file = false,
                  },
                },
              },
              gitbrowse = { enabled = true },
              diagnostics = { enabled = true },
              dashboard = {
                enabled = true,
                sections = {
                  { section = "header" },
                  { key = "s", desc = "Smart picker", action = ":lua Snacks.dashboard.picker.smart()" },
                  { icon = " ", key = "s", desc = "Restore Session", section = "session" },
                  { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
                  { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep', { hidden = true, ignored = true, fuzzy = true })" },

                  { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
                  { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
                  { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
                  { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
                  { section = "startup" },
                },
              },
            })

            -- Snacks keymaps

            vim.keymap.set('n', '<space>sd', function() Snacks.picker.diagnostics() end, { desc = "Diagnostics" })
            vim.keymap.set('n', '<space>sD', function() Snacks.picker.diagnostics_buffer() end, { desc = "Buffer Diagnostics"})

            vim.keymap.set('n', '<space>z',   function() Snacks.zen.zoom() end, { desc = 'Toggle Zoom' })
            vim.keymap.set('n', '<space>Z',   function() Snacks.zen() end, { desc = 'Toggle Zen Mode' })
            vim.keymap.set('n', '<space>.',   function() Snacks.scratch() end, { desc = 'Toggle Scratch Buffer' })
            vim.keymap.set('n', '<space>S',   function() Snacks.scratch.select() end, { desc = 'Select Scratch Buffer' })
            vim.keymap.set('n', '<space>bd',  function() Snacks.bufdelete() end, { desc = 'Delete Buffer' })
            vim.keymap.set('n', '<c-/>',       function() Snacks.terminal() end, { desc = 'Toggle Terminal' })
            vim.keymap.set({'n', 't'}, ']]',   function() Snacks.words.jump(vim.v.count1) end, { desc = 'Next Reference' })
            vim.keymap.set({'n', 't'}, '[[',   function() Snacks.words.jump(-vim.v.count1) end, { desc = 'Prev Reference' })

            vim.keymap.set('n', '<space>da',   function() Snacks.dashboard() end, { desc = 'Show dashboard' })
            vim.keymap.set('n', '<space>ff',   function() Snacks.picker.smart() end, { desc = 'Open File' })
            vim.keymap.set('n', '<space>fb',   function() Snacks.picker.buffers() end, { desc = 'Open Buffer' })
            vim.keymap.set('n', '<space>fr',   function() Snacks.picker.registers() end, { desc = 'Show Registers' })
            vim.keymap.set('n', '<space>fc',   function() Snacks.picker.command_history() end, { desc = 'Command history' })
            vim.keymap.set('n', 'q:',          function() Snacks.picker.command_history() end, { desc = 'Command history' })

            vim.keymap.set('n', '<space>fn',   function() Snacks.picker.notifications() end, { desc = 'Show notifications' })
            vim.keymap.set('n', '<space>gb',   function() Snacks.picker.git_branches() end, { desc = 'Show Git branches' })
            vim.keymap.set('n', '<space>rg',   function() Snacks.picker.grep_word() end, { desc = 'Search' })
            -- vim.keymap.set('n', '<space>dm',   function() Snacks.dim() end, { desc = 'Toggle Dim' })

            -- LSP
            vim.keymap.set('n', '<space>gd',   function() Snacks.picker.lsp_definitions() end, { desc = 'Go to definitions' })
            vim.keymap.set('n', '<space>gD',   function() Snacks.picker.lsp_declaration() end, { desc = 'Go to definitions' })
            vim.keymap.set('n', '<space>gr',   function() Snacks.picker.lsp_references() end, { desc = 'Go to references' })
            vim.keymap.set('n', '<space>gI',   function() Snacks.picker.lsp_implementations() end, { desc = 'Go to implementations' })
            vim.keymap.set('n', '<space>gy',   function() Snacks.picker.lsp_type_definitions() end, { desc = 'Go to type definitions' })
            vim.keymap.set('n', '<space>ss',   function() Snacks.picker.lsp_symbols() end, { desc = 'LSP Symbols' })
            vim.keymap.set('n', '<space>sS',   function() Snacks.picker.lsp_workspace_symbols() end, { desc = 'LSP Workspace symbols' })
            vim.keymap.set('n', '<C-n>',       function() Snacks.picker.explorer() end, { desc = 'File explorer' })

            vim.keymap.set('n', '<space>km', function() Snacks.picker.pick('keymaps') end, { desc = 'show keymaps' })

            function copyFullPathToClipboard()
              filename = vim.fn.expand('%:p')
              -- copy to plus register
              vim.fn.setreg('+', filename)
              Snacks.notifier.notify("Path copied: " .. filename)
            end
            vim.keymap.set('n', '<space>cp', copyFullPathToClipboard, { desc = 'Copy filename' })

            '';
        }
        # {
        #   plugin = which-key-nvim;
        #   type = "lua";
        # }

        {
          plugin = markview-nvim;
          type = "lua";
          config = ''
            require("markview.extras.checkboxes").setup()
            require("markview.extras.headings").setup()
            require("markview.extras.editor").setup()
            require("markview").setup({
              preview = { 
                enable = false,
              },
            })
            vim.keymap.set('n', '<space>mv', '<cmd>Markview<cr>', { desc = "Markdown Miewer toggle" })
          '';
        }
        {
          plugin = vim-terraform;
          type = "lua";
          config = ''
            vim.cmd([[silent! autocmd! filetypedetect BufRead,BufNewFile *.tf]])
            vim.cmd([[autocmd BufRead,BufNewFile *.hcl set filetype=hcl]])
            vim.cmd([[autocmd BufRead,BufNewFile .terraformrc,terraform.rc set filetype=hcl]])
            vim.cmd([[autocmd BufRead,BufNewFile *.tf,*.tfvars set filetype=terraform]])
            vim.cmd([[autocmd BufRead,BufNewFile *.tfstate,*.tfstate.backup set filetype=json]])

            vim.cmd([[let g:terraform_fmt_on_save=1]])
            vim.cmd([[let g:terraform_align=1]])
          '';
        }
        {
          plugin = pkgs.wheat.kulala-nvim;
          type = "lua";
          config = ''
            require("kulala").setup({})
          '';
        }
        {
          plugin = pkgs.wheat.vim-kubernetes;
          type = "lua";
          config = ''
            vim.api.nvim_create_autocmd("FileType", {
              pattern = "yaml",
              callback = function()
                vim.keymap.set({'n', 'v'}, '<leader>ka', '<cmd>KubeApply<CR>', { buffer = true })
                vim.keymap.set({'n', 'v'}, '<leader>kd', '<cmd>KubeDelete<CR>', { buffer = true })
              end
            })
          '';
          # provides KubeApply, KubeCreate, KubeDelete
        }
        {
          plugin = pkgs.wheat.yaml-companion-nvim;
          type = "lua";
          config = ''
          '';
        }
        vim-commentary
        vim-unimpaired
        vim-repeat
        vim-go
        {
          plugin = vim-tmux-navigator;
          type = "lua";
          config = ''
            local opts = {buffer = 0}
            -- vim.keymap.set('t', '<C-h>', [[<Cmd>TmuxNavigateLeft<CR>]], opts)
            -- vim.keymap.set('t', '<C-l>', [[<Cmd>TmuxNavigateRight<CR>]], opts)
          '';
        }
        supertab
        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        cmp-cmdline
        cmp-tmux
        cmp-git
        vim-python-pep8-indent
        nvim-treesitter.withAllGrammars
        nvim-treesitter-parsers.just
        nvim-treesitter-parsers.rust
        rustaceanvim
        nvim-dap
        undotree
        zoxide-vim
        vim-fugitive
        vim-tmux-navigator
        fzf-lsp-nvim
        lazy-nvim
        vim-helm
        vim-indentwise
        {
          plugin = lualine-nvim;
          type = "lua";
          config = ''
            require('lualine').setup(
              {
                theme = 'onedark',
              }
            )
          '';
        }
        {
          plugin = dashboard-nvim;
          type = "lua";
          config = ''
            require("dashboard").setup({})
          '';
        }
        {
          plugin = persistence-nvim;
          type = "lua";
          config = ''
            require("persistence")
          '';
        }
        {
          plugin = auto-session;
          type = "lua";
          config = ''
            require('auto-session').setup({
              auto_session_suppress_dirs = { '~/Downloads', '/' },
              auto_save_enabled = true,
              auto_restore_enabled = true,
              auto_session_use_git_branch = false,
              -- This will save and restore folds automatically
              session_lens = {
                buftypes_to_ignore = {},
                load_on_setup = true,
                theme_conf = { border = true },
                previewer = false,
              },
            })
          '';
        }
        {
          plugin = catppuccin-nvim;
          config = ''
            colorscheme catppuccin-mocha
          '';
        }
        {
          plugin = nvim-lspconfig;
          type = "lua";
          config = ''
            require('lspconfig').lua_ls.setup({
              capabilities = require('cmp_nvim_lsp').default_capabilities()
            })
            require('lspconfig').nil_ls.setup({
              capabilities = require('cmp_nvim_lsp').default_capabilities(),
              settings = {
                ['nil'] = {
                  nix = {
                    filetypes =  { "nix" },
                    rootPatterns = { "flake.nix" },
                    flake = {
                      autoEvalInputs = false,
                    },
                  },
                  formatting = {
                    command = { "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt" },
                  },
                  diagnostics = {
                    excludedFiles = { "generated.nix" },
                  },
                },
              },
            })
            require('lspconfig').terraformls.setup({})
            require('lspconfig').tflint.setup({})
          '';
        }
        {
          plugin = diaglist-nvim;
          type = "lua";
          config = ''
            require("diaglist").init({
              debug = false,
              -- increase for noisy servers
              debounce_ms = 50,
            })
            vim.keymap.set("n", "<space>dw", "<cmd>lua require('diaglist').open_all_diagnostics()<cr>")
            vim.keymap.set("n", "<space>d0", "<cmd>lua require('diaglist').open_all_diagnostics()<cr>")
          '';
        }
        {
          plugin = nvim-cmp;
          type = "lua";
          config = ''
            local cmp = require('cmp')
            cmp.setup({
              window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
              },
              mapping = cmp.mapping.preset.insert({
                ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<C-e>'] = cmp.mapping.abort(),
                ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
              }),
              matching = {
                disallow_fuzzy_matching = false,
              },
              sources = cmp.config.sources(
                {
                  { name = 'nvim_lsp' },
                },
                {
                  { name = 'fuzzy_buffer' }
                }
              )
            })

            -- Set configuration for specific filetype.
            cmp.setup.filetype('gitcommit', {
              sources = cmp.config.sources(
                {
                  { name = 'git' },
                },
                {
                  { name = 'fuzzy_buffer' },
                }
              )
            })

            cmp.setup.filetype('yaml', {
              sources = cmp.config.sources(
                {
                  { name = 'nvim_lsp' },
                },
                {
                  { name = 'git' },
                }, {
                  { name = 'fuzzy_buffer' },
                }
              )
            })
            cmp.setup.filetype('py', {
              sources = cmp.config.sources(
                {
                  { name = 'nvim_lsp' },
                },
                {
                  { name = 'fuzzy_buffer' },
                }
              )
            })


            -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
            cmp.setup.cmdline({ '/', '?' }, {
              mapping = cmp.mapping.preset.cmdline(),
              sources = {
                { name = 'fuzzy_buffer' }
              }
            })

            -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
            cmp.setup.cmdline(':', {
              mapping = cmp.mapping.preset.cmdline(),
              sources = cmp.config.sources(
               {
                { name = 'cmdline' }
               }
              )
            })
          '';
        }
        # {
        #   plugin = trouble-nvim;
        #   type = "lua";
        #   config = ''
        #     vim.keymap.set("n", "<space>t", "<cmd>TroubleToggle<CR>")
        #   '';
        # }
        {
           plugin = fzf-lua;
           type = "lua";
           config = ''
             require("fzf-lua").setup({ "fzf-vim" })
           '';
        }
        {
          plugin = lspkind-nvim;
          type = "lua";
          config = ''
            local lspkind = require('lspkind')
            cmp.setup {
              formatting = {
                format = lspkind.cmp_format({
                  mode = 'symbol_text', -- show only symbol annotations
                  maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
                                 -- can also be a function to dynamically calculate max width such as
                                 -- maxwidth = function() return math.floor(0.45 * vim.o.columns) end,
                  ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
                  show_labelDetails = true, -- show labelDetails in menu. Disabled by default

                  -- The function below will be called before any actual modifications from lspkind
                  -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
                  -- before = function (entry, vim_item)
                  --  ...
                  --  return vim_item
                  --end
                })
              }
            }
          '';
        }
        {
          plugin = nvim-tree-lua;
          type = "lua";
          config = ''
            require("nvim-tree").setup()
          '';
        }
        nvim-web-devicons
        vim-nix
        {
          plugin = vim-gitgutter;
          config = ''
            let g:gitgutter_enabled=1
            let g:gitgutter_terminal_reports_focus=0
            let g:gitgutter_grep = 'rg --hidden'
            let g:gitgutter_map_keys = 1
            highlight GitGutterAdd    guifg=#a6e3a1 ctermfg=2
            highlight GitGutterChange guifg=#fab387 ctermfg=3
            highlight GitGutterDelete guifg=#f38ba8 ctermfg=1
          '';
        }
        {
          plugin = vim-better-whitespace;
          type = "lua";
          config = ''
            vim.g.strip_whitespace_on_save = false
            vim.g.better_whitespace_guicolor = "#eba0ac"
            vim.g.better_whitespace_enabled = 0
          '';
        }
        {
          plugin = toggleterm-nvim;
          type = "lua";
          config = ''
            require("toggleterm").setup({
              shade_terminals = true;
            })

            -- Set updatetime for terminal buffers only
            vim.api.nvim_create_autocmd("TermOpen", {
            callback = function()
              vim.opt_local.updatetime = 15
            end,
            })
            vim.keymap.set({'n', 't'}, '<space>tt', '<cmd>ToggleTerm<CR>')
          '';
        }
        {
          plugin = pkgs.wheat.nvim-base64;
          type = "lua";
          config = ''
            require("nvim-base64").setup({})
            vim.keymap.set('x', "<leader>b", "<Plug>(FromBase64)")
            vim.keymap.set('x', "<leader>B", "<Plug>(ToBase64)")
          '';
        }
        {
          plugin = claude-code-nvim;
          type = "lua";
          config = ''
            require("claude-code").setup({
              window = {
                position = "float",
                float = {
                  width = "90%",
                  height = "90%",
                },
              },
              refresh = {
                updatetime = 20,
              },
              command = "claude --continue",
              keymaps = {
                toggle = {
                  normal = false,
                  terminal = false,
                },
              },
            })
            vim.keymap.set({'n','t'}, '<space>ai', function()
              require("claude-code").toggle()
            end, { desc = 'Toggle AI' })
          '';
        }
      ];
      withPython3 = true;
      withNodeJs = true;
      extraLuaConfig = ''
        vim.o.clipboard = "unnamedplus"
        vim.g.mapleader = ","
        vim.o.syntax = 'on'
        vim.o.number = true
        vim.o.ruler = true
        vim.o.relativenumber = true
        vim.o.ts = 4
        vim.o.sw = 4
        vim.o.et = true
        --  vim.o.autochdir = true
        vim.o.incsearch = true
        vim.o.hlsearch = true
        vim.o.ignorecase = true
        vim.o.spelllang = 'en_us'
        -- vim.o.spellsuggest = 'base,9'
        vim.o.laststatus = 2
        vim.o.updatetime = 150
        vim.o.guifont = 'Fira Code:h10'

        -- Enable fold persistence
        --vim.o.foldmethod = 'syntax'
        vim.o.foldmethod = 'manual'
        vim.o.foldlevelstart = 99
        vim.o.viewoptions = 'folds,cursor'

        vim.api.nvim_create_autocmd("FileType", {
          pattern = "nix",
          callback = function(args)
            vim.opt.commentstring = "# %s"
          end
        })

        -- remap Y to yy
        vim.keymap.set('n', 'Y', 'yy')

        -- TODO test
        -- vim.keymap.set('n', '<C-n>', '<Cmd>NvimTreeToggle<CR>')

        -- vim.keymap.set('n', '<leader>rg', 'yiw:Rg<Space><C-r>0<CR>')

        local prefix = vim.env.XDG_CONFIG_HOME or vim.fn.expand("~/.config")
        vim.opt.undodir = { prefix .. "/nvim/.undodir//"}
        vim.opt.backupdir = {prefix .. "/nvim/.backup//"}
        vim.opt.directory = { prefix .. "/nvim/.swp//"}

        -- Auto-save and restore folds
        vim.api.nvim_create_autocmd("BufWinLeave", {
          pattern = "*",
          callback = function()
            if vim.bo.filetype ~= "" then
              vim.cmd("silent! mkview")
            end
          end
        })

        vim.api.nvim_create_autocmd("BufWinEnter", {
          pattern = "*",
          callback = function()
            if vim.bo.filetype ~= "" then
              vim.cmd("silent! loadview")
            end
          end
        })

        local local_init = vim.fn.expand("~/.config/nvim/init-local.lua")
        if vim.fn.filereadable(local_init) == 1 then
          dofile(local_init)
        end
      '';
    };
  };
}
