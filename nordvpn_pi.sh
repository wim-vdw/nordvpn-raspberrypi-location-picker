#!/usr/bin/env bash
###################################################################################################
# Description: NordVPN Raspberry Pi random location picker.
# Version: 1.3.2
# Author: Wim Van den Wyngaert
#
# Exit codes:
#   0  - Success.
#   10 - No country codes could be displayed.
#   20 - No files for country.
#   30 - Problem killing OpenVPN process.
#   40 - OpenVPN process already running.
#   50 - Country code and protocol missing.
#
# Change history:
#   1.0.0 - Initial version.
#   1.1.0 - Add following functionalities: kill, check status and get public IP address.
#   1.1.1 - Create help screen + comments in header of script.
#   1.1.2 - Update help screen (start and reload options).
#   1.2.0 - Add following functionalities: start and reload.
#   1.3.0 - Remove obsolete reload function.
#   1.3.1 - Update help via here script.
#   1.3.2 - Update shebang.
###################################################################################################

VERSION="1.3.2"
BASEPATH="/etc/openvpn"
AUTH_FILE="/etc/openvpn/nordvpn-auth.txt"
CONNECT_TIMEOUT=3
CONNECT_RETRY=3
CONNECT_RETRY_MAX=3

# Exit codes.
SUCCESS=0
NO_COUNTRY_CODES=10
NO_FILES_FOR_COUNTRY=20
PROBLEM_KILLING_PROCESS=30
ALREADY_RUNNING=40
COUNTRY_CODE_AND_PROTOCOL_MISSING=50

display_help() {
  cat <<- _EOF_
NordVPN Raspberry Pi random location picker.

Details for some of the arguments:
  [CC]    - NordVPN Country Code in lowercase.
  [PROTO] - NordVPN Transfer protocol in lowercase (tcp or udp).

Usage: nordvpn_pi.sh [OPTIONS] COMMAND [ARGS]

Options:
  -h, --help           Show this message and exit.
  -v, --version        Show version and exit.

Commands:
  countries            Show available country codes for NordVPN.
  protocols            Show available protocols for NordVPN.
  ip                   Display current public IP address.
  check                Check if OpenVPN process for NordVPN is running.
  kill                 Kill current OpenVPN process for NordVPN.
  start [CC] [PROTO]   Start OpenVPN process for a NordVPN location and protocol.
                       If a process already runs nothing will happen.
_EOF_
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
  if ! pgrep openvpn >/dev/null 2>&1
  then
    echo "OpenVPN process status for NordVPN: not active"
  else
    PROCESS_ID=$(pgrep openvpn)
    echo "OpenVPN process status for NordVPN: active"
    echo "OpenVPN process id: $PROCESS_ID"
  fi
}

kill_current_connection() {
  if ! pgrep openvpn >/dev/null 2>&1
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
  FILE=${FILES[$NUM]}
}

start_connection() {
  COUNTRY=$1
  PROTOCOL=$2
  if pgrep openvpn >/dev/null 2>&1
  then
    PROCESS_ID=$(pgrep openvpn)
    echo "Error: OpenVPN process for NordVPN already running."
    echo "OpenVPN process id: $PROCESS_ID"
    echo "Use the kill command of this script first to stop the current connection."
    exit $ALREADY_RUNNING
  fi
  get_random_file "$COUNTRY" "$PROTOCOL"
  echo "Starting new connection..."
  echo "NordVPN file: $FILE"
  echo "Authorization file: $AUTH_FILE"
  sudo -b openvpn --config "$FILE" --auth-user-pass $AUTH_FILE --connect-timeout $CONNECT_TIMEOUT \
                  --connect-retry $CONNECT_RETRY --connect-retry-max $CONNECT_RETRY_MAX
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
  if [[ $# -lt 3 ]]
  then
    echo "Error: Specify a country code and a protocol, both in lowercase."
    echo "Usage: nordvpn_pi.sh start [COUNTRY_CODE] [PROTOCOL]"
    exit $COUNTRY_CODE_AND_PROTOCOL_MISSING
  fi
  COUNTRY=$2
  PROTOCOL=$3
  start_connection "$COUNTRY" "$PROTOCOL"
  exit $SUCCESS
fi

echo "Nothing done."
echo "Command for help: nordvpn_pi.sh --help"
exit $SUCCESS
