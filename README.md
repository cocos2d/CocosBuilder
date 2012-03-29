# CocosBuilder

CocosBuilder is a free tool (released under MIT-licence) for graphically laying out sprites, layers and scenes for Cocos2D iPhone and Mac. It’s ideal for quickly and accurately creating menus and other parts of the interface, but can also be used to create levels, particle systems or any other kind of Cocos2D node graphs.


## Getting started with the source

Cocos2d and other extensions are provided as a submodules to this project. To be able to compile the source code you need first check out the module. Change directory into the top (this) directory of CocosBuilder and run:

    git submodule init
    git submodule update

When building CocosBuilder, make sure that "CocosBuilder" is the selected target (it may be some of the plug-in targets by default).


## Still having trouble compiling CocosBuilder?

It is most likely still a problem with the submodules. Edit the .git/config file and remove the lines that are referencing submodules. Then change directory into the top directory and run:

    git submodule init
    git submodule update
