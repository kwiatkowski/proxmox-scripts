#!/bin/sh

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

export $(grep -v '^#' $SCRIPTPATH/.env | xargs -d '\n')

size=$(df -h "$1" | awk '{ print $2 }' | tail -n 1 | cut -d 'G' -f 1)
available=$(df -h "$1" | awk '{ print $4 }' | tail -n 1 | cut -d 'G' -f 1)
used=$(df -h "$1" | awk '{ print $3 }' | tail -n 1 | cut -d 'G' -f 1)
used_percentage=$(df -h "$1" | awk '{ print $5 }' | tail -n 1 | cut -d '%' -f 1)

/usr/bin/mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t "$2/size" -m "$size"
/usr/bin/mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t "$2/available" -m "$available"
/usr/bin/mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t "$2/used" -m "$used"
/usr/bin/mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t "$2/used_percentage" -m "$used_percentage"
/usr/bin/mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t "$2/temperature" -m "$temp"
