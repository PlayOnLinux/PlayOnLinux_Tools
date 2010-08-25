#!/bin/bash

wineSrcArchFile=$1
source lib_build

echo "$(date) -- Processing for $wineSrcArchFile"
getSignFile $wineSrcArchFile
checkSign $wineSrcArchFile.sign $wineSrcArchFile
if [ $signState != "0" ]
then 
	getWineSrc $wineSrcArchFile
	checkSign $wineSrcArchFile.sign $wineSrcArchFile
fi
echo "Signature State : $signState"
if [ "$signState" = "0" ] 
then
	preBuild $wineSrcArchFile
	if build $wineSrcArchFile
	then {
		cd $OPWD
		polize $wineSrcArchFile
		echo "Removing $wineSrcArchFile -- file ready to upload"
		echo -n ";$(getVersion $wineSrcArchFile)" >> $patchAllowLst
		rm -fr $wineSrcArchFile  $HOME/wb
		touch /build/wine/haveToSync
	}
	else {
		cd $OPWD
		echo "marking $wineSrcArchFile as failed"
		echo "$(buildingVersion $wineSrcArchFile)" >> failedToBuild
	}
	fi
fi
echo "$(date) -- Saving nohup file's"
