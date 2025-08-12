{
  pkg,
  lib,
  pkgs,
  ...
}: {
  vim = {
    viAlias = true;
    vimAlias = true;

    spellcheck = {
      enable = true;
      #programmingWordlist.enable = true;
    };

    lsp = {
      enable = true;

      formatOnSave = true;

      lightbulb.enable = true;
      trouble.enable = true;
      #lspSignature.enable = true;
    };

    languages = {
      enableFormat = true;
      enableTreesitter = true;
      enableExtraDiagnostics = true;

      nix.enable = true;
      markdown.enable = true;
      bash.enable = true;
      clang.enable = true;
      css.enable = true;
      html.enable = true;
      sql.enable = true;
      java.enable = true;
      kotlin.enable = true;
      ts.enable = true;
      go.enable = true;
      lua.enable = true;
      zig.enable = true;
      python.enable = true;
      typst.enable = true;
      rust = {
        enable = true;
        crates.enable = true;
      };
      dart.enable = true;
      ruby.enable = true;
    };

    visuals = {
      nvim-scrollbar.enable = true;
      nvim-web-devicons.enable = true;
      nvim-cursorline.enable = true;
      cinnamon-nvim.enable = true;
      fidget-nvim.enable = true;
      highlight-undo.enable = true;
      indent-blankline.enable = true;

      cellular-automaton.enable = false;
    };

    statusline = {
      lualine = {
        enable = true;
        theme = "catppuccin";
      };
    };

    theme = {
      enable = true;
      name = "catppuccin";
      style = "mocha";
      transparent = false;
    };

    autopairs.nvim-autopairs.enable = true;

    autocomplete = {
      nvim-cmp.enable = false;
      blink-cmp.enable = true;
    };

    snippets.luasnip.enable = true;

    filetree.neo-tree.enable = true;

    tabline.nvimBufferline.enable = true;

    treesitter.context.enable = true;

    binds = {
      whichKey.enable = true;
      cheatsheet.enable = true;
    };

    telescope.enable = true;

    git = {
      enable = true;
      gitsigns = {
        enable = true;
        # TODO: what does this mean? Apparently disabled by default due to some annoying debug msgs
        codeActions.enable = false;
      };
      neogit.enable = true;
    };

    minimap = {
      minimap-vim.enable = false;
      codewindow.enable = true;
    };

    dashboard = {
      dashboard-nvim.enable = false;
      alpha.enable = true;
    };

    notify.nvim-notify.enable = true;

    projects.project-nvim.enable = true;

    utility = {
      ccc.enable = true;
      vim-wakatime.enable = false;
      diffview-nvim.enable = true;
      yanky-nvim = {
        enable = true;
        setupOpts = {
          ring.storage = "sqlite";
          # disable for now to avoid annoying clipboard read warnings from kitty (OSC 52)
          system_clipboard.sync_with_ring = false;
        };
      };
      icon-picker.enable = true;
    };

    extraPlugins = {
      guess-indent = {
        package = pkgs.vimPlugins.guess-indent-nvim;
        setup = "require('guess-indent').setup {}";
      };
    };
  };
}
