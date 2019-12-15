# NordVPN Raspberry Pi random location picker
A random location picker for your NordVPN account on Raspberry Pi using OpenVPN.  
You only need to provide a NordVPN supported country code and protocol.  
Based on the country specific ovpn files and your security file the script will take a random file to open the VPN connection.  
I have made this script because I encountered stability problems (and conflicts with other applications like Pi-hole) with the native NordVPN Linux app.  
Several features such as display public IP address, check connection, kill connection, start/reload connection have been included.  
Script has been tested on Raspbian GNU/Linux 10 (buster).
## References
[How to setup OpenVPN on Raspberry Pi | NordVPN](https://nordvpn.com/tutorials/raspberry-pi/openvpn/)
## Prerequisites
Install OpenVPN and the NordVPN ovpn files according to the instructions mentioned in the link above.  
Prepare a file /etc/openvpn/nordvpnauth.txt including your NordVPN credentials (first line email address, second line password).  
Also make sure the user who will execute the script has sudo rights.
## Installation instructions
Put the bash script on your Raspberry Pi or clone this repository.  
Make sure the user who executes the script has sudo rights (example pi user).
## Usage
Help screen:
```
NordVPN Raspberry Pi random location picker.

Details for some of the arguments:
  CC    - NordVPN Country Code in lowercase.
  PROTO - NordVPN Transfer protocol lowercase (tcp or udp).

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
  reload [CC] [PROTO]  Reload OpenVPN process for a NordVPN location and protocol.
                       Current process (if running) will be stopped, a new one will be started.
```
## Example
Start a new OpenVPN process for a random location in Belgium (be) using NordVPN's TCP/IP protocol:
```
$ nordvpn_pi.sh be tcp
```
## Task list
- [x] Add feature to display NordVPN's supported country codes and protocols.
- [x] Add feature to display public IP address.
- [x] Add help and version option.
- [ ] Update script's header documentation including versioning.
- [x] Add feature to check and kill OpenVPN processes for NordVPN.
- [ ] Add feature to start and reload OpenVPN process for NordVPN.
- [ ] Make repository public after testing.
