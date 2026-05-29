# /etc/nixos/hosts/nixos/nvf-configuration.nix
{ config, pkgs, ... }:

{
  programs.nvf = {
    enable = true;

    settings = {
      vim = {
        ## UI / Theme
        theme.enable = true;
        theme.name = "rose-pine";
        theme.style = "moon";
        statusline.lualine.enable = true;
        telescope.enable = true;
        autocomplete.nvim-cmp.enable = true;
        viAlias = false;
        vimAlias = true;

        ## LSP & Treesitter
        languages = {
          enableTreesitter = true;

          nix.enable = true;
          clang.enable = true;
          rust.enable = true;
          python.enable = true;
          markdown.enable = true;
        };

        lsp = {
          enable = true;
          formatOnSave = true;
          lightbulb.enable = true;
          trouble.enable = true;
          nvim-docs-view.enable = true;
        };

        mini.tabline = {
          enable = true;
        };

        filetree.nvimTree = {
          enable = true;
          mappings.toggle = " e";
          setupOpts.hijack_cursor = true;
        };

        utility.snacks-nvim = {
          enable = true;
          setupOpts = {
            bigfile.enable = true;
            dashboard.enable = true;
          };
        };
        autopairs.nvim-autopairs.enable = true;
        comments.comment-nvim.enable = true;
        # useSystemClipboard = true;
        git.gitsigns.enable = true;
        utility.motion.hop.enable = true; # Quick navigation
        utility.surround.enable = true;
        ## Plugins to preload (startPlugins)
        # startPlugins = [
        #   "gitsigns-nvim"
        #   "nvim-tree-lua"
        #   "which-key-nvim"
        #   "telescope"
        # ];

        ## Extra plugins with custom setup
      };
    };
  };
}
