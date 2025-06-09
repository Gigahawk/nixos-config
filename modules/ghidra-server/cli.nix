{
  writeShellScriptBin,
  writeText,

  directory,
  jdkPackage,
  package
}:

let
  server_conf = writeText "server.conf" "ghidra.repositories.dir=${directory}/repositories";
in writeShellScriptBin "ghidra-svrAdmin" ''
  exec ${jdkPackage}/bin/java \
    -cp ${package}/lib/ghidra/Ghidra/Framework/Utility/lib/Utility.jar \
    -Djava.system.class.loader=ghidra.GhidraClassLoader \
    -Dfile.encoding=UTF8 \
    -Duser.country=US -Duser.language=en -Duser.variant= \
    -Xshare:off ghidra.Ghidra ghidra.server.ServerAdmin \
    ${server_conf} "$@"
''
