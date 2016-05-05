#!/bin/bash

clear

txt_main_menu_title="Main Menu"
ip_addresses=$(ifconfig | awk -v RS="\n\n" '{ for (i=1; i<=NF; i++) if ($i == "inet" && $(i+1) ~ /^addr:/) address = substr($(i+1), 6); if (address != "127.0.0.1") printf "%s\t%s\n", $1, address }')
txt_main_menu="IP Addresses:\n$ip_addresses\n"

dialog --cr-wrap --no-label "Go back" --yes-label "Yes !!" --shadow --title "$txt_main_menu_title" --default-button no --yesno "$txt_main_menu" 0 0

# Get exit status
# 0 means user hit [yes] button.
# 1 means user hit [no] button.
# 255 means user hit [Esc] key.
response=$?

case $response in
	0) echo "yes";;
	1) echo "no";;
	255) echo "[ESC] key pressed.";;
esac
