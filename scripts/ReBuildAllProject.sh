#!/bin/sh
HOMEPATH=$(cd "$(dirname "$0")"; pwd)

# Remove build directory
cd ..
rm -Rf build/

# Clean and build CocosBuilder
cd CocosBuilder/
xcodebuild -alltargets clean
xcodebuild -target CocosBuilder -configuration Debug build

# Clean and build Plugins
cd "$HOMEPATH"
PLUGINSPATH="../PlugIn Nodes/"
cd "$PLUGINSPATH"
for pluginDirName in $(ls .)
do
    if test -d "$pluginDirName"
    then
	cd "$pluginDirName"
	if test -d $(ls -d *.xcodeproj)
	    then
	    xcodebuild -configuration Debug build    
	fi
       	cd ..
    fi
done









