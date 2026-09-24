# Migrated from LazyVim (hosts/nixos/modules/nvim/*) to native nvf.
# No lazy.nvim, no Mason: plugins/LSP/formatters come from nixpkgs.
#
# Keybind policy: LazyVim defaults kept, your custom ones win on conflict.
# Dropped (no equivalent without lazy/Mason):
#   <leader>l / :Lazy, :Mason, dashboard "lazy"/"mason" entries,
#   <leader>uF/uf format-toggle, profiler toggles, <leader>gG duplicate,
#   snacks dashboard 2-pane layout (mixed Lua tables aren't expressible in Nix),
#   dashboard custom formats/icon fns, _G.dd/_G.bt debug globals.
# Simplified: <esc> just clears hlsearch, <leader>u* toggles use plain :set.
{ config, pkgs, ... }:

{
  programs.nvf = {
    enable = true;

    settings = {
      vim = {
        # Leader must be set before plugins load (was LazyVim options.lua).
        globals = {
          mapleader = " ";
          maplocalleader = "\\";
          vimtex_view_method = "zathura"; # was lua/plugins/vimtex.lua
          trouble_lualine = true; # show symbols in lualine (was LazyVim default)
        };

        # Editor options (was LazyVim options.lua; nvf already sets sane defaults).
        options = {
          number = true;
          relativenumber = true;
          cursorline = true;
          expandtab = true;
          tabstop = 2;
          shiftwidth = 2;
          ignorecase = true;
          smartcase = true;
          splitbelow = true;
          splitright = true;
          termguicolors = true;
          undofile = true;
          undolevels = 10000;
          updatetime = 200;
          timeoutlen = 300;
          scrolloff = 4;
          sidescrolloff = 8;
          signcolumn = "yes";
          wrap = false;
          conceallevel = 2; # required by render-markdown
          confirm = true;
          mouse = "a";
          pumheight = 10;
          showmode = false;
          smartindent = true;
          spelllang = "en";
          foldlevel = 99;
          foldmethod = "indent";
        };

        useSystemClipboard = true;

        # Theme (was lua/plugins/tokynight.lua: transparent tokyonight).
        theme = {
          enable = true;
          name = "tokyonight";
          style = "moon"; # tokyonight.nvim default, matches your old setup
          transparent = true;
        };

        statusline.lualine.enable = true;
        telescope.enable = true;
        binds.whichKey.enable = true;
        autocomplete.nvim-cmp.enable = true;

        # Languages (was example.lua treesitter ensure_installed + lspconfig).
        # Replaces Mason's stylua/shellcheck/shfmt/flake8 via nix packages.
        languages = {
          enableTreesitter = true;
          enableFormat = true;
          enableExtraDiagnostics = true;

          nix.enable = true;
          bash.enable = true;
          lua.enable = true;
          clang.enable = true;
          rust.enable = true; # was lua/plugins/rust.lua (rust-analyzer)
          python.enable = true; # was pyright in example.lua
          typescript.enable = true; # was tsserver + tsx in example.lua
          tsx.enable = true;
          json.enable = true;
          yaml.enable = true;
          html.enable = true;
          tex.enable = true; # vimtex backend (was lua/plugins/vimtex.lua)
          markdown = {
            enable = true;
            extensions.render-markdown-nvim = {
              enable = true; # was lua/plugins/markdown.lua
              setupOpts.file_types = [ "markdown" "Avante" ];
            };
          };
        };

        lsp = {
          enable = true;
          formatOnSave = true;
          lightbulb.enable = true;
          trouble.enable = true;
          nvim-docs-view.enable = true;
        };

        mini.tabline.enable = false; # replaced by bufferline below (was LazyVim default)

        tabline.nvimBufferline.enable = true; # was bufferline.nvim (LazyVim default)

        filetree.nvimTree = {
          enable = true;
          mappings.toggle = " e";
          setupOpts.hijack_cursor = true;
        };

        # Snacks (was lua/plugins/snacks.lua). setupOpts passes straight
        # through to require("snacks").setup(), Nix syntax instead of Lua.
        utility.snacks-nvim = {
          enable = true;
          setupOpts = {
            bigfile.enable = true;
            quickfile.enable = true;
            bufdelete.enable = true;
            git.enable = true;
            rename.enable = true;
            statuscolumn.enable = true;
            terminal.enable = true;
            input.enable = true;
            picker.enable = true; # needed by dashboard pick() actions
            image.enable = true;
            indent = {
              enable = true;
              indent.enabled = false;
              animate.enabled = false;
              scope.treesitter.enabled = true;
            };
            lazygit = {
              enable = true;
              theme = {
                activeBorderColor = {
                  fg = "DiagnosticWarn";
                  bold = true;
                };
                searchingActiveBorderColor = {
                  fg = "DiagnosticWarn";
                  bold = true;
                };
              };
            };
            notifier = {
              enable = true;
              timeout = 3000;
            };
            dashboard = {
              enable = true;
              preset.keys = [
                {
                  icon = " ";
                  key = "f";
                  desc = "find file";
                  action = ":lua Snacks.dashboard.pick('files')";
                }
                {
                  icon = " ";
                  key = "s";
                  desc = "restore session";
                  section = "session";
                }
                {
                  icon = " ";
                  key = "w";
                  desc = "find text";
                  action = ":lua Snacks.dashboard.pick('live_grep')";
                }
                {
                  icon = " ";
                  key = "r";
                  desc = "recent files";
                  action = ":lua Snacks.dashboard.pick('oldfiles')";
                }
                {
                  icon = " ";
                  key = "e";
                  desc = "explorer";
                  action = ":NvimTreeToggle";
                }
                {
                  icon = " ";
                  key = "g";
                  desc = "browse git";
                  action = ":lua Snacks.lazygit()";
                }
                {
                  icon = " ";
                  key = "c";
                  desc = "Config";
                  action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})";
                }
                {
                  icon = "󰭿 ";
                  key = "q";
                  desc = "quit";
                  action = ":qa";
                }
              ];
              sections = [
                {
                  section = "terminal";
                  cmd = "cbonsai --live";
                  height = 19;
                  padding = 1;
                }
                {
                  section = "keys";
                  gap = 1;
                  padding = 1;
                }
                {
                  section = "recent_files";
                  cwd = true;
                  limit = 5;
                  padding = 1;
                }
                { section = "startup"; }
              ];
            };
            styles = {
              notification = {
                border = "single";
                wo = {
                  wrap = true;
                  winblend = 0;
                };
              };
              "notification.history" = {
                border = "single";
              };
              lazygit = {
                border = "single";
              };
              blame_line = {
                border = "single";
                title = "git blame";
              };
            };
          };
        };

        autopairs.nvim-autopairs.enable = true;
        comments.comment-nvim.enable = true;
        git.gitsigns.enable = true;
        utility.motion.hop.enable = true;
        utility.motion.flash-nvim.enable = true; # was flash.nvim (LazyVim defaults s/S/r/R)
        utility.surround.enable = true;
        utility.grug-far-nvim.enable = true; # was grug-far.nvim (<leader>sr)
        utility.yanky-nvim.enable = true; # was yanky.nvim ([y/]y ring cycling)
        utility.leetcode-nvim.enable = true; # was lua/plugins/leet.lua (defaults)

        # Avante (was lua/plugins/avante.lua, provider claude).
        assistant.avante-nvim = {
          enable = true;
          setupOpts = {
            provider = "claude";
            providers = {
              claude = {
                endpoint = "https://api.anthropic.com";
                model = "claude-sonnet-4-20250514";
                timeout = 30000;
                extra_request_body = {
                  temperature = 0.75;
                  max_tokens = 20480;
                };
              };
            };
          };
        };

        # Supermaven (was supermaven-nvim, loaded as completion source).
        # Needs auth on first run (:SupermavenUseFree or API key). NOTE: its
        # default accept key is <Tab>, which fights supertab below — change
        # setupOpts.keymaps if you use inline suggestions.
        assistant.supermaven-nvim.enable = true;

        # Plugins with no nvf module (were lua/plugins/*).
        # If a rebuild complains about a missing pkgs.vimPlugins attribute,
        # delete that entry here.
        extraPlugins = {
          vimtex = {
            package = pkgs.vimPlugins.vimtex;
            setup = "vim.g.vimtex_view_method = 'zathura'";
          };
          vim-tmux-navigator = {
            package = pkgs.vimPlugins.vim-tmux-navigator;
            setup = "";
          };
          vim-be-good = {
            package = pkgs.vimPlugins.vim-be-good;
            setup = "";
          };
          img-clip = {
            package = pkgs.vimPlugins.img-clip-nvim;
            setup = ''
              require('img-clip').setup({
                default = {
                  embed_image_as_base64 = false,
                  prompt_for_file_name = false,
                  drag_and_drop = { insert_mode = true },
                  use_absolute_path = true,
                },
              })
            '';
          };
          notify = {
            # backend for noice.nvim popups
            package = pkgs.vimPlugins.nvim-notify;
            setup = "require('notify').setup({ stages = 'static' })";
          };
          noice = {
            # was noice.nvim (LazyVim default UI for cmdline/messages/LSP docs)
            package = pkgs.vimPlugins.noice-nvim;
            setup = ''
              require('noice').setup({
                lsp = {
                  override = {
                    ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
                    ['vim.lsp.util.stylize_markdown'] = true,
                    ['cmp.entry.get_documentation'] = true,
                  },
                },
                presets = {
                  bottom_search = true,
                  command_palette = true,
                  long_message_to_split = true,
                },
              })
            '';
          };
          persistence = {
            # sessions; makes the dashboard "restore session" key meaningful
            package = pkgs.vimPlugins.persistence-nvim;
            setup = "require('persistence').setup()";
          };
          todo-comments = {
            package = pkgs.vimPlugins.todo-comments-nvim;
            setup = "require('todo-comments').setup()";
          };
          mini-ai = {
            # was mini.ai (LazyVim default textobjects)
            package = pkgs.vimPlugins.mini-nvim;
            setup = "require('mini.ai').setup()";
          };
          dressing = {
            # was dressing.nvim (avante input provider dep)
            package = pkgs.vimPlugins.dressing-nvim;
            setup = "require('dressing').setup()";
          };
          markdown-preview = {
            # was markdown-preview.nvim (<leader>cp).
            # NOTE: on first use the plugin wants to build its node server
            # (:call mkdp#util#install), which fails from the read-only
            # /nix/store. If preview doesn't start, that build is why —
            # inline rendering via render-markdown (already enabled) always works.
            package = pkgs.vimPlugins.markdown-preview-nvim;
            setup = "";
          };
        };

        # ---- Keymaps: LazyVim defaults, yours win on conflict ----
        keymaps = [
          # better up/down (Lazy default)
          {
            key = "j";
            mode = [
              "n"
              "x"
            ];
            action = "v:count == 0 ? 'gj' : 'j'";
            expr = true;
            silent = true;
            desc = "Down";
          }
          {
            key = "k";
            mode = [
              "n"
              "x"
            ];
            action = "v:count == 0 ? 'gk' : 'k'";
            expr = true;
            silent = true;
            desc = "Up";
          }
          {
            key = "<Down>";
            mode = [
              "n"
              "x"
            ];
            action = "v:count == 0 ? 'gj' : 'j'";
            expr = true;
            silent = true;
            desc = "Down";
          }
          {
            key = "<Up>";
            mode = [
              "n"
              "x"
            ];
            action = "v:count == 0 ? 'gk' : 'k'";
            expr = true;
            silent = true;
            desc = "Up";
          }

          # NOTE: Lazy maps <C-h/j/k/l> to window nav; yours (vim-tmux-navigator
          # below) intentionally overrides that.

          # resize window with <ctrl> arrows (Lazy default)
          {
            key = "<C-Up>";
            mode = "n";
            action = "<cmd>resize +2<cr>";
            desc = "Increase Window Height";
          }
          {
            key = "<C-Down>";
            mode = "n";
            action = "<cmd>resize -2<cr>";
            desc = "Decrease Window Height";
          }
          {
            key = "<C-Left>";
            mode = "n";
            action = "<cmd>vertical resize -2<cr>";
            desc = "Decrease Window Width";
          }
          {
            key = "<C-Right>";
            mode = "n";
            action = "<cmd>vertical resize +2<cr>";
            desc = "Increase Window Width";
          }

          # move lines with <alt> j/k (Lazy default)
          {
            key = "<A-j>";
            mode = "n";
            action = "<cmd>execute 'move .+' . v:count1<cr>==";
            desc = "Move Down";
          }
          {
            key = "<A-k>";
            mode = "n";
            action = "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==";
            desc = "Move Up";
          }
          {
            key = "<A-j>";
            mode = "i";
            action = "<esc><cmd>m .+1<cr>==gi";
            desc = "Move Down";
          }
          {
            key = "<A-k>";
            mode = "i";
            action = "<esc><cmd>m .-2<cr>==gi";
            desc = "Move Up";
          }
          {
            key = "<A-j>";
            mode = "v";
            action = ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv";
            desc = "Move Down";
          }
          {
            key = "<A-k>";
            mode = "v";
            action = ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv";
            desc = "Move Up";
          }

          # buffers (Lazy default; <leader>bd is yours)
          {
            key = "<S-h>";
            mode = "n";
            action = "<cmd>bprevious<cr>";
            desc = "Prev Buffer";
          }
          {
            key = "<S-l>";
            mode = "n";
            action = "<cmd>bnext<cr>";
            desc = "Next Buffer";
          }
          {
            key = "[b";
            mode = "n";
            action = "<cmd>bprevious<cr>";
            desc = "Prev Buffer";
          }
          {
            key = "]b";
            mode = "n";
            action = "<cmd>bnext<cr>";
            desc = "Next Buffer";
          }
          {
            key = "<leader>bb";
            mode = "n";
            action = "<cmd>e #<cr>";
            desc = "Switch to Other Buffer";
          }
          {
            key = "<leader>`";
            mode = "n";
            action = "<cmd>e #<cr>";
            desc = "Switch to Other Buffer";
          }
          {
            key = "<leader>bd";
            mode = "n";
            lua = true;
            action = "function() Snacks.bufdelete() end";
            desc = "Delete Buffer";
          }
          {
            key = "<leader>bo";
            mode = "n";
            lua = true;
            action = "function() Snacks.bufdelete.other() end";
            desc = "Delete Other Buffers";
          }
          {
            key = "<leader>bD";
            mode = "n";
            action = "<cmd>:bd<cr>";
            desc = "Delete Buffer and Window";
          }

          # clear hlsearch on escape (Lazy also stops snippets; simplified)
          {
            key = "<esc>";
            mode = "n";
            action = "<cmd>noh<cr>";
            desc = "Clear hlsearch";
          }
          {
            key = "<leader>ur";
            mode = "n";
            action = "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>";
            desc = "Redraw / Clear hlsearch / Diff Update";
          }

          # saner n/N behavior (Lazy default)
          {
            key = "n";
            mode = "n";
            action = "'Nn'[v:searchforward].'zv'";
            expr = true;
            desc = "Next Search Result";
          }
          {
            key = "n";
            mode = "x";
            action = "'Nn'[v:searchforward]";
            expr = true;
            desc = "Next Search Result";
          }
          {
            key = "n";
            mode = "o";
            action = "'Nn'[v:searchforward]";
            expr = true;
            desc = "Next Search Result";
          }
          {
            key = "N";
            mode = "n";
            action = "'nN'[v:searchforward].'zv'";
            expr = true;
            desc = "Prev Search Result";
          }
          {
            key = "N";
            mode = "x";
            action = "'nN'[v:searchforward]";
            expr = true;
            desc = "Prev Search Result";
          }
          {
            key = "N";
            mode = "o";
            action = "'nN'[v:searchforward]";
            expr = true;
            desc = "Prev Search Result";
          }

          # undo break-points (Lazy default)
          {
            key = ",";
            mode = "i";
            action = ",<c-g>u";
          }
          {
            key = ".";
            mode = "i";
            action = ".<c-g>u";
          }
          {
            key = ";";
            mode = "i";
            action = ";<c-g>u";
          }

          # save file (Lazy default)
          {
            key = "<C-s>";
            mode = [
              "i"
              "x"
              "n"
              "s"
            ];
            action = "<cmd>w<cr><esc>";
            desc = "Save File";
          }
          {
            key = "<leader>K";
            mode = "n";
            action = "<cmd>norm! K<cr>";
            desc = "Keywordprg";
          }

          # better indenting (Lazy default)
          {
            key = "<";
            mode = "x";
            action = "<gv";
          }
          {
            key = ">";
            mode = "x";
            action = ">gv";
          }

          # commenting below/above (Lazy default, uses comment-nvim's gcc)
          {
            key = "gco";
            mode = "n";
            action = "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>";
            desc = "Add Comment Below";
          }
          {
            key = "gcO";
            mode = "n";
            action = "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>";
            desc = "Add Comment Above";
          }

          # new file: Lazy's <leader>fn moved to <leader>fN, yours wins <leader>fn
          {
            key = "<leader>fN";
            mode = "n";
            action = "<cmd>enew<cr>";
            desc = "New File";
          }
          {
            key = "<leader>fn";
            mode = "n";
            lua = true;
            action = "function() Snacks.notifier.show_history() end";
            desc = "Notification History";
          }

          # location / quickfix lists (Lazy default)
          {
            key = "<leader>xl";
            mode = "n";
            lua = true;
            action = ''
              function()
                local ok, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
                if not ok and err then vim.notify(err, vim.log.levels.ERROR) end
              end
            '';
            desc = "Location List";
          }
          {
            key = "<leader>xq";
            mode = "n";
            lua = true;
            action = ''
              function()
                local ok, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
                if not ok and err then vim.notify(err, vim.log.levels.ERROR) end
              end
            '';
            desc = "Quickfix List";
          }
          {
            key = "[q";
            mode = "n";
            action = "<cmd>cprev<cr>";
            desc = "Previous Quickfix";
          }
          {
            key = "]q";
            mode = "n";
            action = "<cmd>cnext<cr>";
            desc = "Next Quickfix";
          }

          # format via LSP (Lazy used its formatter; nvf-native equivalent)
          {
            key = "<leader>cf";
            mode = [
              "n"
              "x"
            ];
            lua = true;
            action = "function() vim.lsp.buf.format() end";
            desc = "Format";
          }

          # diagnostics (Lazy default)
          {
            key = "<leader>cd";
            mode = "n";
            lua = true;
            action = "function() vim.diagnostic.open_float() end";
            desc = "Line Diagnostics";
          }
          {
            key = "]d";
            mode = "n";
            lua = true;
            action = "function() vim.diagnostic.jump({ count = vim.v.count1, float = true }) end";
            desc = "Next Diagnostic";
          }
          {
            key = "[d";
            mode = "n";
            lua = true;
            action = "function() vim.diagnostic.jump({ count = -vim.v.count1, float = true }) end";
            desc = "Prev Diagnostic";
          }
          {
            key = "]e";
            mode = "n";
            lua = true;
            action = "function() vim.diagnostic.jump({ count = vim.v.count1, severity = vim.diagnostic.severity.ERROR, float = true }) end";
            desc = "Next Error";
          }
          {
            key = "[e";
            mode = "n";
            lua = true;
            action = "function() vim.diagnostic.jump({ count = -vim.v.count1, severity = vim.diagnostic.severity.ERROR, float = true }) end";
            desc = "Prev Error";
          }
          {
            key = "]w";
            mode = "n";
            lua = true;
            action = "function() vim.diagnostic.jump({ count = vim.v.count1, severity = vim.diagnostic.severity.WARN, float = true }) end";
            desc = "Next Warning";
          }
          {
            key = "[w";
            mode = "n";
            lua = true;
            action = "function() vim.diagnostic.jump({ count = -vim.v.count1, severity = vim.diagnostic.severity.WARN, float = true }) end";
            desc = "Prev Warning";
          }

          # simple option toggles (Lazy used Snacks.toggle; same effect)
          {
            key = "<leader>us";
            mode = "n";
            action = "<cmd>set spell!<cr>";
            desc = "Toggle Spelling";
          }
          {
            key = "<leader>uw";
            mode = "n";
            action = "<cmd>set wrap!<cr>";
            desc = "Toggle Wrap";
          }
          {
            key = "<leader>uL";
            mode = "n";
            action = "<cmd>set relativenumber!<cr>";
            desc = "Toggle Relative Number";
          }
          {
            key = "<leader>ul";
            mode = "n";
            action = "<cmd>set number!<cr>";
            desc = "Toggle Line Number";
          }
          {
            key = "<leader>ub";
            mode = "n";
            lua = true;
            action = "function() vim.o.background = vim.o.background == 'dark' and 'light' or 'dark' end";
            desc = "Toggle Dark Background";
          }
          {
            key = "<leader>ud";
            mode = "n";
            lua = true;
            action = "function() vim.diagnostic.enable(not vim.diagnostic.is_enabled()) end";
            desc = "Toggle Diagnostics";
          }
          {
            key = "<leader>uh";
            mode = "n";
            lua = true;
            action = "function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end";
            desc = "Toggle Inlay Hints";
          }

          # git / lazygit (Lazy defaults; <leader>gl is yours and wins)
          {
            key = "<leader>gg";
            mode = "n";
            lua = true;
            action = "function() Snacks.lazygit() end";
            desc = "Lazygit";
          }
          {
            key = "<leader>gl";
            mode = "n";
            lua = true;
            action = "function() Snacks.lazygit() end";
            desc = "Lazygit";
          }
          {
            key = "<leader>gb";
            mode = "n";
            lua = true;
            action = "function() Snacks.git.blame_line() end";
            desc = "Blame Line";
          }
          {
            key = "<leader>gL";
            mode = "n";
            lua = true;
            action = "function() Snacks.picker.git_log() end";
            desc = "Git Log";
          }
          {
            key = "<leader>gf";
            mode = "n";
            lua = true;
            action = "function() Snacks.picker.git_log_file() end";
            desc = "Git Current File History";
          }
          {
            key = "<leader>gB";
            mode = [
              "n"
              "x"
            ];
            lua = true;
            action = "function() Snacks.gitbrowse() end";
            desc = "Git Browse (open)";
          }
          {
            key = "<leader>gY";
            mode = [
              "n"
              "x"
            ];
            lua = true;
            action = ''
              function()
                Snacks.gitbrowse({ open = function(url) vim.fn.setreg('+', url) end, notify = false })
              end
            '';
            desc = "Git Browse (copy)";
          }

          # rename file (yours, was snacks.lua)
          {
            key = "<leader>cR";
            mode = "n";
            lua = true;
            action = "function() Snacks.rename() end";
            desc = "Rename File";
          }

          # search / picker family (Lazy default; sk = keymap hints)
          {
            key = "<leader>sk";
            mode = "n";
            lua = true;
            action = "function() Snacks.picker.keymaps() end";
            desc = "Keymaps";
          }
          {
            key = "<leader>ff";
            mode = "n";
            lua = true;
            action = "function() Snacks.picker.files() end";
            desc = "Find Files";
          }
          {
            key = "<leader><space>";
            mode = "n";
            lua = true;
            action = "function() Snacks.picker.files() end";
            desc = "Find Files";
          }
          {
            key = "<leader>,";
            mode = "n";
            lua = true;
            action = "function() Snacks.picker.buffers() end";
            desc = "Buffers";
          }
          {
            key = "<leader>fb";
            mode = "n";
            lua = true;
            action = "function() Snacks.picker.buffers() end";
            desc = "Buffers";
          }
          {
            key = "<leader>/";
            mode = "n";
            lua = true;
            action = "function() Snacks.picker.grep() end";
            desc = "Grep";
          }
          {
            key = "<leader>sg";
            mode = "n";
            lua = true;
            action = "function() Snacks.picker.grep() end";
            desc = "Grep";
          }
          {
            key = "<leader>sw";
            mode = [
              "n"
              "x"
            ];
            lua = true;
            action = "function() Snacks.picker.grep_word() end";
            desc = "Visual selection or word";
          }
          {
            key = "<leader>fr";
            mode = "n";
            lua = true;
            action = "function() Snacks.picker.recent() end";
            desc = "Recent";
          }
          {
            key = "<leader>sh";
            mode = "n";
            lua = true;
            action = "function() Snacks.picker.help() end";
            desc = "Help Pages";
          }
          {
            key = "<leader>sR";
            mode = "n";
            lua = true;
            action = "function() Snacks.picker.resume() end";
            desc = "Resume";
          }
          {
            key = "<leader>sd";
            mode = "n";
            lua = true;
            action = "function() Snacks.picker.diagnostics() end";
            desc = "Diagnostics";
          }
          {
            key = "<leader>ss";
            mode = "n";
            lua = true;
            action = "function() Snacks.picker.lsp_symbols() end";
            desc = "Goto Symbol";
          }
          {
            key = "<leader>sS";
            mode = "n";
            lua = true;
            action = "function() Snacks.picker.lsp_workspace_symbols() end";
            desc = "Goto Symbol (Workspace)";
          }

          # quit (Lazy default)
          {
            key = "<leader>qq";
            mode = "n";
            action = "<cmd>qa<cr>";
            desc = "Quit All";
          }

          # windows and tabs (Lazy default)
          {
            key = "<leader>-";
            mode = "n";
            action = "<C-W>s";
            desc = "Split Window Below";
          }
          {
            key = "<leader>|";
            mode = "n";
            action = "<C-W>v";
            desc = "Split Window Right";
          }
          {
            key = "<leader>wd";
            mode = "n";
            action = "<C-W>c";
            desc = "Delete Window";
          }
          {
            key = "<leader><tab>l";
            mode = "n";
            action = "<cmd>tablast<cr>";
            desc = "Last Tab";
          }
          {
            key = "<leader><tab>o";
            mode = "n";
            action = "<cmd>tabonly<cr>";
            desc = "Close Other Tabs";
          }
          {
            key = "<leader><tab>f";
            mode = "n";
            action = "<cmd>tabfirst<cr>";
            desc = "First Tab";
          }
          {
            key = "<leader><tab><tab>";
            mode = "n";
            action = "<cmd>tabnew<cr>";
            desc = "New Tab";
          }
          {
            key = "<leader><tab>]";
            mode = "n";
            action = "<cmd>tabnext<cr>";
            desc = "Next Tab";
          }
          {
            key = "<leader><tab>d";
            mode = "n";
            action = "<cmd>tabclose<cr>";
            desc = "Close Tab";
          }
          {
            key = "<leader><tab>[";
            mode = "n";
            action = "<cmd>tabprevious<cr>";
            desc = "Previous Tab";
          }

          # terminal (Lazy defaults for fT/ft; <leader><leader> is yours)
          {
            key = "<leader>fT";
            mode = "n";
            lua = true;
            action = "function() Snacks.terminal() end";
            desc = "Terminal (cwd)";
          }
          {
            key = "<leader><leader>";
            mode = "n";
            lua = true;
            action = "function() Snacks.terminal() end";
            desc = "Terminal";
          }
          {
            key = "<c-/>";
            mode = [
              "n"
              "t"
            ];
            lua = true;
            action = "function() Snacks.terminal.toggle() end";
            desc = "Toggle Terminal";
          }
          {
            key = "<c-_>";
            mode = [
              "n"
              "t"
            ];
            lua = true;
            action = "function() Snacks.terminal.toggle() end";
            desc = "which_key_ignore";
          }

          # tmux navigator (yours, was VimTmuxNaviagator.lua;
          # overrides Lazy's <C-h/j/k/l> window nav)
          {
            key = "<c-h>";
            mode = "n";
            action = "<cmd><C-U>TmuxNavigateLeft<cr>";
          }
          {
            key = "<c-j>";
            mode = "n";
            action = "<cmd><C-U>TmuxNavigateDown<cr>";
          }
          {
            key = "<c-k>";
            mode = "n";
            action = "<cmd><C-U>TmuxNavigateUp<cr>";
          }
          {
            key = "<c-l>";
            mode = "n";
            action = "<cmd><C-U>TmuxNavigateRight<cr>";
          }
          {
            key = "<c-\\>";
            mode = "n";
            action = "<cmd><C-U>TmuxNavigatePrevious<cr>";
          }

          # supertab (yours, was supertab.lua): Tab cycles cmp / jumps / completes
          {
            key = "<Tab>";
            mode = [
              "i"
              "s"
            ];
            lua = true;
            action = ''
              function(fallback)
                local cmp = require('cmp')
                local unpack_ = unpack or table.unpack
                local line, col = unpack_(vim.api.nvim_win_get_cursor(0))
                local has_words_before = col ~= 0
                  and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
                if cmp.visible() then
                  cmp.select_next_item()
                elseif vim.snippet.active({ direction = 1 }) then
                  vim.schedule(function() vim.snippet.jump(1) end)
                elseif has_words_before then
                  cmp.complete()
                else
                  fallback()
                end
              end
            '';
            desc = "Super Tab";
          }
          {
            key = "<S-Tab>";
            mode = [
              "i"
              "s"
            ];
            lua = true;
            action = ''
              function(fallback)
                local cmp = require('cmp')
                if cmp.visible() then
                  cmp.select_prev_item()
                elseif vim.snippet.active({ direction = -1 }) then
                  vim.schedule(function() vim.snippet.jump(-1) end)
                else
                  fallback()
                end
              end
            '';
            desc = "Super Shift-Tab";
          }

          # search and replace (was grug-far.nvim, <leader>sr)
          {
            key = "<leader>sr";
            mode = [
              "n"
              "x"
            ];
            action = "<cmd>GrugFar<cr>";
            desc = "Search and Replace";
          }

          # sessions (was persistence.nvim)
          {
            key = "<leader>qs";
            mode = "n";
            lua = true;
            action = "function() require('persistence').load() end";
            desc = "Restore Session";
          }
          {
            key = "<leader>ql";
            mode = "n";
            lua = true;
            action = "function() require('persistence').load({ last = true }) end";
            desc = "Restore Last Session";
          }
          {
            key = "<leader>qd";
            mode = "n";
            lua = true;
            action = "function() require('persistence').stop() end";
            desc = "Don't Save Current Session";
          }
          {
            key = "<leader>qS";
            mode = "n";
            lua = true;
            action = "function() require('persistence').select() end";
            desc = "Select Session";
          }

          # todo comments (was todo-comments.nvim)
          {
            key = "]t";
            mode = "n";
            lua = true;
            action = "function() require('todo-comments').jump_next() end";
            desc = "Next Todo Comment";
          }
          {
            key = "[t";
            mode = "n";
            lua = true;
            action = "function() require('todo-comments').jump_prev() end";
            desc = "Previous Todo Comment";
          }
          {
            key = "<leader>xt";
            mode = "n";
            action = "<cmd>TodoTrouble<cr>";
            desc = "Todo (Trouble)";
          }

          # markdown browser preview (was markdown-preview.nvim)
          {
            key = "<leader>cp";
            mode = "n";
            action = "<cmd>MarkdownPreviewToggle<cr>";
            desc = "Markdown Preview";
          }

          # yank ring cycling (was yanky.nvim)
          {
            key = "[y";
            mode = "n";
            action = "<Plug>(YankyCycleForward)";
            desc = "Cycle Forward Through Yank History";
          }
          {
            key = "]y";
            mode = "n";
            action = "<Plug>(YankyCycleBackward)";
            desc = "Cycle Backward Through Yank History";
          }
        ];
      };
    };
  };
}
