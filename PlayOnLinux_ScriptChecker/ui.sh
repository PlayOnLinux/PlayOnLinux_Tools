#!/bin/bash

## Script checker for PlayOnLinux
# 
#
#
#

## Colors
txtblk='\e[0;30m' # Black - Regular
txtred='\e[0;31m' # Red
txtgrn='\e[0;32m' # Green
txtylw='\e[0;33m' # Yellow
txtblu='\e[0;34m' # Blue
txtpur='\e[0;35m' # Purple
txtcyn='\e[0;36m' # Cyan
txtwht='\e[0;37m' # White
bldblk='\e[1;30m' # Black - Bold
bldred='\e[1;31m' # Red
bldgrn='\e[1;32m' # Green
bldylw='\e[1;33m' # Yellow
bldblu='\e[1;34m' # Blue
bldpur='\e[1;35m' # Purple
bldcyn='\e[1;36m' # Cyan
bldwht='\e[1;37m' # White
unkblk='\e[4;30m' # Black - Underline
undred='\e[4;31m' # Red
undgrn='\e[4;32m' # Green
undylw='\e[4;33m' # Yellow
undblu='\e[4;34m' # Blue
undpur='\e[4;35m' # Purple
undcyn='\e[4;36m' # Cyan
undwht='\e[4;37m' # White
bakblk='\e[40m'   # Black - Background
bakred='\e[41m'   # Red
badgrn='\e[42m'   # Green
bakylw='\e[43m'   # Yellow
bakblu='\e[44m'   # Blue
bakpur='\e[45m'   # Purple
bakcyn='\e[46m'   # Cyan
bakwht='\e[47m'   # White
txtrst='\e[0m'    # Text Reset

no_color()
{
export txtblk='' # Black - Regular
export txtred='' # Red
export txtgrn='' # Green
export txtylw='' # Yellow
export txtblu='' # Blue
export txtpur='' # Purple
export txtcyn='' # Cyan
export txtwht='' # White
export bldblk='' # Black - Bold
export bldred='' # Red
export bldgrn='' # Green
export bldylw='' # Yellow
export bldblu='' # Blue
export bldpur='' # Purple
export bldcyn='' # Cyan
export bldwht='' # White
export unkblk='' # Black - Underline
export undred='' # Red
export undgrn='' # Green
export undylw='' # Yellow
export undblu='' # Blue
export undpur='' # Purple
export undcyn='' # Cyan
export undwht='' # White
export bakblk=''   # Black - Background
export bakred=''   # Red
export badgrn=''   # Green
export bakylw=''   # Yellow
export bakblu=''   # Blue
export bakpur=''   # Purple
export bakcyn=''   # Cyan
export bakwht=''   # White
export txtrst=''    # Text Reset
}

polsc()
{
export txtblk='<span foreground="#000000">' # Black - Regular
export txtred='<span foreground="#FF0000">' # Red
export txtgrn='<span foreground="#008000">' # Green
export txtylw='<span foreground="#FF8000">' # Yellow
export txtblu='<span foreground="#0000C0">' # Blue
export txtpur='<span foreground="#800080">' # Purple
export txtcyn='<span foreground="#00FFFF">' # Cyan
export txtwht='<span foreground="#FFFFFF">' # White
export bldblk='<span foreground="#000000" weight="bold">' # Black - Bold
export bldred='<span foreground="#FF0000" weight="bold">' # Red
export bldgrn='<span foreground="#008000" weight="bold">' # Green
export bldylw='<span foreground="#FF8000" weight="bold">' # Yellow
export bldblu='<span foreground="#0000C0" weight="bold">' # Blue
export bldpur='<span foreground="#800080" weight="bold">' # Purple
export bldcyn='<span foreground="#00FFFF" weight="bold">' # Cyan
export bldwht='<span foreground="#FFFFFF" weight="bold">' # White
export unkblk='<span foreground="#000000" underline="single">' # Black - Underline
export undred='<span foreground="#FF0000" underline="single">' # Red
export undgrn='<span foreground="#008000" underline="single">' # Green
export undylw='<span foreground="#FF8000" underline="single">' # Yellow
export undblu='<span foreground="#0000C0" underline="single">' # Blue
export undpur='<span foreground="#800080" underline="single">' # Purple
export undcyn='<span foreground="#00FFFF" underline="single">' # Cyan
export undwht='<span foreground="#FFFFFF" underline="single">' # White
export bakblk='<span background="#000000">'   # Black - Background
export bakred='<span background="#FF0000">'   # Red
export badgrn='<span background="#008000">'   # Green
export bakylw='<span background="#FFFF00">'   # Yellow
export bakblu='<span background="#0000C0">'   # Blue
export bakpur='<span background="#800080">'   # Purple
export bakcyn='<span background="#00FFFF">'   # Cyan
export bakwht='<span background="#FFFFFF">'   # White
export txtrst='</span>'    # Text Reset
}

s_echo ()
{
	printf "$1" 
}
s_tab ()
{
	[ "$1" = "" ] && t="4" || t="$1"
	for (( i = 0; i<$t; i++ ))
	do
		printf "\t"
	done
}
s_etab()
{
	s_tab "$@" >&2
}
s_eret()
{
	printf "\n" >&2
}
s_elem()
{
	printf " * $1\n" >&2
}
s_ok ()
{
	s_tab $1
	shift
	[ "$1" = "" ] && mess="Ok" || mess="$1"
	printf "[ ${bldgrn}$mess${txtrst} ]\n"
}
s_err ()
{
	s_tab $1
	errors="true"
	shift
	[ "$1" = "" ] && mess="Error" || mess="$1"
        printf "[ ${bldred}$mess${txtrst} ]\n"
}
s_war ()
{
	s_tab $1
	shift
	[ "$1" = "" ] && mess="Warning" || mess="$1"
	warning="true"
        printf "[ ${bldylw}$mess${txtrst} ]\n"
}
calctab ()
{
	ntab=$(( $(printf "$1" | wc -c) / 8 ))
	addtb=$(( 7 - ntab ))
	echo $addtb
}
