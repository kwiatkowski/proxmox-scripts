#!/bin/sh

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

export $(grep -v '^#' $SCRIPTPATH/.env | xargs -d '\n')

temp=`sensors --no-adapter 2>/dev/null | grep 'Package id' | awk '{print int($4)}'`

/usr/bin/mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t "$1/temperature" -m "$temp"
