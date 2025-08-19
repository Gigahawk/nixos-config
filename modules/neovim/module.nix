{ inputs, system, ... }:
{
  environment.systemPackages = [
    inputs.self.packages.${system}.nvim
  ];
  # Disable base neovim and use nvf config instead
  programs.neovim.enable = false;
}
