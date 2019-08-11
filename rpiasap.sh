#!/bin/bash

# RpiAsAP Script 

echo
echo -en " \033[1;32m"
echo -e "⋱⋱ ⋰⋰		     RpiAsAP"
echo -en "\033[1;31m"
echo -e " ◖ ● ◗		 *** INSTALL ***"
echo -e "◖ ● ● ◗	 	ver 1.2, July 2019"
echo -e " ◖ ● ◗		 Raspbian 2019.4"
echo -e "   ●"
echo -en "\033[0m"
echo

#_______________________________________________________________________
if [ "$1" == "--help" ] || [ "$1" == "help" ] || [ "$1" == "-h" ]; then
echo "
RpiAsAP Help:

usage: ./rpiasap.sh [SSID NAME] [WPA PASSPHRASE] [HARDWARE MODE] [CHANNEL]

WPA PASSPHRASE:
>= 8 chars

HARDWARE MODES:
a = IEE 802.11a (5 GHz)
b = IEE 802.11b (2.4 GHz)
g = IEE 802.11g (2.4 GHz)
ad = IEE 802.11ad (60GHz)

CHANNEL:
1-13 if IEE 802.11bg
"
exit 0
fi

if (( $EUID != 0 )); then
	echo "ERROR: No administrator rights."
	exit 1
fi
#_______________________________________________________________________

echo Installing...
apt install dnsmasq hostapd

echo Backup...
mkdir ./rpiasap_backup
#---------------------------------------------------------
cp /etc/dhcpcd.conf ./rpiasap_backup/dhcpcd.conf.backup
cp /etc/dnsmasq.conf ./rpiasap_backup/dnsmasq.conf.backup
cp /etc/default/hostapd ./rpiasap_backup/hostapd.backup
#cp /etc/sysctl.conf ./rpiasap_backup/sysctl.conf.backup
#cp /etc/iptables.ipv4.nat ./rpiasap_backup/iptables.ipv4.nat.backup
#cp /etc/rc.local ./rpiasap_backup/rc.local.backup

cp -r ./rpiasap_backup ./rpiasap_backup2
#---------------------------------------------------------

echo Checking input...
SSID=$1
PASS=$2
HWM=$3
CHANNEL=$4

if [ -z "$SSID" ] || [ "$SSID" == " " ]; then
        SSID="RPI_AP"
fi

if [ -z "$HWM" ] || [ "$HWM" != "a" ] && [ "$HWM" != "b" ] && [ "$HWM" != "g" ] && [ "$HWM" != "ad" ]; then
        HWM="g"
fi

if [ -z "$PASS" ] || [ "$PASS" == " " ] || [ "$(printf $PASS | wc -c)" -lt 8 ]; then
		PASS="WpaTestPass123"
fi

if [ -z "$CHANNEL" ] || [ "$CHANNEL" -lt 1 ] || [ "$CHANNEL" -gt 13 ]; then
		CHANNEL=$(shuf -i 1-13 -n 1)
fi

echo 
tput setaf 1 && tput setab 2 && echo
echo Information:
echo -------------------------------
echo "SSID:		$SSID"		
echo "HW MODE:	$HWM"		
echo "PASS:		$PASS"		
echo "CHANNEL:	$CHANNEL"	
echo -------------------------------
tput sgr0 && echo

echo Working...

echo Temporary disabling 'wlan0'...
ifconfig wlan0 down

echo Creating configs...

cat <<EOF >> /etc/dhcpcd.conf

interface wlan0
	static ip_address=192.168.4.1/24
	nohook wpa_supplicant
EOF

systemctl restart dhcpcd

cat <<EOF > /etc/dnsmasq.conf
interface=wlan0
dhcp-range=192.168.4.2,192.168.4.31,255.255.255.0,24h
EOF

cat <<EOF > /etc/hostapd/hostapd.conf
interface=wlan0
driver=nl80211
ssid=$SSID
hw_mode=$HWM
channel=$CHANNEL
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=$PASS
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF

sed -i "s/#DAEMON_CONF.*/DAEMON_CONF=\"\/etc\/hostapd\/hostapd.conf\"/g" /etc/default/hostapd

systemctl unmask hostapd
systemctl enable hostapd
systemctl start hostapd

#sed -i "s/#net.ipv4.ip_forward=1.*/net.ipv4.ip_forward=1/g" /etc/sysctl.conf

#iptables -t nat -A  POSTROUTING -o eth0 -j MASQUERADE
#sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"

#sed -i -e '$i \iptables-restore < /etc/iptables.ipv4.nat\n' /etc/rc.local

echo Restarting 'dhcpcd' and 'dnsmasq'
systemctl restart dhcpcd
systemctl restart dnsmasq

echo Enabling 'wlan0'...
ifconfig wlan0 up

echo Done
