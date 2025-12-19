{
  pkg,
  lib,
  pkgs,
  ...
}:
{
  vim = {
    viAlias = true;
    vimAlias = true;

    searchCase = "smart";

    spellcheck = {
      enable = true;
      #programmingWordlist.enable = true;
    };

    keymaps =
      let
        # Visual append similar to vscodevim
        # Behavior:
        # - Visual block mode: fall back to standard neovim behavior
        # - Visual line mode: emulate VSCode behavior
        # - Visual mode: not implemented, can't think of why you would want to do this anyways
        visual-insert-keybind = key: {
          inherit key;
          mode = [ "x" ];
          lua = true;
          action = ''
            function()
              -- Only do this in visual line mode
              local mode = vim.fn.mode()
              if mode ~= "V" then
                vim.api.nvim_feedkeys("${key}", "n", false)
                return
              end

              -- Cache visual line numbers
              local l1 = vim.fn.getpos(".")[2]
              local lorig = l1
              local l2 = vim.fn.getpos("v")[2]

              if l1 > l2 then
                l1, l2 = l2, l1
              end

              -- Exit visual, go into append mode
              vim.api.nvim_feedkeys(
                vim.api.nvim_replace_termcodes(
                  "<Esc>${key}", true, false, true
                ),
                "n",
                false
              )

              vim.api.nvim_create_autocmd("InsertLeave", {
                once = true,
                callback = function()
                  local cursor_pos = vim.api.nvim_win_get_cursor(0)

                  for lnum = l1, l2 do
                    -- Move to each non blank line and reapply the last insert
                    local line = vim.fn.getline(lnum)
                    if line:match("%S") and lnum ~= lorig then
                      vim.api.nvim_feedkeys(
                        vim.api.nvim_replace_termcodes(
                          ":" .. tostring(lnum) .. "<CR>.", true, false, true
                        ),
                        "n",
                        false
                      )
                    end
                  end

                  -- Return cursor to original location
                  -- Doesn't seem to work?
                  --vim.api.nvim_win_set_cursor(0, cursor_pos)
                  vim.api.nvim_feedkeys(
                    vim.api.nvim_replace_termcodes(
                      ":" .. tostring(cursor_pos[1]) .. "<CR>" .. tostring(cursor_pos[2] + 1) .. "|",
                      true, false, true
                    ),
                    "n",
                    false
                  )
                end
              })
            end
          '';
        };
      in
      [
        (visual-insert-keybind "A")
        (visual-insert-keybind "I")
        {
          key = "<leader>fe";
          mode = "";
          action = ":Neotree<CR>";
        }
      ];

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

      nix = {
        enable = true;
        lsp.enable = true;
        format = {
          enable = true;
          type = ["nixfmt"];
        };
      };
      markdown = {
        enable = true;
        lsp.enable = true;
        extensions = {
          render-markdown-nvim.enable = true;
        };
      };
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
      python = {
        enable = true;
        format = {
          enable = true;
          type = ["ruff"];
        };
      };
      typst.enable = true;
      rust = {
        enable = true;
        extensions = {
          crates-nvim.enable = true;
        };
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

    filetree.neo-tree = {
      enable = true;
      setupOpts = {
        filesystem = {
          filtered_items = {
            visible = true;
          };
        };
      };
    };

    tabline.nvimBufferline = {
      enable = true;
      mappings = {
        closeCurrent = "<leader>bq";
      };
    };

    treesitter.context.enable = true;

    binds = {
      whichKey.enable = true;
      cheatsheet.enable = true;
    };

    telescope.enable = true;

    runner.run-nvim = {
      enable = true;
    };

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
      # I have no idea how this works, using multicursor.nvim instead
      #multicursors = {
      #  enable = true;
      #};
      ccc.enable = true;
      vim-wakatime.enable = false;
      diffview-nvim.enable = true;
      yanky-nvim = {
        enable = true;
        setupOpts = {
          ring.storage = "sqlite";
          # disable for now to avoid annoying clipboard read warnings from kitty/ghostty (OSC 52)
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
      markdown-toc = {
        package = pkgs.vimPlugins.vim-markdown-toc;
        #setup = "require('vim-markdown-toc').setup {}";
      };
    };

    lazy.plugins = {
      "multicursor.nvim" = {
        package = pkgs.vimPlugins.multicursor-nvim;
        setupModule = "multicursor-nvim";
        after = ''
          local mc = require("multicursor-nvim")

          local set = vim.keymap.set

          set({"n", "x"}, "<up>", function() mc.lineAddCursor(-1) end)
          set({"n", "x"}, "<down>", function() mc.lineAddCursor(1) end)
          set({"n", "x"}, "<leader><up>", function() mc.lineSkipCursor(-1) end)
          set({"n", "x"}, "<leader><down>", function() mc.lineSkipCursor(1) end)
        '';
      };
    };
  };
}
