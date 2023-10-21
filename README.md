# picamnano

## Pi Setup

Using an old Pi3B+ with Debian 11 Bullseye

### Prepare camera

```bash
# check if camera is working
v4l2-ctl --list-devices
raspistill  

# enable the following to use libcamera, but it disables raspistill
sudo raspi-config 
3 Interface Options / I1 Enable legacy camera support / NO
6 Advanced Ooptions / A8 Enable glamor graphics acceleration / YES

sudo nano /boot/firmware/config.txt
# append
camera_auto_detect=0
dtoverlay=imx219
sudo reboot now

libcamera-hello
```

### Set fixed IP address

```bash
sudo vi /etc/resolv.conf
nameserver 192.168.1.4

sudo vi /etc/dhcpcd.conf
interface wlan0
static ip_address=192.168.1.12/24
static routers=192.168.1.1
static domain_name_servers=192.168.1.4 8.8.8.8
```

Reboot and add to DNS:

- picam.fqp.ch
- picam.local

### Install MediaMTX (formerly rtsp-simple-server) 

<https://github.com/bluenviron/mediamtx>
<https://www.allerstorfer.at/kameraserver-mit-raspberry-pi/>

```bash
# install docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker rolf    # allow docker without sudo

sudo docker run --rm -it --network=host bluenviron/mediamtx:latest-ffmpeg-rpi

sudo docker run \
    --name mediamtx \
    --restart always \
    --network=host \
    --privileged \
    --tmpfs /dev/shm:exec \
    -v /run/udev:/run/udev:ro \
    -v ./mediamtx.yml:/mediamtx.yml \
    -e MTX_PATHS_CAM_SOURCE=rpiCamera \
    bluenviron/mediamtx:latest-rpi

```

Access video streams

- WebRTC http://picam.fqp.ch:8889/cam
- HLS http://picam.fqp.ch:8888/cam/
- RTSP vlc rtsp://picam.fqp.ch:8554/cam
- RTMP vlc rtmp://picam.fqp.ch/cam

## Nano setup

<https://developer.nvidia.com/embedded/learn/get-started-jetson-nano-devkit#prepare-items>

Set fixed ip addr in settings, add to DNS.

```ssh-copy-id -i ~/.ssh/id_rsa.pub rolf@nano.fqp.ch```

Execute on nano:
```bash
# set root password
sudo -i
passwd
# allow root ssh login with sed to deploy viseron config.yaml
sudo vi /etc/ssh/sshd_config
# set "PermitRootLogin yes"
systemctl restart sshd

# allow docker without sudo
sudo usermod -aG docker rolf
# allow writing to /var/log
sudo usermod -aG syslog rolf
```

Copy key ```ssh-copy-id -i ~/.ssh/id_rsa.pub root@nano.fqp.ch```, then set ```PermitRootLogin prohibit-password``` in sshd_config.

### Install Viseron

<https://viseron.netlify.app/docs/documentation>

```bash
mkdir viseron
mkdir viseron/config
mkdir viseron/recordings

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


sudo docker run -it --rm \
  --name viseron \
  -v /etc/localtime:/etc/localtime:ro \
  -v /media/rolf/SSD500GB/viseron:/recordings \
  -v /home/rolf/viseron/config:/config \
  -p 8888:8888 \
  --runtime=nvidia \
  --privileged \
  roflcoopter/jetson-nano-viseron:latest
```

<http://jano.fqp.ch:8888>

Add cronjob to poll viseron every two minutes and restart container if necessary: ```./monitorViseron.sh install```

