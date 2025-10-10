{
  writeShellScriptBin,
  nix-output-monitor,
  nixos-rebuild,
  ...
}:

writeShellScriptBin "vcgencmd_nice" (builtins.readFile ./vcgencmd_nice.sh)
