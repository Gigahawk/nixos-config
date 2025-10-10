final: prev: {
  yt-dlp = prev.yt-dlp.overrideAttrs (old: rec {
    version = "2025.3.26";
    src = prev.fetchPypi {
      inherit version;
      pname = "yt_dlp";
      hash = "sha256-R0Vhcrx6iNuhxRn+QtgAh6j1MMA9LL8k4GCkH48fbss=";
    };
    # Disable https://github.com/NixOS/nixpkgs/commit/c32729c079419a776abfc5808c978e9a3f0e9fb1
    # idk why we need to do this
    postPatch = ''
      true
    '';
  });
}
