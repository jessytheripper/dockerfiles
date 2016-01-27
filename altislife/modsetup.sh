#!/bin/bash

STEAM_VOLUME="/home/steam"
STEAMCMD="$STEAM_VOLUME/steamcmd"
ARMA3_DIR="$STEAMCMD/arma3/"
WGET_BIN=$(command -v wget)
UNZIP_BIN=$(command -v unzip)
MYSQL_BIN=$(command -v mysql)

echo "Fetching AltisLife content..."
$WGET_BIN -O /tmp/AltisLifeLinux.zip http://dl.jessytheripper.com/Altis-life-4.0-Linux.zip

echo "Extracting AltisLife content..."
$UNZIP_BIN /tmp/AltisLifeLinux.zip -d /tmp/

echo "Moving @life_server and @extDB2..."
mv /tmp/Altis-life-4.0-Linux/\@life_server $ARMA3_DIR/
mv /tmp/Altis-life-4.0-Linux/\@extDB2 $ARMA3_DIR/

echo "Moving mpmission AltisLife..."
mv /tmp/Altis-life-4.0-Linux/MPMissions/Altis_Life.Altis.pbo $ARMA3_DIR/mpmissions/

echo "Populating MySQL database..."
$MYSQL_BIN -u root -p$MYSQL_ROOT_PASSWORD -h altislifedb < /tmp/Altis-life-4.0-Linux/arma3life-4.0.sql

echo "Configuring extDB2..."
sed -i "s/Password = password/Password = $MYSQL_ROOT_PASSWORD/g" $ARMA3_DIR/\@extDB2/extdb-conf.ini
sed -i "s/Name = Database_Name/Name = arma3life/g" $ARMA3_DIR/\@extDB2/extdb-conf.ini

cd $STEAMCMD/arma3/ && ./arma3server -name=Altis -config=server.cfg -mod=@life_server;@extDB2
