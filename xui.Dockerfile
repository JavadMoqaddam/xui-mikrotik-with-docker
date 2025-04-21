FROM ubuntu:22.04 
RUN apt update && \
    apt install -y unzip curl socat systemctl nano && \ 
RUN curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh | bash

