#!/bin/bash

# NordVPN Raspberry Pi random location picker.
# Exit codes:
#   10 No country codes could be displayed
#   20 No files for country
#   30 Problem killing OpenVPN process

BASEPATH="/etc/openvpn"

display_help() {
  echo "NordVPN Raspberry Pi random location picker"
  echo
  echo "Usage: nordvpn_pi.sh [OPTIONS] COMMAND [ARGS]"
  echo
  echo "Options:"
  echo "  -h, --help      Show this message and exit."
  echo "  -v, --version   Show version and exit."
  echo
  echo "Commands:"
  echo "  countries       Show available country codes."
  echo "  protocols       Show available protocols."
  echo "  ip              Display current public IP address."
  echo "  check           Check if OpenVPN process for NordVPN is running."
  echo "  kill            Kill current OpenVPN process for NordVPN."
  echo "  restart         Restart OpenVPN process based on new NordVPN file."
}

display_version() {
  echo "NordVPN Raspberry Pi random location picker 1.0.0"
}

display_countries() {
  if ! ls -l "$BASEPATH"/*nordvpn*ovpn >/dev/null 2>&1
  then
    echo "Error: Make sure NordVPN ovpn files are located in /etc/openvpn"
    exit 10
  fi
  COUNTRY_PREVIOUS=""
  echo "The following country codes are supported:"
  for FILE in "$BASEPATH"/*nordvpn*ovpn
  do
    COUNTRY="${FILE:13:2}"
    if [[ ! "$COUNTRY" == "$COUNTRY_PREVIOUS" ]]
    then
      echo "  $COUNTRY"
    fi
    COUNTRY_PREVIOUS=$COUNTRY
  done
}

display_protocols() {
  echo "The following protocols are supported:"
  echo "  tcp - Transmission Control Protocol (reliable) for web browsing."
  echo "  udp - User Datagram Protocol for online streaming/downloading."
}

display_public_ip() {
  IP_ADDRESS=$(curl --silent https://api.ipify.org)
  echo "Your public IP address: $IP_ADDRESS"
}

check_openvpn_process() {
  if ! ps -ef | pgrep openvpn | grep -v pgrep >/dev/null 2>&1
  then
    echo "OpenVPN process status for NordVPN: not active"
  else
    PROCESS_ID=$(ps -ef | pgrep openvpn | grep -v pgrep)
    echo "OpenVPN process status for NordVPN: active"
    echo "OpenVPN process id: $PROCESS_ID"
  fi
}

kill_current_connection() {
  if ! ps -ef | pgrep openvpn | grep -v pgrep >/dev/null 2>&1
  then
    echo "There is currently no OpenVPN process for NordVPN running."
    exit 0
  fi
  echo "Killing NordVPN connection now!"
  if sudo killall openvpn >/dev/null 2>&1
  then
    echo "OpenVPN process for NordVPN killed with success!"
  else
    echo "Error: Problem killing OpenVPN process for NordVPN."
    echo "Check your sudo rights."
    exit 30
  fi
}

get_random_file() {
  COUNTRY=$1
  PROTOCOL=$2
  if ! ls -l "$BASEPATH"/"$COUNTRY"*nordvpn*"$PROTOCOL"*ovpn >/dev/null 2>&1
  then
    echo "Error: No files found, make sure you specify an existing country and protocol."
    exit 20
  fi
  FILES=()
  COUNTER=0
  for FILE in "$BASEPATH"/"$COUNTRY"*nordvpn*"$PROTOCOL"*ovpn
  do
    FILES+=("$FILE")
    COUNTER+=1
  done
  NUMBER=${#FILES[@]}
  NUM=$((RANDOM % NUMBER))
  echo "${FILES[$NUM]}"
}

if [[ $# -eq 0 ]]
then
  display_help
  exit 0
fi

if [[ $1 == "-h" ]] || [[ $1 == "--help" ]]
then
  display_help
  exit 0
fi

if [[ $1 == "-v" ]] || [[ $1 == "--version" ]]
then
  display_version
  exit 0
fi

if [[ $1 == "countries" ]]
then
  display_countries
  exit 0
fi

if [[ $1 == "protocols" ]]
then
  display_protocols
  exit 0
fi

if [[ $1 == "ip" ]]
then
  display_public_ip
  exit 0
fi

if [[ $1 == "check" ]]
then
  check_openvpn_process
  exit 0
fi

if [[ $1 == "kill" ]]
then
  kill_current_connection
  exit 0
fi

echo "Nothing done."
echo "Command for help: nordvpn_pi.sh --help"
exit 0
