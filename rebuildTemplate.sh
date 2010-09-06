#!/bin/bash
function usage
{
	echo "This tools can be used to rebuild the translation template"
	echo "$0 --playonlinux $HOME/PlayOnLinux_Source --template lang/po/pol.pot"
}
if [ $# -lt 4 ] 
then
usage
exit
fi

while [ $# -gt 0 ]
do
	case $1 in
	--playonlinux)
		SOURCEDIR=$2
		shift
		shift
	;;
	--template)
		TEMPLATE=$2
		shift
		shift
	;;
	*)
	usage
	;;
	esac
done
echo "Changing dir to '$SOURCEDIR'"
cd "$SOURCEDIR"
echo "Sauvegarde dans '$TEMPLATE'"
xgettext -L Shell -F -o $TEMPLATE $(find bash -type f ) $(find lib -type f ) playonlinux*
xgettext -L Python -F -j --copyright-holder="PlayOnLinux Team" --package-name=PlayOnLinux --msgid-bugs-address="MulX <os2mule@gmail.com>" -o $TEMPLATE $(find python/ -type f ! -iname "*.pyc" )
