#!/bin/bash

# PlayOnLinux Script checker
# Made by Quentin Pâris and SuperPlumus

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
	if [ "$err" = "0" ]
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
		deprecated_list="cfg_check POL_SetupWindow_Open POL_SetupWindow_Quit select_prefixe select_prefix Set_WineVersion_Session fonts_to_prefixe Set_GLSL POL_SetupWindow_auto_shortcut POL_SetupWindow_make_shortcut POL_SetupWindow_detect_exit wine POL_SetupWindow_message_image POL_SetupWindow_shortcut POL_SetupWindow_download browser Use_WineVersion POL_SetupWindow_prefixcreate POL_SetupWindow_games POL_SetupWindow_install_wine POL_SetupWindow_normalprefixcreate POL_SetupWindow_specialprefixcreate POL_SetupWindow_oldprefixcreate fonts_to_prefix POL_SetupError POL_SetupWindow_reboot Set_WineVersion_Assign POL_SetupWindow_wait_next_signal POL_SelectPrefix POL_SetupWindow_InitWithImages Set_SoundBitsPerSample Set_SoundEmulDriver Set_SoundHardwareAcceleration Set_SoundSampleRate"
	else
		type_err="err"
		s_echo "Checking forbidden functions"
		deprecated_list="sudo gksu gksudo kdesu kdesudo POL_Winetricks verifier_installation_e Create_Patched_Wine_Version Get_Latest_Wine_Version"
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
	#cat /tmp/script | grep '^TITLE=' > /tmp/title
	#source /tmp/title
	#if [ "$TITLE" = "" ]
	ScriptChecker_Title="$(cat /tmp/script | sed -n 's/TITLE=\"\([^\"]*\)\"/\1/p')"
	if [ "$ScriptChecker_Title" = "" ]
	then
		s_err 5
	elif [ "$ScriptChecker_Title" != "$(basename $file)" ]
	then
		s_err 5 "`$ScriptChecker_Title' doesn't match script name"
	else
		s_ok 5 "$ScriptChecker_Title"
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
	
	if [ "$lignes" != "" ]; then
        while read item
        do
            item_url="$(echo "$item" | sed -n "s/.*POL_Download \(\"\|'\)\([^\"']*\)\(\"\|'\).*/\2/p")"
            item_md5="$(echo "$item" | sed -n "s/.*POL_Download \(\"\|'\)\([^\"']*\)\(\"\|'\) \(\"\|'\)\([^\"']*\)\(\"\|'\).*/\4/p")"
	        
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
            elif [ "$POLSC" = "TRUE" ] # Si on vérifie depuis POLSC, on teste uniquement les md5
            then
                if [ "$item_md5" = "" ] # Si il n'y a pas de md5
		        then
		            [ "$i" = "0" ] && s_eret && i=1
	                s_elem "<$item_url>\nNot MD5"
	                found_err="true"
	                err_type="err"
	            fi
            fi
        done << EOF
$lignes
EOF
    fi
    
	if [ "$found_err" = "true" ]
	then
		s_etab 2
		s_$err_type 4
	else
		s_ok 4
	fi
}

check_dll_override_pol_call ()
{
	s_echo "Checking POL_Call POL_Function_OverrideDLL"
	
	if [ "$(cat /tmp/script | grep "POL_Function_OverrideDLL")" = "" ]
	then
 		s_ok 1
	else
		s_war 1
	fi	
}

check_rm_top_left ()
{
	s_echo "Checking rm \"\$POL_USER_ROOT/tmp/*.jpg\""
	
	if [ "$(cat /tmp/script | grep "rm \"\?\(\$POL_USER_ROOT\|\$REPERTOIRE\)/tmp/\*.jpg\"\?")" = "" ]
	then
 		s_ok 1
	else
		s_war 1
	fi
}

check_fonts_smooth_rgb()
{
    s_echo "Checking POL_Function_FontsSmoothRGB missing POL_Call"
	
	if [ "$(cat /tmp/script | grep "^POL_Function_FontsSmoothRGB")" = "" ]
	then
 		s_ok 1
	else
		s_war 1
	fi
}

