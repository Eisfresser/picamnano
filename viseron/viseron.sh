docker kill viseron
docker rm viseron
sudo docker run \
  --name viseron \
  --restart always \
  -v /media/rolf/SSD500GB/viseron:/recordings \
  -v /home/rolf/viseron/config:/config \
  -v /etc/localtime:/etc/localtime:ro \
  -p 8888:8888 \
  --runtime=nvidia \
  --privileged \
  roflcoopter/jetson-nano-viseron:latest
  