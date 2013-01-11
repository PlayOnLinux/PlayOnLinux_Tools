#!/bin/bash

"$HOME/bin/add_scripts"
source ui.sh

mkdir -p $HOME/www/scripts/details
no_color

list="$(find $HOME/PlayOnLinux_Scripts/)"
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

	if [ -d "$HOME/PlayOnLinux_Scripts/$ele5" ] && [ ! "$ele5" = "" ] && [ ! "$ele6" = "" ]
	then
	        s_echo "$ele6"	
		rm "$HOME/www/scripts/details/$ele6.txt" 2> /dev/null
		bash script_checker.sh --nocolor "$elem" 2>> "$HOME/www/scripts/details/$ele6.txt" >> "$HOME/www/scripts/details/$ele6.txt"
		code="$?"
		s_tab $ntab
		[ "$code" = "0" ] && s_ok
		[ "$code" = "1" ] && s_war
		[ "$code" = "2" ] && s_err
		wget "http://www.playonlinux.com/api/script_state.php?i=$ele6&s=$(( code + 1 ))" -O- -q > /dev/null
		pdata="$(cat "$HOME/www/scripts/details/$ele6.txt")"
		pdata="c=$(POL_Website_urlparse "$pdata")"
		wget "http://www.playonlinux.com/api/script_statewhy.php?i=$ele6" --post-data="$pdata" -O- -q > /dev/null
	fi
	IFS="$newifs"

done
