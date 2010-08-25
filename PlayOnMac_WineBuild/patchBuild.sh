#!/bin/bash

line=$@
source lib_build

rm -rf $HOME/wb /tmp/patch &>/dev/null
#checking line from text file
P_chkLine $line || { P_reportError $? $P_idTask "Internal Error Please contact MulX IMMEDIATLY!" ; echo "Error with line: '$line' ... continue" ;   exit ; }
#update status page
P_changeStatus $P_idTask 1 
#checking patch file
P_chkPatch || { P_reportError $? $P_idTask ; exit ; } 

cd $WORKDIR
P_wineSrcFile=wine-$P_WineVersion.tar.bz2

echo "$(date) -- Processing task $P_idTask"
getSignFile $P_wineSrcFile
checkSign $P_wineSrcFile.sign $P_wineSrcFile
if [ $signState != "0" ] 
then
	getWineSrc $P_wineSrcFile
	checkSign $P_wineSrcFile.sign $P_wineSrcFile
fi
echo "Signature State : $signState"
[ "$signState" == "0" ] || {  P_reportError 7 $P_idTask ; exit ; }
preBuild $P_wineSrcFile
needPatch=true
if build $P_wineSrcFile $P_name
then {
	cd $OPWD
	P_polize  $P_wineSrcFile $P_name $P_idTask
	echo "Removing $P_wineSrcFile"
	P_changeStatus $P_idTask 2 
	touch /build/wine/haveToSync
}
else {
	cd $OPWD
	P_reportError $[40+$buildState] $P_idTask
}
fi
rm -rf $P_wineSrcFile $HOME/wb
echo "$(date) -- Saving nohup file"
