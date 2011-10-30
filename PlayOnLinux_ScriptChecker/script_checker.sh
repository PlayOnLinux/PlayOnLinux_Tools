#!/bin/bash

# PlayOnLinux Script checker
# Made by Quentin Pâris

output="/dev/stderr"

source ui.sh

[ "$1" == "--nocolor" ] && shift && no_color

[ "$1" == "--polsc" ] && POLSC="TRUE" && shift && polsc

file="$1"
shift


remove_gpg()
{
	if [ ! "$(grep "BEGIN PGP SIGNATURE" "$file")" = "" ]
	then
		GPG=`awk '/^-----BEGIN PGP SIGNATURE-----/ {print NR ; exit 0; }' "$file"`
		tail -n +${GPG} "$file" > "/tmp/script.asc" 2> /dev/null
		    head -n $(( GPG - 1 )) "$file"  | grep -v "cat << \"-----END PGP SIGNATURE-----\" > /dev/null" > "/tmp/script" 2> /dev/null
	else
		cp "$file" "/tmp/script" 2> /dev/null
	fi
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
		deprecated_list="cfg_check POL_SetupWindow_Open POL_SetupWindow_Quit select_prefixe select_prefix Set_WineVersion_Session fonts_to_prefixe Set_GLSL POL_SetupWindow_auto_shortcut POL_SetupWindow_make_shortcut POL_SetupWindow_detect_exit wine POL_SetupWindow_message_image POL_SetupWindow_shortcut POL_SetupWindow_download browser Use_WineVersion POL_SetupWindow_prefixcreate POL_SetupWindow_games POL_SetupWindow_install_wine POL_SetupWindow_normalprefixcreate POL_SetupWindow_specialprefixcreate POL_SetupWindow_oldprefixcreate fonts_to_prefix POL_SetupError POL_SetupWindow_reboot Set_WineVersion_Assign"
	else
		type_err="err"
		s_echo "Checking forbidden functions"
		deprecated_list="sudo gksu gksudo kdesu kdesudo POL_Winetricks verifier_installation_e Create_Patched_Wine_Version"
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
	if [ "$last_line" = "" ]
	then
		last_line="$(cat /tmp/script | tail -n 2 | head -n 1)"
	fi
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
check_var_repertoire()
{
        s_echo "Checking \$REPERTOIRE absence"

	if [ "$(cat /tmp/script | grep '\$REPERTOIRE')" = "" ]
	then
 		s_ok 3
	else
		s_war 3
	fi	
}
check_shebang()
{
        s_echo "Checking #!/bin/bash presence"

	if [ "$(cat /tmp/script | head -n 1)" = "#!/bin/bash" ]
	then
 		s_ok 3
	else
		s_err 3
	fi	
}
check_programfiles_prefixcreate()
{
        s_echo "Checking \$PROGRAMFILES exist before use"
	found="$(cat /tmp/script | grep -m 1 -o 'POL_Wine_PrefixCreate\|POL_SetupWindow_prefixcreate\|\$PROGRAMFILES')"
	if [ "$found" != "\$PROGRAMFILES" ] || [ "$found" = "" ]
	then
 		s_ok 2
	else
		s_err 2
	fi	
}
check_source_pol()
{
        s_echo "Checking source \"\$PLAYONLINUX/lib/sources\""
	
	if [ ! "$(cat /tmp/script | grep "source \"\$PLAYONLINUX/lib/sources\"")" = "" ]
	then
 		s_ok 1
	else
		s_err 1
	fi	
}
check_programfiles_dur()
{
        s_echo "Checking no path .../drive_c/Program Files/..."
	
	if [ "$(cat /tmp/script | grep "/drive_c/Program Files/")" = "" ]
	then
 		s_ok 1
	else
		s_err 1
	fi	
}
check_init_close()
{
        s_echo "Checking POL_SetupWindow_Init and Close"
	
	[ ! "$(cat /tmp/script | grep -o "POL_SetupWindow_Init\|POL_SetupWindow_InitWithImages")" = "" ] || presence="FALSE"
	[ ! "$(cat /tmp/script | grep -o "POL_SetupWindow_Close")" = "" ] || presence="FALSE"
	if [ ! "$presence" = "FALSE" ]
	then
 		s_ok 2
	else
		s_err 2
	fi	
}
check_wineprefix_selectprefix()
{
        s_echo "Checking \$WINEPREFIX exist before use"
	found="$(cat /tmp/script | grep -m 1 -o 'POL_Wine_SelectPrefix\|select_prefix\|\$WINEPREFIX')"
	if [ "$found" != "\$WINEPREFIX" ] || [ "$found" = "" ]
	then
 		s_ok 2
	else
		s_err 2
	fi	
}

check_download()
{
        s_echo "Checking POL_Download"
        
	lignes="$(cat /tmp/script | grep "POL_Download")"
	found_err="false"
	i="0"
	err_type=""

    while read item
    do
        item_url="$(echo "$item" | sed -n 's/.*POL_Download \"\([^\"]*\)\".*/\1/p')"
        item_md5="$(echo "$item" | sed -n 's/.*POL_Download \"\([^\"]*\)\" \"\([^\"]*\)\".*/\2/p')"
	    
	    # Ce ne doit pas être POLSC qui appelle le ScriptChecker, et il ne doit pas y avoir l'argument NO_MD5
	    if [ "$POLSC" != "TRUE" ] && [ "$item_md5" != "NO_MD5" ]
	    then
	    
	        # Il faut que $1 ne contienne pas de variable, et que $2 (md5) soit présent
	        if [ "$(echo "$item_url" | grep '\$')" = "" ] && [ "$item_md5" != "" ]
	        then
	            rm "/tmp/pol-file-download" &> /dev/null
	            
	            # Il faut que l'URL existe
		        if wget --spider "$item_url" &> /dev/null
		        then
		            wget "$item_url" --output-document="/tmp/pol-file-download" &> /dev/null
		            md5="$(md5sum "/tmp/pol-file-download" | awk '{print $1}')"
		            
		            # Si les 2 sommes md5 ne correspondent pas
		            if [ "$md5" != "$item_md5" ]
		            then
		                [ "$i" = "0" ] && s_eret && i=1
		                s_elem "<$item_url>\nMD5 Mismatch !"
		                found_err="true"
		                err_type="err"
		            fi
		            rm "/tmp/pol-file-download" &> /dev/null
		        else # Si l'URL n'existe pas
		            [ "$i" = "0" ] && s_eret && i=1
		            s_elem "<$item_url>\nFile not found !"
		            found_err="true"
		            err_type="err"
                fi
		    elif [ "$item_md5" = "" ] # Si il n'y a pas de md5
		    then
		        [ "$i" = "0" ] && s_eret && i=1
	            s_elem "<$item_url>\nNot MD5"
	            found_err="true"
	            err_type="err"
		    else # Si il y a une variable
		        [ "$i" = "0" ] && s_eret && i=1
		        s_elem "<$item_url>\nVariable found, Abort checked md5"
		        found_err="true"
		        [ "$err_type" != "err" ] && err_type="war"
	        fi
        fi
    done << EOF
$lignes
EOF
    
	if [ "$found_err" = "true" ]
	then
		s_etab 2
		s_$err_type 4
	else
		s_ok 4
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
check_var_repertoire
check_shebang
check_programfiles_prefixcreate
check_source_pol
check_programfiles_dur
check_init_close
check_wineprefix_selectprefix
# check_download # Cause some problem ; disabled for the moment
echo ""

[ "$errors" = "true" ] && exit 2
[ "$warning" = "true" ] && exit 1
exit 0
