# rpiASAP
Script to set RPI 3B+ as an AP

Script <i>rpiasap.sh</i> sets your RPI 3B(+) as an Wireless Access Point. 

<b>Usage:</b>

<i>./rpiasap.sh [SSID NAME] [WPA PASSPHRASE] [HARDWARE MODE] [CHANNEL]</i>

<i>WPA PASSPHRASE: (>= 8 chars)</i>
<i>HARDWARE MODES: (a = IEE 802.11a (5 GHz), b = IEE 802.11b (2.4 GHz), g = IEE 802.11g (2.4 GHz), ad = IEE 802.11ad (60GHz))</i>
<i>CHANNEL: (1-13 if IEE 802.11bg)</i>

Script summaries this tutorial: https://www.raspberrypi.org/documentation/configuration/wireless/access-point.md. Setting up bridge/routing/... (currently) not supported.

Script <i>rpisasap_unins.sh</i> restores your RPI to a state before AP.
