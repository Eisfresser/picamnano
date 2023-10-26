#!/bin/bash

picam() {
    echo "deploy picam"
    scp mediamtx/mediamtx.yml rolf@picam.fqp.ch:/home/rolf/mediamtx.yml
    ssh rolf@picam.fqp.ch "docker restart mediamtx"
}

viseron() {
    echo "deploy viseron"
    scp viseron/config.yaml root@nano.fqp.ch:/home/rolf/viseron/config/config.yaml
    scp viseron/monitorViseron.sh root@nano.fqp.ch:/home/rolf/monitorViseron.sh
    scp viseron/viseron.sh root@nano.fqp.ch:/home/rolf/viseron/viseron.sh
}

frigate() {
    echo "deploy frigate"
    ssh root@nano.fqp.ch "mkdir -p /home/rolf/frigate && mkdir -p /media/rolf/SSD500GB/frigate/media"
    scp frigate/frigate.sh root@nano.fqp.ch:/home/rolf/frigate/frigate.sh
    scp frigate/config.yml root@nano.fqp.ch:/home/rolf/frigate/config.yml
}

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 {picam|viseron|all}"
  exit 1
fi

case "$1" in
  picam)
    picam
    ;;
  viseron)
    viseron
    ;;
  frigate)
    frigate
    ;;
  all)
    picam
    viseron
    frigate
    ;;
  *)
    echo "Invalid argument: $1"
    echo "Usage: $0 {picam|viseron|frigate|all}"
    exit 1
    ;;
esac
