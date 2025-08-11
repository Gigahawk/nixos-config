{ inputs, system, ... }:
{
  environment.systemPackages = [
    inputs.self.packages.${system}.nvim
  ];
  #programs.neovim = {
  #  enable = true;
  #  defaultEditor = true;
  #  viAlias = true;
  #  vimAlias = true;
  #};
}
