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
3 Interface Options / I1 Enable legacy camera support
6 Advanced Ooptions / A8 Enable glamor graphics acceleration
sudo nano /boot/firmware/config.txt
# append
camera_auto_detect=0
dtoverlay=imx219
sudo reboot now

libcamera-hello
```

### Install MediaMTX (formerly rtsp-simple-server) 

<https://github.com/bluenviron/mediamtx>
<https://www.allerstorfer.at/kameraserver-mit-raspberry-pi/>

```bash
# install docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

sudo docker run --rm -it --network=host bluenviron/mediamtx:latest-ffmpeg-rpi

sudo docker run \
    --restart always \
    --network=host \
    --privileged \
    --tmpfs /dev/shm:exec \
    -v /run/udev:/run/udev:ro \
    -v ./mediamtx.yml:/mediamtx.yml \
    -e MTX_PATHS_CAM_SOURCE=rpiCamera \
    bluenviron/mediamtx:latest-rpi

```

Open RTSP stream in VLC with rtsp://192.168.1.240:8554/cam

