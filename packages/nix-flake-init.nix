{
  writeShellScriptBin,
  nix,
  git,
  ...
}:
writeShellScriptBin "nfi" ''
  ${git}/bin/git init

  ${nix}/bin/nix flake init \
    --refresh \
    -t github:Gigahawk/flake-templates#"$@"
''
