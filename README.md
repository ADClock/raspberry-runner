# raspberry-runner
Guide and Scripts for running ADClock on a Raspberry PI. The following guide will always run the latest version of [ADClock Server](https://github.com/ADClock/server).

## Install
0. Buy a Raspberry & SD-Card (PI Zero in our case)
1. Download the latest [Raspberry PI OS](https://www.raspberrypi.org/software/operating-systems/#raspberry-pi-os-32-bit). 
2. Flash the image to the SD-Card. [Win32DiskImager](https://www.heise.de/download/product/win32-disk-imager-92033) will help you.
3. Startup the pi and finish os installation. This might take up an hour.
4. Create new folder in pi home. `mkdir /home/pi/adclock && cd /home/pi/adclock`
5. Download the scripts from this repository. `git clone https://github.com/ADClock/raspberry-runner.git && cd raspberry-runner`
6. Make `run.sh` executable. `sudo chmod +x run.sh`
7. Register `run.sh` in startup.
    - Edit rc.local: `sudo nano /etc/rc.local` 
    - Add following line before exit: `(cd /home/pi/adclock/raspberry-runner/ && sh run.sh)`
    - Save and exit by pressing `^X` followed by `Y` and `Enter`
8. Reboot the raspberry pi. `sudo reboot`
9. The ADClock Server should be online under `<raspberry-ip-adress>:80` 

## Debugging
If the server is not reachable you can try executing the script by yourself and view the console output:
```shell
cd /home/pi/adclock/raspberry-runner/
sh run.sh
```
You might want to add `sudo`, because only root users can bind port 80. (See [here](https://superuser.com/questions/710253/allow-non-root-process-to-bind-to-port-80-and-443)) However the run.sh instance called on startup runs under root user - no special `sudo` needed there.


## FAQ
### What if I want to upgrade raspberry-runner? (should never be needed)
Run following commands:
```shell
cd /home/pi/adclock/raspberry-runner
git reset --hard HEAD
git pull
sudo chmod +x run.sh
```

### I see a new version of [ADClock Server](https://github.com/ADClock/server) on GitHub, but it doesn't download it.
Maybe your GitHub API rate limit exceeded. You can pass a specific version. See below.

### How do I run a specific version?
Run the following commands:
```shell
cd /home/pi/adclock/raspberry-runner
sh run.sh <release-tag>
```
If the given version is not downloaded yet it will download it from GitHub.

If you want to use a custom version simply create a subfolder and insert a `server.jar`. Run the script as mentioned above.

### It seems like raspberry is frozen.
Well. Maybe a `sudo reboot` helps?

### I get the error "Server VM is only supported on ARMv7+ VFP"
Well. Maybe you need to remove Java 11 and install Java 8 instead. See [this](https://mathematica.stackexchange.com/questions/218347/raspberry-pi-server-vm-is-only-supported-on-armv7-vfp-error).
```shell
apt list --installed *jre*
sudo apt remove openjdk-11-jre-headless
sudo apt get openjdk-8-jre
```

### BindException: The adress is already used.
Well. You should end the other process or change the port. Currently we do not provide an option for that. Sorry.
