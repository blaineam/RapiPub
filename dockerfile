FROM ubuntu

RUN apt-get update

RUN apt install -y wget cron tar curl ffmpeg

RUN wget $(curl -L -s https://api.github.com/repos/porjo/youtubeuploader/releases/latest | grep -o -E "https://(.*)youtubeuploader_(.*)Linux_x86_64.tar.gz") && tar -xf youtubeuploader_*.tar.gz -C /usr/local/bin

COPY command.sh /command.sh

RUN chmod +x /command.sh

RUN echo '* * * * * root /command.sh /data/media /data/processed /data/resources/intro.m4v /data/resources/outro.m4v 1920x1080 libx265 10000 >/proc/1/fd/1 2>/proc/1/fd/2' > /etc/crontab

ENTRYPOINT /command.sh /data/media /data/processed /data/resources/intro.m4v /data/resources/outro.m4v 1920x1080 libx265 10000 && cron -f