check_old_modif_registry()
{
	type_err="war" 
	s_echo "Checking old modifcations registry"
	values_list="VideoMemorySize DefaultSampleRate DirectDrawRenderer Nonpower2Mode OffscreenRenderingMode PixelShaderMode RenderTargetLockMode UseGLSL Audio"
	found_err=false
	i=0	
	for item in $values_list
	do	
		if [ ! "$(cat /tmp/script | grep "\\\\\?\"$item\\\\\?\"=\\\\\?\".*\\\\\?\"")" = "" ]
		then
			[ "$i" = "0" ] && s_eret && i=1
			s_elem "$item modfication by old method"
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

check_comments_accents()
{
	s_echo "Checking absence accents in comments"
	
	if [ ! "$(cat /tmp/script | grep "#[^éèêëàäöüÉÈÊËÀÄÖÜ]*[éèëêàäöüÉÈÊËÀÄÖÜ]")" = "" ]
	then
		s_err 3
	else
	    s_ok 3
	fi
}

check_bad_messages_gettext()
{
	check_message()
	{
		if [ "$(cat /tmp/script | grep "\$(eval_gettext [\'\"]$1[\'\"])")" != "" ]
		then
			[ "$i" = "0" ] && s_eret && i=1
			s_elem "$1"
			found_err=true
		fi
	}
	
	s_echo "Checking bad gettext messages"
	found_err=false
	i=0	
	
	check_message "Please insert media into your disk drive\\\nif not already done."
	check_message "Installation in progress..."
	check_message "Please select the setup file to run:"
	check_message "Please select the setup file to run."
	check_message "\$TITLE has been installed successfully."
	check_message "Where is \$TITLE install file?"
	check_message "Please wait while \$APPLICATION_TITLE is installing \$TITLE..."
	check_message "Don't forget to close Steam when the download\\\nis finished, so \$APPLICATION_TITLE can continue\\\nto install your game."
	check_message "Please wait while \$TITLE is installed."
	
	if [ "$found_err" = "true" ]
	then
		s_etab 3
		s_war 3
	else
		s_ok 3
	fi
}

check_short_prefix_name()
{
    s_echo "Checking absence short prefix name"
	
	if [ "$(cat /tmp/script | grep "^PREFIX=\"[^\"]\{2,4\}\"")" = "" ] && [ "$(cat /tmp/script | grep "^POL_Wine_SelectPrefix \"[^\"]\{2,4\}\"")" = "" ]
	then
 		s_ok 1
	else
		s_war 1
	fi
}

check_var_prefix_exist()
{
    s_echo "Checking presence \$PREFIX variable"
	
	if [ "$(cat /tmp/script | grep "^PREFIX=\"[^\"]*\"")" != "" ]
	then
 		s_ok 1
	else
		s_war 1
	fi
}

check_xgettext_ok()
{
    if [ "$(which xgettext)" != "" ]
    then
	    s_echo "Checking possible to extract string"
        
	    if xgettext -L Shell "/tmp/script" &> /dev/null
	    then
		    s_ok 3
	    else
	        s_err 3
	    fi
	fi
}

check_eval_gettext_double_quote()
{
    s_echo "Checking absence messages delimited by doubles-quotes"
	
	if [ "$(cat /tmp/script | grep '$(eval_gettext ".*$.*")')" = "" ]
	then
 		s_ok 1
	else
		s_err 1
	fi
}

check_mmdevapi_override()
{
    s_echo "Checking no disabled mmdevapi.dll with wine >= 1.4"
	
	if [ "$(cat /tmp/script | grep 'WORKING_WINE_VERSION="1.\(4\|5\).*"')" != "" ] && [ "$(cat /tmp/script | grep 'OverrideDLL "" "mmdevapi"')" != "" ]
	then
 		s_war 1
	else
		s_ok 1
	fi
}

check_start_unix()
{
    s_echo "Checking no utilisation POL_Wine start /unix"
	
	if [ "$(cat /tmp/script | grep 'POL_Wine start /unix')" = "" ]
	then
 		s_ok 1
	else
		s_war 1
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
if [ "$POLSC" = "TRUE" ]; then
check_download
fi
check_dll_override_pol_call
check_rm_top_left
check_old_modif_registry
check_fonts_smooth_rgb
#check_comments_accents
check_bad_messages_gettext
check_short_prefix_name
#check_var_prefix_exist
check_xgettext_ok
check_eval_gettext_double_quote
check_mmdevapi_override
#check_start_unix

echo ""

[ "$errors" = "true" ] && exit 2
[ "$warning" = "true" ] && exit 1
exit 0
