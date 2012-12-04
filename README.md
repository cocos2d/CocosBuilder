# CocosBuilder

CocosBuilder is a free tool (released under MIT-licence) for rapidly developing games and apps. CocosBuilder is built for Cocos2d's Javascript bindings, which means that your code, animations, and interfaces will run unmodified on iPhone, Android and HTML 5. If you prefer to go native all the way, there are readers available for cocos2d-iphone and cocos2d-x.

For more info and binary downloads, please visit [cocosbuilder.com](http://cocosbuilder.com).

## Getting started with the source

Cocos2d and other extensions are provided as a submodules to this project. To be able to compile the source code you need first check out the module. Change directory into the top (this) directory of CocosBuilder and run:

    git clone https://github.com/cocos2d/CocosBuilder
    cd CocosBuilder
    git submodule update --init
    cd CocosBuilder/libs/cocos2d-iphone/
    git submodule update --init

When building CocosBuilder, make sure that "CocosBuilder" is the selected target (it may be some of the plug-in targets by default).

## Still having trouble compiling CocosBuilder?

It is most likely still a problem with the submodules. Edit the .git/config file and remove the lines that are referencing submodules. Then change directory into the top directory and run:

    git submodule update --init

When building CocosBuilder, make sure that "CocosBuilder" is the selected target (it may be some of the plug-in targets by default).

## Running CocosPlayer

CocosBuilder has a companioning app called CocosPlayer. CocosPlayer let's you run your app directly on the device without compiling the complete project. All you need to set it up is running CocosPlayer on the same wireless network as CocosBuilder and they will automatically connect with each other.

To install CocosPlayer on your device (or in Simulator) you need to get the source code, either by downloading it from cocosbuilder.com or by cloning the git project (see above). Open the CocosPlayer project and install the app from Xcode.