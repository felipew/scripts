#!/bin/sh
#
#
# Commom Scripts..

# includes
# WORK
HOSTNAME=`scutil --get ComputerName`
if test $HOSTNAME = "id25218000" ; then
	# work related stuff
	# hostnames, sshs, repositories...
	source /Users/felipew/Documents/Scripts/utils.sh
fi
########################################################

# fast dir
cd1(){
	case $1 in
		"1")
			cd ~/Documents/Dev/
			;;
		"2")
			cd ~/Documents/DevMe/
			;;
		"3")
			cd ~/Documents/DevDocs/
			;;
		"*")
			echo "1 - ~/Documents/Dev/"
			echo "2 - ~/Documents/DevMe/"
			echo "3 - ~/Documents/DevDocs/"
			;;
	esac
}

# Show netfork interfaces IP.
ip(){
	ifconfig | grep "inet " | grep -v "127.0.0.1"
}

wifi(){
	_opt=$1

	if test "x${_opt}" = "x" ; then
		echo "$FUNCNAME (on|off)"
		return 1
	fi

	if test "${_opt}" = "on" -o "${_opt}" = "off" ; then
		_interface=`networksetup -listallhardwareports | grep -E '(Wi-Fi|AirPort)' -A 1 | grep -o "en."`
		for in in $_interface ; do
			networksetup -setairportpower $in $_opt
		done
	fi
}

# Show wireless networks
scan(){
	/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport scan
}

# connect to a wifi network
connect(){
	if test $# -eq 2 ; then
		connectWifi $1 $2
		return;
	fi
	echo "Escaneando redes..."
	scan | cut -c 1-32

	echo -n "Digite a rede a qual deseja se conectar: "
	read ssid
	echo -n "Digite a senha da rede ${ssid}: "
	read passwd

	connectWifi $ssid $passwd
}

# wifi helper
connectWifi(){
	_ssid=$1 ; shift
	_pass=$1

	if test "x${_ssid}" = "x" ; then
		return 1
	fi 

	_interface=`networksetup -listallhardwareports | grep -E '(Wi-Fi|AirPort)' -A 1 | grep -o "en."`
	for in in $_interface ; do
		networksetup -setairportnetwork $in "${_ssid}" "${_pass}"
	done
}