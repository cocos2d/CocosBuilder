#!/bin/sh

CCB_VERSION=$1

# Remove build directory
cd ..
rm -Rf build/

# Clean and build CocosBuilder
cd CocosBuilder/
xcodebuild -alltargets clean
xcodebuild -target CocosBuilder -configuration Debug build

# Create archives
cd ..
# mkdir "build/CocosBuilder-$CCB_VERSION-examples"
# mkdir "build/CocosBuilder-$CCB_VERSION-CCBReader"
# cp -RL "Examples" "build/CocosBuilder-$CCB_VERSION-examples/"
# cp -RL "Examples/CocosBuilderExample/libs/CCBReader" "build/CocosBuilder-$CCB_VERSION-CCBReader/"

cd build/
zip -r "CocosBuilder-$CCB_VERSION.zip" CocosBuilder.app
# zip -r "CocosBuilder-$CCB_VERSION-examples.zip" "CocosBuilder-$CCB_VERSION-examples"
# zip -r "CocosBuilder-$CCB_VERSION-CCBReader.zip" "CocosBuilder-$CCB_VERSION-CCBReader"
