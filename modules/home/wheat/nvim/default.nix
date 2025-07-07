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
      lazygit
      nodePackages.eslint
      lua-language-server
      rust-analyzer
      helm-ls
      yaml-language-server
      pyright
      nil
      terraform-ls
      tflint
    ];

    programs.zsh.shellAliases = {
      v = "nvim";
      vi = "nvim";
      vim = "nvim";
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
          plugin = mini-nvim;
          type = "lua";
        }
        # {
        #   plugin = CopilotChat-nvim;
        #   type = "lua";
        # }
        # {
        #   plugin = copilot-lua;
        #   type = "lua";
        # }
        # {
        #   plugin = copilot-lualine;
        #   type = "lua";
        # }
        {
          plugin = snacks-nvim;
          type = "lua";
          config = ''
            require('snacks').setup({
              indent = { enabled = true },
              terminal = { enabled = true },
              zen = { enabled = true },
              bufdelete = { enabled = true },
              dim = { enabled = true },
              debug = { enabled = true },
              layout = { enabled = true },
              notifier = { enabled = true },
              explorer = {
                  replace_netrw = true,
                  hidden = true,
                  ignored = true,
                  git_untracked = true,
                  follow_file = false,
              },
              dashboard = {
                  enabled = true,
                  sections = {
                    { section = "header" },
                    { key = "s", desc = "Smart picker", action = ":lua Snacks.dashboard.picker.smart()" },
                    { icon = " ", key = "s", desc = "Restore Session", section = "session" },
                    { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
                    { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep', { hidden = true, ignored = true, fuzzy = true })" },

                    -- { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
                    { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
                    { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
                    { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
                    { section = "startup" },
                  },
              },
            })
            vim.keymap.set('n', '<space>da', ":lua Snacks.dashboard()<CR>")
            vim.keymap.set('n', '<space>ff', ":lua Snacks.picker.smart()<CR>")
            vim.keymap.set('n', '<space>fg', ":lua Snacks.picker.git_files()<CR>")
            vim.keymap.set('n', '<space>fb', ":lua Snacks.picker.buffers()<CR>")
            vim.keymap.set('n', '<space>fc', ":lua Snacks.picker.command_history()<CR>")
            vim.keymap.set('n', '<space>fn', ":lua Snacks.picker.notifications()<CR>")
            vim.keymap.set('n', '<space>fw', ":lua Snacks.picker.oldfiles()<CR>")
            vim.keymap.set('n', '<space>gb', ":lua Snacks.picker.git_branches()<CR>")
            vim.keymap.set('n', '<space>gl', ":lua Snacks.picker.git_log()<CR>")
            vim.keymap.set({ "n", "x" }, "<leader>rg", function() Snacks.picker.grep_word() end)
            -- old mapping, muscle memory
            vim.keymap.set('n', '<leader>rg', "yiw:lua Snacks.picker.grep()<CR>")

            vim.keymap.set('n', '<leader>ff', ":lua Snacks.picker.smart()<CR>")
            vim.keymap.set("n", ":bd", ":lua Snacks.bufdelete()<CR>", { noremap = true, silent = true })
            vim.keymap.set('n', '<space>dm', ":lua Snacks.dim()<CR>")

            -- LSP
            vim.keymap.set("n", "<space>gd", ":lua Snacks.picker.lsp_definitions()<CR>")
            vim.keymap.set("n", "<space>gD", ":lua Snacks.picker.lsp_declarations()<CR>")
            vim.keymap.set("n", "<space>gr", ":lua Snacks.picker.lsp_references()<CR>")
            vim.keymap.set("n", "<space>gI", ":lua Snacks.picker.lsp_implementations()<CR>")
            vim.keymap.set("n", "<space>gy", ":lua Snacks.picker.lsp_type_definitions()<CR>")
            vim.keymap.set("n", "<leader>ss", ":lua Snacks.picker.lsp_symbols()<CR>")
            vim.keymap.set("n", "<leader>sS", ":lua Snacks.picker.lsp_workspace_symbols()<CR>")
            vim.keymap.set('n', "<C-n>", ":lua Snacks.picker.explorer()<CR>")
            '';
        }
        {
          plugin = markview-nvim;
          type = "lua";
          config = ''
            require("markview.extras.checkboxes").setup();
            require("markview.extras.headings").setup();
            require("markview.extras.editor").setup();
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
          plugin = pkgs.wheat.yaml-companion-nvim;
          type = "lua";
          config = ''
          '';
        }
        vim-commentary
        vim-unimpaired
        vim-repeat
        vim-go
        vim-tmux-navigator
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
        telescope-vim-bookmarks-nvim
        telescope-symbols-nvim
        vim-fugitive
        vim-tmux-navigator
        vim-terminator     # execute shell commands
        fzf-lsp-nvim
        telescope-zoxide
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
                 { name = 'fuzzy_path' }
               },
               {
                { name = 'cmdline' }
               }
              )
            })
          '';
        }
        {
          plugin = trouble-nvim;
          type = "lua";
          config = ''
            vim.keymap.set("n", "<space>t", "<cmd>TroubleToggle<CR>")
          '';
        }
        {
          plugin = telescope-nvim;
          type = "lua";
        }
        {
          plugin = telescope-fzf-native-nvim;
          type = "lua";
          config = ''
            require('telescope').load_extension('fzf')
          '';

        }
        {
          plugin = telescope-file-browser-nvim;
          type = "lua";
          config = ''
            -- require('telescope').load_extension('file_browser')
            -- vim.keymap.set("n", "<space>f", "<cmd>Telescope file_browser select_buffer=true<CR>")
          '';
        }
        {
          plugin = telescope-undo-nvim;
          type = "lua";
          config = ''
            require('telescope').load_extension('undo')
            vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<CR>")
          '';
        }
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
            let g:gitgutter_grep = 'rg'
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
            vim.g.strip_whitespace_on_save = true
            vim.g.better_whitespace_guicolor = "#eba0ac"
            vim.g.better_whitespace_enabled = 0
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

        vim.api.nvim_create_autocmd("FileType", {
          pattern = "nix",
          callback = function(args)
            vim.opt.commentstring = "# %s"
          end
        })

        -- remap Y to yy
        vim.keymap.set('n', 'Y', 'yy')
        vim.keymap.set('n', '<C-n>', '<Cmd>NvimTreeToggle<CR>')
        -- vim.keymap.set('n', '<leader>r', '<Cmd>NvimTreeRefresh<CR>')
        -- vim.keymap.set('n', '<leader>n', '<Cmd>NvimTreeFindFile<CR>')
        -- vim.keymap.set('n', '<leader>rg', 'yiw:Rg<Space><C-r>0<CR>')
        -- vim.keymap.set('n', '<space>rg', '<Cmd>Telescope live_grep<CR>')

        local prefix = vim.env.XDG_CONFIG_HOME or vim.fn.expand("~/.config")
        vim.opt.undodir = { prefix .. "/nvim/.undodir//"}
        vim.opt.backupdir = {prefix .. "/nvim/.backup//"}
        vim.opt.directory = { prefix .. "/nvim/.swp//"}

        local local_init = vim.fn.expand("~/.config/nvim/init-local.lua")
        if vim.fn.filereadable(local_init) == 1 then
          dofile(local_init)
        end
      '';
    };
  };
}
