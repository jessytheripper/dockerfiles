#!/bin/bash

STEAM_VOLUME="/home/steam"
STEAMCMD="$STEAM_VOLUME/steamcmd"
EXILESERVER_TMP_DIR="/tmp/exileServer"
#EXILE_TMP_DIR="/tmp/exile"
ARMA3_DIR="$STEAMCMD/arma3/"
WGET_BIN=$(command -v wget)
UNZIP_BIN=$(command -v unzip)
MYSQL_BIN=$(command -v mysql)

if [ ! -z ${EXILE_UPDATE_DATA+x} ] || [ ! -d $ARMA3_DIR/\@exileserver ]; then
    echo "Fetching Exile content..."
    $WGET_BIN -O /tmp/\@ExileServer-latest.zip http://dl.jessytheripper.com/@ExileServer-latest.zip
    $WGET_BIN -O /tmp/\@Exile-latest.zip http://dl.jessytheripper.com/@Exile-latest.zip
    $UNZIP_BIN /tmp/\@ExileServer-latest.zip -d $EXILESERVER_TMP_DIR
    $UNZIP_BIN /tmp/\@Exile-latest.zip -d $ARMA3_DIR/

    echo "Moving MySQL files..."
    mv  $EXILESERVER_TMP_DIR/MySQL/ $ARMA3_DIR/MySQL/

    echo "Moving ExileServer files.."
    mv $EXILESERVER_TMP_DIR/Arma3Server/\@ExileServer $ARMA3_DIR/\@exileserver

    echo "Moving Battleye files..."
    mv $EXILESERVER_TMP_DIR/Arma3Server/battleye/* $ARMA3_DIR/battleye/

    echo "Moving key files..."
    mv $EXILESERVER_TMP_DIR/Arma3Server/keys/* $ARMA3_DIR/keys/

    echo "Moving mpmissions..."
    mv $EXILESERVER_TMP_DIR/Arma3Server/mpmissions/* $ARMA3_DIR/mpmissions/*

    echo "Moving tbb file..."
    mv $EXILESERVER_TMP_DIR/Arma3Server/tbbmalloc.dll $ARMA3_DIR/
    
    echo "Renaming Exile client directory..."
    mv $ARMA3_DIR/\@Exile $ARMA3_DIR\@exile

    echo "Getting Tanoa mission files..."
    $WGET_BIN -O /tmp/master.zip https://github.com/d4n1ch/acd_Tanoa_MF/archive/master.zip
    $UNZIP_BIN /tmp/master.zip -d /tmp/

    echo "Applying Tanoa mission files..."
    cp -r /tmp/acd_Tanoa_MF-master/mpmissions/* $ARMA3_DIR/mpmissions/
fi

if [ ! -z ${INIT_DATABASE+x} ] || [ ! -z ${MYSQL_ROOT_PASSWORD} ]; then
    echo "Initializing user and database..."
    $MYSQL_BIN -u root -p$MYSQL_ROOT_PASSWORD -h exiledb -e "CREATE DATABASE exile;"
    MYSQL_USER_PASSWORD=$(cat /dev/urandom| tr -dc 'a-zA-Z0-9!#' | fold -w 15 | head -1)
    $MYSQL_BIN -u root -p$MYSQL_ROOT_PASSWORD -h exiledb -e "CREATE USER 'exile'@'%' IDENTIFIED BY '$MYSQL_USER_PASSWORD'; FLUSH PRIVILEGES;"
    $MYSQL_BIN -u root -p$MYSQL_ROOT_PASSWORD -h exiledb -e "GRANT ALL PRIVILEGES ON exile.* TO 'exile'@'%'; FLUSH PRIVILEGES;"

    echo "Populating MySQL database..."
    $MYSQL_BIN -u exile -p$MYSQL_USER_PASSWORD -h exiledb < $ARMA3_DIR/MySQL/exile.sql

    echo "Configuring extDB2..."
    sed -i "s/Username = changeme/Username = exile/g" $ARMA3_DIR/\@exileserver/extdb-conf.ini
    sed -i "s/Password =.*/Password = $MYSQL_USER_PASSWORD/g" $ARMA3_DIR/\@exileserver/extdb-conf.ini
    sed -i "s/127.0.0.1/exiledb/" $ARMA3_DIR/\@exileserver/extdb-conf.ini
    echo "MySQL password for exile user: $MYSQL_USER_PASSWORD"
fi

mv $ARMA3_DIR/\@exileserver/config.cfg $ARMA3_DIR/

cd $ARMA3_DIR && ./arma3server -config=config.cfg -mod=@exile -servermod=@exileserver -autoinit
