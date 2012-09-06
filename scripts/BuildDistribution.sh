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
mkdir "build/CocosBuilder-$CCB_VERSION-examples"
cp -RL CocosBuilderExample "build/CocosBuilder-$CCB_VERSION-examples/"
cp -RL "Add to Your Project" "build/CocosBuilder-$CCB_VERSION-examples/"

cd build/
zip -r "CocosBuilder-$CCB_VERSION.zip" CocosBuilder.app
zip -r "CocosBuilder-$CCB_VERSION-examples.zip" "CocosBuilder-$CCB_VERSION-examples"
