#!/bin/bash
###################################################################################################
# Description: NordVPN Raspberry Pi random location picker.
# Version: 1.1.2
# Author: Wim Van den Wyngaert
#
# Exit codes:
#   0  - Success.
#   10 - No country codes could be displayed.
#   20 - No files for country.
#   30 - Problem killing OpenVPN process.
#   40 - OpenVPN process already running.
#
# Change history:
#   1.0.0 - Initial version.
#   1.1.0 - Add following functionalities: kill, check status and get public IP address.
#   1.1.1 - Create help screen + comments in header of script.
#   1.1.2 - Update help screen (start and reload options).
###################################################################################################

# Test:
# sudo openvpn --config /etc/openvpn/de705.nordvpn.com.tcp443.ovpn --auth-user-pass /etc/openvpn/nordvpn-auth.txt --connect-timeout 5 --connect-retry-max 3

VERSION="1.1.2"
BASEPATH="/etc/openvpn"
AUTH_FILE="/etc/openvpn/nordvpn-auth.txt"
CONNECT_TIMEOUT=3
CONNECT_RETRY_MAX=3

# Exit codes.
SUCCESS=0
NO_COUNTRY_CODES=10
NO_FILES_FOR_COUNTRY=20
PROBLEM_KILLING_PROCESS=30
ALREADY_RUNNING=40

display_help() {
  echo "NordVPN Raspberry Pi random location picker."
  echo
  echo "Details for some of the arguments:"
  echo "  [CC]    - NordVPN Country Code in lowercase."
  echo "  [PROTO] - NordVPN Transfer protocol in lowercase (tcp or udp)."
  echo
  echo "Usage: nordvpn_pi.sh [OPTIONS] COMMAND [ARGS]"
  echo
  echo "Options:"
  echo "  -h, --help           Show this message and exit."
  echo "  -v, --version        Show version and exit."
  echo
  echo "Commands:"
  echo "  countries            Show available country codes for NordVPN."
  echo "  protocols            Show available protocols for NordVPN."
  echo "  ip                   Display current public IP address."
  echo "  check                Check if OpenVPN process for NordVPN is running."
  echo "  kill                 Kill current OpenVPN process for NordVPN."
  echo "  start [CC] [PROTO]   Start OpenVPN process for a NordVPN location and protocol."
  echo "                       If a process already runs nothing will happen."
  echo "  reload [CC] [PROTO]  Reload OpenVPN process for a NordVPN location and protocol."
  echo "                       Current process will be stopped, a new one will be started."
}

display_version() {
  echo "NordVPN Raspberry Pi random location picker $VERSION"
}

display_countries() {
  if ! ls -l "$BASEPATH"/*nordvpn*ovpn >/dev/null 2>&1
  then
    echo "Error: Make sure NordVPN ovpn files are located in /etc/openvpn"
    exit $NO_COUNTRY_CODES
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
  if ! ps -ef | pgrep openvpn >/dev/null 2>&1
  then
    echo "OpenVPN process status for NordVPN: not active"
  else
    PROCESS_ID=$(ps -ef | pgrep openvpn)
    echo "OpenVPN process status for NordVPN: active"
    echo "OpenVPN process id: $PROCESS_ID"
  fi
}

kill_current_connection() {
  if ! ps -ef | pgrep openvpn >/dev/null 2>&1
  then
    echo "There is currently no OpenVPN process for NordVPN running."
    exit $SUCCESS
  fi
  echo "Killing NordVPN connection now!"
  if sudo killall openvpn >/dev/null 2>&1
  then
    echo "OpenVPN process for NordVPN killed with success!"
  else
    echo "Error: Problem killing OpenVPN process for NordVPN."
    echo "Check your sudo rights."
    exit $PROBLEM_KILLING_PROCESS
  fi
}

start_connection() {
  if ps -ef | pgrep openvpn >/dev/null 2>&1
  then
    PROCESS_ID=$(ps -ef | pgrep openvpn)
    echo "Error: OpenVPN process for NordVPN already running."
    echo "OpenVPN process id: $PROCESS_ID"
    echo "Use the kill command of this script first or the reload command."
    exit $ALREADY_RUNNING
  fi
  echo "Starting new connection..."
}

reload_connection() {
  echo "Reloading connection..."
}

get_random_file() {
  COUNTRY=$1
  PROTOCOL=$2
  if ! ls -l "$BASEPATH"/"$COUNTRY"*nordvpn*"$PROTOCOL"*ovpn >/dev/null 2>&1
  then
    echo "Error: No files found, make sure you specify an existing country and protocol."
    exit $NO_FILES_FOR_COUNTRY
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
  exit $SUCCESS
fi

if [[ $1 == "-h" ]] || [[ $1 == "--help" ]]
then
  display_help
  exit $SUCCESS
fi

if [[ $1 == "-v" ]] || [[ $1 == "--version" ]]
then
  display_version
  exit $SUCCESS
fi

if [[ $1 == "countries" ]]
then
  display_countries
  exit $SUCCESS
fi

if [[ $1 == "protocols" ]]
then
  display_protocols
  exit $SUCCESS
fi

if [[ $1 == "ip" ]]
then
  display_public_ip
  exit $SUCCESS
fi

if [[ $1 == "check" ]]
then
  check_openvpn_process
  exit $SUCCESS
fi

if [[ $1 == "kill" ]]
then
  kill_current_connection
  exit $SUCCESS
fi

if [[ $1 == "start" ]]
then
  start_connection
  exit $SUCCESS
fi

if [[ $1 == "reload" ]]
then
  reload_connection
  exit $SUCCESS
fi

echo "Nothing done."
echo "Command for help: nordvpn_pi.sh --help"
exit $SUCCESS
