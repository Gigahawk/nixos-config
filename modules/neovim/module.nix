{ inputs, pkgs, ... }:
{
  environment.systemPackages = [
    inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.nvim
  ];
  # Disable base neovim and use nvf config instead
  programs.neovim.enable = false;
}
