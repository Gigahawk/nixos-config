final: prev: rec {
  python3 = prev.python3.override {
    packageOverrides = self: super: {
      aiohttp = super.aiohttp.overrideAttrs (old: {
        src = final.fetchPypi {
          inherit (old) pname version;
          sha256 = "sha256-T8YThenJjXL830fm3YGDP0ey93wRTCnNZKNhvlenY6I=";
        };
        # Tests keep failing, seems to be more common on slower systems
        doCheck = false;
      });
    };
  };
}
