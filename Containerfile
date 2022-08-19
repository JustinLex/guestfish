FROM ubuntu:22.04

WORKDIR /root

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
          libguestfs-tools \
          qemu-utils \
          linux-image-generic

COPY guestfish.sh /root/guestfish.sh

ENTRYPOINT ./guestfish.sh
