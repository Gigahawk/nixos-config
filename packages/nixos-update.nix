{ writeShellScriptBin
, nix-output-monitor
, nixos-rebuild
, ...
}:

writeShellScriptBin "nixos-update" ''
  ${nixos-rebuild}/bin/nixos-rebuild \
    --log-format internal-json -v \
    --flake github:Gigahawk/nixos-config --refresh \
    "$@" \
    |& ${nix-output-monitor}/bin/nom --json
''
