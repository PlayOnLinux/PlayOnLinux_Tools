#!/bin/bash

# PlayOnLinux Script checker
# Made by Quentin Pâris

output="/dev/stderr"

source ui.sh

[ "$1" == "--nocolor" ] && shift && no_color

[ "$1" == "--polsc" ] && shift && polsc

file="$1"
shift


remove_gpg()
{
	GPG=`awk '/^-----BEGIN PGP SIGNATURE-----/ {print NR ; exit 0; }' "$file"`
	tail -n +${GPG} "$file" > "/tmp/script.asc" 2> /dev/null
        head -n $(( GPG - 1 )) "$file"  | grep -v "cat << \"-----END PGP SIGNATURE-----\" > /dev/null" > "/tmp/script" 2> /dev/null
	s_echo "Remove signature"
	s_ok
}
check_syntax()
{
	s_echo "Checking script syntax"
	bash -n "/tmp/script" 2> /tmp/syntax_err
	err="$?"
	[ "$err" = "0" ] || s_eret
	cat /tmp/syntax_err >&2
	[ "$err" = "0" ] || s_etab 2 
	if [ "$?" = "0" ]
	then
		s_ok
	else
		s_err
	fi
}
check_deprecated()
{
	if [ "$1" = "" ] 
	then
		type_err="war" 
		s_echo "Checking deprecated functions"
		deprecated_list="POL_SetupWindow_make_shortcut Use_Wineversion POL_SetupWindow_auto_shortcut POL_SetupWindow_prefixcreate select_prefix select_prefixe POL_SetupWindow_install_wine POL_SetupWindow_detect_exit cfg_check wine Set_WineVersion_Assign browser POL_SetupWindow_download"
	else
		type_err="err"
		s_echo "Checking forbidden functions"
		deprecated_list="sudo gksu gksudo POL_Winetricks verifier_installation_e Create_Patched_Wine_Version"
	fi
	found_err=false
	i=0	
	for item in $deprecated_list
	do	
		if [ ! "$(cat /tmp/script | grep "^$item")" = "" ]
		then
			[ "$i" = "0" ] && s_eret && i=1
			s_elem "$item is deprecated"
			found_err=true
		fi
	done
	if [ "$found_err" = "true" ]
	then
		s_etab 3
		s_$type_err 3
	else
		s_ok 3
	fi
}
check_title()
{
	s_echo "Checking \$TITLE"
	cat /tmp/script | grep '^TITLE=' > /tmp/title
	source /tmp/title
	if [ "$TITLE" = "" ]
	then
		s_err 5
	else
		s_ok 5 "$TITLE"
	fi
}
check_exit()
{
	s_echo "Checking exit"
	last_line="$(cat /tmp/script | tail -n 1)"
	if [ "$last_line" = "exit" ] || [ "$last_line" = "exit 0" ]
	then
		s_ok 5 "$last_line"
	else
		s_err 5 "$last_line"
	fi
}
check_scale ()
{
	s_echo "Checking convert scale absence"
	if [ "$(cat /tmp/script | grep convert | grep scale)" = "" ]
	then
		s_ok 3
	else
		s_err 3
	fi
}
check_mifs ()
{
        s_echo "Checking make icon for shortcut absence"
        if [ "$(cat /tmp/script | grep convert | grep geometry)" = "" ]
        then
                s_ok 2
        else
                s_err 2
        fi
}
check_debug ()
{
        s_echo "Checking POL_Debug_Init presence"
        if [ "$(cat /tmp/script | grep POL_Debug_Init)" = "" ]
        then
                s_war 2
        else
                s_ok 2
        fi
}
check_vms()
{
        s_echo "Checking old vms function absence"
        if [ "$(cat /tmp/script | grep vms.reg)" = "" ]
        then
                s_ok 2
        else
                s_err 2
        fi

}
check_winetricks()
{
	s_echo "Checking winetricks absence"
        if [ "$(cat /tmp/script | grep 'bash winetricks')" = "" ] &&  [ "$(cat /tmp/script | grep 'POL_Winetricks')" = "" ]
	then
		s_ok 3
	else
		s_err 3
	fi
}
check_old_programfiles()
{
	s_echo "Checking ProgramFile detection absence"
	if [ "$(cat /tmp/script | grep 'wine cmd /c echo "%ProgramFiles%"')" = "" ]
        then
                s_ok 2
        else
                s_err 2
        fi

}
check_cdrom_problem()
{
	s_echo "Checking cdrom find absence"
	if [ "$(cat /tmp/script | grep 'CHECK=$(find . -iwholename')" = "" ]
        then
                s_ok 3
        else
                s_err 3
        fi


}
check_old_wine()
{
	cw()
	{
	        s_echo "Checking old wine version absence : $1.x"

        	if [ "$(cat /tmp/script | grep -i "WINEVERSION" | grep "$1")" = "" ] && [ "$(cat /tmp/script | grep -i "WINE_VERSION" | grep "$1")" = "" ]
        	then
        	        s_ok 1
       		else
                	s_err 1
        	fi
	}
	cw 0.9
	cw 1.0
	cw 1.1
}
check_lng_str()
{
        s_echo "Checking LNG strings absence"

	nLng="$(cat /tmp/script | grep '^LNG_' | wc -l)"
	if [ "$nLng" = "0" ]
	then
 		s_ok 3
	else
		s_war 3 "$nLng items found"
	fi	
}
## STARTING
remove_gpg
check_syntax
check_title
check_deprecated --forbidden
check_deprecated
check_exit
check_scale
check_mifs
check_debug
check_vms
check_winetricks 
check_old_programfiles
check_cdrom_problem
check_old_wine
check_lng_str
echo ""

[ "$errors" = "true" ] && exit 2
[ "$warning" = "true" ] && exit 1
exit 0
