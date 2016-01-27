FROM debian:jessie
MAINTAINER Jessy <jessytheripper@gmail.com> 

RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y lib32gcc1 lib32stdc++6 wget
RUN useradd -u 2000 -m -d /home/steam/ -s /bin/bash steam

USER steam

VOLUME ["/home/steam/"]
ADD start.sh /start.sh
ADD server.cfg /tmp/server.cfg

EXPOSE 2302/udp
EXPOSE 2303/udp
EXPOSE 2304/udp

CMD ["/bin/bash", "/start.sh"]
