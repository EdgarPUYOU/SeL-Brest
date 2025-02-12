Setup Gala 2023
===

# Réseau

## Matériel en réseau:
- 2 switch avec double lien redondant (ports Gigabit 1 et 2)
    - sw1-regie:
        - @IP: 192.168.0.2
    - sw2-scene:
        - @IP: 192.168.0.3
        - console/telnet/enable pw: sel2023
    - VLANs:
        - Audio[10]: 13-18
        - DMX[20]: 9-12
        - Video[30]: 5-8        
- Serveur DHCP Raspberri Pi
	- OS: OpenWRT
	- @IP: 192.168.0.1/24
	- admin web:
		- user: root
		- mdp: sel2023
- AP wifi
	- @IP: 192.168.0.10/24
	- ssid: r3gie
	- cle wifi: sel2023regie
	- admin web:
		- user: admin
		- mdp: sel2023gala
- interface ShowNET (pour laser):
	- @IP: 192.168.1.50/24
- PC sel :
	- @IP: 192.168.1.60/24


## Configuration des switch

```
(config)#service password-encryption
(config)#line vty 0 15
(config-line)#password sel2023
(config-line)#login
(config-line)#exit
(config)#enable secret sel2023
(config)#interface vlan 1
(config-if)#ip address 192.168.0.2 255.255.255.0
(config-if)#no sh
(config-if)#exit


```
