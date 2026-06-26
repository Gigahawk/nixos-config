final: prev: {
  yt-dlp = prev.yt-dlp.overrideAttrs (
    finalAttrs: prevAttrs: rec {
      version = "2026.06.09";
      src = prev.fetchFromGitHub {
        inherit (prevAttrs.src) owner repo;
        tag = version;
        hash = "sha256-ykqTDPzKKIWRGSQmw2esCRKyYqDZKXRYDeba888tkDU=";
      };
    }
  );
}
