# NordVPN Raspberry Pi random location picker
A random location picker for your NordVPN account on your Raspberry Pi using OpenVPN.  
You only need to provide a NordVPN supported country code and protocol.  
Based on the multiple country specific ovpn files the script will take a random file to open the VPN connection.  
I have made this script because I encountered stability problems (and conflicts with other applications like Pi-Hole) with the NordVPN Linux app.  
Script has been tested on Raspbian GNU/Linux 10 (buster).
## References
[How to setup OpenVPN on Raspberry Pi | NordVPN](https://nordvpn.com/tutorials/raspberry-pi/openvpn/)
## Prerequisites
ToDo
## Installation instructions
Just put the bash script on your Raspberry Pi or clone this repository.  
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
## Task list
- [x] Add feature to display NordVPN's supported country codes and protocols.
- [x] Add feature to display public IP address.
- [x] Add help and version option.
- [ ] Update script's header documentation including versioning.
- [x] Add feature to check and kill OpenVPN processes for NordVPN.
- [ ] Add feature to start and reload OpenVPN process for NordVPN.
- [ ] Make repository public after testing.
