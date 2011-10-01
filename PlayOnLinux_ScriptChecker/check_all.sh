#!/bin/bash
source ui.sh

mkdir -p $HOME/www/scripts/details
no_color

list="$(find /home/tinou/PlayOnLinux_Scripts/)"
oldifs="$IFS"
newifs="
"
IFS="$newifs"
set "$list"
for elem in $*
do
	IFS="$oldifs"
	ele5="$(echo $elem | cut -d"/" -f5)"
        ele6="$(echo $elem | cut -d"/" -f6)"
	ntab=$(calctab "$ele6")

	if [ -d "/home/tinou/PlayOnLinux_Scripts/$ele5" ] && [ ! "$ele5" = "" ] && [ ! "$ele6" = "" ]
	then
	        s_echo "$ele6"	
		rm "$HOME/www/scripts/details/$ele6.txt" 2> /dev/null
		bash script_checker.sh --nocolor "$elem" 2>> "$HOME/www/scripts/details/$ele6.txt" >> "$HOME/www/scripts/details/$ele6.txt"
		code="$?"
		s_tab $ntab
		[ "$code" = "0" ] && s_ok
		[ "$code" = "1" ] && s_war
		[ "$code" = "2" ] && s_err
	fi
	IFS="$newifs"

done
