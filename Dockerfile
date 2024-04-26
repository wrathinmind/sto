from python:3.12

RUN apt update
RUN pip install natsort
RUN apt install ffmpeg -y

WORKDIR /app
COPY download_all.sh .
COPY download.sh .
RUN chmod +x *.sh

# ENTRYPOINT ["echo $0 $1 $@"]
ENTRYPOINT ["/bin/bash", "-c", "/app/download_all.sh $@"]