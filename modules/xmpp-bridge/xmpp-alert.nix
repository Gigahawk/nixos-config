{ config, pkgs, inputs, system, ... }:
pkgs.writeShellScriptBin "xmpp-alert" ''
  export XMPPBRIDGE_JID=$(${pkgs.coreutils}/bin/cat ${config.age.secrets.xmpp-jid.path})
  export XMPPBRIDGE_PASSWORD=$(${pkgs.coreutils}/bin/cat ${config.age.secrets.xmpp-password.path})
  export XMPPBRIDGE_PEER_JID=$(${pkgs.coreutils}/bin/cat ${config.age.secrets.xmpp-target-jid.path})
  ${inputs.xmpp-bridge.packages.${system}.default}/bin/xmpp-bridge $@
''