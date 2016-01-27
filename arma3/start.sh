#!/bin/bash

STEAM_VOLUME="/home/steam"
STEAMCMD="$STEAM_VOLUME/steamcmd"
ARMA3_INST="$STEAMCMD/arma3_inst.txt"
WGET_BIN=$(command -v wget)
TAR_BIN=$(command -v tar)

if [ ! -d "$STEAMCMD" ]; then
  mkdir $STEAMCMD
fi

cat << EOF > $STEAMCMD/arma3_inst.txt 
// installing arma3
@ShutdownOnFailedCommand 1 //set to 0 if updating multiple servers at once
@NoPromptForPassword 1
login $STEAM_LOGIN $STEAM_PASSWORD
force_install_dir ./arma3/
app_update 233780 validate
quit
EOF

$WGET_BIN -O /tmp/steamcmd_linux.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
$TAR_BIN --overwrite -xvzf /tmp/steamcmd_linux.tar.gz -C $STEAMCMD
$STEAMCMD/steamcmd.sh  +runscript $ARMA3_INST
mkdir -p $HOME/".local/share/Arma 3"
mkdir -p $HOME/".local/share/Arma 3 - Other Profiles"

if [ -z ${ARMA3_SERVER_CFG+x} ]; then
  echo "Using the default server.cfg..."
  cp /tmp/server.cfg $STEAMCMD/arma3/server.cfg
else
  echo "Using custom server.cfg..."
  $WGET_BIN -O $STEAMCMD/arma3/server.cfg $ARMA3_SERVER_CFG
  local STATUS=$?
  if [ $STATUS -ne 0 ]; then
    echo "Unable to fetch server.cfg from remote, falling back to default server.cfg..."
    cp /tmp/server.cfg $STEAMCMD/arma3/server.cfg
  fi
fi

ADMIN_PASSWORD=$(grep passwordAdmin $STEAMCMD/arma3/server.cfg | cut -f2 -d'"')
SERVER_COMMAND_PASSWORD=$(grep serverCommandPassword $STEAMCMD/arma3/server.cfg | cut -f2 -d'"')

echo "admin password: $ADMIN_PASSWORD"
echo "server command password: $SERVER_COMMAND_PASSWORD"

#######################################################
# This is the mod specific part. Anyone can overwrite
# This file to configure a specific mod in top of this 
# Arma3 Docker image. 
# You just need to define $MOD_SCRIPT when running and 
# add it to the image build.

if [ ! -z ${MOD_SCRIPT+x} ] && [ -f $MOD_SCRIPT ]; then
  echo "Launching $MOD_SCRIPT to setup mod for this instance"
  /bin/bash $MOD_SCRIPT
#######################################################
else
  cd $STEAMCMD/arma3/ && ./arma3server -name=public -config=server.cfg
fi
