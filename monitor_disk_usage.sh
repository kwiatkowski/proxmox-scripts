#!/bin/sh

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
STATEFILE="$SCRIPTPATH/.state"

export $(grep -v '^#' $SCRIPTPATH/.env | xargs -d '\n')

if [ ! -f "$STATEFILE" ]; then
    touch "$STATEFILE"
fi

# Funkcja sprawdzająca, czy wartość istnieje w pliku stanu
value_exists() {
    if grep -q "$1" "$STATEFILE"; then
        return 0 # Wartość istnieje
    else
        return 1 # Wartość nie istnieje
    fi
}

# Funkcja aktualizująca wartość w pliku stanu
update_value() {
    if value_exists "$1"; then
        sed -i "s|$1=.*|$1=$2|" "$STATEFILE"
    else
        echo "$1=$2" >> "$STATEFILE"
    fi
}

# Odczytanie poprzednich wartości z pliku stanu lub ustawienie domyślnych wartości
prev_size=$(grep "$2/size" "$STATEFILE" | cut -d "=" -f 2 || echo "")
prev_available=$(grep "$2/available" "$STATEFILE" | cut -d "=" -f 2 || echo "")
prev_used=$(grep "$2/used" "$STATEFILE" | cut -d "=" -f 2 || echo "")
prev_used_percentage=$(grep "$2/used_percentage" "$STATEFILE" | cut -d "=" -f 2 || echo "")

# Odczytanie aktualnych wartości
size=$(df -h "$1" | awk '{ print $2 }' | tail -n 1 | cut -d 'G' -f 1)
available=$(df -h "$1" | awk '{ print $4 }' | tail -n 1 | cut -d 'G' -f 1)
used=$(df -h "$1" | awk '{ print $3 }' | tail -n 1 | cut -d 'G' -f 1)
used_percentage=$(df -h "$1" | awk '{ print $5 }' | tail -n 1 | cut -d '%' -f 1)

# Aktualizacja pliku stanu i wysłanie danych tylko w przypadku zmiany
if [ "$size" != "$prev_size" ]; then
    /usr/bin/mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t "$2/size" -m "$size"
    update_value "$2/size" "$size"
fi

if [ "$available" != "$prev_available" ]; then
    /usr/bin/mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t "$2/available" -m "$available"
    update_value "$2/available" "$available"
fi

if [ "$used" != "$prev_used" ]; then
    /usr/bin/mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t "$2/used" -m "$used"
    update_value "$2/used" "$used"
fi

if [ "$used_percentage" != "$prev_used_percentage" ]; then
    /usr/bin/mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t "$2/used_percentage" -m "$used_percentage"
    update_value "$2/used_percentage" "$used_percentage"
fi

if [ "$temp" != "$prev_temp" ]; then
    /usr/bin/mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t "$2/temperature" -m "$temp"
    update_value "$2/temperature" "$temp"
fi
