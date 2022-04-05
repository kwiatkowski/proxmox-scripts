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
```

## Installation

Update with apt-get to pull in the new package information.

`apt-get update`

### Step 1 - [Installation Mosquitto](https://mosquitto.org/)

Install the mosquitto package and its client software.

`apt-get install mosquitto mosquitto-clients`

More information [about mosquitto](https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-the-mosquitto-mqtt-messaging-broker-on-debian-8).

### Step 2 - [Installation Hddtemp](https://wiki.archlinux.org/title/Hddtemp)

`apt-get install hddtemp`

More information [about hddtemp](https://wiki.archlinux.org/title/Hddtemp)

## Scripts

### home_assistant_mqtt_disk_mornitor.sh

Publish MQTT messages with disk information such as:

1. size
2. available
3. used
4. used_percentage
5. temperature

Use:
`home_assistant_mqtt_disk_mornitor.sh '/dev/sda1' 'monitor/proxmox/disc/nas'`

`/dev/sda1` - physical partition

`monitor/proxmox/disc/nas` - mqtt topic defined in HA configuration

Adding to crontab:

`* * * * * /bin/bash /home/scripts/home_assistant_mqtt_disk_mornitor.sh '/dev/sda1' 'monitor/proxmox/disc/nas' >> /home/scripts/logs/home_assistant_mqtt_disk_mornitor.log 2>&1`

### home_assistant_mqtt_processor_monitor.sh

Publish MQTT messages with processor information such as:

1. temperature

Use:
`home_assistant_mqtt_processor_monitor.sh 'monitor/proxmox/procesor'`

`monitor/proxmox/procesor` - mqtt topic defined in HA configuration

Adding to crontab:

`* * * * * /bin/bash /home/scripts/home_assistant_mqtt_processor_monitor.sh 'monitor/proxmox/procesor' >> /home/scripts/logs/home_assistant_mqtt_processor_monitor.log 2>&1`
