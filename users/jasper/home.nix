{
  config,
  pkgs,
  desktop,
  inputs,
  system,
  ...
}:
let
  nnn = pkgs.nnn.override {
    withNerdIcons = true;
    # Something about regex support?
    withPcre = true;
  };

in
{
  imports = [
    inputs.ironbar.homeManagerModules.default
  ];
  home.username = "jasper";
  home.homeDirectory = "/home/jasper";

  home.stateVersion = "23.05";

  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };

  programs.nnn = {
    enable = true;
    package = nnn;
    plugins = {
      src = inputs.nnn-plugins + "/plugins";
    };
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

      bind = [
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

        "$mod, P, exec, wlogout"
      ]
      ++ (builtins.concatLists (
        builtins.genList (
          i:
          let
            ws = i + 1;
            keycode = 10 + i;
          in
          [
            "$mod, code:${toString keycode}, workspace, ${toString ws}"
            "$mod SHIFT, code:${toString keycode}, movetoworkspace, ${toString ws}"
          ]
        ) 10
      ));

      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        "SHIFT, XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%+"
        "SHIFT, XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%-"

        ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];

      bindl = [
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
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

  services.udiskie = {
    enable = true;
    settings = {
      program_options = {
        file_manager = "${nnn}/bin/nnn";
      };
    };
  };

  programs.waybar = {
    #enable = desktop;
    settings =
      let
        batConfig = bat: {
          inherit bat;
          interval = 1;
          states = {
            # good = 95;
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-full = "{capacity}% {icon}";
          format-charging = "{capacity}% 󰂄";
          format-plugged = "{capacity}% ";
          format-alt = "{time} {icon}";
          # format-good = ""; # An empty format will hide the module
          # format-full = "";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
        };
      in
      {
        mainBar = {
          # Is this required for fullscreen to work properly?
          layer = "bottom";
          position = "top";
          spacing = 0;
          margins = "0 0 0 0";

          modules-left = [
            "tray"
            "hyprland/workspaces"
          ];
          modules-center = [
            "hyprland/window"
          ];
          modules-right = [
            "disk"
            "group/perfgroup"
            "backlight"
            "wireplumber"
            # TODO: battery should only be displayed on hosts with battery?
            "group/batterygroup"
            "network"
            "clock"
          ];

          "tray" = {
            icon-size = 21;
            spacing = 1;
          };

          "clock" = {
            interval = 1;
            format = "{:%F %a\n%T}";
            justify = "center";
          };

          "network" = {
            interval = 1;
            format-wifi = "{essid}\n ({signalStrength}%)";
            format-ethernet = "{ipaddr}/{cidr} ";
            tooltip-format = "{ifname} via {gwaddr} ";
            format-linked = "{ifname} (No IP) ";
            format-disconnected = "Disconnected ⚠";
            format-alt = "{ifname}: {ipaddr}/{cidr}";
            justify = "center";
          };

          "group/batterygroup" = {
            orientation = "vertical";
            # TODO: This should be defined per host?
            modules = [
              "battery#ariosbat0"
              "battery#ariosbat1"
            ];
          };

          "battery#ariosbat0" = batConfig "BAT0";
          "battery#ariosbat1" = batConfig "BAT1";

          "group/perfgroup" = {
            orientation = "vertical";
            modules = [
              "cpu"
              "memory"
            ];
          };

          "cpu" = {
            interval = 1;
            format = "{usage}% ";
          };

          "memory" = {
            interval = 1;
            format = "{}% ";
          };

          "disk" = {
            interval = 30;
            # TODO: Some hosts  might want more than one of these modules
            # i.e. ptolemy might want for monitoring pool usage
            # Maybe put these in a dropdown? How to show which disk is being indicated?
            path = "/";
            format = "{percentage_used}% ";
          };

          "wireplumber" = {
            # scroll-step: 1, # %, can be a float
            format = "{volume}% {icon}\n{format_source}";
            format-bluetooth = "{volume}% {icon}\n{format_source}";
            format-bluetooth-muted = " {icon}\n{format_source}";
            # volume-xmark displays as Ŷ in vim due to wrong font awesome font awesome fallback or something?
            format-muted = "\n{format_source}";
            format-source = "{volume}% ";
            format-source-muted = "";
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = [
                ""
                ""
                ""
              ];
            };
            justify = "center";
            #on-click = "pavucontrol"
          };

          "backlight" = {
            # device = "acpi_video1";
            format = "{percent}% {icon}";
            format-icons = [
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
            ];
          };
        };
      };

    style = ''

      * {
          /* `otf-font-awesome` is required to be installed for icons */
          font-family: Roboto, "Font Awesome 6 Free Solid", sans-serif;
          font-size: 13px;
      }

      window#waybar {
          background-color: rgba(43, 48, 59, 0.5);
          border-bottom: 3px solid rgba(100, 114, 125, 0.5);
          color: #ffffff;
          transition-property: background-color;
          transition-duration: .5s;
      }

      window#waybar.hidden {
          opacity: 0.2;
      }

      /*
      window#waybar.empty {
          background-color: transparent;
      }
      window#waybar.solo {
          background-color: #FFFFFF;
      }
      */

      window#waybar.termite {
          background-color: #3F3F3F;
      }

      window#waybar.chromium {
          background-color: #000000;
          border: none;
      }

      button {
          /* Use box-shadow instead of border so the text isn't offset */
          box-shadow: inset 0 -3px transparent;
          /* Avoid rounded borders under each button name */
          border: none;
          border-radius: 0;
      }

      /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
      button:hover {
          background: inherit;
          box-shadow: inset 0 -3px #ffffff;
      }

      /* you can set a style on hover for any module like this */
      #pulseaudio:hover {
          background-color: #a37800;
      }

      #workspaces button {
          padding: 0 5px;
          background-color: transparent;
          color: #ffffff;
      }

      #workspaces button:hover {
          background: rgba(0, 0, 0, 0.2);
      }

      /* #workspaces button.focused { */
      #workspaces button.active {
          background-color: #64727D;
          box-shadow: inset 0 -3px #ffffff;
      }

      #workspaces button.urgent {
          background-color: #eb4d4b;
      }

      #mode {
          background-color: #64727D;
          box-shadow: inset 0 -3px #ffffff;
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #disk,
      #temperature,
      #backlight,
      #network,
      #pulseaudio,
      #wireplumber,
      #custom-media,
      #tray,
      #mode,
      #idle_inhibitor,
      #scratchpad,
      #power-profiles-daemon,
      #mpd {
          padding: 0 10px;
          color: #ffffff;
      }

      #window,
      #workspaces {
          margin: 0 4px;
      }

      /* If workspaces is the leftmost module, omit left margin */
      .modules-left > widget:first-child > #workspaces {
          margin-left: 0;
      }

      /* If workspaces is the rightmost module, omit right margin */
      .modules-right > widget:last-child > #workspaces {
          margin-right: 0;
      }

      #clock {
          background-color: #64727D;
      }

      #battery {
          background-color: #ffffff;
          color: #000000;
      }

      #battery.charging, #battery.plugged {
          color: #ffffff;
          background-color: #26A65B;
      }

      #battery.critical:not(.charging) {
          background-color: #f53c3c;
          color: #ffffff;
      }

      #power-profiles-daemon {
          padding-right: 15px;
      }

      #power-profiles-daemon.performance {
          background-color: #f53c3c;
          color: #ffffff;
      }

      #power-profiles-daemon.balanced {
          background-color: #2980b9;
          color: #ffffff;
      }

      #power-profiles-daemon.power-saver {
          background-color: #2ecc71;
          color: #000000;
      }

      label:focus {
          background-color: #000000;
      }

      #cpu {
          background-color: #2ecc71;
          color: #000000;
      }

      #memory {
          background-color: #9b59b6;
      }

      #disk {
          background-color: #964B00;
      }

      #backlight {
          background-color: #90b1b1;
      }

      #network {
          background-color: #2980b9;
      }

      #network.disconnected {
          background-color: #f53c3c;
      }

      #pulseaudio {
          background-color: #f1c40f;
          color: #000000;
      }

      #pulseaudio.muted {
          background-color: #90b1b1;
          color: #2a5c45;
      }

      #wireplumber {
          background-color: #fff0f5;
          color: #000000;
      }

      #wireplumber.muted {
          background-color: #f53c3c;
      }

      #custom-media {
          background-color: #66cc99;
          color: #2a5c45;
          min-width: 100px;
      }

      #custom-media.custom-spotify {
          background-color: #66cc99;
      }

      #custom-media.custom-vlc {
          background-color: #ffa000;
      }

      #temperature {
          background-color: #f0932b;
      }

      #temperature.critical {
          background-color: #eb4d4b;
      }

      #tray {
          background-color: #2980b9;
      }

      #tray > .passive {
          -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
          -gtk-icon-effect: highlight;
          background-color: #eb4d4b;
      }

      #idle_inhibitor {
          background-color: #2d3436;
      }

      #idle_inhibitor.activated {
          background-color: #ecf0f1;
          color: #2d3436;
      }

      #mpd {
          background-color: #66cc99;
          color: #2a5c45;
      }

      #mpd.disconnected {
          background-color: #f53c3c;
      }

      #mpd.stopped {
          background-color: #90b1b1;
      }

      #mpd.paused {
          background-color: #51a37a;
      }

      #language {
          background: #00b093;
          color: #740864;
          padding: 0 5px;
          margin: 0 5px;
          min-width: 16px;
      }

      #keyboard-state {
          background: #97e1ad;
          color: #000000;
          padding: 0 0px;
          margin: 0 5px;
          min-width: 16px;
      }

      #keyboard-state > label {
          padding: 0 5px;
      }

      #keyboard-state > label.locked {
          background: rgba(0, 0, 0, 0.2);
      }

      #scratchpad {
          background: rgba(0, 0, 0, 0.2);
      }

      #scratchpad.empty {
        background-color: transparent;
      }

      #privacy {
          padding: 0;
      }

      #privacy-item {
          padding: 0 5px;
          color: white;
      }

      #privacy-item.screenshare {
          background-color: #cf5700;
      }

      #privacy-item.audio-in {
          background-color: #1ca000;
      }

      #privacy-item.audio-out {
          background-color: #0069d4;
      }
    '';
  };

  programs.ironbar = {
    enable = true;
    config = {
      start = [
        {
          type = "tray";
        }
        {
          type = "workspaces";
        }
      ];
      center = [ ];
      end = [ ];
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

  programs.brave = {
    enable = desktop;
    commandLineArgs = [
      "--force-dark-mode"
    ];
    dictionaries = [
      pkgs.hunspellDictsChromium.en_US
    ];
    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
      { id = "gfbliohnnapiefjpjlpjnehglfpaknnc"; } # surfingkeys
      { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # darkreader
      {
        id = "dcpihecpambacapedldabdbpakmachpb";
        updateUrl = "https://raw.githubusercontent.com/iamadamdev/bypass-paywalls-chrome/master/updates.xml";
      }
    ];
  };

  programs.firefox = {
    enable = desktop;
    policies = {
      AppAutoUpdate = false;
      # Ideally this would be off but apparently it's
      # the only way to see valid settings values???
      #BlockAboutConfig = true;
      ManagedBookmarks = [
      ];
      DisablePocket = true;
      DisableProfileImport = true;
      DisableProfileRefresh = true;
      DisableSetDesktopBackground = true;
      DisableTelemetry = true;
      DisableThirdPartyModuleBlocking = true;
      DisplayBookmarksToolbar = true;
      DisplayMenuBar = false;
      # TODO: migrate these to use NUR?
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          default_area = "menupanel";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
          private_browsing = true;
        };
        "addon@darkreader.org" = {
          default_area = "menupanel";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
          installation_mode = "force_installed";
          private_browsing = true;
        };
        #"{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
        #  default_area = "menupanel";
        #  install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-ff/latest.xpi";
        #  installation_mode = "force_installed";
        #  private_browsing = true;
        #};
        "{a8332c60-5b6d-41ee-bfc8-e9bb331d34ad}" = {
          default_area = "menupanel";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/surfingkeys_ff/latest.xpi";
          installation_mode = "force_installed";
          private_browsing = true;
        };
      };
    };
    profiles = {
      default = {
        id = 0;
        isDefault = true;
        settings = {
          "browser.startup.homepage" = "https://hackaday.com";
          # This doesn't seem to work?
          "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
        };
        bookmarks = {
          force = true;
          settings = [
            {
              name = "Nixpkgs Search";
              url = "search.nixos.org";
              #toolbar = true;
            }
            {
              name = "Home Manager Options";
              url = "https://nix-community.github.io/home-manager/options.xhtml";
              #toolbar = true;
            }
          ];
        };
      };
    };
  };

  programs.vesktop = {
    enable = desktop;
    settings = {
      discordBranch = "stable";
      transparencyOption = "acrylic";
      tray = true;
      minimizeToTray = true;
      openLinksWithElectron = false;
      enableMenu = true;
      disableSmoothScroll = false;
      hardwareAcceleration = true;
      hardwareVideoAcceleration = true;
      arRPC = false;
      appBadge = true;
      disableMinSize = true;
      clickTrayToShowHide = true;
      customTitleBar = false;

      enableSplashScreen = false;
      splashTheming = false;
      splashColor = "white";
      splashBackground = "black";

      spellCheckLanguages = [ "en" ];

      audio = {
        workaround = false;

        deviceSelect = true;
        granularSelect = true;

        ignoreVirtual = false;
        ignoreDevices = false;
        ignoreInputMedia = false;

        onlySpeakers = false;
        onlyDefaultSpeakers = false;
      };
    };
    vencord = {
      settings = {
        autoUpdate = false;
        autoupdateNotification = false;
        useQuickCss = false;
        eagerPatches = false;
        enabledThemes = [ ];
        enableReactDevtools = false;
        themeLinks = [ ];
        frameless = false;
        transparent = true;
        winCtrlQ = false;
        disableMinSize = true;
        winNativeTitleBar = false;

        plugins = {
          AlwaysAnimate.enabled = true;
          AnonymiseFileNames.enabled = true;
          BetterGifPicker.enabled = true;
          BetterSessions.enabled = true;
          BetterSettings.enabled = true;
          BetterUploadButton.enabled = true;
          BiggerStreamPreview.enabled = true;
          CallTimer.enabled = true;
          ClearURLs.enabled = true;
          CopyFileContents.enabled = true;
          FakeNitro.enabled = true;
          FixImagesQuality.enabled = true;
          FixSpotifyEmbeds.enabled = true;
          FixYoutubeEmbeds.enabled = true;
          FriendsSince.enabled = true;
          FullSearchContext.enabled = true;
          ImageZoom.enabled = true;
          MessageLatency.enabled = true;
          MessageLinkEmbeds = true;
          MessageLogger.enabled = true;
          NoOnboardingDelay.enabled = true;
          NoTrack.enabled = true;
          ReverseImageSearch.enabled = true;
          Settings.enabled = true;
          YoutubeAdblock.enabled = true;
        };

        notifications = {
          timeout = 1;
          position = "top-right";
          useNative = "never";
          logLimit = 2;
        };
      };
      themes = {
      };
    };
  };
}
