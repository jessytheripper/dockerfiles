# Arma 3 server Dockerfile

## Introduction

This dockerfile install Steam CLI and download Arma 3 server content and execute it. 
The container needs two environment variables to work properly:
```
STEAM_LOGIN
STEAM_PASSWORD
```
containing the login and password to connect to a steam account.
Because it use a volume to store the Steam and Arma 3 data, you will need to create a directory on the host filesystem to bind the volume.

## Building from source

To build from source you need to clone the git repo and run docker build:
```
git clone https://github.com/jessytheripper/dockerfiles.git
cd arma3
docker build -t arma3server .
```

## Running

First, you need to create the mountpoint used by the docker volume (I use /home/steam but you can change this accordingly in the Dockerfile):
```
# mkdir /home/steam
# chown 2000:2000 /home/steam/
```

**Note:** We use 2000 as uid/guid which is the same when creating the steam user in the container. We will need around 2GB of memory to download Arma 3 content.

Run the container using root or sudo:
```
docker run -e STEAM_LOGIN='your_steam_login' -e STEAM_PASSWORD='your_steam_password' -p 2302:2302 -v /home/steam:/home/steam -d -t arma3server
```

## Customizing server.cfg

For now, Arma 3 server.cfg is generated in start.sh. This is just a "vanilla" release, I will probably make it as an environment variable (pointing to a URL for example) in the future.

## Logging

All logs print out in stdout/stderr and are available via the docker logs command:
```
docker logs <CONTAINER_NAME>
```

If everything works fine (after start.sh has finished to download Steam and Arma 3), you should see something like:
```
15:36:29 Game Port: 2302, Steam Query Port: 2303
15:36:29 Initializing Steam server - Game Port: 2302, Steam Query Port: 2303
Arma 3 Console version 1.54 : port 2302
15:36:30 Connected to Steam servers
```

## Versions

- GNU/Linux Debian Jessie: **8.x**
