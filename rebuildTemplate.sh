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
echo "Chdir to '$SOURCEDIR'"
cd "$SOURCEDIR"
echo "Sauvegarde dans '$TEMPLATE'"
cat << EOF > $TEMPLATE
# PlayOnLinux translation template
# Copyright (C) 2007-2010 PlayOnLinux Team
# This file is distributed under the same license as the PlayOnLiux package.
#
#, fuzzy
msgid ""
msgstr ""
"Project-Id-Version: PlayOnLinux\n"
"Report-Msgid-Bugs-To: MulX <os2mule@gmail.com>\n"
"POT-Creation-Date: $(date --rfc-3339=second)\n"
"PO-Revision-Date: YEAR-MO-DA HO:MI+ZONE\n"
"Last-Translator: FULL NAME <EMAIL@ADDRESS>\n"
"Language-Team: LANGUAGE <LL@li.org>\n"
"MIME-Version: 1.0\n"
"Content-Type: text/plain; charset=UTF-8\n"
"Content-Transfer-Encoding: 8bit\n"

EOF
#genre pour les fichiers shell
xgettext -L Shell -F -j --omit-header --foreign-user -o $TEMPLATE $(find bash -type f ) $(find lib -type f ) playonlinux*
#pareil pour python
xgettext -L Python -F -j --omit-header --foreign-user -o $TEMPLATE $(find python/ -type f ! -iname "*.pyc" )
#inclure les trads des plugins
[ -f plugins/pot.strings ] && cat plugins/pot.strings >> $TEMPLATE
