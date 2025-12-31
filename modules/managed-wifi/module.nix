{ config, ... }:
{
  networking.wireless = {
    secretsFile = config.age.secrets.wifi-env.path;
    networks = {
      gameboy.pskRaw = "ext:GAMEBOY_PASS";
      gameboy-5GHz.pskRaw = "ext:GAMEBOY_PASS";
    };
  };
}
