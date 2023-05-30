#!/bin/sh

SCRIPTPATH="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P)"
STATEFILE="$SCRIPTPATH/.state"

export $(grep -v '^#' "$SCRIPTPATH/.env" | xargs -d '\n')

if [ ! -f "$STATEFILE" ]; then
    touch "$STATEFILE"
fi

value_exists() {
    if grep -q "$1" "$STATEFILE"; then
        return 0
    else
        return 1
    fi
}

update_value() {
    if value_exists "$1"; then
        sed -i "s|$1=.*|$1=$2|" "$STATEFILE"
    else
        echo "$1=$2" >> "$STATEFILE"
    fi
}

get_temperature() {
    device=$1
    if echo "$device" | grep -q "/dev/nvme"; then
        temperature1=$(/usr/sbin/nvme smart-log "$device" | awk '/temperature/ {print $3}')
        temperature2=$(/usr/sbin/nvme smart-log "$device" | awk '/Temperature Sensor/ {print $5}')
        echo "$temperature1,$temperature2"
    else
        temperature=$(/usr/sbin/hddtemp -n "$device")
        echo "$temperature"
    fi
}

device=$1
topic1="$2/temperature"
topic2="$2/temperature_nvme"

prev_temp1=$(grep "$topic1" "$STATEFILE" | cut -d "=" -f 2 || echo "")
prev_temp2=$(grep "$topic2" "$STATEFILE" | cut -d "=" -f 2 || echo "")

IFS=',' read -r -a temperatures <<< "$(get_temperature "$device")"
temp1=${temperatures[0]}
temp2=${temperatures[1]}

if [ "$temp1" != "$prev_temp1" ]; then
    /usr/bin/mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASS" -t "$topic1" -m "$temp1"
    update_value "$topic1" "$temp1"
fi

if [ "$temp2" != "$prev_temp2" ]; then
    /usr/bin/mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASS" -t "$topic2" -m "$temp2"
    update_value "$topic2" "$temp2"
fi
