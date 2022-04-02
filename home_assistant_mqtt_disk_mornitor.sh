#!/bin/sh

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

export $(grep -v '^#' $SCRIPTPATH/.env | xargs -d '\n')

size=`df -h $DISK | awk '{ print $2 }' | tail -n 1 | cut -d 'G' -f1`
available=`df -h $DISK | awk '{ print $4 }' | tail -n 1 | cut -d 'G' -f1`
used=`df -h $DISK | awk '{ print $3 }' | tail -n 1 | cut -d 'G' -f1`
used_percentage=`df -h $DISK | awk '{ print $5 }' | tail -n 1 | cut -d '%' -f1`

/usr/bin/mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t "monitoring/disk/nas/size" -m "$size"
/usr/bin/mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t "monitoring/disk/nas/available" -m "$available"
/usr/bin/mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t "monitoring/disk/nas/used" -m "$used"
/usr/bin/mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t "monitoring/disk/nas/used_percentage" -m "$used_percentage"
