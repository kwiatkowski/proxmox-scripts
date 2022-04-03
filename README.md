# proxmox-scripts

Publication information about the host to the mosquitto broker.

## Configuration

Copy the configuration file.

`cp .env.example .env`

Update environment variables.

```
MQTT_HOST=192.168.0.199
MQTT_PORT=1883
MQTT_USER=user
MQTT_PASS=pass

DISK=/dev/sda1
```

## Installation

Update with apt-get to pull in the new package information.

`apt-get update`

### Step 1 - Installation Mosquitto

Install the mosquitto package and its client software.

`apt-get install mosquitto mosquitto-clients`

More information [about mosquitto](https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-the-mosquitto-mqtt-messaging-broker-on-debian-8).

## Scripts

### home_assistant_mqtt_disk_mornitor.sh

Publishing messages with information about the disk.

Using and adding to crontab:

`* * * * * /bin/bash /home/scripts/home_assistant_mqtt_disk_mornitor.sh >> /home/scripts/cron.log 2>&1`
