{
  writeShellScriptBin,
  nix-output-monitor,
  nixos-rebuild,
  ...
}:

writeShellScriptBin "nixos-update-local" ''
  ${nixos-rebuild}/bin/nixos-rebuild \
    --log-format internal-json -v \
    --flake . \
    "$@" \
    |& ${nix-output-monitor}/bin/nom --json
''
