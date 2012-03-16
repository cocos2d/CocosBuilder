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
zip -r "build/CocosBuilder-$CCB_VERSION-examples.zip" CocosBuilderExample/* Documentation/* CCBReader/*
cd build/
zip -r "CocosBuilder-$CCB_VERSION.zip" CocosBuilder.app
