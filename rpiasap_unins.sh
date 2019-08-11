#!/bin/bash

echo
echo -en " \033[1;32m"
echo -e "⋱⋱ ⋰⋰		     RpiAsAP"
echo -en "\033[1;31m"
echo -e " ◖ ● ◗		*** UNINSTALL ***"
echo -e "◖ ● ● ◗	 	ver 1.2, July 2019"
echo -e " ◖ ● ◗		  Raspbian 2019.4"
echo -e "   ●"
echo -en "\033[0m"
echo

if (( $EUID != 0 )); then
	echo "ERROR: No administrator rights."
	exit 1
fi

ifconfig wlan0 down

echo Installing...
apt purge dnsmasq hostapd

echo Removing files
rm -rf /etc/default/hostapd
rm -rf /etc/hostapd/hostapd.conf
rm -rf /etc/hostapd

echo Restoring backup

#---------------------------------------------------------
cp ./rpiasap_backup/dhcpcd.conf.backup /etc/dhcpcd.conf
cp ./rpiasap_backup/dnsmasq.conf.backup /etc/dnsmasq.conf
#cp ./rpiasap_backup/sysctl.conf.backup /etc/sysctl.conf
#cp ./rpiasap_backup/iptables.ipv4.nat.backup /etc/iptables.ipv4.nat
#cp ./rpiasap_backup/rc.local.backup ~/rc.local
#---------------------------------------------------------

systemctl restart dhcpcd
ifconfig wlan0 up

echo Done
