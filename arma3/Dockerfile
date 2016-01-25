FROM debian:jessie
MAINTAINER Jessy <jessytheripper@gmail.com> 

RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y lib32gcc1 lib32stdc++6 wget
RUN useradd -u 2000 -m -d /home/steam/ -s /bin/bash steam

USER steam

VOLUME ["/home/steam/"]
ADD start.sh /start.sh

EXPOSE 2302/udp

CMD ["/bin/bash", "/start.sh"]
