#!/bin/bash

hciconfig hci0 down
hciconfig hci0 up

logfile="ble.log"
option=$1

if [  "$option" == "--mac" ]; then
  mac=$2
  # Run hcitool lescan for 10 sec and save output to log file
  timeout 10 stdbuf -oL hcitool lescan > $logfile
  # Kill hcitool lescan after specified time
  pkill --signal SIGINT hcitool
  # Look for MAC addresses and save them in new array
  mac_list=($(grep -oE '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}' $logfile))

  if [ -n "$mac" ]; then
    echo "Searching for $mac"
    # Iterate through list and find somparison to MAC provided in arguement
    for i in "${mac_list[@]}"
    do
      if [ "$i" == "$mac" ]; then
        echo "BLE Mac found: $i"
        # INSERT_CUSTOM_COMMAND_HERE #
        exit 0
      fi
    done
    echo "No BLE matching MAC Found."
  else
    echo "No matching MAC address found in scan."
  fi

else
  echo "Error: Please specify valid argument (--mac)"
fi