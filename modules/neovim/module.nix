{ inputs, ... }:
{
  environment.systemPackages = [
    inputs.self.packages.${stdenv.hostPlatform.system}.nvim
  ];
  # Disable base neovim and use nvf config instead
  programs.neovim.enable = false;
}
