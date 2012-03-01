# CocosBuilder - User Guide

With CocosBuilder you can graphically layout your Cocos2D node graphs and scenes and add them to your project with a single line of code. CocosBuilder is built around a plug-in system that allows the addition of almost any type of Cocos2D objects. By default, the following objects are supported _CCNode_, _CCLayer_, _CCLayerColor_, _CCLayerGradient_, _CCSprite_, _CCMenu_, _CCMenuItemImage_, _CCLabelBMFont_, _CCLabelTTF_, _CCParticleSystem_.


## Working in CocosBuilder

When creating a new document, make sure it is in the same directory as you other assets you want to use with CocosBuilder and in your project. Only assets in the same directory will show up in the program. The stage size can be up to a million points. The center of origin option will tell if the stage’s origin is set to the bottom left corner or the center of the stage. You can change the stage size and origin at any time in the View menu.

Use the selection tool to select objects to change their properties. Hold down the command key and drag the stage to instantly switch to the scroll view tool. Add objects by using the Object -> Add Object menu. You can also add CCSprite’s by dragging images from the Image Assets palette to the stage. If you drop images on a CCMenu they will automatically be added as CCMenuItemImages.

Edit the objects you have added by selecting them. If the object you have clicked on is obscured by another object, you can use the Select Behind option in the Object menu right after clicking. When an object is selected its properties will show up on the right side of the main window. Any updates you make in the properties view will be immediately reflected in your objects. You can move, rotate and scale objects by dragging their transform handles, it’s also possible to nudge them by using cmd-arrowkeys.


## Loading scenes and nodes

CocosBuilder files, or ccb-files can be easily loaded into your application with a single line of code. To load a node graph, add the CCBReader.h and CCBReader.m files to your Cocos2D project, then call the nodeGraphFromFile: method as follows.

CCNode* myNode = [CCBReader nodeGraphFromFile:@"MyNodeGraph.ccb"];
You may need to cast the returned value depending on what sort of object is the root node in your ccb-file and how you will use it in your code. For instance, if you load a CCParticleSystem, use the following code.
CCParticleSystem* myParticles = (CCParticleSystem*) [CCBReader nodeGraphFromFile:@"MyParticleSystem.ccb"];

For your convenience, CCBReader can also wrap your node graph in a scene. To load your ccb-file in a scene call sceneWithNodeGraphFromFile:

CCScene* myScene = [CCBReader sceneWithNodeGraphFromFile:@"MyScene.ccb"];