{ config, lib, pkgs, modulesPath, options, ... }:
{

  raspi4.config = options.raspi4.config.default // {
    cm4 = {
      # Disable traditional dwc-otg driver
      # to allow dwc2 to work
      otg_mode = 0;
    };
  };

  hardware.raspberry-pi."4" = {
    apply-overlays-dtmerge.enable = true;
    tc358743 = {
      enable = true;
      lanes = 4;
    };
    i2c1.enable = true;
  };

  hardware.deviceTree = {
    enable = true;
    filter = "bcm2711-rpi-cm4.dtb";
    overlays = [
      rec {
        name = "dwc2";
        dtboFile = "${config.boot.kernelPackages.kernel}/dtbs/overlays/${name}.dtbo";
      }

      # Use one from nixos-hardware to support overriding number of lanes
      #rec {
      #  name = "tc358743";
      #  dtboFile = "${config.boot.kernelPackages.kernel}/dtbs/overlays/${name}.dtbo";
      #}

      # Doesn't seem to work? use nixos-hardware one instead
      #rec {
      #  name = "i2c1";
      #  dtboFile = "${config.boot.kernelPackages.kernel}/dtbs/overlays/${name}.dtbo";
      #}

      # RTC for BliKVM PCIe
      {
        name = "pcf8563-overlay";
        dtsText = ''
          /dts-v1/;
          /plugin/;

          / {
            compatible = "brcm,bcm2711";

            fragment@0 {
              target = <&i2c1>;

              __overlay__ {
                #address-cells = <1>;
                #size-cells = <0>;
                status = "okay";

                pcf8563: pcf8563@51 {
                  compatible = "nxp,pcf8563";
                  reg = <0x51>;
                };
              };
            };
          };
        '';
      }
    ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s3.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}

