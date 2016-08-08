# Exile server Dockerfile

## Introduction

This dockerfile is based on the arma3server docker image. It just setup Exile content and start the server with this mod.
The container needs all dependencies from arma3server, plus a MySQL database instance. Read instructions below for further details.

## Building from source

To build from source you need to clone the git repo and run docker build:
```
git clone https://github.com/jessytheripper/dockerfiles.git
cd arma3
docker build -t arma3server .
cd ../exile
docker build -t exile .
```
## Running

Exile Mod needs a MySQL database to store persistent data of the world. Instead of embedding a MySQL server in the same container (which is, btw, ugly), we use a prebuild image available in the docker library (pull action). You just need to execute the lines below (but first, fill a password for MySQL and a directory to store MySQL data in your host).

```
docker pull mysql/mysql-server:5.6
docker run -d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=<choose_a_password> -v <mountpoint_for_mysql_data>:/var/lib/mysql --name exiledb mysql/mysql-server:5.6
```

The next thing to do, is to link the database instance to the Exile instance so it can be accessible from that container. We simply use the --link option giving the MySQL instance name as parameter. You also need to provide the MySQL root password from the previous instance. You can refer to the arma3server README for the other parameters on the command line.

```
docker run -e STEAM_LOGIN='<your_steam_login>' -e STEAM_PASSWORD='<your_steam_password>' -e MYSQL_ROOT_PASSWORD=<password_from_mysql_instance> --link exiledb:exiledb -v /home/steam:/home/steam -d -t exile
```

## Logging

All logs print out in stdout/stderr and are available via the docker logs command:
```
docker logs <CONTAINER_NAME>
```

## Tweaking

config.cfg loads by default New Tanoa map. You can modify template using either Exile.Namalsk, Exile.Altis or Exile.Tanoa as value.

## Production

This docker image is aim to speed-up the install and deployment process for Arma3/Exilemod server. It means you just have a working server instance no more, no less.
*If you want to use it in production, you need to configure battleye / steamapi (security things).* You also need to make sure every configuration variables are set as you except.

## Versions

- GNU/Linux Debian Jessie: **8.x**

- MySQL server: **5.6**

- Exile mod: **1.0.0**
