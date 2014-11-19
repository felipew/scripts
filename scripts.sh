#!/bin/sh
#
#
# Commom Scripts..

# includes
# WORK
HOSTNAME=`scutil --get ComputerName`
if test $HOSTNAME = "id25218000" ; then
	# work related stuff get from my work git
	# hostnames, sshs, repositories...
	source /Users/felipew/Documents/Scripts/utils.sh
fi
########################################################

# fast dir
cd1(){
	subdir(){
		dir=$1
		if test "x$dir" = "x" ; then
			# vazio nao faz nada
			return
		fi

		if test -d $dir ; then
			cd $dir
			return
		fi

		newdir=`ls -1 | grep $dir | head -n1`
		echo $newdir
		if ! test -z $newdir ; then
			cd $newdir
			return
		fi
	}
	case $1 in
		"1"|"dev")
			cd ~/Documents/Dev/
			;;
		"2"|"me")
			cd ~/Documents/DevMe/
			;;
		"3"|"docs")
			cd ~/Documents/DevDocs/
			;;
		"4" | "scripts")
			cd ~/Documents/Scripts
			;;
		"*")
			echo "1 - ~/Documents/Dev/"
			echo "2 - ~/Documents/DevMe/"
			echo "3 - ~/Documents/DevDocs/"
			exit
			;;
	esac

	subdir $2
}

# iOS Debuggin made easy
# Remote Virtual Interface utils
# Create an Remote Virtual Interface with the given UUID
crvi() {
	uuid=$1

	if test -z $uuid ; then
		echo "$FUNCNAME <uuid>"
		return false
	fi

	countOld=`ifconfig -l | wc -w`

	# check if device already have a rvi created
	activeDevice=`rvictl -l | grep -c $uuid`
	if test $activeDevice -gt 1 ; then
		deviceInterface=`rvictl -l | grep $uuid | awk '{ print $NF }'`
		echo "Device already created at interface $deviceInterface"
		return 0
	fi

	rvictl -s $uuid 

	countNew=`ifconfig -l | wc -w`

	if test $countNew -gt $countOld ; then
		deviceInterface=`rvictl -l | grep $uuid | awk '{ print $NF }'`
		echo "RVI created at interface $deviceInterface"
	else
		echo "Failed to create RVI, check if the device is connected or if the UUID is correct"
	fi
}
drvi(){
	uuid=$1

	if test -z $uuid ; then
		echo "$FUNCNAME <uuid>"
		return false
	fi

	rvictl -x $uuid
}

debug_iphone(){
	crvi "055d8dca3765bdeb225567fb513fad6f1e126a1b"
}
end_iphone(){
	drvi "055d8dca3765bdeb225567fb513fad6f1e126a1b"
}
debug_ipad(){
	crvi "d00d8d81bdfe58f129a2b06e8bb1fd58b1018c0e"
}
end_ipad(){
	drvi "d00d8d81bdfe58f129a2b06e8bb1fd58b1018c0e"
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

	connectWifi "$ssid" "$passwd"
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
