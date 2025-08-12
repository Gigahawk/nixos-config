{
  config,
  pkgs,
  ...
}: {
  home.username = "jasper";
  home.homeDirectory = "/home/jasper";

  home.stateVersion = "23.05";

  programs.home-manager.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      "$term" = "kitty";
      "$menu" = "walker";

      input.touchpad = {
        natural_scroll = true;
      };

      bind =
        [
          "$mod, Return, exec, $term"

          "$mod, D, exec, $menu"

          "$mod, Q, killactive"

          "$mod, H, movefocus, l"
          "$mod, J, movefocus, d"
          "$mod, K, movefocus, u"
          "$mod, L, movefocus, r"

          "$mod SHIFT, H, movewindow, l"
          "$mod SHIFT, J, movewindow, d"
          "$mod SHIFT, K, movewindow, u"
          "$mod SHIFT, L, movewindow, r"
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
    };
  };
  services.walker = {
    enable = true;
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
}
