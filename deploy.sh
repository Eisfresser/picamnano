#!/bin/bash

picam() {
    echo "deploy picam"
    scp mediamtx.yml rolf@picam.fqp.ch:/home/rolf/mediamtx.yml
    ssh rolf@picam.fqp.ch "docker restart mediamtx"
}

viseron() {
    echo "deploy viseron"
    scp config.yaml root@nano.fqp.ch:/home/rolf/viseron/config/config.yaml
    scp monitorViseron.sh root@nano.fqp.ch:/home/rolf/monitorViseron.sh
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
  all)
    picam
    viseron
    ;;
  *)
    echo "Invalid argument: $1"
    echo "Usage: $0 {picam|viseron|all}"
    exit 1
    ;;
esac
