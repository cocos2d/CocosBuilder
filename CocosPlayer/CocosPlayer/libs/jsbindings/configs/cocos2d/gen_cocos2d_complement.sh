#!/bin/sh
#
# run this script from the cocos2d directory
# eg: $ cd ~/src/cocos2d-iphone/cocos2d/
#
mv ccDeprecated.h ccDeprecated.xxx

# Common
../external/jsbindings/generate_complement.py -e ../external/jsbindings/configs/cocos2d/cocos2d-ios-complement-exceptions.txt -o ../external/jsbindings/configs/cocos2d/cocos2d-complement.txt *.h Support/*.h Platforms/*.h

# iOS
../external/jsbindings/generate_complement.py -e ../external/jsbindings/configs/cocos2d/cocos2d-ios-complement-exceptions.txt -o ../external/jsbindings/configs/cocos2d/cocos2d-ios-complement.txt *.h Support/*.h Platforms/*.h Platforms/iOS/*.h

# Mac
../external/jsbindings/generate_complement.py -e ../external/jsbindings/configs/cocos2d/cocos2d-mac-complement-exceptions.txt -o ../external/jsbindings/configs/cocos2d/cocos2d-mac-complement.txt *.h Support/*.h Platforms/*.h Platforms/Mac/*.h

mv ccDeprecated.xxx ccDeprecated.h
