#!/bin/bash
export LC_ALL=C
cd /build/wine/
if [ -f lock ] ; then
	exit 1
fi
touch lock
echo "$(date) -- Initializing (build script version 0.3) .."
source lib_build
echo "getting list of version (from ibiblio.org)"
versionToBuild
cat requestedPriority /tmp/wineSrcToBuild > /tmp/foo
mv -f /tmp/foo /tmp/wineSrcToBuild
rm /tmp/wineVersionList /tmp/localVersionList
export buildState=-1
echo "Done !"
while read wineSrcArchFile
do
	echo "writing to  $wineSrcArchFile.build.out"
	bash /build/wine/bNohup.sh $wineSrcArchFile &>  $wineSrcArchFile.build.out
done < /tmp/wineSrcToBuild
if [ -f /build/wine/patch ] ; then 
	P_Start
fi
rm -f lock
echo "request:poweroff" >nohup.out
touch /tmp/halt
