#!/bin/sh
#
# run this script from the cocos2d directory
# eg: $ cd ~/src/cocos2d-iphone/cocos2d/
#
mv ccDeprecated.h ccDeprecated.xxx

gen_bridge_metadata -F complete --no-64-bit -c '-DCC_ENABLE_CHIPMUNK_INTEGRATION=1 -ISupport -IPlatforms -I. -I../external/Chipmunk/include/chipmunk/. -I../external/Chipmunk/include/chipmunk/constraints/.' *.h Support/*.h Platforms/*.h -o ../external/jsbindings/configs/cocos2d/cocos2d.bridgesupport

gen_bridge_metadata -F complete --64-bit -c '-D__CC_PLATFORM_MAC -ISupport -IPlatforms -IPlatforms/Mac -I.' *.h Platforms/*.h Platforms/Mac/*.h -o ../external/jsbindings/configs/cocos2d/cocos2d-mac.bridgesupport 

gen_bridge_metadata -F complete --no-64-bit -c '-D__CC_PLATFORM_IOS -ISupport -IPlatforms -IPlatforms/iOS -I.' *.h Platforms/*.h Platforms/iOS/*.h -o ../external/jsbindings/configs/cocos2d/cocos2d-ios.bridgesupport  -e ../external/jsbindings/configs/cocos2d/cocos2d-ios-exceptions.bridgesupport

mv ccDeprecated.xxx ccDeprecated.h
