#!/usr/bin/env sh

# Retrieve the raw temperature reading for "Package id 0:" (e.g., "+16.0°C")
TEMP_RAW=$(sensors | grep "Package id 0:" | awk '{print $4}' | tr -d '+')

# Remove the degree symbol and any trailing characters to extract a numeric value
TEMP_VAL=$(echo "$TEMP_RAW" | sed 's/°C//')

# Define the warning threshold (in °C)
WARN_THRESHOLD=50

# Validate that the temperature is numeric
if ! echo "$TEMP_VAL" | grep -Eq '^[0-9]+(\.[0-9]+)?$'; then
    echo "N/A"
    exit 1
fi

# Compare the temperature with the warning threshold
if [ "$(echo "$TEMP_VAL >= $WARN_THRESHOLD" | bc -l)" -eq 1 ]; then
    # If above threshold, set the label foreground to red
    echo "%{F#FF0000} $TEMP_RAW%{F-}"
else
    # Otherwise, set the label foreground to white
    echo "%{F#FFA725} $TEMP_RAW%{F-}"
fi
