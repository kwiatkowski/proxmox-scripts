#!/bin/sh

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

export $(grep -v '^#' $SCRIPTPATH/.env | xargs -d '\n')

get_temperature() {
    device=$1
    if echo "$device" | grep -q "/dev/nvme"; then
        temperature1=$(/usr/sbin/nvme smart-log "$device" | awk '/temperature/ {print $3}' | sed 's/°C//')
        temperature2=$(/usr/sbin/nvme smart-log "$device" | awk '/Temperature Sensor/ {print $5}' | sed 's/°C//')
        echo "$temperature1,$temperature2"
    else
        temperature=$(/usr/sbin/hddtemp -n "$device")
        echo "$temperature"
    fi
}

device=$1
topic1="$2/temperature"
topic2="$2/temperature_nvme"

temperatures=$(get_temperature "$device")
temp1=$(echo "$temperatures" | awk -F',' '{print $1}')
temp2=$(echo "$temperatures" | awk -F',' '{print $2}')

/usr/bin/mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASS" -t "$topic1" -m "$temp1"
/usr/bin/mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASS" -t "$topic2" -m "$temp2"
