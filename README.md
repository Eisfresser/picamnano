# picamnano

## Pi Setup

Using an old Pi3B+ with Debian 11 Bullseye

sudo raspi-config 
3 Interface Options / I1 Enable legacy camera support
6 Advanced Ooptions / A8 Enable glamor graphics acceleration

sudo nano /boot/firmware/config.txt
# append
camera_auto_detect=0
dtoverlay=imx219

sudo reboot now

