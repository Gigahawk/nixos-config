{ config, pkgs, ... }:
pkgs.writeShellScriptBin "xmpp-alert" ''
  export XMPPBRIDGE_JID=$(cat ${config.age.secrets.xmpp-jid.path})
  export XMPPBRIDGE_PASSWORD=$(cat ${config.age.secrets.xmpp-password.path})
  export XMPPBRIDGE_PEER_JID=$(cat ${config.age.secrets.xmpp-target-jid.path})
  xmpp-bridge $@
''