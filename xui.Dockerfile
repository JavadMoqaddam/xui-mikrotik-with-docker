FROM ubuntu:22.04 AS extractor 
RUN apt update && \
    apt install -y unzip curl socat systemctl nano #&& \
    #curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh | bash

