{
  config,
  pkgs,
  desktop,
  ...
}: {
  home.username = "jasper";
  home.homeDirectory = "/home/jasper";

  home.stateVersion = "23.05";

  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };

  wayland.windowManager.hyprland = {
    enable = desktop;
    settings = {
      "$mod" = "SUPER";
      "$term" = "ghostty";
      "$menu" = "walker";
      "$bar" = "waybar";

      input.touchpad = {
        natural_scroll = true;
      };

      exec-once = [
        "waybar"
      ];

      bind =
        [
          "$mod, Return, exec, $term"

          "$mod, D, exec, $menu"

          "$mod, Q, killactive"

          "$mod, F, fullscreen"

          "$mod, H, movefocus, l"
          "$mod, J, movefocus, d"
          "$mod, K, movefocus, u"
          "$mod, L, movefocus, r"

          "$mod SHIFT, H, movewindow, l"
          "$mod SHIFT, J, movewindow, d"
          "$mod SHIFT, K, movewindow, u"
          "$mod SHIFT, L, movewindow, r"

          "$mod SHIFT, W, exec, iwmenu -l $menu"
        ]
        ++ (
          builtins.concatLists (builtins.genList (i: let
              ws = i + 1;
            in [
              "$mod, code:1${toString i}, workspace, ${toString ws}"
              "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
            ])
            9)
        );

      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ];

      bindl = [
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ];
    };
  };

  services.walker = {
    enable = desktop;
    settings = {
      app_launch_prefix = "";
      as_window = false;
      close_when_open = false;
      disable_click_to_close = false;
      force_keyboard_focus = false;
      hotreload_theme = false;
      locale = " ";
      monitor = "";
      terminal_title_flag = "";
      theme = "default";
      timeout = 0;
    };
  };

  services.fnott = {
    enable = desktop;
  };

  programs.waybar = {
    enable = desktop;
    settings = {
      mainBar = {
        modules-left = [
          "hyprland/workspaces"
        ];
        modules-center = [
          "hyprland/window"
        ];
        modules-right = [
          "clock"
          "battery"
          "network"
        ];
      };
    };
  };

  programs.ghostty = {
    enable = desktop;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };
}
