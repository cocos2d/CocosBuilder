/**
 * @module cocos2dx
 */
var cc = cc || {};

/**
 * @class CCAction
 */
cc.Action = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method setOriginalTarget
 * @param {cocos2d::CCNode*}
 */
setOriginalTarget : function () {},

/**
 * @method setTarget
 * @param {cocos2d::CCNode*}
 */
setTarget : function () {},

/**
 * @method getOriginalTarget
 * @return A value converted from C/C++ "cocos2d::CCNode*"
 */
getOriginalTarget : function () {},

/**
 * @method stop
 */
stop : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method getTarget
 * @return A value converted from C/C++ "cocos2d::CCNode*"
 */
getTarget : function () {},

/**
 * @method step
 * @param {float}
 */
step : function () {},

/**
 * @method setTag
 * @param {int}
 */
setTag : function () {},

/**
 * @method getTag
 * @return A value converted from C/C++ "int"
 */
getTag : function () {},

/**
 * @method isDone
 * @return A value converted from C/C++ "bool"
 */
isDone : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCAction*"
 */
create : function () {},

/**
 * @method CCAction
 * @constructor
 */
CCAction : function () {},

};

/**
 * @class CCFiniteTimeAction
 */
cc.FiniteTimeAction = {

/**
 * @method setDuration
 * @param {float}
 */
setDuration : function () {},

/**
 * @method getDuration
 * @return A value converted from C/C++ "float"
 */
getDuration : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCFiniteTimeAction*"
 */
reverse : function () {},

/**
 * @method CCFiniteTimeAction
 * @constructor
 */
CCFiniteTimeAction : function () {},

};

/**
 * @class CCSpeed
 */
cc.Speed = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method setInnerAction
 * @param {cocos2d::CCActionInterval*}
 */
setInnerAction : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method stop
 */
stop : function () {},

/**
 * @method step
 * @param {float}
 */
step : function () {},

/**
 * @method setSpeed
 * @param {float}
 */
setSpeed : function () {},

/**
 * @method initWithAction
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCActionInterval*}
 * @param {float}
 */
initWithAction : function () {},

/**
 * @method getInnerAction
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
getInnerAction : function () {},

/**
 * @method isDone
 * @return A value converted from C/C++ "bool"
 */
isDone : function () {},

/**
 * @method getSpeed
 * @return A value converted from C/C++ "float"
 */
getSpeed : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCSpeed*"
 * @param {cocos2d::CCActionInterval*}
 * @param {float}
 */
create : function () {},

/**
 * @method CCSpeed
 * @constructor
 */
CCSpeed : function () {},

};

/**
 * @class CCFollow
 */
cc.Follow = {

/**
 * @method initWithTarget
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCNode*}
 * @param {cocos2d::CCRect}
 */
initWithTarget : function () {},

/**
 * @method stop
 */
stop : function () {},

/**
 * @method setBoudarySet
 * @param {bool}
 */
setBoudarySet : function () {},

/**
 * @method step
 * @param {float}
 */
step : function () {},

/**
 * @method isDone
 * @return A value converted from C/C++ "bool"
 */
isDone : function () {},

/**
 * @method isBoundarySet
 * @return A value converted from C/C++ "bool"
 */
isBoundarySet : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCFollow*"
 * @param {cocos2d::CCNode*}
 * @param {cocos2d::CCRect}
 */
create : function () {},

/**
 * @method CCFollow
 * @constructor
 */
CCFollow : function () {},

};

/**
 * @class CCGLProgram
 */
cc.GLProgram = {

/**
 * @method fragmentShaderLog
 * @return A value converted from C/C++ "const char*"
 */
fragmentShaderLog : function () {},

/**
 * @method addAttribute
 * @param {const char*}
 * @param {unsigned int}
 */
addAttribute : function () {},

/**
 * @method setUniformLocationWithMatrix4fv
 * @param {int}
 * @param {float*}
 * @param {unsigned int}
 */
setUniformLocationWithMatrix4fv : function () {},

/**
 * @method getUniformLocationForName
 * @return A value converted from C/C++ "int"
 * @param {const char*}
 */
getUniformLocationForName : function () {},

/**
 * @method use
 */
use : function () {},

/**
 * @method vertexShaderLog
 * @return A value converted from C/C++ "const char*"
 */
vertexShaderLog : function () {},

/**
 * @method initWithVertexShaderByteArray
 * @return A value converted from C/C++ "bool"
 * @param {const char*}
 * @param {const char*}
 */
initWithVertexShaderByteArray : function () {},

/**
 * @method initWithVertexShaderFilename
 * @return A value converted from C/C++ "bool"
 * @param {const char*}
 * @param {const char*}
 */
initWithVertexShaderFilename : function () {},

/**
 * @method setUniformsForBuiltins
 */
setUniformsForBuiltins : function () {},

/**
 * @method setUniformLocationWith3i
 * @param {int}
 * @param {int}
 * @param {int}
 * @param {int}
 */
setUniformLocationWith3i : function () {},

/**
 * @method setUniformLocationWith3iv
 * @param {int}
 * @param {int*}
 * @param {unsigned int}
 */
setUniformLocationWith3iv : function () {},

/**
 * @method updateUniforms
 */
updateUniforms : function () {},

/**
 * @method setUniformLocationWith4iv
 * @param {int}
 * @param {int*}
 * @param {unsigned int}
 */
setUniformLocationWith4iv : function () {},

/**
 * @method link
 * @return A value converted from C/C++ "bool"
 */
link : function () {},

/**
 * @method setUniformLocationWith2iv
 * @param {int}
 * @param {int*}
 * @param {unsigned int}
 */
setUniformLocationWith2iv : function () {},

/**
 * @method reset
 */
reset : function () {},

/**
 * @method setUniformLocationWith4i
 * @param {int}
 * @param {int}
 * @param {int}
 * @param {int}
 * @param {int}
 */
setUniformLocationWith4i : function () {},

/**
 * @method setUniformLocationWith1i
 * @param {int}
 * @param {int}
 */
setUniformLocationWith1i : function () {},

/**
 * @method setUniformLocationWith2i
 * @param {int}
 * @param {int}
 * @param {int}
 */
setUniformLocationWith2i : function () {},

/**
 * @method CCGLProgram
 * @constructor
 */
CCGLProgram : function () {},

};

/**
 * @class CCTouch
 */
cc.Touch = {

/**
 * @method getPreviousLocationInView
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 */
getPreviousLocationInView : function () {},

/**
 * @method getLocation
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 */
getLocation : function () {},

/**
 * @method getDelta
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 */
getDelta : function () {},

/**
 * @method getStartLocationInView
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 */
getStartLocationInView : function () {},

/**
 * @method getStartLocation
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 */
getStartLocation : function () {},

/**
 * @method getID
 * @return A value converted from C/C++ "int"
 */
getID : function () {},

/**
 * @method setTouchInfo
 * @param {int}
 * @param {float}
 * @param {float}
 */
setTouchInfo : function () {},

/**
 * @method getLocationInView
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 */
getLocationInView : function () {},

/**
 * @method getPreviousLocation
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 */
getPreviousLocation : function () {},

/**
 * @method CCTouch
 * @constructor
 */
CCTouch : function () {},

};

/**
 * @class CCSet
 */
cc.Set = {

/**
 * @method count
 * @return A value converted from C/C++ "int"
 */
count : function () {},

/**
 * @method addObject
 * @param {cocos2d::CCObject*}
 */
addObject : function () {},

/**
 * @method mutableCopy
 * @return A value converted from C/C++ "cocos2d::CCSet*"
 */
mutableCopy : function () {},

/**
 * @method anyObject
 * @return A value converted from C/C++ "cocos2d::CCObject*"
 */
anyObject : function () {},

/**
 * @method removeAllObjects
 */
removeAllObjects : function () {},

/**
 * @method removeObject
 * @param {cocos2d::CCObject*}
 */
removeObject : function () {},

/**
 * @method copy
 * @return A value converted from C/C++ "cocos2d::CCSet*"
 */
copy : function () {},

/**
 * @method containsObject
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCObject*}
 */
containsObject : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCSet*"
 */
create : function () {},

};

/**
 * @class CCTexture2D
 */
cc.Texture2D = {

/**
 * @method getShaderProgram
 * @return A value converted from C/C++ "cocos2d::CCGLProgram*"
 */
getShaderProgram : function () {},

/**
 * @method getMaxT
 * @return A value converted from C/C++ "float"
 */
getMaxT : function () {},

/**
 * @method stringForFormat
 * @return A value converted from C/C++ "const char*"
 */
stringForFormat : function () {},

/**
 * @method initWithImage
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCImage*}
 */
initWithImage : function () {},

/**
 * @method setShaderProgram
 * @param {cocos2d::CCGLProgram*}
 */
setShaderProgram : function () {},

/**
 * @method getMaxS
 * @return A value converted from C/C++ "float"
 */
getMaxS : function () {},

/**
 * @method hasPremultipliedAlpha
 * @return A value converted from C/C++ "bool"
 */
hasPremultipliedAlpha : function () {},

/**
 * @method getPixelsHigh
 * @return A value converted from C/C++ "unsigned int"
 */
getPixelsHigh : function () {},

/**
 * @method getName
 * @return A value converted from C/C++ "unsigned int"
 */
getName : function () {},

/**
 * @method setMaxT
 * @param {float}
 */
setMaxT : function () {},

/**
 * @method drawInRect
 * @param {cocos2d::CCRect}
 */
drawInRect : function () {},

/**
 * @method getContentSize
 * @return A value converted from C/C++ "cocos2d::CCSize"
 */
getContentSize : function () {},

/**
 * @method setAliasTexParameters
 */
setAliasTexParameters : function () {},

/**
 * @method setAntiAliasTexParameters
 */
setAntiAliasTexParameters : function () {},

/**
 * @method generateMipmap
 */
generateMipmap : function () {},

/**
 * @method getPixelFormat
 * @return A value converted from C/C++ "cocos2d::CCTexture2DPixelFormat"
 */
getPixelFormat : function () {},

/**
 * @method getContentSizeInPixels
 * @return A value converted from C/C++ "cocos2d::CCSize"
 */
getContentSizeInPixels : function () {},

/**
 * @method getPixelsWide
 * @return A value converted from C/C++ "unsigned int"
 */
getPixelsWide : function () {},

/**
 * @method drawAtPoint
 * @param {cocos2d::CCPoint}
 */
drawAtPoint : function () {},

/**
 * @method hasMipmaps
 * @return A value converted from C/C++ "bool"
 */
hasMipmaps : function () {},

/**
 * @method initWithPVRFile
 * @return A value converted from C/C++ "bool"
 * @param {const char*}
 */
initWithPVRFile : function () {},

/**
 * @method setMaxS
 * @param {float}
 */
setMaxS : function () {},

/**
 * @method setDefaultAlphaPixelFormat
 * @param {cocos2d::CCTexture2DPixelFormat}
 */
setDefaultAlphaPixelFormat : function () {},

/**
 * @method defaultAlphaPixelFormat
 * @return A value converted from C/C++ "cocos2d::CCTexture2DPixelFormat"
 */
defaultAlphaPixelFormat : function () {},

/**
 * @method PVRImagesHavePremultipliedAlpha
 * @param {bool}
 */
PVRImagesHavePremultipliedAlpha : function () {},

/**
 * @method CCTexture2D
 * @constructor
 */
CCTexture2D : function () {},

};

/**
 * @class CCNode
 */
cc.Node = {

/**
 * @method getShaderProgram
 * @return A value converted from C/C++ "cocos2d::CCGLProgram*"
 */
getShaderProgram : function () {},

/**
 * @method getChildren
 * @return A value converted from C/C++ "cocos2d::CCArray*"
 */
getChildren : function () {},

/**
 * @method getScriptHandler
 * @return A value converted from C/C++ "int"
 */
getScriptHandler : function () {},

/**
 * @method convertToWorldSpaceAR
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 * @param {cocos2d::CCPoint}
 */
convertToWorldSpaceAR : function () {},

/**
 * @method isIgnoreAnchorPointForPosition
 * @return A value converted from C/C++ "bool"
 */
isIgnoreAnchorPointForPosition : function () {},

/**
 * @method init
 * @return A value converted from C/C++ "bool"
 */
init : function () {},

/**
 * @method setRotation
 * @param {float}
 */
setRotation : function () {},

/**
 * @method setZOrder
 * @param {int}
 */
setZOrder : function () {},

/**
 * @method setScaleY
 * @param {float}
 */
setScaleY : function () {},

/**
 * @method setScaleX
 * @param {float}
 */
setScaleX : function () {},

/**
 * @method unregisterScriptHandler
 */
unregisterScriptHandler : function () {},

/**
 * @method getTag
 * @return A value converted from C/C++ "int"
 */
getTag : function () {},

/**
 * @method convertToWorldSpace
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 * @param {cocos2d::CCPoint}
 */
convertToWorldSpace : function () {},

/**
 * @method setSkewX
 * @param {float}
 */
setSkewX : function () {},

/**
 * @method setSkewY
 * @param {float}
 */
setSkewY : function () {},

/**
 * @method convertTouchToNodeSpace
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 * @param {cocos2d::CCTouch*}
 */
convertTouchToNodeSpace : function () {},

/**
 * @method getRotationX
 * @return A value converted from C/C++ "float"
 */
getRotationX : function () {},

/**
 * @method getRotationY
 * @return A value converted from C/C++ "float"
 */
getRotationY : function () {},

/**
 * @method setParent
 * @param {cocos2d::CCNode*}
 */
setParent : function () {},

/**
 * @method numberOfRunningActions
 * @return A value converted from C/C++ "unsigned int"
 */
numberOfRunningActions : function () {},

/**
 * @method stopActionByTag
 * @param {int}
 */
stopActionByTag : function () {},

/**
 * @method reorderChild
 * @param {cocos2d::CCNode*}
 * @param {int}
 */
reorderChild : function () {},

/**
 * @method setPositionY
 * @param {float}
 */
setPositionY : function () {},

/**
 * @method setPositionX
 * @param {float}
 */
setPositionX : function () {},

/**
 * @method getAnchorPoint
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 */
getAnchorPoint : function () {},

/**
 * @method isVisible
 * @return A value converted from C/C++ "bool"
 */
isVisible : function () {},

/**
 * @method getChildrenCount
 * @return A value converted from C/C++ "unsigned int"
 */
getChildrenCount : function () {},

/**
 * @method setAnchorPoint
 * @param {cocos2d::CCPoint}
 */
setAnchorPoint : function () {},

/**
 * @method convertToNodeSpaceAR
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 * @param {cocos2d::CCPoint}
 */
convertToNodeSpaceAR : function () {},

/**
 * @method visit
 */
visit : function () {},

/**
 * @method setShaderProgram
 * @param {cocos2d::CCGLProgram*}
 */
setShaderProgram : function () {},

/**
 * @method getRotation
 * @return A value converted from C/C++ "float"
 */
getRotation : function () {},

/**
 * @method resumeSchedulerAndActions
 */
resumeSchedulerAndActions : function () {},

/**
 * @method getZOrder
 * @return A value converted from C/C++ "int"
 */
getZOrder : function () {},

/**
 * @method getAnchorPointInPoints
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 */
getAnchorPointInPoints : function () {},

/**
 * @method runAction
 * @return A value converted from C/C++ "cocos2d::CCAction*"
 * @param {cocos2d::CCAction*}
 */
runAction : function () {},

/**
 * @method transform
 */
transform : function () {},

/**
 * @method setVertexZ
 * @param {float}
 */
setVertexZ : function () {},

/**
 * @method setScheduler
 * @param {cocos2d::CCScheduler*}
 */
setScheduler : function () {},

/**
 * @method stopAllActions
 */
stopAllActions : function () {},

/**
 * @method getSkewX
 * @return A value converted from C/C++ "float"
 */
getSkewX : function () {},

/**
 * @method getSkewY
 * @return A value converted from C/C++ "float"
 */
getSkewY : function () {},

/**
 * @method ignoreAnchorPointForPosition
 * @param {bool}
 */
ignoreAnchorPointForPosition : function () {},

/**
 * @method getActionByTag
 * @return A value converted from C/C++ "cocos2d::CCAction*"
 * @param {int}
 */
getActionByTag : function () {},

/**
 * @method setRotationX
 * @param {float}
 */
setRotationX : function () {},

/**
 * @method setRotationY
 * @param {float}
 */
setRotationY : function () {},

/**
 * @method getScheduler
 * @return A value converted from C/C++ "cocos2d::CCScheduler*"
 */
getScheduler : function () {},

/**
 * @method getOrderOfArrival
 * @return A value converted from C/C++ "unsigned int"
 */
getOrderOfArrival : function () {},

/**
 * @method setContentSize
 * @param {cocos2d::CCSize}
 */
setContentSize : function () {},

/**
 * @method setActionManager
 * @param {cocos2d::CCActionManager*}
 */
setActionManager : function () {},

/**
 * @method isRunning
 * @return A value converted from C/C++ "bool"
 */
isRunning : function () {},

/**
 * @method getParent
 * @return A value converted from C/C++ "cocos2d::CCNode*"
 */
getParent : function () {},

/**
 * @method getPositionY
 * @return A value converted from C/C++ "float"
 */
getPositionY : function () {},

/**
 * @method getPositionX
 * @return A value converted from C/C++ "float"
 */
getPositionX : function () {},

/**
 * @method setVisible
 * @param {bool}
 */
setVisible : function () {},

/**
 * @method pauseSchedulerAndActions
 */
pauseSchedulerAndActions : function () {},

/**
 * @method getVertexZ
 * @return A value converted from C/C++ "float"
 */
getVertexZ : function () {},

/**
 * @method _setZOrder
 * @param {int}
 */
_setZOrder : function () {},

/**
 * @method setScale
 * @param {float}
 */
setScale : function () {},

/**
 * @method getChildByTag
 * @return A value converted from C/C++ "cocos2d::CCNode*"
 * @param {int}
 */
getChildByTag : function () {},

/**
 * @method setOrderOfArrival
 * @param {unsigned int}
 */
setOrderOfArrival : function () {},

/**
 * @method getScaleY
 * @return A value converted from C/C++ "float"
 */
getScaleY : function () {},

/**
 * @method getScaleX
 * @return A value converted from C/C++ "float"
 */
getScaleX : function () {},

/**
 * @method cleanup
 */
cleanup : function () {},

/**
 * @method getContentSize
 * @return A value converted from C/C++ "cocos2d::CCSize"
 */
getContentSize : function () {},

/**
 * @method setGrid
 * @param {cocos2d::CCGridBase*}
 */
setGrid : function () {},

/**
 * @method boundingBox
 * @return A value converted from C/C++ "cocos2d::CCRect"
 */
boundingBox : function () {},

/**
 * @method draw
 */
draw : function () {},

/**
 * @method transformAncestors
 */
transformAncestors : function () {},

/**
 * @method setUserObject
 * @param {cocos2d::CCObject*}
 */
setUserObject : function () {},

/**
 * @method registerScriptHandler
 * @param {int}
 */
registerScriptHandler : function () {},

/**
 * @method convertTouchToNodeSpaceAR
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 * @param {cocos2d::CCTouch*}
 */
convertTouchToNodeSpaceAR : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method sortAllChildren
 */
sortAllChildren : function () {},

/**
 * @method convertToNodeSpace
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 * @param {cocos2d::CCPoint}
 */
convertToNodeSpace : function () {},

/**
 * @method getScale
 * @return A value converted from C/C++ "float"
 */
getScale : function () {},

/**
 * @method getCamera
 * @return A value converted from C/C++ "cocos2d::CCCamera*"
 */
getCamera : function () {},

/**
 * @method setTag
 * @param {int}
 */
setTag : function () {},

/**
 * @method stopAction
 * @param {cocos2d::CCAction*}
 */
stopAction : function () {},

/**
 * @method getActionManager
 * @return A value converted from C/C++ "cocos2d::CCActionManager*"
 */
getActionManager : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCNode*"
 */
create : function () {},

/**
 * @method CCNode
 * @constructor
 */
CCNode : function () {},

};

/**
 * @class CCNodeRGBA
 */
cc.NodeRGBA = {

/**
 * @method updateDisplayedColor
 * @param {cocos2d::ccColor3B}
 */
updateDisplayedColor : function () {},

/**
 * @method setColor
 * @param {cocos2d::ccColor3B}
 */
setColor : function () {},

/**
 * @method isCascadeOpacityEnabled
 * @return A value converted from C/C++ "bool"
 */
isCascadeOpacityEnabled : function () {},

/**
 * @method getColor
 * @return A value converted from C/C++ "cocos2d::ccColor3B"
 */
getColor : function () {},

/**
 * @method getDisplayedOpacity
 * @return A value converted from C/C++ "unsigned char"
 */
getDisplayedOpacity : function () {},

/**
 * @method setCascadeColorEnabled
 * @param {bool}
 */
setCascadeColorEnabled : function () {},

/**
 * @method setOpacity
 * @param {unsigned char}
 */
setOpacity : function () {},

/**
 * @method setOpacityModifyRGB
 * @param {bool}
 */
setOpacityModifyRGB : function () {},

/**
 * @method setCascadeOpacityEnabled
 * @param {bool}
 */
setCascadeOpacityEnabled : function () {},

/**
 * @method updateDisplayedOpacity
 * @param {unsigned char}
 */
updateDisplayedOpacity : function () {},

/**
 * @method init
 * @return A value converted from C/C++ "bool"
 */
init : function () {},

/**
 * @method getOpacity
 * @return A value converted from C/C++ "unsigned char"
 */
getOpacity : function () {},

/**
 * @method isOpacityModifyRGB
 * @return A value converted from C/C++ "bool"
 */
isOpacityModifyRGB : function () {},

/**
 * @method isCascadeColorEnabled
 * @return A value converted from C/C++ "bool"
 */
isCascadeColorEnabled : function () {},

/**
 * @method getDisplayedColor
 * @return A value converted from C/C++ "cocos2d::ccColor3B"
 */
getDisplayedColor : function () {},

/**
 * @method CCNodeRGBA
 * @constructor
 */
CCNodeRGBA : function () {},

};

/**
 * @class CCSpriteFrame
 */
cc.SpriteFrame = {

/**
 * @method setRotated
 * @param {bool}
 */
setRotated : function () {},

/**
 * @method setTexture
 * @param {cocos2d::CCTexture2D*}
 */
setTexture : function () {},

/**
 * @method getOffset
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 */
getOffset : function () {},

/**
 * @method setRectInPixels
 * @param {cocos2d::CCRect}
 */
setRectInPixels : function () {},

/**
 * @method getTexture
 * @return A value converted from C/C++ "cocos2d::CCTexture2D*"
 */
getTexture : function () {},

/**
 * @method getRect
 * @return A value converted from C/C++ "cocos2d::CCRect"
 */
getRect : function () {},

/**
 * @method setOffsetInPixels
 * @param {cocos2d::CCPoint}
 */
setOffsetInPixels : function () {},

/**
 * @method getRectInPixels
 * @return A value converted from C/C++ "cocos2d::CCRect"
 */
getRectInPixels : function () {},

/**
 * @method setOriginalSize
 * @param {cocos2d::CCSize}
 */
setOriginalSize : function () {},

/**
 * @method getOriginalSizeInPixels
 * @return A value converted from C/C++ "cocos2d::CCSize"
 */
getOriginalSizeInPixels : function () {},

/**
 * @method setOriginalSizeInPixels
 * @param {cocos2d::CCSize}
 */
setOriginalSizeInPixels : function () {},

/**
 * @method setOffset
 * @param {cocos2d::CCPoint}
 */
setOffset : function () {},

/**
 * @method isRotated
 * @return A value converted from C/C++ "bool"
 */
isRotated : function () {},

/**
 * @method setRect
 * @param {cocos2d::CCRect}
 */
setRect : function () {},

/**
 * @method getOffsetInPixels
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 */
getOffsetInPixels : function () {},

/**
 * @method getOriginalSize
 * @return A value converted from C/C++ "cocos2d::CCSize"
 */
getOriginalSize : function () {},

};

/**
 * @class CCAnimationFrame
 */
cc.AnimationFrame = {

/**
 * @method setSpriteFrame
 * @param {cocos2d::CCSpriteFrame*}
 */
setSpriteFrame : function () {},

/**
 * @method getUserInfo
 * @return A value converted from C/C++ "cocos2d::CCDictionary*"
 */
getUserInfo : function () {},

/**
 * @method setDelayUnits
 * @param {float}
 */
setDelayUnits : function () {},

/**
 * @method getSpriteFrame
 * @return A value converted from C/C++ "cocos2d::CCSpriteFrame*"
 */
getSpriteFrame : function () {},

/**
 * @method getDelayUnits
 * @return A value converted from C/C++ "float"
 */
getDelayUnits : function () {},

/**
 * @method setUserInfo
 * @param {cocos2d::CCDictionary*}
 */
setUserInfo : function () {},

/**
 * @method initWithSpriteFrame
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCSpriteFrame*}
 * @param {float}
 * @param {cocos2d::CCDictionary*}
 */
initWithSpriteFrame : function () {},

/**
 * @method CCAnimationFrame
 * @constructor
 */
CCAnimationFrame : function () {},

};

/**
 * @class CCAnimation
 */
cc.Animation = {

/**
 * @method getLoops
 * @return A value converted from C/C++ "unsigned int"
 */
getLoops : function () {},

/**
 * @method setFrames
 * @param {cocos2d::CCArray*}
 */
setFrames : function () {},

/**
 * @method getFrames
 * @return A value converted from C/C++ "cocos2d::CCArray*"
 */
getFrames : function () {},

/**
 * @method addSpriteFrame
 * @param {cocos2d::CCSpriteFrame*}
 */
addSpriteFrame : function () {},

/**
 * @method setRestoreOriginalFrame
 * @param {bool}
 */
setRestoreOriginalFrame : function () {},

/**
 * @method setDelayPerUnit
 * @param {float}
 */
setDelayPerUnit : function () {},

/**
 * @method initWithAnimationFrames
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCArray*}
 * @param {float}
 * @param {unsigned int}
 */
initWithAnimationFrames : function () {},

/**
 * @method init
 * @return A value converted from C/C++ "bool"
 */
init : function () {},

/**
 * @method initWithSpriteFrames
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCArray*}
 * @param {float}
 */
initWithSpriteFrames : function () {},

/**
 * @method setLoops
 * @param {unsigned int}
 */
setLoops : function () {},

/**
 * @method addSpriteFrameWithFileName
 * @param {const char*}
 */
addSpriteFrameWithFileName : function () {},

/**
 * @method getTotalDelayUnits
 * @return A value converted from C/C++ "float"
 */
getTotalDelayUnits : function () {},

/**
 * @method getDelayPerUnit
 * @return A value converted from C/C++ "float"
 */
getDelayPerUnit : function () {},

/**
 * @method getRestoreOriginalFrame
 * @return A value converted from C/C++ "bool"
 */
getRestoreOriginalFrame : function () {},

/**
 * @method getDuration
 * @return A value converted from C/C++ "float"
 */
getDuration : function () {},

/**
 * @method addSpriteFrameWithTexture
 * @param {cocos2d::CCTexture2D*}
 * @param {cocos2d::CCRect}
 */
addSpriteFrameWithTexture : function () {},

/**
 * @method CCAnimation
 * @constructor
 */
CCAnimation : function () {},

};

/**
 * @class CCActionInterval
 */
cc.ActionInterval = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 */
initWithDuration : function () {},

/**
 * @method setAmplitudeRate
 * @param {float}
 */
setAmplitudeRate : function () {},

/**
 * @method getAmplitudeRate
 * @return A value converted from C/C++ "float"
 */
getAmplitudeRate : function () {},

/**
 * @method step
 * @param {float}
 */
step : function () {},

/**
 * @method getElapsed
 * @return A value converted from C/C++ "float"
 */
getElapsed : function () {},

/**
 * @method isDone
 * @return A value converted from C/C++ "bool"
 */
isDone : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 * @param {float}
 */
create : function () {},

};

/**
 * @class CCSequence
 */
cc.Sequence = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method stop
 */
stop : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method initWithTwoActions
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCFiniteTimeAction*}
 * @param {cocos2d::CCFiniteTimeAction*}
 */
initWithTwoActions : function () {},

};

/**
 * @class CCRepeat
 */
cc.Repeat = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method setInnerAction
 * @param {cocos2d::CCFiniteTimeAction*}
 */
setInnerAction : function () {},

/**
 * @method stop
 */
stop : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method initWithAction
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCFiniteTimeAction*}
 * @param {unsigned int}
 */
initWithAction : function () {},

/**
 * @method getInnerAction
 * @return A value converted from C/C++ "cocos2d::CCFiniteTimeAction*"
 */
getInnerAction : function () {},

/**
 * @method isDone
 * @return A value converted from C/C++ "bool"
 */
isDone : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCRepeat*"
 * @param {cocos2d::CCFiniteTimeAction*}
 * @param {unsigned int}
 */
create : function () {},

};

/**
 * @class CCRepeatForever
 */
cc.RepeatForever = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method setInnerAction
 * @param {cocos2d::CCActionInterval*}
 */
setInnerAction : function () {},

/**
 * @method step
 * @param {float}
 */
step : function () {},

/**
 * @method initWithAction
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCActionInterval*}
 */
initWithAction : function () {},

/**
 * @method getInnerAction
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
getInnerAction : function () {},

/**
 * @method isDone
 * @return A value converted from C/C++ "bool"
 */
isDone : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCRepeatForever*"
 * @param {cocos2d::CCActionInterval*}
 */
create : function () {},

/**
 * @method CCRepeatForever
 * @constructor
 */
CCRepeatForever : function () {},

};

/**
 * @class CCSpawn
 */
cc.Spawn = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method stop
 */
stop : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method initWithTwoActions
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCFiniteTimeAction*}
 * @param {cocos2d::CCFiniteTimeAction*}
 */
initWithTwoActions : function () {},

};

/**
 * @class CCRotateTo
 */
cc.RotateTo = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

};

/**
 * @class CCRotateBy
 */
cc.RotateBy = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

};

/**
 * @class CCMoveBy
 */
cc.MoveBy = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {cocos2d::CCPoint}
 */
initWithDuration : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCMoveBy*"
 * @param {float}
 * @param {cocos2d::CCPoint}
 */
create : function () {},

};

/**
 * @class CCMoveTo
 */
cc.MoveTo = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {cocos2d::CCPoint}
 */
initWithDuration : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCMoveTo*"
 * @param {float}
 * @param {cocos2d::CCPoint}
 */
create : function () {},

};

/**
 * @class CCSkewTo
 */
cc.SkewTo = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {float}
 * @param {float}
 */
initWithDuration : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCSkewTo*"
 * @param {float}
 * @param {float}
 * @param {float}
 */
create : function () {},

/**
 * @method CCSkewTo
 * @constructor
 */
CCSkewTo : function () {},

};

/**
 * @class CCSkewBy
 */
cc.SkewBy = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {float}
 * @param {float}
 */
initWithDuration : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCSkewBy*"
 * @param {float}
 * @param {float}
 * @param {float}
 */
create : function () {},

};

/**
 * @class CCJumpBy
 */
cc.JumpBy = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {cocos2d::CCPoint}
 * @param {float}
 * @param {unsigned int}
 */
initWithDuration : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCJumpBy*"
 * @param {float}
 * @param {cocos2d::CCPoint}
 * @param {float}
 * @param {unsigned int}
 */
create : function () {},

};

/**
 * @class CCJumpTo
 */
cc.JumpTo = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCJumpTo*"
 * @param {float}
 * @param {cocos2d::CCPoint}
 * @param {float}
 * @param {int}
 */
create : function () {},

};

/**
 * @class CCBezierBy
 */
cc.BezierBy = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {cocos2d::ccBezierConfig}
 */
initWithDuration : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

};

/**
 * @class CCBezierTo
 */
cc.BezierTo = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {cocos2d::ccBezierConfig}
 */
initWithDuration : function () {},

};

/**
 * @class CCScaleTo
 */
cc.ScaleTo = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

};

/**
 * @class CCScaleBy
 */
cc.ScaleBy = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

};

/**
 * @class CCBlink
 */
cc.Blink = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {unsigned int}
 */
initWithDuration : function () {},

/**
 * @method stop
 */
stop : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCBlink*"
 * @param {float}
 * @param {unsigned int}
 */
create : function () {},

};

/**
 * @class CCFadeIn
 */
cc.FadeIn = {

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCFadeIn*"
 * @param {float}
 */
create : function () {},

};

/**
 * @class CCFadeOut
 */
cc.FadeOut = {

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCFadeOut*"
 * @param {float}
 */
create : function () {},

};

/**
 * @class CCFadeTo
 */
cc.FadeTo = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {unsigned char}
 */
initWithDuration : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCFadeTo*"
 * @param {float}
 * @param {unsigned char}
 */
create : function () {},

};

/**
 * @class CCTintTo
 */
cc.TintTo = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {unsigned char}
 * @param {unsigned char}
 * @param {unsigned char}
 */
initWithDuration : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTintTo*"
 * @param {float}
 * @param {unsigned char}
 * @param {unsigned char}
 * @param {unsigned char}
 */
create : function () {},

};

/**
 * @class CCTintBy
 */
cc.TintBy = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {short}
 * @param {short}
 * @param {short}
 */
initWithDuration : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTintBy*"
 * @param {float}
 * @param {short}
 * @param {short}
 * @param {short}
 */
create : function () {},

};

/**
 * @class CCDelayTime
 */
cc.DelayTime = {

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCDelayTime*"
 * @param {float}
 */
create : function () {},

};

/**
 * @class CCAnimate
 */
cc.Animate = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method getAnimation
 * @return A value converted from C/C++ "cocos2d::CCAnimation*"
 */
getAnimation : function () {},

/**
 * @method stop
 */
stop : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method initWithAnimation
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCAnimation*}
 */
initWithAnimation : function () {},

/**
 * @method setAnimation
 * @param {cocos2d::CCAnimation*}
 */
setAnimation : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCAnimate*"
 * @param {cocos2d::CCAnimation*}
 */
create : function () {},

/**
 * @method CCAnimate
 * @constructor
 */
CCAnimate : function () {},

};

/**
 * @class CCTargetedAction
 */
cc.TargetedAction = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method setForcedTarget
 * @param {cocos2d::CCNode*}
 */
setForcedTarget : function () {},

/**
 * @method initWithTarget
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCNode*}
 * @param {cocos2d::CCFiniteTimeAction*}
 */
initWithTarget : function () {},

/**
 * @method stop
 */
stop : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method getForcedTarget
 * @return A value converted from C/C++ "cocos2d::CCNode*"
 */
getForcedTarget : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTargetedAction*"
 * @param {cocos2d::CCNode*}
 * @param {cocos2d::CCFiniteTimeAction*}
 */
create : function () {},

/**
 * @method CCTargetedAction
 * @constructor
 */
CCTargetedAction : function () {},

};

/**
 * @class CCActionCamera
 */
cc.ActionCamera = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method CCActionCamera
 * @constructor
 */
CCActionCamera : function () {},

};

/**
 * @class CCOrbitCamera
 */
cc.OrbitCamera = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {float}
 * @param {float}
 * @param {float}
 * @param {float}
 * @param {float}
 * @param {float}
 */
initWithDuration : function () {},

/**
 * @method sphericalRadius
 * @param {float*}
 * @param {float*}
 * @param {float*}
 */
sphericalRadius : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCOrbitCamera*"
 * @param {float}
 * @param {float}
 * @param {float}
 * @param {float}
 * @param {float}
 * @param {float}
 * @param {float}
 */
create : function () {},

/**
 * @method CCOrbitCamera
 * @constructor
 */
CCOrbitCamera : function () {},

};

/**
 * @class CCActionManager
 */
cc.ActionManager = {

/**
 * @method getActionByTag
 * @return A value converted from C/C++ "cocos2d::CCAction*"
 * @param {unsigned int}
 * @param {cocos2d::CCObject*}
 */
getActionByTag : function () {},

/**
 * @method removeActionByTag
 * @param {unsigned int}
 * @param {cocos2d::CCObject*}
 */
removeActionByTag : function () {},

/**
 * @method removeAllActions
 */
removeAllActions : function () {},

/**
 * @method addAction
 * @param {cocos2d::CCAction*}
 * @param {cocos2d::CCNode*}
 * @param {bool}
 */
addAction : function () {},

/**
 * @method resumeTarget
 * @param {cocos2d::CCObject*}
 */
resumeTarget : function () {},

/**
 * @method pauseTarget
 * @param {cocos2d::CCObject*}
 */
pauseTarget : function () {},

/**
 * @method removeAllActionsFromTarget
 * @param {cocos2d::CCObject*}
 */
removeAllActionsFromTarget : function () {},

/**
 * @method resumeTargets
 * @param {cocos2d::CCSet*}
 */
resumeTargets : function () {},

/**
 * @method removeAction
 * @param {cocos2d::CCAction*}
 */
removeAction : function () {},

/**
 * @method numberOfRunningActionsInTarget
 * @return A value converted from C/C++ "unsigned int"
 * @param {cocos2d::CCObject*}
 */
numberOfRunningActionsInTarget : function () {},

/**
 * @method pauseAllRunningActions
 * @return A value converted from C/C++ "cocos2d::CCSet*"
 */
pauseAllRunningActions : function () {},

/**
 * @method CCActionManager
 * @constructor
 */
CCActionManager : function () {},

};

/**
 * @class CCActionEase
 */
cc.ActionEase = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method stop
 */
stop : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method initWithAction
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCActionInterval*}
 */
initWithAction : function () {},

/**
 * @method getInnerAction
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
getInnerAction : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCActionEase*"
 * @param {cocos2d::CCActionInterval*}
 */
create : function () {},

};

/**
 * @class CCEaseRateAction
 */
cc.EaseRateAction = {

/**
 * @method setRate
 * @param {float}
 */
setRate : function () {},

/**
 * @method initWithAction
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCActionInterval*}
 * @param {float}
 */
initWithAction : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method getRate
 * @return A value converted from C/C++ "float"
 */
getRate : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCEaseRateAction*"
 * @param {cocos2d::CCActionInterval*}
 * @param {float}
 */
create : function () {},

};

/**
 * @class CCEaseIn
 */
cc.EaseIn = {

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCEaseIn*"
 * @param {cocos2d::CCActionInterval*}
 * @param {float}
 */
create : function () {},

};

/**
 * @class CCEaseOut
 */
cc.EaseOut = {

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCEaseOut*"
 * @param {cocos2d::CCActionInterval*}
 * @param {float}
 */
create : function () {},

};

/**
 * @class CCEaseInOut
 */
cc.EaseInOut = {

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCEaseInOut*"
 * @param {cocos2d::CCActionInterval*}
 * @param {float}
 */
create : function () {},

};

/**
 * @class CCEaseExponentialIn
 */
cc.EaseExponentialIn = {

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCEaseExponentialIn*"
 * @param {cocos2d::CCActionInterval*}
 */
create : function () {},

};

/**
 * @class CCEaseExponentialOut
 */
cc.EaseExponentialOut = {

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCEaseExponentialOut*"
 * @param {cocos2d::CCActionInterval*}
 */
create : function () {},

};

/**
 * @class CCEaseExponentialInOut
 */
cc.EaseExponentialInOut = {

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCEaseExponentialInOut*"
 * @param {cocos2d::CCActionInterval*}
 */
create : function () {},

};

/**
 * @class CCEaseSineIn
 */
cc.EaseSineIn = {

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCEaseSineIn*"
 * @param {cocos2d::CCActionInterval*}
 */
create : function () {},

};

/**
 * @class CCEaseSineOut
 */
cc.EaseSineOut = {

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCEaseSineOut*"
 * @param {cocos2d::CCActionInterval*}
 */
create : function () {},

};

/**
 * @class CCEaseSineInOut
 */
cc.EaseSineInOut = {

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCEaseSineInOut*"
 * @param {cocos2d::CCActionInterval*}
 */
create : function () {},

};

/**
 * @class CCEaseElastic
 */
cc.EaseElastic = {

/**
 * @method setPeriod
 * @param {float}
 */
setPeriod : function () {},

/**
 * @method initWithAction
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCActionInterval*}
 * @param {float}
 */
initWithAction : function () {},

/**
 * @method getPeriod
 * @return A value converted from C/C++ "float"
 */
getPeriod : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

};

/**
 * @class CCEaseElasticIn
 */
cc.EaseElasticIn = {

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

};

/**
 * @class CCEaseElasticOut
 */
cc.EaseElasticOut = {

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

};

/**
 * @class CCEaseElasticInOut
 */
cc.EaseElasticInOut = {

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

};

/**
 * @class CCEaseBounce
 */
cc.EaseBounce = {

/**
 * @method bounceTime
 * @return A value converted from C/C++ "float"
 * @param {float}
 */
bounceTime : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCEaseBounce*"
 * @param {cocos2d::CCActionInterval*}
 */
create : function () {},

};

/**
 * @class CCEaseBounceIn
 */
cc.EaseBounceIn = {

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCEaseBounceIn*"
 * @param {cocos2d::CCActionInterval*}
 */
create : function () {},

};

/**
 * @class CCEaseBounceOut
 */
cc.EaseBounceOut = {

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCEaseBounceOut*"
 * @param {cocos2d::CCActionInterval*}
 */
create : function () {},

};

/**
 * @class CCEaseBounceInOut
 */
cc.EaseBounceInOut = {

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCEaseBounceInOut*"
 * @param {cocos2d::CCActionInterval*}
 */
create : function () {},

};

/**
 * @class CCEaseBackIn
 */
cc.EaseBackIn = {

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCEaseBackIn*"
 * @param {cocos2d::CCActionInterval*}
 */
create : function () {},

};

/**
 * @class CCEaseBackOut
 */
cc.EaseBackOut = {

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCEaseBackOut*"
 * @param {cocos2d::CCActionInterval*}
 */
create : function () {},

};

/**
 * @class CCEaseBackInOut
 */
cc.EaseBackInOut = {

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCEaseBackInOut*"
 * @param {cocos2d::CCActionInterval*}
 */
create : function () {},

};

/**
 * @class CCActionInstant
 */
cc.ActionInstant = {

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCFiniteTimeAction*"
 */
reverse : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method step
 * @param {float}
 */
step : function () {},

/**
 * @method isDone
 * @return A value converted from C/C++ "bool"
 */
isDone : function () {},

/**
 * @method CCActionInstant
 * @constructor
 */
CCActionInstant : function () {},

};

/**
 * @class CCShow
 */
cc.Show = {

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCFiniteTimeAction*"
 */
reverse : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCShow*"
 */
create : function () {},

/**
 * @method CCShow
 * @constructor
 */
CCShow : function () {},

};

/**
 * @class CCHide
 */
cc.Hide = {

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCFiniteTimeAction*"
 */
reverse : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCHide*"
 */
create : function () {},

/**
 * @method CCHide
 * @constructor
 */
CCHide : function () {},

};

/**
 * @class CCToggleVisibility
 */
cc.ToggleVisibility = {

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCToggleVisibility*"
 */
create : function () {},

/**
 * @method CCToggleVisibility
 * @constructor
 */
CCToggleVisibility : function () {},

};

/**
 * @class CCFlipX
 */
cc.FlipX = {

/**
 * @method initWithFlipX
 * @return A value converted from C/C++ "bool"
 * @param {bool}
 */
initWithFlipX : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCFiniteTimeAction*"
 */
reverse : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCFlipX*"
 * @param {bool}
 */
create : function () {},

/**
 * @method CCFlipX
 * @constructor
 */
CCFlipX : function () {},

};

/**
 * @class CCFlipY
 */
cc.FlipY = {

/**
 * @method initWithFlipY
 * @return A value converted from C/C++ "bool"
 * @param {bool}
 */
initWithFlipY : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCFiniteTimeAction*"
 */
reverse : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCFlipY*"
 * @param {bool}
 */
create : function () {},

/**
 * @method CCFlipY
 * @constructor
 */
CCFlipY : function () {},

};

/**
 * @class CCPlace
 */
cc.Place = {

/**
 * @method initWithPosition
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCPoint}
 */
initWithPosition : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCPlace*"
 * @param {cocos2d::CCPoint}
 */
create : function () {},

/**
 * @method CCPlace
 * @constructor
 */
CCPlace : function () {},

};

/**
 * @class CCCallFunc
 */
cc.CallFunc = {

/**
 * @method execute
 */
execute : function () {},

/**
 * @method initWithTarget
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCObject*}
 */
initWithTarget : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method getTargetCallback
 * @return A value converted from C/C++ "cocos2d::CCObject*"
 */
getTargetCallback : function () {},

/**
 * @method getScriptHandler
 * @return A value converted from C/C++ "int"
 */
getScriptHandler : function () {},

/**
 * @method setTargetCallback
 * @param {cocos2d::CCObject*}
 */
setTargetCallback : function () {},

/**
 * @method CCCallFunc
 * @constructor
 */
CCCallFunc : function () {},

};

/**
 * @class CCGridAction
 */
cc.GridAction = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method getGrid
 * @return A value converted from C/C++ "cocos2d::CCGridBase*"
 */
getGrid : function () {},

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {cocos2d::CCSize}
 */
initWithDuration : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCGridAction*"
 * @param {float}
 * @param {cocos2d::CCSize}
 */
create : function () {},

};

/**
 * @class CCGrid3DAction
 */
cc.Grid3DAction = {

/**
 * @method setVertex
 * @param {cocos2d::CCPoint}
 * @param {cocos2d::ccVertex3F}
 */
setVertex : function () {},

/**
 * @method getGrid
 * @return A value converted from C/C++ "cocos2d::CCGridBase*"
 */
getGrid : function () {},

/**
 * @method vertex
 * @return A value converted from C/C++ "ccVertex3F"
 * @param {cocos2d::CCPoint}
 */
vertex : function () {},

/**
 * @method originalVertex
 * @return A value converted from C/C++ "ccVertex3F"
 * @param {cocos2d::CCPoint}
 */
originalVertex : function () {},

};

/**
 * @class CCTiledGrid3DAction
 */
cc.TiledGrid3DAction = {

/**
 * @method tile
 * @return A value converted from C/C++ "ccQuad3"
 * @param {cocos2d::CCPoint}
 */
tile : function () {},

/**
 * @method setTile
 * @param {cocos2d::CCPoint}
 * @param {cocos2d::ccQuad3}
 */
setTile : function () {},

/**
 * @method originalTile
 * @return A value converted from C/C++ "ccQuad3"
 * @param {cocos2d::CCPoint}
 */
originalTile : function () {},

/**
 * @method getGrid
 * @return A value converted from C/C++ "cocos2d::CCGridBase*"
 */
getGrid : function () {},

};

/**
 * @class CCWaves3D
 */
cc.Waves3D = {

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {cocos2d::CCSize}
 * @param {unsigned int}
 * @param {float}
 */
initWithDuration : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method getAmplitudeRate
 * @return A value converted from C/C++ "float"
 */
getAmplitudeRate : function () {},

/**
 * @method setAmplitude
 * @param {float}
 */
setAmplitude : function () {},

/**
 * @method getAmplitude
 * @return A value converted from C/C++ "float"
 */
getAmplitude : function () {},

/**
 * @method setAmplitudeRate
 * @param {float}
 */
setAmplitudeRate : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCWaves3D*"
 * @param {float}
 * @param {cocos2d::CCSize}
 * @param {unsigned int}
 * @param {float}
 */
create : function () {},

};

/**
 * @class CCFlipX3D
 */
cc.FlipX3D = {

/**
 * @method initWithSize
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCSize}
 * @param {float}
 */
initWithSize : function () {},

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 */
initWithDuration : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCFlipX3D*"
 * @param {float}
 */
create : function () {},

};

/**
 * @class CCFlipY3D
 */
cc.FlipY3D = {

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCFlipY3D*"
 * @param {float}
 */
create : function () {},

};

/**
 * @class CCLens3D
 */
cc.Lens3D = {

/**
 * @method setConcave
 * @param {bool}
 */
setConcave : function () {},

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {cocos2d::CCSize}
 * @param {cocos2d::CCPoint}
 * @param {float}
 */
initWithDuration : function () {},

/**
 * @method setLensEffect
 * @param {float}
 */
setLensEffect : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method getLensEffect
 * @return A value converted from C/C++ "float"
 */
getLensEffect : function () {},

/**
 * @method setPosition
 * @param {cocos2d::CCPoint}
 */
setPosition : function () {},

/**
 * @method getPosition
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 */
getPosition : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCLens3D*"
 * @param {float}
 * @param {cocos2d::CCSize}
 * @param {cocos2d::CCPoint}
 * @param {float}
 */
create : function () {},

};

/**
 * @class CCRipple3D
 */
cc.Ripple3D = {

/**
 * @method setAmplitudeRate
 * @param {float}
 */
setAmplitudeRate : function () {},

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {cocos2d::CCSize}
 * @param {cocos2d::CCPoint}
 * @param {float}
 * @param {unsigned int}
 * @param {float}
 */
initWithDuration : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method getAmplitudeRate
 * @return A value converted from C/C++ "float"
 */
getAmplitudeRate : function () {},

/**
 * @method setAmplitude
 * @param {float}
 */
setAmplitude : function () {},

/**
 * @method getAmplitude
 * @return A value converted from C/C++ "float"
 */
getAmplitude : function () {},

/**
 * @method setPosition
 * @param {cocos2d::CCPoint}
 */
setPosition : function () {},

/**
 * @method getPosition
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 */
getPosition : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCRipple3D*"
 * @param {float}
 * @param {cocos2d::CCSize}
 * @param {cocos2d::CCPoint}
 * @param {float}
 * @param {unsigned int}
 * @param {float}
 */
create : function () {},

};

/**
 * @class CCShaky3D
 */
cc.Shaky3D = {

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {cocos2d::CCSize}
 * @param {int}
 * @param {bool}
 */
initWithDuration : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCShaky3D*"
 * @param {float}
 * @param {cocos2d::CCSize}
 * @param {int}
 * @param {bool}
 */
create : function () {},

};

/**
 * @class CCLiquid
 */
cc.Liquid = {

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {cocos2d::CCSize}
 * @param {unsigned int}
 * @param {float}
 */
initWithDuration : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method getAmplitudeRate
 * @return A value converted from C/C++ "float"
 */
getAmplitudeRate : function () {},

/**
 * @method setAmplitude
 * @param {float}
 */
setAmplitude : function () {},

/**
 * @method getAmplitude
 * @return A value converted from C/C++ "float"
 */
getAmplitude : function () {},

/**
 * @method setAmplitudeRate
 * @param {float}
 */
setAmplitudeRate : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCLiquid*"
 * @param {float}
 * @param {cocos2d::CCSize}
 * @param {unsigned int}
 * @param {float}
 */
create : function () {},

};

/**
 * @class CCWaves
 */
cc.Waves = {

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {cocos2d::CCSize}
 * @param {unsigned int}
 * @param {float}
 * @param {bool}
 * @param {bool}
 */
initWithDuration : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method getAmplitudeRate
 * @return A value converted from C/C++ "float"
 */
getAmplitudeRate : function () {},

/**
 * @method setAmplitude
 * @param {float}
 */
setAmplitude : function () {},

/**
 * @method getAmplitude
 * @return A value converted from C/C++ "float"
 */
getAmplitude : function () {},

/**
 * @method setAmplitudeRate
 * @param {float}
 */
setAmplitudeRate : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCWaves*"
 * @param {float}
 * @param {cocos2d::CCSize}
 * @param {unsigned int}
 * @param {float}
 * @param {bool}
 * @param {bool}
 */
create : function () {},

};

/**
 * @class CCTwirl
 */
cc.Twirl = {

/**
 * @method setAmplitudeRate
 * @param {float}
 */
setAmplitudeRate : function () {},

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {cocos2d::CCSize}
 * @param {cocos2d::CCPoint}
 * @param {unsigned int}
 * @param {float}
 */
initWithDuration : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method getAmplitudeRate
 * @return A value converted from C/C++ "float"
 */
getAmplitudeRate : function () {},

/**
 * @method setAmplitude
 * @param {float}
 */
setAmplitude : function () {},

/**
 * @method getAmplitude
 * @return A value converted from C/C++ "float"
 */
getAmplitude : function () {},

/**
 * @method setPosition
 * @param {cocos2d::CCPoint}
 */
setPosition : function () {},

/**
 * @method getPosition
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 */
getPosition : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTwirl*"
 * @param {float}
 * @param {cocos2d::CCSize}
 * @param {cocos2d::CCPoint}
 * @param {unsigned int}
 * @param {float}
 */
create : function () {},

};

/**
 * @class CCPageTurn3D
 */
cc.PageTurn3D = {

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCPageTurn3D*"
 * @param {float}
 * @param {cocos2d::CCSize}
 */
create : function () {},

};

/**
 * @class CCProgressTo
 */
cc.ProgressTo = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {float}
 */
initWithDuration : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCProgressTo*"
 * @param {float}
 * @param {float}
 */
create : function () {},

};

/**
 * @class CCProgressFromTo
 */
cc.ProgressFromTo = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {float}
 * @param {float}
 */
initWithDuration : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCProgressFromTo*"
 * @param {float}
 * @param {float}
 * @param {float}
 */
create : function () {},

};

/**
 * @class CCShakyTiles3D
 */
cc.ShakyTiles3D = {

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {cocos2d::CCSize}
 * @param {int}
 * @param {bool}
 */
initWithDuration : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCShakyTiles3D*"
 * @param {float}
 * @param {cocos2d::CCSize}
 * @param {int}
 * @param {bool}
 */
create : function () {},

};

/**
 * @class CCShatteredTiles3D
 */
cc.ShatteredTiles3D = {

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {cocos2d::CCSize}
 * @param {int}
 * @param {bool}
 */
initWithDuration : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCShatteredTiles3D*"
 * @param {float}
 * @param {cocos2d::CCSize}
 * @param {int}
 * @param {bool}
 */
create : function () {},

};

/**
 * @class CCShuffleTiles
 */
cc.ShuffleTiles = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method placeTile
 * @param {cocos2d::CCPoint}
 * @param {cocos2d::Tile*}
 */
placeTile : function () {},

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {cocos2d::CCSize}
 * @param {unsigned int}
 */
initWithDuration : function () {},

/**
 * @method getDelta
 * @return A value converted from C/C++ "cocos2d::CCSize"
 * @param {cocos2d::CCSize}
 */
getDelta : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method shuffle
 * @param {unsigned int*}
 * @param {unsigned int}
 */
shuffle : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCShuffleTiles*"
 * @param {float}
 * @param {cocos2d::CCSize}
 * @param {unsigned int}
 */
create : function () {},

};

/**
 * @class CCFadeOutTRTiles
 */
cc.FadeOutTRTiles = {

/**
 * @method turnOnTile
 * @param {cocos2d::CCPoint}
 */
turnOnTile : function () {},

/**
 * @method turnOffTile
 * @param {cocos2d::CCPoint}
 */
turnOffTile : function () {},

/**
 * @method transformTile
 * @param {cocos2d::CCPoint}
 * @param {float}
 */
transformTile : function () {},

/**
 * @method testFunc
 * @return A value converted from C/C++ "float"
 * @param {cocos2d::CCSize}
 * @param {float}
 */
testFunc : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCFadeOutTRTiles*"
 * @param {float}
 * @param {cocos2d::CCSize}
 */
create : function () {},

};

/**
 * @class CCFadeOutBLTiles
 */
cc.FadeOutBLTiles = {

/**
 * @method testFunc
 * @return A value converted from C/C++ "float"
 * @param {cocos2d::CCSize}
 * @param {float}
 */
testFunc : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCFadeOutBLTiles*"
 * @param {float}
 * @param {cocos2d::CCSize}
 */
create : function () {},

};

/**
 * @class CCFadeOutUpTiles
 */
cc.FadeOutUpTiles = {

/**
 * @method transformTile
 * @param {cocos2d::CCPoint}
 * @param {float}
 */
transformTile : function () {},

/**
 * @method testFunc
 * @return A value converted from C/C++ "float"
 * @param {cocos2d::CCSize}
 * @param {float}
 */
testFunc : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCFadeOutUpTiles*"
 * @param {float}
 * @param {cocos2d::CCSize}
 */
create : function () {},

};

/**
 * @class CCFadeOutDownTiles
 */
cc.FadeOutDownTiles = {

/**
 * @method testFunc
 * @return A value converted from C/C++ "float"
 * @param {cocos2d::CCSize}
 * @param {float}
 */
testFunc : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCFadeOutDownTiles*"
 * @param {float}
 * @param {cocos2d::CCSize}
 */
create : function () {},

};

/**
 * @class CCTurnOffTiles
 */
cc.TurnOffTiles = {

/**
 * @method turnOnTile
 * @param {cocos2d::CCPoint}
 */
turnOnTile : function () {},

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method turnOffTile
 * @param {cocos2d::CCPoint}
 */
turnOffTile : function () {},

/**
 * @method shuffle
 * @param {unsigned int*}
 * @param {unsigned int}
 */
shuffle : function () {},

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {cocos2d::CCSize}
 * @param {unsigned int}
 */
initWithDuration : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

};

/**
 * @class CCWavesTiles3D
 */
cc.WavesTiles3D = {

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {cocos2d::CCSize}
 * @param {unsigned int}
 * @param {float}
 */
initWithDuration : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method getAmplitudeRate
 * @return A value converted from C/C++ "float"
 */
getAmplitudeRate : function () {},

/**
 * @method setAmplitude
 * @param {float}
 */
setAmplitude : function () {},

/**
 * @method getAmplitude
 * @return A value converted from C/C++ "float"
 */
getAmplitude : function () {},

/**
 * @method setAmplitudeRate
 * @param {float}
 */
setAmplitudeRate : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCWavesTiles3D*"
 * @param {float}
 * @param {cocos2d::CCSize}
 * @param {unsigned int}
 * @param {float}
 */
create : function () {},

};

/**
 * @class CCJumpTiles3D
 */
cc.JumpTiles3D = {

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {cocos2d::CCSize}
 * @param {unsigned int}
 * @param {float}
 */
initWithDuration : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method getAmplitudeRate
 * @return A value converted from C/C++ "float"
 */
getAmplitudeRate : function () {},

/**
 * @method setAmplitude
 * @param {float}
 */
setAmplitude : function () {},

/**
 * @method getAmplitude
 * @return A value converted from C/C++ "float"
 */
getAmplitude : function () {},

/**
 * @method setAmplitudeRate
 * @param {float}
 */
setAmplitudeRate : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCJumpTiles3D*"
 * @param {float}
 * @param {cocos2d::CCSize}
 * @param {unsigned int}
 * @param {float}
 */
create : function () {},

};

/**
 * @class CCSplitRows
 */
cc.SplitRows = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {unsigned int}
 */
initWithDuration : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCSplitRows*"
 * @param {float}
 * @param {unsigned int}
 */
create : function () {},

};

/**
 * @class CCSplitCols
 */
cc.SplitCols = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {unsigned int}
 */
initWithDuration : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCSplitCols*"
 * @param {float}
 * @param {unsigned int}
 */
create : function () {},

};

/**
 * @class CCActionTween
 */
cc.ActionTween = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {const char*}
 * @param {float}
 * @param {float}
 */
initWithDuration : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCActionTween*"
 * @param {float}
 * @param {const char*}
 * @param {float}
 * @param {float}
 */
create : function () {},

};

/**
 * @class CCCardinalSplineTo
 */
cc.CardinalSplineTo = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {cocos2d::CCPointArray*}
 * @param {float}
 */
initWithDuration : function () {},

/**
 * @method getPoints
 * @return A value converted from C/C++ "cocos2d::CCPointArray*"
 */
getPoints : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method updatePosition
 * @param {cocos2d::CCPoint}
 */
updatePosition : function () {},

/**
 * @method CCCardinalSplineTo
 * @constructor
 */
CCCardinalSplineTo : function () {},

};

/**
 * @class CCCardinalSplineBy
 */
cc.CardinalSplineBy = {

/**
 * @method startWithTarget
 * @param {cocos2d::CCNode*}
 */
startWithTarget : function () {},

/**
 * @method updatePosition
 * @param {cocos2d::CCPoint}
 */
updatePosition : function () {},

/**
 * @method reverse
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
reverse : function () {},

/**
 * @method CCCardinalSplineBy
 * @constructor
 */
CCCardinalSplineBy : function () {},

};

/**
 * @class CCCatmullRomTo
 */
cc.CatmullRomTo = {

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {cocos2d::CCPointArray*}
 */
initWithDuration : function () {},

};

/**
 * @class CCCatmullRomBy
 */
cc.CatmullRomBy = {

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {cocos2d::CCPointArray*}
 */
initWithDuration : function () {},

};

/**
 * @class CCAtlasNode
 */
cc.AtlasNode = {

/**
 * @method setTexture
 * @param {cocos2d::CCTexture2D*}
 */
setTexture : function () {},

/**
 * @method draw
 */
draw : function () {},

/**
 * @method initWithTileFile
 * @return A value converted from C/C++ "bool"
 * @param {const char*}
 * @param {unsigned int}
 * @param {unsigned int}
 * @param {unsigned int}
 */
initWithTileFile : function () {},

/**
 * @method setColor
 * @param {cocos2d::ccColor3B}
 */
setColor : function () {},

/**
 * @method setOpacity
 * @param {unsigned char}
 */
setOpacity : function () {},

/**
 * @method setTextureAtlas
 * @param {cocos2d::CCTextureAtlas*}
 */
setTextureAtlas : function () {},

/**
 * @method getTexture
 * @return A value converted from C/C++ "cocos2d::CCTexture2D*"
 */
getTexture : function () {},

/**
 * @method getTextureAtlas
 * @return A value converted from C/C++ "cocos2d::CCTextureAtlas*"
 */
getTextureAtlas : function () {},

/**
 * @method setOpacityModifyRGB
 * @param {bool}
 */
setOpacityModifyRGB : function () {},

/**
 * @method getQuadsToDraw
 * @return A value converted from C/C++ "unsigned int"
 */
getQuadsToDraw : function () {},

/**
 * @method updateAtlasValues
 */
updateAtlasValues : function () {},

/**
 * @method getColor
 * @return A value converted from C/C++ "cocos2d::ccColor3B"
 */
getColor : function () {},

/**
 * @method initWithTexture
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCTexture2D*}
 * @param {unsigned int}
 * @param {unsigned int}
 * @param {unsigned int}
 */
initWithTexture : function () {},

/**
 * @method isOpacityModifyRGB
 * @return A value converted from C/C++ "bool"
 */
isOpacityModifyRGB : function () {},

/**
 * @method setQuadsToDraw
 * @param {unsigned int}
 */
setQuadsToDraw : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCAtlasNode*"
 * @param {const char*}
 * @param {unsigned int}
 * @param {unsigned int}
 * @param {unsigned int}
 */
create : function () {},

/**
 * @method CCAtlasNode
 * @constructor
 */
CCAtlasNode : function () {},

};

/**
 * @class CCDrawNode
 */
cc.DrawNode = {

/**
 * @method draw
 */
draw : function () {},

/**
 * @method clear
 */
clear : function () {},

/**
 * @method init
 * @return A value converted from C/C++ "bool"
 */
init : function () {},

/**
 * @method drawDot
 * @param {cocos2d::CCPoint}
 * @param {float}
 * @param {cocos2d::ccColor4F}
 */
drawDot : function () {},

/**
 * @method drawSegment
 * @param {cocos2d::CCPoint}
 * @param {cocos2d::CCPoint}
 * @param {float}
 * @param {cocos2d::ccColor4F}
 */
drawSegment : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCDrawNode*"
 */
create : function () {},

/**
 * @method CCDrawNode
 * @constructor
 */
CCDrawNode : function () {},

};

/**
 * @class CCCamera
 */
cc.Camera = {

/**
 * @method locate
 */
locate : function () {},

/**
 * @method restore
 */
restore : function () {},

/**
 * @method setEyeXYZ
 * @param {float}
 * @param {float}
 * @param {float}
 */
setEyeXYZ : function () {},

/**
 * @method setCenterXYZ
 * @param {float}
 * @param {float}
 * @param {float}
 */
setCenterXYZ : function () {},

/**
 * @method getCenterXYZ
 * @param {float*}
 * @param {float*}
 * @param {float*}
 */
getCenterXYZ : function () {},

/**
 * @method isDirty
 * @return A value converted from C/C++ "bool"
 */
isDirty : function () {},

/**
 * @method init
 */
init : function () {},

/**
 * @method setDirty
 * @param {bool}
 */
setDirty : function () {},

/**
 * @method setUpXYZ
 * @param {float}
 * @param {float}
 * @param {float}
 */
setUpXYZ : function () {},

/**
 * @method getUpXYZ
 * @param {float*}
 * @param {float*}
 * @param {float*}
 */
getUpXYZ : function () {},

/**
 * @method getEyeXYZ
 * @param {float*}
 * @param {float*}
 * @param {float*}
 */
getEyeXYZ : function () {},

/**
 * @method getZEye
 * @return A value converted from C/C++ "float"
 */
getZEye : function () {},

/**
 * @method CCCamera
 * @constructor
 */
CCCamera : function () {},

};

/**
 * @class CCSprite
 */
cc.Sprite = {

/**
 * @method draw
 */
draw : function () {},

/**
 * @method setTexture
 * @param {cocos2d::CCTexture2D*}
 */
setTexture : function () {},

/**
 * @method isFlipX
 * @return A value converted from C/C++ "bool"
 */
isFlipX : function () {},

/**
 * @method getTexture
 * @return A value converted from C/C++ "cocos2d::CCTexture2D*"
 */
getTexture : function () {},

/**
 * @method setScaleY
 * @param {float}
 */
setScaleY : function () {},

/**
 * @method setScale
 * @param {float}
 */
setScale : function () {},

/**
 * @method setOpacity
 * @param {unsigned char}
 */
setOpacity : function () {},

/**
 * @method setDisplayFrameWithAnimationName
 * @param {const char*}
 * @param {int}
 */
setDisplayFrameWithAnimationName : function () {},

/**
 * @method setRotationY
 * @param {float}
 */
setRotationY : function () {},

/**
 * @method setAnchorPoint
 * @param {cocos2d::CCPoint}
 */
setAnchorPoint : function () {},

/**
 * @method setOpacityModifyRGB
 * @param {bool}
 */
setOpacityModifyRGB : function () {},

/**
 * @method getBatchNode
 * @return A value converted from C/C++ "cocos2d::CCSpriteBatchNode*"
 */
getBatchNode : function () {},

/**
 * @method isTextureRectRotated
 * @return A value converted from C/C++ "bool"
 */
isTextureRectRotated : function () {},

/**
 * @method isOpacityModifyRGB
 * @return A value converted from C/C++ "bool"
 */
isOpacityModifyRGB : function () {},

/**
 * @method setVertexZ
 * @param {float}
 */
setVertexZ : function () {},

/**
 * @method getTextureRect
 * @return A value converted from C/C++ "cocos2d::CCRect"
 */
getTextureRect : function () {},

/**
 * @method updateDisplayedOpacity
 * @param {unsigned char}
 */
updateDisplayedOpacity : function () {},

/**
 * @method initWithSpriteFrameName
 * @return A value converted from C/C++ "bool"
 * @param {const char*}
 */
initWithSpriteFrameName : function () {},

/**
 * @method isFrameDisplayed
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCSpriteFrame*}
 */
isFrameDisplayed : function () {},

/**
 * @method getAtlasIndex
 * @return A value converted from C/C++ "unsigned int"
 */
getAtlasIndex : function () {},

/**
 * @method setRotation
 * @param {float}
 */
setRotation : function () {},

/**
 * @method setDisplayFrame
 * @param {cocos2d::CCSpriteFrame*}
 */
setDisplayFrame : function () {},

/**
 * @method getOffsetPosition
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 */
getOffsetPosition : function () {},

/**
 * @method setBatchNode
 * @param {cocos2d::CCSpriteBatchNode*}
 */
setBatchNode : function () {},

/**
 * @method setRotationX
 * @param {float}
 */
setRotationX : function () {},

/**
 * @method setScaleX
 * @param {float}
 */
setScaleX : function () {},

/**
 * @method setTextureAtlas
 * @param {cocos2d::CCTextureAtlas*}
 */
setTextureAtlas : function () {},

/**
 * @method setFlipY
 * @param {bool}
 */
setFlipY : function () {},

/**
 * @method setFlipX
 * @param {bool}
 */
setFlipX : function () {},

/**
 * @method removeAllChildrenWithCleanup
 * @param {bool}
 */
removeAllChildrenWithCleanup : function () {},

/**
 * @method sortAllChildren
 */
sortAllChildren : function () {},

/**
 * @method setAtlasIndex
 * @param {unsigned int}
 */
setAtlasIndex : function () {},

/**
 * @method setVertexRect
 * @param {cocos2d::CCRect}
 */
setVertexRect : function () {},

/**
 * @method setDirty
 * @param {bool}
 */
setDirty : function () {},

/**
 * @method isDirty
 * @return A value converted from C/C++ "bool"
 */
isDirty : function () {},

/**
 * @method reorderChild
 * @param {cocos2d::CCNode*}
 * @param {int}
 */
reorderChild : function () {},

/**
 * @method ignoreAnchorPointForPosition
 * @param {bool}
 */
ignoreAnchorPointForPosition : function () {},

/**
 * @method setColor
 * @param {cocos2d::ccColor3B}
 */
setColor : function () {},

/**
 * @method getTextureAtlas
 * @return A value converted from C/C++ "cocos2d::CCTextureAtlas*"
 */
getTextureAtlas : function () {},

/**
 * @method initWithSpriteFrame
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCSpriteFrame*}
 */
initWithSpriteFrame : function () {},

/**
 * @method removeChild
 * @param {cocos2d::CCNode*}
 * @param {bool}
 */
removeChild : function () {},

/**
 * @method updateTransform
 */
updateTransform : function () {},

/**
 * @method isFlipY
 * @return A value converted from C/C++ "bool"
 */
isFlipY : function () {},

/**
 * @method updateDisplayedColor
 * @param {cocos2d::ccColor3B}
 */
updateDisplayedColor : function () {},

/**
 * @method setSkewX
 * @param {float}
 */
setSkewX : function () {},

/**
 * @method setSkewY
 * @param {float}
 */
setSkewY : function () {},

/**
 * @method setVisible
 * @param {bool}
 */
setVisible : function () {},

/**
 * @method createWithSpriteFrameName
 * @return A value converted from C/C++ "cocos2d::CCSprite*"
 * @param {const char*}
 */
createWithSpriteFrameName : function () {},

/**
 * @method createWithSpriteFrame
 * @return A value converted from C/C++ "cocos2d::CCSprite*"
 * @param {cocos2d::CCSpriteFrame*}
 */
createWithSpriteFrame : function () {},

/**
 * @method CCSprite
 * @constructor
 */
CCSprite : function () {},

};

/**
 * @class CCLabelTTF
 */
cc.LabelTTF = {

/**
 * @method setFontName
 * @param {const char*}
 */
setFontName : function () {},

/**
 * @method setDimensions
 * @param {cocos2d::CCSize}
 */
setDimensions : function () {},

/**
 * @method getFontSize
 * @return A value converted from C/C++ "float"
 */
getFontSize : function () {},

/**
 * @method getString
 * @return A value converted from C/C++ "const char*"
 */
getString : function () {},

/**
 * @method setVerticalAlignment
 * @param {cocos2d::CCVerticalTextAlignment}
 */
setVerticalAlignment : function () {},

/**
 * @method getFontName
 * @return A value converted from C/C++ "const char*"
 */
getFontName : function () {},

/**
 * @method setString
 * @param {const char*}
 */
setString : function () {},

/**
 * @method getDimensions
 * @return A value converted from C/C++ "cocos2d::CCSize"
 */
getDimensions : function () {},

/**
 * @method setFontSize
 * @param {float}
 */
setFontSize : function () {},

/**
 * @method setHorizontalAlignment
 * @param {cocos2d::CCTextAlignment}
 */
setHorizontalAlignment : function () {},

/**
 * @method init
 * @return A value converted from C/C++ "bool"
 */
init : function () {},

/**
 * @method getVerticalAlignment
 * @return A value converted from C/C++ "cocos2d::CCVerticalTextAlignment"
 */
getVerticalAlignment : function () {},

/**
 * @method getHorizontalAlignment
 * @return A value converted from C/C++ "cocos2d::CCTextAlignment"
 */
getHorizontalAlignment : function () {},

/**
 * @method CCLabelTTF
 * @constructor
 */
CCLabelTTF : function () {},

};

/**
 * @class CCDirector
 */
cc.Director = {

/**
 * @method pause
 */
pause : function () {},

/**
 * @method setDelegate
 * @param {cocos2d::CCDirectorDelegate*}
 */
setDelegate : function () {},

/**
 * @method setContentScaleFactor
 * @param {float}
 */
setContentScaleFactor : function () {},

/**
 * @method getContentScaleFactor
 * @return A value converted from C/C++ "float"
 */
getContentScaleFactor : function () {},

/**
 * @method getWinSizeInPixels
 * @return A value converted from C/C++ "cocos2d::CCSize"
 */
getWinSizeInPixels : function () {},

/**
 * @method getDeltaTime
 * @return A value converted from C/C++ "float"
 */
getDeltaTime : function () {},

/**
 * @method setKeypadDispatcher
 * @param {cocos2d::CCKeypadDispatcher*}
 */
setKeypadDispatcher : function () {},

/**
 * @method setActionManager
 * @param {cocos2d::CCActionManager*}
 */
setActionManager : function () {},

/**
 * @method setAlphaBlending
 * @param {bool}
 */
setAlphaBlending : function () {},

/**
 * @method popToRootScene
 */
popToRootScene : function () {},

/**
 * @method getNotificationNode
 * @return A value converted from C/C++ "cocos2d::CCNode*"
 */
getNotificationNode : function () {},

/**
 * @method getWinSize
 * @return A value converted from C/C++ "cocos2d::CCSize"
 */
getWinSize : function () {},

/**
 * @method end
 */
end : function () {},

/**
 * @method isSendCleanupToScene
 * @return A value converted from C/C++ "bool"
 */
isSendCleanupToScene : function () {},

/**
 * @method getVisibleOrigin
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 */
getVisibleOrigin : function () {},

/**
 * @method mainLoop
 */
mainLoop : function () {},

/**
 * @method setDepthTest
 * @param {bool}
 */
setDepthTest : function () {},

/**
 * @method getSecondsPerFrame
 * @return A value converted from C/C++ "float"
 */
getSecondsPerFrame : function () {},

/**
 * @method convertToUI
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 * @param {cocos2d::CCPoint}
 */
convertToUI : function () {},

/**
 * @method setAccelerometer
 * @param {cocos2d::CCAccelerometer*}
 */
setAccelerometer : function () {},

/**
 * @method init
 * @return A value converted from C/C++ "bool"
 */
init : function () {},

/**
 * @method setScheduler
 * @param {cocos2d::CCScheduler*}
 */
setScheduler : function () {},

/**
 * @method startAnimation
 */
startAnimation : function () {},

/**
 * @method getRunningScene
 * @return A value converted from C/C++ "cocos2d::CCScene*"
 */
getRunningScene : function () {},

/**
 * @method setViewport
 */
setViewport : function () {},

/**
 * @method stopAnimation
 */
stopAnimation : function () {},

/**
 * @method setGLDefaultValues
 */
setGLDefaultValues : function () {},

/**
 * @method resume
 */
resume : function () {},

/**
 * @method setTouchDispatcher
 * @param {cocos2d::CCTouchDispatcher*}
 */
setTouchDispatcher : function () {},

/**
 * @method isNextDeltaTimeZero
 * @return A value converted from C/C++ "bool"
 */
isNextDeltaTimeZero : function () {},

/**
 * @method getDelegate
 * @return A value converted from C/C++ "cocos2d::CCDirectorDelegate*"
 */
getDelegate : function () {},

/**
 * @method setOpenGLView
 * @param {cocos2d::CCEGLView*}
 */
setOpenGLView : function () {},

/**
 * @method convertToGL
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 * @param {cocos2d::CCPoint}
 */
convertToGL : function () {},

/**
 * @method purgeCachedData
 */
purgeCachedData : function () {},

/**
 * @method getTotalFrames
 * @return A value converted from C/C++ "unsigned int"
 */
getTotalFrames : function () {},

/**
 * @method runWithScene
 * @param {cocos2d::CCScene*}
 */
runWithScene : function () {},

/**
 * @method setNotificationNode
 * @param {cocos2d::CCNode*}
 */
setNotificationNode : function () {},

/**
 * @method drawScene
 */
drawScene : function () {},

/**
 * @method popScene
 */
popScene : function () {},

/**
 * @method isDisplayStats
 * @return A value converted from C/C++ "bool"
 */
isDisplayStats : function () {},

/**
 * @method setProjection
 * @param {cocos2d::ccDirectorProjection}
 */
setProjection : function () {},

/**
 * @method getZEye
 * @return A value converted from C/C++ "float"
 */
getZEye : function () {},

/**
 * @method setNextDeltaTimeZero
 * @param {bool}
 */
setNextDeltaTimeZero : function () {},

/**
 * @method getVisibleSize
 * @return A value converted from C/C++ "cocos2d::CCSize"
 */
getVisibleSize : function () {},

/**
 * @method getScheduler
 * @return A value converted from C/C++ "cocos2d::CCScheduler*"
 */
getScheduler : function () {},

/**
 * @method pushScene
 * @param {cocos2d::CCScene*}
 */
pushScene : function () {},

/**
 * @method getAnimationInterval
 * @return A value converted from C/C++ "double"
 */
getAnimationInterval : function () {},

/**
 * @method isPaused
 * @return A value converted from C/C++ "bool"
 */
isPaused : function () {},

/**
 * @method setDisplayStats
 * @param {bool}
 */
setDisplayStats : function () {},

/**
 * @method replaceScene
 * @param {cocos2d::CCScene*}
 */
replaceScene : function () {},

/**
 * @method setAnimationInterval
 * @param {double}
 */
setAnimationInterval : function () {},

/**
 * @method getActionManager
 * @return A value converted from C/C++ "cocos2d::CCActionManager*"
 */
getActionManager : function () {},

/**
 * @method sharedDirector
 * @return A value converted from C/C++ "cocos2d::CCDirector*"
 */
sharedDirector : function () {},

};

/**
 * @class CCGridBase
 */
cc.GridBase = {

/**
 * @method setGridSize
 * @param {cocos2d::CCSize}
 */
setGridSize : function () {},

/**
 * @method calculateVertexPoints
 */
calculateVertexPoints : function () {},

/**
 * @method afterDraw
 * @param {cocos2d::CCNode*}
 */
afterDraw : function () {},

/**
 * @method beforeDraw
 */
beforeDraw : function () {},

/**
 * @method isTextureFlipped
 * @return A value converted from C/C++ "bool"
 */
isTextureFlipped : function () {},

/**
 * @method getGridSize
 * @return A value converted from C/C++ "cocos2d::CCSize"
 */
getGridSize : function () {},

/**
 * @method getStep
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 */
getStep : function () {},

/**
 * @method set2DProjection
 */
set2DProjection : function () {},

/**
 * @method setStep
 * @param {cocos2d::CCPoint}
 */
setStep : function () {},

/**
 * @method setTextureFlipped
 * @param {bool}
 */
setTextureFlipped : function () {},

/**
 * @method blit
 */
blit : function () {},

/**
 * @method setActive
 * @param {bool}
 */
setActive : function () {},

/**
 * @method getReuseGrid
 * @return A value converted from C/C++ "int"
 */
getReuseGrid : function () {},

/**
 * @method setReuseGrid
 * @param {int}
 */
setReuseGrid : function () {},

/**
 * @method isActive
 * @return A value converted from C/C++ "bool"
 */
isActive : function () {},

/**
 * @method reuse
 */
reuse : function () {},

};

/**
 * @class CCGrid3D
 */
cc.Grid3D = {

/**
 * @method calculateVertexPoints
 */
calculateVertexPoints : function () {},

/**
 * @method setVertex
 * @param {cocos2d::CCPoint}
 * @param {cocos2d::ccVertex3F}
 */
setVertex : function () {},

/**
 * @method reuse
 */
reuse : function () {},

/**
 * @method vertex
 * @return A value converted from C/C++ "ccVertex3F"
 * @param {cocos2d::CCPoint}
 */
vertex : function () {},

/**
 * @method blit
 */
blit : function () {},

/**
 * @method originalVertex
 * @return A value converted from C/C++ "ccVertex3F"
 * @param {cocos2d::CCPoint}
 */
originalVertex : function () {},

/**
 * @method CCGrid3D
 * @constructor
 */
CCGrid3D : function () {},

};

/**
 * @class CCTiledGrid3D
 */
cc.TiledGrid3D = {

/**
 * @method calculateVertexPoints
 */
calculateVertexPoints : function () {},

/**
 * @method reuse
 */
reuse : function () {},

/**
 * @method originalTile
 * @return A value converted from C/C++ "ccQuad3"
 * @param {cocos2d::CCPoint}
 */
originalTile : function () {},

/**
 * @method tile
 * @return A value converted from C/C++ "ccQuad3"
 * @param {cocos2d::CCPoint}
 */
tile : function () {},

/**
 * @method setTile
 * @param {cocos2d::CCPoint}
 * @param {cocos2d::ccQuad3}
 */
setTile : function () {},

/**
 * @method blit
 */
blit : function () {},

/**
 * @method CCTiledGrid3D
 * @constructor
 */
CCTiledGrid3D : function () {},

};

/**
 * @class CCLabelAtlas
 */
cc.LabelAtlas = {

/**
 * @method setString
 * @param {const char*}
 */
setString : function () {},

/**
 * @method updateAtlasValues
 */
updateAtlasValues : function () {},

/**
 * @method getString
 * @return A value converted from C/C++ "const char*"
 */
getString : function () {},

/**
 * @method CCLabelAtlas
 * @constructor
 */
CCLabelAtlas : function () {},

};

/**
 * @class CCSpriteBatchNode
 */
cc.SpriteBatchNode = {

/**
 * @method appendChild
 * @param {cocos2d::CCSprite*}
 */
appendChild : function () {},

/**
 * @method reorderBatch
 * @param {bool}
 */
reorderBatch : function () {},

/**
 * @method getTexture
 * @return A value converted from C/C++ "cocos2d::CCTexture2D*"
 */
getTexture : function () {},

/**
 * @method visit
 */
visit : function () {},

/**
 * @method setTexture
 * @param {cocos2d::CCTexture2D*}
 */
setTexture : function () {},

/**
 * @method removeChildAtIndex
 * @param {unsigned int}
 * @param {bool}
 */
removeChildAtIndex : function () {},

/**
 * @method removeSpriteFromAtlas
 * @param {cocos2d::CCSprite*}
 */
removeSpriteFromAtlas : function () {},

/**
 * @method atlasIndexForChild
 * @return A value converted from C/C++ "unsigned int"
 * @param {cocos2d::CCSprite*}
 * @param {int}
 */
atlasIndexForChild : function () {},

/**
 * @method increaseAtlasCapacity
 */
increaseAtlasCapacity : function () {},

/**
 * @method insertChild
 * @param {cocos2d::CCSprite*}
 * @param {unsigned int}
 */
insertChild : function () {},

/**
 * @method lowestAtlasIndexInChild
 * @return A value converted from C/C++ "unsigned int"
 * @param {cocos2d::CCSprite*}
 */
lowestAtlasIndexInChild : function () {},

/**
 * @method draw
 */
draw : function () {},

/**
 * @method initWithTexture
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCTexture2D*}
 * @param {unsigned int}
 */
initWithTexture : function () {},

/**
 * @method setTextureAtlas
 * @param {cocos2d::CCTextureAtlas*}
 */
setTextureAtlas : function () {},

/**
 * @method removeAllChildrenWithCleanup
 * @param {bool}
 */
removeAllChildrenWithCleanup : function () {},

/**
 * @method sortAllChildren
 */
sortAllChildren : function () {},

/**
 * @method reorderChild
 * @param {cocos2d::CCNode*}
 * @param {int}
 */
reorderChild : function () {},

/**
 * @method rebuildIndexInOrder
 * @return A value converted from C/C++ "unsigned int"
 * @param {cocos2d::CCSprite*}
 * @param {unsigned int}
 */
rebuildIndexInOrder : function () {},

/**
 * @method getTextureAtlas
 * @return A value converted from C/C++ "cocos2d::CCTextureAtlas*"
 */
getTextureAtlas : function () {},

/**
 * @method getDescendants
 * @return A value converted from C/C++ "cocos2d::CCArray*"
 */
getDescendants : function () {},

/**
 * @method removeChild
 * @param {cocos2d::CCNode*}
 * @param {bool}
 */
removeChild : function () {},

/**
 * @method highestAtlasIndexInChild
 * @return A value converted from C/C++ "unsigned int"
 * @param {cocos2d::CCSprite*}
 */
highestAtlasIndexInChild : function () {},

};

/**
 * @class CCLabelBMFont
 */
cc.LabelBMFont = {

/**
 * @method setAnchorPoint
 * @param {cocos2d::CCPoint}
 */
setAnchorPoint : function () {},

/**
 * @method createFontChars
 */
createFontChars : function () {},

/**
 * @method getString
 * @return A value converted from C/C++ "const char*"
 */
getString : function () {},

/**
 * @method setScale
 * @param {float}
 */
setScale : function () {},

/**
 * @method setOpacity
 * @param {unsigned char}
 */
setOpacity : function () {},

/**
 * @method setCascadeOpacityEnabled
 * @param {bool}
 */
setCascadeOpacityEnabled : function () {},

/**
 * @method getFntFile
 * @return A value converted from C/C++ "const char*"
 */
getFntFile : function () {},

/**
 * @method updateLabel
 */
updateLabel : function () {},

/**
 * @method setWidth
 * @param {float}
 */
setWidth : function () {},

/**
 * @method isOpacityModifyRGB
 * @return A value converted from C/C++ "bool"
 */
isOpacityModifyRGB : function () {},

/**
 * @method isCascadeOpacityEnabled
 * @return A value converted from C/C++ "bool"
 */
isCascadeOpacityEnabled : function () {},

/**
 * @method initWithString
 * @return A value converted from C/C++ "bool"
 * @param {const char*}
 * @param {const char*}
 * @param {float}
 * @param {cocos2d::CCTextAlignment}
 * @param {cocos2d::CCPoint}
 */
initWithString : function () {},

/**
 * @method setCascadeColorEnabled
 * @param {bool}
 */
setCascadeColorEnabled : function () {},

/**
 * @method setOpacityModifyRGB
 * @param {bool}
 */
setOpacityModifyRGB : function () {},

/**
 * @method updateDisplayedOpacity
 * @param {unsigned char}
 */
updateDisplayedOpacity : function () {},

/**
 * @method init
 * @return A value converted from C/C++ "bool"
 */
init : function () {},

/**
 * @method setFntFile
 * @param {const char*}
 */
setFntFile : function () {},

/**
 * @method getOpacity
 * @return A value converted from C/C++ "unsigned char"
 */
getOpacity : function () {},

/**
 * @method setLineBreakWithoutSpace
 * @param {bool}
 */
setLineBreakWithoutSpace : function () {},

/**
 * @method setScaleY
 * @param {float}
 */
setScaleY : function () {},

/**
 * @method setScaleX
 * @param {float}
 */
setScaleX : function () {},

/**
 * @method getColor
 * @return A value converted from C/C++ "cocos2d::ccColor3B"
 */
getColor : function () {},

/**
 * @method getDisplayedOpacity
 * @return A value converted from C/C++ "unsigned char"
 */
getDisplayedOpacity : function () {},

/**
 * @method isCascadeColorEnabled
 * @return A value converted from C/C++ "bool"
 */
isCascadeColorEnabled : function () {},

/**
 * @method setColor
 * @param {cocos2d::ccColor3B}
 */
setColor : function () {},

/**
 * @method setCString
 * @param {const char*}
 */
setCString : function () {},

/**
 * @method getDisplayedColor
 * @return A value converted from C/C++ "cocos2d::ccColor3B"
 */
getDisplayedColor : function () {},

/**
 * @method updateDisplayedColor
 * @param {cocos2d::ccColor3B}
 */
updateDisplayedColor : function () {},

/**
 * @method setAlignment
 * @param {cocos2d::CCTextAlignment}
 */
setAlignment : function () {},

/**
 * @method purgeCachedData
 */
purgeCachedData : function () {},

/**
 * @method CCLabelBMFont
 * @constructor
 */
CCLabelBMFont : function () {},

};

/**
 * @class CCLayer
 */
cc.Layer = {

/**
 * @method unregisterScriptTouchHandler
 */
unregisterScriptTouchHandler : function () {},

/**
 * @method keyBackClicked
 */
keyBackClicked : function () {},

/**
 * @method ccTouchBegan
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCTouch*}
 * @param {cocos2d::CCEvent*}
 */
ccTouchBegan : function () {},

/**
 * @method setAccelerometerInterval
 * @param {double}
 */
setAccelerometerInterval : function () {},

/**
 * @method ccTouchesCancelled
 * @param {cocos2d::CCSet*}
 * @param {cocos2d::CCEvent*}
 */
ccTouchesCancelled : function () {},

/**
 * @method unregisterScriptAccelerateHandler
 */
unregisterScriptAccelerateHandler : function () {},

/**
 * @method ccTouchesMoved
 * @param {cocos2d::CCSet*}
 * @param {cocos2d::CCEvent*}
 */
ccTouchesMoved : function () {},

/**
 * @method registerScriptAccelerateHandler
 * @param {int}
 */
registerScriptAccelerateHandler : function () {},

/**
 * @method getTouchMode
 * @return A value converted from C/C++ "int"
 */
getTouchMode : function () {},

/**
 * @method setAccelerometerEnabled
 * @param {bool}
 */
setAccelerometerEnabled : function () {},

/**
 * @method init
 * @return A value converted from C/C++ "bool"
 */
init : function () {},

/**
 * @method isTouchEnabled
 * @return A value converted from C/C++ "bool"
 */
isTouchEnabled : function () {},

/**
 * @method getScriptAccelerateHandlerEntry
 * @return A value converted from C/C++ "cocos2d::CCScriptHandlerEntry*"
 */
getScriptAccelerateHandlerEntry : function () {},

/**
 * @method getScriptKeypadHandlerEntry
 * @return A value converted from C/C++ "cocos2d::CCScriptHandlerEntry*"
 */
getScriptKeypadHandlerEntry : function () {},

/**
 * @method ccTouchMoved
 * @param {cocos2d::CCTouch*}
 * @param {cocos2d::CCEvent*}
 */
ccTouchMoved : function () {},

/**
 * @method setTouchEnabled
 * @param {bool}
 */
setTouchEnabled : function () {},

/**
 * @method unregisterScriptKeypadHandler
 */
unregisterScriptKeypadHandler : function () {},

/**
 * @method isKeypadEnabled
 * @return A value converted from C/C++ "bool"
 */
isKeypadEnabled : function () {},

/**
 * @method ccTouchesEnded
 * @param {cocos2d::CCSet*}
 * @param {cocos2d::CCEvent*}
 */
ccTouchesEnded : function () {},

/**
 * @method setTouchMode
 * @param {cocos2d::ccTouchesMode}
 */
setTouchMode : function () {},

/**
 * @method isAccelerometerEnabled
 * @return A value converted from C/C++ "bool"
 */
isAccelerometerEnabled : function () {},

/**
 * @method ccTouchEnded
 * @param {cocos2d::CCTouch*}
 * @param {cocos2d::CCEvent*}
 */
ccTouchEnded : function () {},

/**
 * @method registerScriptTouchHandler
 * @param {int}
 * @param {bool}
 * @param {int}
 * @param {bool}
 */
registerScriptTouchHandler : function () {},

/**
 * @method ccTouchCancelled
 * @param {cocos2d::CCTouch*}
 * @param {cocos2d::CCEvent*}
 */
ccTouchCancelled : function () {},

/**
 * @method getScriptTouchHandlerEntry
 * @return A value converted from C/C++ "cocos2d::CCTouchScriptHandlerEntry*"
 */
getScriptTouchHandlerEntry : function () {},

/**
 * @method ccTouchesBegan
 * @param {cocos2d::CCSet*}
 * @param {cocos2d::CCEvent*}
 */
ccTouchesBegan : function () {},

/**
 * @method setTouchPriority
 * @param {int}
 */
setTouchPriority : function () {},

/**
 * @method getTouchPriority
 * @return A value converted from C/C++ "int"
 */
getTouchPriority : function () {},

/**
 * @method setKeypadEnabled
 * @param {bool}
 */
setKeypadEnabled : function () {},

/**
 * @method registerWithTouchDispatcher
 */
registerWithTouchDispatcher : function () {},

/**
 * @method keyMenuClicked
 */
keyMenuClicked : function () {},

/**
 * @method registerScriptKeypadHandler
 * @param {int}
 */
registerScriptKeypadHandler : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCLayer*"
 */
create : function () {},

/**
 * @method CCLayer
 * @constructor
 */
CCLayer : function () {},

};

/**
 * @class CCLayerRGBA
 */
cc.LayerRGBA = {

/**
 * @method updateDisplayedColor
 * @param {cocos2d::ccColor3B}
 */
updateDisplayedColor : function () {},

/**
 * @method setColor
 * @param {cocos2d::ccColor3B}
 */
setColor : function () {},

/**
 * @method isCascadeOpacityEnabled
 * @return A value converted from C/C++ "bool"
 */
isCascadeOpacityEnabled : function () {},

/**
 * @method getColor
 * @return A value converted from C/C++ "cocos2d::ccColor3B"
 */
getColor : function () {},

/**
 * @method getDisplayedOpacity
 * @return A value converted from C/C++ "unsigned char"
 */
getDisplayedOpacity : function () {},

/**
 * @method setCascadeColorEnabled
 * @param {bool}
 */
setCascadeColorEnabled : function () {},

/**
 * @method setOpacity
 * @param {unsigned char}
 */
setOpacity : function () {},

/**
 * @method setOpacityModifyRGB
 * @param {bool}
 */
setOpacityModifyRGB : function () {},

/**
 * @method setCascadeOpacityEnabled
 * @param {bool}
 */
setCascadeOpacityEnabled : function () {},

/**
 * @method updateDisplayedOpacity
 * @param {unsigned char}
 */
updateDisplayedOpacity : function () {},

/**
 * @method init
 * @return A value converted from C/C++ "bool"
 */
init : function () {},

/**
 * @method getOpacity
 * @return A value converted from C/C++ "unsigned char"
 */
getOpacity : function () {},

/**
 * @method isOpacityModifyRGB
 * @return A value converted from C/C++ "bool"
 */
isOpacityModifyRGB : function () {},

/**
 * @method isCascadeColorEnabled
 * @return A value converted from C/C++ "bool"
 */
isCascadeColorEnabled : function () {},

/**
 * @method getDisplayedColor
 * @return A value converted from C/C++ "cocos2d::ccColor3B"
 */
getDisplayedColor : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCLayerRGBA*"
 */
create : function () {},

/**
 * @method CCLayerRGBA
 * @constructor
 */
CCLayerRGBA : function () {},

};

/**
 * @class CCLayerColor
 */
cc.LayerColor = {

/**
 * @method draw
 */
draw : function () {},

/**
 * @method isOpacityModifyRGB
 * @return A value converted from C/C++ "bool"
 */
isOpacityModifyRGB : function () {},

/**
 * @method setColor
 * @param {cocos2d::ccColor3B}
 */
setColor : function () {},

/**
 * @method changeWidthAndHeight
 * @param {float}
 * @param {float}
 */
changeWidthAndHeight : function () {},

/**
 * @method setOpacityModifyRGB
 * @param {bool}
 */
setOpacityModifyRGB : function () {},

/**
 * @method changeWidth
 * @param {float}
 */
changeWidth : function () {},

/**
 * @method setOpacity
 * @param {unsigned char}
 */
setOpacity : function () {},

/**
 * @method setContentSize
 * @param {cocos2d::CCSize}
 */
setContentSize : function () {},

/**
 * @method changeHeight
 * @param {float}
 */
changeHeight : function () {},

/**
 * @method CCLayerColor
 * @constructor
 */
CCLayerColor : function () {},

};

/**
 * @class CCLayerGradient
 */
cc.LayerGradient = {

/**
 * @method getStartColor
 * @return A value converted from C/C++ "cocos2d::ccColor3B"
 */
getStartColor : function () {},

/**
 * @method isCompressedInterpolation
 * @return A value converted from C/C++ "bool"
 */
isCompressedInterpolation : function () {},

/**
 * @method getStartOpacity
 * @return A value converted from C/C++ "unsigned char"
 */
getStartOpacity : function () {},

/**
 * @method setVector
 * @param {cocos2d::CCPoint}
 */
setVector : function () {},

/**
 * @method setStartOpacity
 * @param {unsigned char}
 */
setStartOpacity : function () {},

/**
 * @method setCompressedInterpolation
 * @param {bool}
 */
setCompressedInterpolation : function () {},

/**
 * @method setEndOpacity
 * @param {unsigned char}
 */
setEndOpacity : function () {},

/**
 * @method getVector
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 */
getVector : function () {},

/**
 * @method setEndColor
 * @param {cocos2d::ccColor3B}
 */
setEndColor : function () {},

/**
 * @method getEndColor
 * @return A value converted from C/C++ "cocos2d::ccColor3B"
 */
getEndColor : function () {},

/**
 * @method getEndOpacity
 * @return A value converted from C/C++ "unsigned char"
 */
getEndOpacity : function () {},

/**
 * @method setStartColor
 * @param {cocos2d::ccColor3B}
 */
setStartColor : function () {},

};

/**
 * @class CCLayerMultiplex
 */
cc.LayerMultiplex = {

/**
 * @method initWithArray
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCArray*}
 */
initWithArray : function () {},

/**
 * @method switchToAndReleaseMe
 * @param {unsigned int}
 */
switchToAndReleaseMe : function () {},

/**
 * @method addLayer
 * @param {cocos2d::CCLayer*}
 */
addLayer : function () {},

/**
 * @method switchTo
 * @param {unsigned int}
 */
switchTo : function () {},

/**
 * @method CCLayerMultiplex
 * @constructor
 */
CCLayerMultiplex : function () {},

};

/**
 * @class CCScene
 */
cc.Scene = {

/**
 * @method init
 * @return A value converted from C/C++ "bool"
 */
init : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCScene*"
 */
create : function () {},

/**
 * @method CCScene
 * @constructor
 */
CCScene : function () {},

};

/**
 * @class CCTransitionEaseScene
 */
cc.TransitionEaseScene = {

/**
 * @method easeActionWithAction
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 * @param {cocos2d::CCActionInterval*}
 */
easeActionWithAction : function () {},

};

/**
 * @class CCTransitionScene
 */
cc.TransitionScene = {

/**
 * @method draw
 */
draw : function () {},

/**
 * @method finish
 */
finish : function () {},

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {cocos2d::CCScene*}
 */
initWithDuration : function () {},

/**
 * @method cleanup
 */
cleanup : function () {},

/**
 * @method hideOutShowIn
 */
hideOutShowIn : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTransitionScene*"
 * @param {float}
 * @param {cocos2d::CCScene*}
 */
create : function () {},

/**
 * @method CCTransitionScene
 * @constructor
 */
CCTransitionScene : function () {},

};

/**
 * @class CCTransitionSceneOriented
 */
cc.TransitionSceneOriented = {

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {cocos2d::CCScene*}
 * @param {cocos2d::tOrientation}
 */
initWithDuration : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTransitionSceneOriented*"
 * @param {float}
 * @param {cocos2d::CCScene*}
 * @param {cocos2d::tOrientation}
 */
create : function () {},

/**
 * @method CCTransitionSceneOriented
 * @constructor
 */
CCTransitionSceneOriented : function () {},

};

/**
 * @class CCTransitionRotoZoom
 */
cc.TransitionRotoZoom = {

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTransitionRotoZoom*"
 * @param {float}
 * @param {cocos2d::CCScene*}
 */
create : function () {},

/**
 * @method CCTransitionRotoZoom
 * @constructor
 */
CCTransitionRotoZoom : function () {},

};

/**
 * @class CCTransitionJumpZoom
 */
cc.TransitionJumpZoom = {

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTransitionJumpZoom*"
 * @param {float}
 * @param {cocos2d::CCScene*}
 */
create : function () {},

/**
 * @method CCTransitionJumpZoom
 * @constructor
 */
CCTransitionJumpZoom : function () {},

};

/**
 * @class CCTransitionMoveInL
 */
cc.TransitionMoveInL = {

/**
 * @method action
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
action : function () {},

/**
 * @method easeActionWithAction
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 * @param {cocos2d::CCActionInterval*}
 */
easeActionWithAction : function () {},

/**
 * @method initScenes
 */
initScenes : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTransitionMoveInL*"
 * @param {float}
 * @param {cocos2d::CCScene*}
 */
create : function () {},

/**
 * @method CCTransitionMoveInL
 * @constructor
 */
CCTransitionMoveInL : function () {},

};

/**
 * @class CCTransitionMoveInR
 */
cc.TransitionMoveInR = {

/**
 * @method initScenes
 */
initScenes : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTransitionMoveInR*"
 * @param {float}
 * @param {cocos2d::CCScene*}
 */
create : function () {},

/**
 * @method CCTransitionMoveInR
 * @constructor
 */
CCTransitionMoveInR : function () {},

};

/**
 * @class CCTransitionMoveInT
 */
cc.TransitionMoveInT = {

/**
 * @method initScenes
 */
initScenes : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTransitionMoveInT*"
 * @param {float}
 * @param {cocos2d::CCScene*}
 */
create : function () {},

/**
 * @method CCTransitionMoveInT
 * @constructor
 */
CCTransitionMoveInT : function () {},

};

/**
 * @class CCTransitionMoveInB
 */
cc.TransitionMoveInB = {

/**
 * @method initScenes
 */
initScenes : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTransitionMoveInB*"
 * @param {float}
 * @param {cocos2d::CCScene*}
 */
create : function () {},

/**
 * @method CCTransitionMoveInB
 * @constructor
 */
CCTransitionMoveInB : function () {},

};

/**
 * @class CCTransitionSlideInL
 */
cc.TransitionSlideInL = {

/**
 * @method action
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
action : function () {},

/**
 * @method easeActionWithAction
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 * @param {cocos2d::CCActionInterval*}
 */
easeActionWithAction : function () {},

/**
 * @method initScenes
 */
initScenes : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTransitionSlideInL*"
 * @param {float}
 * @param {cocos2d::CCScene*}
 */
create : function () {},

/**
 * @method CCTransitionSlideInL
 * @constructor
 */
CCTransitionSlideInL : function () {},

};

/**
 * @class CCTransitionSlideInR
 */
cc.TransitionSlideInR = {

/**
 * @method action
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
action : function () {},

/**
 * @method initScenes
 */
initScenes : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTransitionSlideInR*"
 * @param {float}
 * @param {cocos2d::CCScene*}
 */
create : function () {},

/**
 * @method CCTransitionSlideInR
 * @constructor
 */
CCTransitionSlideInR : function () {},

};

/**
 * @class CCTransitionSlideInB
 */
cc.TransitionSlideInB = {

/**
 * @method action
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
action : function () {},

/**
 * @method initScenes
 */
initScenes : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTransitionSlideInB*"
 * @param {float}
 * @param {cocos2d::CCScene*}
 */
create : function () {},

/**
 * @method CCTransitionSlideInB
 * @constructor
 */
CCTransitionSlideInB : function () {},

};

/**
 * @class CCTransitionSlideInT
 */
cc.TransitionSlideInT = {

/**
 * @method action
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
action : function () {},

/**
 * @method initScenes
 */
initScenes : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTransitionSlideInT*"
 * @param {float}
 * @param {cocos2d::CCScene*}
 */
create : function () {},

/**
 * @method CCTransitionSlideInT
 * @constructor
 */
CCTransitionSlideInT : function () {},

};

/**
 * @class CCTransitionShrinkGrow
 */
cc.TransitionShrinkGrow = {

/**
 * @method easeActionWithAction
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 * @param {cocos2d::CCActionInterval*}
 */
easeActionWithAction : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTransitionShrinkGrow*"
 * @param {float}
 * @param {cocos2d::CCScene*}
 */
create : function () {},

/**
 * @method CCTransitionShrinkGrow
 * @constructor
 */
CCTransitionShrinkGrow : function () {},

};

/**
 * @class CCTransitionFlipX
 */
cc.TransitionFlipX = {

/**
 * @method CCTransitionFlipX
 * @constructor
 */
CCTransitionFlipX : function () {},

};

/**
 * @class CCTransitionFlipY
 */
cc.TransitionFlipY = {

/**
 * @method CCTransitionFlipY
 * @constructor
 */
CCTransitionFlipY : function () {},

};

/**
 * @class CCTransitionFlipAngular
 */
cc.TransitionFlipAngular = {

/**
 * @method CCTransitionFlipAngular
 * @constructor
 */
CCTransitionFlipAngular : function () {},

};

/**
 * @class CCTransitionZoomFlipX
 */
cc.TransitionZoomFlipX = {

/**
 * @method CCTransitionZoomFlipX
 * @constructor
 */
CCTransitionZoomFlipX : function () {},

};

/**
 * @class CCTransitionZoomFlipY
 */
cc.TransitionZoomFlipY = {

/**
 * @method CCTransitionZoomFlipY
 * @constructor
 */
CCTransitionZoomFlipY : function () {},

};

/**
 * @class CCTransitionZoomFlipAngular
 */
cc.TransitionZoomFlipAngular = {

/**
 * @method CCTransitionZoomFlipAngular
 * @constructor
 */
CCTransitionZoomFlipAngular : function () {},

};

/**
 * @class CCTransitionFade
 */
cc.TransitionFade = {

/**
 * @method CCTransitionFade
 * @constructor
 */
CCTransitionFade : function () {},

};

/**
 * @class CCTransitionCrossFade
 */
cc.TransitionCrossFade = {

/**
 * @method draw
 */
draw : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTransitionCrossFade*"
 * @param {float}
 * @param {cocos2d::CCScene*}
 */
create : function () {},

/**
 * @method CCTransitionCrossFade
 * @constructor
 */
CCTransitionCrossFade : function () {},

};

/**
 * @class CCTransitionTurnOffTiles
 */
cc.TransitionTurnOffTiles = {

/**
 * @method easeActionWithAction
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 * @param {cocos2d::CCActionInterval*}
 */
easeActionWithAction : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTransitionTurnOffTiles*"
 * @param {float}
 * @param {cocos2d::CCScene*}
 */
create : function () {},

/**
 * @method CCTransitionTurnOffTiles
 * @constructor
 */
CCTransitionTurnOffTiles : function () {},

};

/**
 * @class CCTransitionSplitCols
 */
cc.TransitionSplitCols = {

/**
 * @method action
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
action : function () {},

/**
 * @method easeActionWithAction
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 * @param {cocos2d::CCActionInterval*}
 */
easeActionWithAction : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTransitionSplitCols*"
 * @param {float}
 * @param {cocos2d::CCScene*}
 */
create : function () {},

/**
 * @method CCTransitionSplitCols
 * @constructor
 */
CCTransitionSplitCols : function () {},

};

/**
 * @class CCTransitionSplitRows
 */
cc.TransitionSplitRows = {

/**
 * @method action
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 */
action : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTransitionSplitRows*"
 * @param {float}
 * @param {cocos2d::CCScene*}
 */
create : function () {},

/**
 * @method CCTransitionSplitRows
 * @constructor
 */
CCTransitionSplitRows : function () {},

};

/**
 * @class CCTransitionFadeTR
 */
cc.TransitionFadeTR = {

/**
 * @method easeActionWithAction
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 * @param {cocos2d::CCActionInterval*}
 */
easeActionWithAction : function () {},

/**
 * @method actionWithSize
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 * @param {cocos2d::CCSize}
 */
actionWithSize : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTransitionFadeTR*"
 * @param {float}
 * @param {cocos2d::CCScene*}
 */
create : function () {},

/**
 * @method CCTransitionFadeTR
 * @constructor
 */
CCTransitionFadeTR : function () {},

};

/**
 * @class CCTransitionFadeBL
 */
cc.TransitionFadeBL = {

/**
 * @method actionWithSize
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 * @param {cocos2d::CCSize}
 */
actionWithSize : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTransitionFadeBL*"
 * @param {float}
 * @param {cocos2d::CCScene*}
 */
create : function () {},

/**
 * @method CCTransitionFadeBL
 * @constructor
 */
CCTransitionFadeBL : function () {},

};

/**
 * @class CCTransitionFadeUp
 */
cc.TransitionFadeUp = {

/**
 * @method actionWithSize
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 * @param {cocos2d::CCSize}
 */
actionWithSize : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTransitionFadeUp*"
 * @param {float}
 * @param {cocos2d::CCScene*}
 */
create : function () {},

/**
 * @method CCTransitionFadeUp
 * @constructor
 */
CCTransitionFadeUp : function () {},

};

/**
 * @class CCTransitionFadeDown
 */
cc.TransitionFadeDown = {

/**
 * @method actionWithSize
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 * @param {cocos2d::CCSize}
 */
actionWithSize : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTransitionFadeDown*"
 * @param {float}
 * @param {cocos2d::CCScene*}
 */
create : function () {},

/**
 * @method CCTransitionFadeDown
 * @constructor
 */
CCTransitionFadeDown : function () {},

};

/**
 * @class CCTransitionPageTurn
 */
cc.TransitionPageTurn = {

/**
 * @method actionWithSize
 * @return A value converted from C/C++ "cocos2d::CCActionInterval*"
 * @param {cocos2d::CCSize}
 */
actionWithSize : function () {},

/**
 * @method initWithDuration
 * @return A value converted from C/C++ "bool"
 * @param {float}
 * @param {cocos2d::CCScene*}
 * @param {bool}
 */
initWithDuration : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTransitionPageTurn*"
 * @param {float}
 * @param {cocos2d::CCScene*}
 * @param {bool}
 */
create : function () {},

/**
 * @method CCTransitionPageTurn
 * @constructor
 */
CCTransitionPageTurn : function () {},

};

/**
 * @class CCTransitionProgress
 */
cc.TransitionProgress = {

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTransitionProgress*"
 * @param {float}
 * @param {cocos2d::CCScene*}
 */
create : function () {},

/**
 * @method CCTransitionProgress
 * @constructor
 */
CCTransitionProgress : function () {},

};

/**
 * @class CCTransitionProgressRadialCCW
 */
cc.TransitionProgressRadialCCW = {

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTransitionProgressRadialCCW*"
 * @param {float}
 * @param {cocos2d::CCScene*}
 */
create : function () {},

};

/**
 * @class CCTransitionProgressRadialCW
 */
cc.TransitionProgressRadialCW = {

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTransitionProgressRadialCW*"
 * @param {float}
 * @param {cocos2d::CCScene*}
 */
create : function () {},

};

/**
 * @class CCTransitionProgressHorizontal
 */
cc.TransitionProgressHorizontal = {

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTransitionProgressHorizontal*"
 * @param {float}
 * @param {cocos2d::CCScene*}
 */
create : function () {},

};

/**
 * @class CCTransitionProgressVertical
 */
cc.TransitionProgressVertical = {

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTransitionProgressVertical*"
 * @param {float}
 * @param {cocos2d::CCScene*}
 */
create : function () {},

};

/**
 * @class CCTransitionProgressInOut
 */
cc.TransitionProgressInOut = {

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTransitionProgressInOut*"
 * @param {float}
 * @param {cocos2d::CCScene*}
 */
create : function () {},

};

/**
 * @class CCTransitionProgressOutIn
 */
cc.TransitionProgressOutIn = {

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTransitionProgressOutIn*"
 * @param {float}
 * @param {cocos2d::CCScene*}
 */
create : function () {},

};

/**
 * @class CCMenuItem
 */
cc.MenuItem = {

/**
 * @method setEnabled
 * @param {bool}
 */
setEnabled : function () {},

/**
 * @method activate
 */
activate : function () {},

/**
 * @method unregisterScriptTapHandler
 */
unregisterScriptTapHandler : function () {},

/**
 * @method isEnabled
 * @return A value converted from C/C++ "bool"
 */
isEnabled : function () {},

/**
 * @method selected
 */
selected : function () {},

/**
 * @method setOpacityModifyRGB
 * @param {bool}
 */
setOpacityModifyRGB : function () {},

/**
 * @method getScriptTapHandler
 * @return A value converted from C/C++ "int"
 */
getScriptTapHandler : function () {},

/**
 * @method isSelected
 * @return A value converted from C/C++ "bool"
 */
isSelected : function () {},

/**
 * @method isOpacityModifyRGB
 * @return A value converted from C/C++ "bool"
 */
isOpacityModifyRGB : function () {},

/**
 * @method registerScriptTapHandler
 * @param {int}
 */
registerScriptTapHandler : function () {},

/**
 * @method unselected
 */
unselected : function () {},

/**
 * @method rect
 * @return A value converted from C/C++ "cocos2d::CCRect"
 */
rect : function () {},

/**
 * @method CCMenuItem
 * @constructor
 */
CCMenuItem : function () {},

};

/**
 * @class CCMenuItemLabel
 */
cc.MenuItemLabel = {

/**
 * @method setEnabled
 * @param {bool}
 */
setEnabled : function () {},

/**
 * @method setLabel
 * @param {cocos2d::CCNode*}
 */
setLabel : function () {},

/**
 * @method activate
 */
activate : function () {},

/**
 * @method getDisabledColor
 * @return A value converted from C/C++ "cocos2d::ccColor3B"
 */
getDisabledColor : function () {},

/**
 * @method setString
 * @param {const char*}
 */
setString : function () {},

/**
 * @method selected
 */
selected : function () {},

/**
 * @method setDisabledColor
 * @param {cocos2d::ccColor3B}
 */
setDisabledColor : function () {},

/**
 * @method getLabel
 * @return A value converted from C/C++ "cocos2d::CCNode*"
 */
getLabel : function () {},

/**
 * @method unselected
 */
unselected : function () {},

/**
 * @method CCMenuItemLabel
 * @constructor
 */
CCMenuItemLabel : function () {},

};

/**
 * @class CCMenuItemAtlasFont
 */
cc.MenuItemAtlasFont = {

/**
 * @method CCMenuItemAtlasFont
 * @constructor
 */
CCMenuItemAtlasFont : function () {},

};

/**
 * @class CCMenuItemFont
 */
cc.MenuItemFont = {

/**
 * @method setFontNameObj
 * @param {const char*}
 */
setFontNameObj : function () {},

/**
 * @method fontNameObj
 * @return A value converted from C/C++ "const char*"
 */
fontNameObj : function () {},

/**
 * @method setFontSizeObj
 * @param {unsigned int}
 */
setFontSizeObj : function () {},

/**
 * @method fontSizeObj
 * @return A value converted from C/C++ "unsigned int"
 */
fontSizeObj : function () {},

/**
 * @method setFontName
 * @param {const char*}
 */
setFontName : function () {},

/**
 * @method fontName
 * @return A value converted from C/C++ "const char*"
 */
fontName : function () {},

/**
 * @method fontSize
 * @return A value converted from C/C++ "unsigned int"
 */
fontSize : function () {},

/**
 * @method setFontSize
 * @param {unsigned int}
 */
setFontSize : function () {},

/**
 * @method CCMenuItemFont
 * @constructor
 */
CCMenuItemFont : function () {},

};

/**
 * @class CCMenuItemSprite
 */
cc.MenuItemSprite = {

/**
 * @method setEnabled
 * @param {bool}
 */
setEnabled : function () {},

/**
 * @method selected
 */
selected : function () {},

/**
 * @method isOpacityModifyRGB
 * @return A value converted from C/C++ "bool"
 */
isOpacityModifyRGB : function () {},

/**
 * @method setNormalImage
 * @param {cocos2d::CCNode*}
 */
setNormalImage : function () {},

/**
 * @method setDisabledImage
 * @param {cocos2d::CCNode*}
 */
setDisabledImage : function () {},

/**
 * @method setSelectedImage
 * @param {cocos2d::CCNode*}
 */
setSelectedImage : function () {},

/**
 * @method getDisabledImage
 * @return A value converted from C/C++ "cocos2d::CCNode*"
 */
getDisabledImage : function () {},

/**
 * @method setOpacityModifyRGB
 * @param {bool}
 */
setOpacityModifyRGB : function () {},

/**
 * @method getSelectedImage
 * @return A value converted from C/C++ "cocos2d::CCNode*"
 */
getSelectedImage : function () {},

/**
 * @method getNormalImage
 * @return A value converted from C/C++ "cocos2d::CCNode*"
 */
getNormalImage : function () {},

/**
 * @method unselected
 */
unselected : function () {},

/**
 * @method CCMenuItemSprite
 * @constructor
 */
CCMenuItemSprite : function () {},

};

/**
 * @class CCMenuItemImage
 */
cc.MenuItemImage = {

/**
 * @method setDisabledSpriteFrame
 * @param {cocos2d::CCSpriteFrame*}
 */
setDisabledSpriteFrame : function () {},

/**
 * @method setSelectedSpriteFrame
 * @param {cocos2d::CCSpriteFrame*}
 */
setSelectedSpriteFrame : function () {},

/**
 * @method init
 * @return A value converted from C/C++ "bool"
 */
init : function () {},

/**
 * @method setNormalSpriteFrame
 * @param {cocos2d::CCSpriteFrame*}
 */
setNormalSpriteFrame : function () {},

/**
 * @method CCMenuItemImage
 * @constructor
 */
CCMenuItemImage : function () {},

};

/**
 * @class CCMenuItemToggle
 */
cc.MenuItemToggle = {

/**
 * @method setSubItems
 * @param {cocos2d::CCArray*}
 */
setSubItems : function () {},

/**
 * @method initWithItem
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCMenuItem*}
 */
initWithItem : function () {},

/**
 * @method isOpacityModifyRGB
 * @return A value converted from C/C++ "bool"
 */
isOpacityModifyRGB : function () {},

/**
 * @method setSelectedIndex
 * @param {unsigned int}
 */
setSelectedIndex : function () {},

/**
 * @method setEnabled
 * @param {bool}
 */
setEnabled : function () {},

/**
 * @method getSelectedIndex
 * @return A value converted from C/C++ "unsigned int"
 */
getSelectedIndex : function () {},

/**
 * @method addSubItem
 * @param {cocos2d::CCMenuItem*}
 */
addSubItem : function () {},

/**
 * @method selected
 */
selected : function () {},

/**
 * @method setOpacityModifyRGB
 * @param {bool}
 */
setOpacityModifyRGB : function () {},

/**
 * @method activate
 */
activate : function () {},

/**
 * @method unselected
 */
unselected : function () {},

/**
 * @method selectedItem
 * @return A value converted from C/C++ "cocos2d::CCMenuItem*"
 */
selectedItem : function () {},

/**
 * @method CCMenuItemToggle
 * @constructor
 */
CCMenuItemToggle : function () {},

};

/**
 * @class CCMenu
 */
cc.Menu = {

/**
 * @method initWithArray
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCArray*}
 */
initWithArray : function () {},

/**
 * @method alignItemsVertically
 */
alignItemsVertically : function () {},

/**
 * @method ccTouchBegan
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCTouch*}
 * @param {cocos2d::CCEvent*}
 */
ccTouchBegan : function () {},

/**
 * @method ccTouchEnded
 * @param {cocos2d::CCTouch*}
 * @param {cocos2d::CCEvent*}
 */
ccTouchEnded : function () {},

/**
 * @method isOpacityModifyRGB
 * @return A value converted from C/C++ "bool"
 */
isOpacityModifyRGB : function () {},

/**
 * @method isEnabled
 * @return A value converted from C/C++ "bool"
 */
isEnabled : function () {},

/**
 * @method setOpacityModifyRGB
 * @param {bool}
 */
setOpacityModifyRGB : function () {},

/**
 * @method setHandlerPriority
 * @param {int}
 */
setHandlerPriority : function () {},

/**
 * @method init
 * @return A value converted from C/C++ "bool"
 */
init : function () {},

/**
 * @method alignItemsHorizontallyWithPadding
 * @param {float}
 */
alignItemsHorizontallyWithPadding : function () {},

/**
 * @method alignItemsHorizontally
 */
alignItemsHorizontally : function () {},

/**
 * @method setEnabled
 * @param {bool}
 */
setEnabled : function () {},

/**
 * @method ccTouchMoved
 * @param {cocos2d::CCTouch*}
 * @param {cocos2d::CCEvent*}
 */
ccTouchMoved : function () {},

/**
 * @method ccTouchCancelled
 * @param {cocos2d::CCTouch*}
 * @param {cocos2d::CCEvent*}
 */
ccTouchCancelled : function () {},

/**
 * @method removeChild
 * @param {cocos2d::CCNode*}
 * @param {bool}
 */
removeChild : function () {},

/**
 * @method alignItemsVerticallyWithPadding
 * @param {float}
 */
alignItemsVerticallyWithPadding : function () {},

/**
 * @method registerWithTouchDispatcher
 */
registerWithTouchDispatcher : function () {},

/**
 * @method CCMenu
 * @constructor
 */
CCMenu : function () {},

};

/**
 * @class CCProgressTimer
 */
cc.ProgressTimer = {

/**
 * @method setAnchorPoint
 * @param {cocos2d::CCPoint}
 */
setAnchorPoint : function () {},

/**
 * @method draw
 */
draw : function () {},

/**
 * @method isReverseDirection
 * @return A value converted from C/C++ "bool"
 */
isReverseDirection : function () {},

/**
 * @method isOpacityModifyRGB
 * @return A value converted from C/C++ "bool"
 */
isOpacityModifyRGB : function () {},

/**
 * @method setBarChangeRate
 * @param {cocos2d::CCPoint}
 */
setBarChangeRate : function () {},

/**
 * @method getPercentage
 * @return A value converted from C/C++ "float"
 */
getPercentage : function () {},

/**
 * @method setSprite
 * @param {cocos2d::CCSprite*}
 */
setSprite : function () {},

/**
 * @method getType
 * @return A value converted from C/C++ "cocos2d::CCProgressTimerType"
 */
getType : function () {},

/**
 * @method setOpacityModifyRGB
 * @param {bool}
 */
setOpacityModifyRGB : function () {},

/**
 * @method getSprite
 * @return A value converted from C/C++ "cocos2d::CCSprite*"
 */
getSprite : function () {},

/**
 * @method setMidpoint
 * @param {cocos2d::CCPoint}
 */
setMidpoint : function () {},

/**
 * @method getMidpoint
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 */
getMidpoint : function () {},

/**
 * @method getBarChangeRate
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 */
getBarChangeRate : function () {},

/**
 * @method initWithSprite
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCSprite*}
 */
initWithSprite : function () {},

/**
 * @method setPercentage
 * @param {float}
 */
setPercentage : function () {},

/**
 * @method setType
 * @param {cocos2d::CCProgressTimerType}
 */
setType : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCProgressTimer*"
 * @param {cocos2d::CCSprite*}
 */
create : function () {},

/**
 * @method CCProgressTimer
 * @constructor
 */
CCProgressTimer : function () {},

};

/**
 * @class CCRenderTexture
 */
cc.RenderTexture = {

/**
 * @method clearStencil
 * @param {int}
 */
clearStencil : function () {},

/**
 * @method begin
 */
begin : function () {},

/**
 * @method listenToForeground
 * @param {cocos2d::CCObject*}
 */
listenToForeground : function () {},

/**
 * @method getClearDepth
 * @return A value converted from C/C++ "float"
 */
getClearDepth : function () {},

/**
 * @method getClearStencil
 * @return A value converted from C/C++ "int"
 */
getClearStencil : function () {},

/**
 * @method end
 */
end : function () {},

/**
 * @method setClearStencil
 * @param {float}
 */
setClearStencil : function () {},

/**
 * @method visit
 */
visit : function () {},

/**
 * @method getSprite
 * @return A value converted from C/C++ "cocos2d::CCSprite*"
 */
getSprite : function () {},

/**
 * @method isAutoDraw
 * @return A value converted from C/C++ "bool"
 */
isAutoDraw : function () {},

/**
 * @method setClearFlags
 * @param {unsigned int}
 */
setClearFlags : function () {},

/**
 * @method draw
 */
draw : function () {},

/**
 * @method setAutoDraw
 * @param {bool}
 */
setAutoDraw : function () {},

/**
 * @method setClearColor
 * @param {cocos2d::ccColor4F}
 */
setClearColor : function () {},

/**
 * @method endToLua
 */
endToLua : function () {},

/**
 * @method clearDepth
 * @param {float}
 */
clearDepth : function () {},

/**
 * @method getClearColor
 * @return A value converted from C/C++ "cocos2d::ccColor4F"
 */
getClearColor : function () {},

/**
 * @method listenToBackground
 * @param {cocos2d::CCObject*}
 */
listenToBackground : function () {},

/**
 * @method clear
 * @param {float}
 * @param {float}
 * @param {float}
 * @param {float}
 */
clear : function () {},

/**
 * @method getClearFlags
 * @return A value converted from C/C++ "unsigned int"
 */
getClearFlags : function () {},

/**
 * @method newCCImage
 * @return A value converted from C/C++ "cocos2d::CCImage*"
 */
newCCImage : function () {},

/**
 * @method setClearDepth
 * @param {float}
 */
setClearDepth : function () {},

/**
 * @method setSprite
 * @param {cocos2d::CCSprite*}
 */
setSprite : function () {},

/**
 * @method CCRenderTexture
 * @constructor
 */
CCRenderTexture : function () {},

};

/**
 * @class CCParticleBatchNode
 */
cc.ParticleBatchNode = {

/**
 * @method removeChildAtIndex
 * @param {unsigned int}
 * @param {bool}
 */
removeChildAtIndex : function () {},

/**
 * @method draw
 */
draw : function () {},

/**
 * @method setTexture
 * @param {cocos2d::CCTexture2D*}
 */
setTexture : function () {},

/**
 * @method initWithFile
 * @return A value converted from C/C++ "bool"
 * @param {const char*}
 * @param {unsigned int}
 */
initWithFile : function () {},

/**
 * @method disableParticle
 * @param {unsigned int}
 */
disableParticle : function () {},

/**
 * @method getTexture
 * @return A value converted from C/C++ "cocos2d::CCTexture2D*"
 */
getTexture : function () {},

/**
 * @method visit
 */
visit : function () {},

/**
 * @method removeAllChildrenWithCleanup
 * @param {bool}
 */
removeAllChildrenWithCleanup : function () {},

/**
 * @method getTextureAtlas
 * @return A value converted from C/C++ "cocos2d::CCTextureAtlas*"
 */
getTextureAtlas : function () {},

/**
 * @method removeChild
 * @param {cocos2d::CCNode*}
 * @param {bool}
 */
removeChild : function () {},

/**
 * @method insertChild
 * @param {cocos2d::CCParticleSystem*}
 * @param {unsigned int}
 */
insertChild : function () {},

/**
 * @method initWithTexture
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCTexture2D*}
 * @param {unsigned int}
 */
initWithTexture : function () {},

/**
 * @method reorderChild
 * @param {cocos2d::CCNode*}
 * @param {int}
 */
reorderChild : function () {},

/**
 * @method setTextureAtlas
 * @param {cocos2d::CCTextureAtlas*}
 */
setTextureAtlas : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCParticleBatchNode*"
 * @param {const char*}
 * @param {unsigned int}
 */
create : function () {},

/**
 * @method createWithTexture
 * @return A value converted from C/C++ "cocos2d::CCParticleBatchNode*"
 * @param {cocos2d::CCTexture2D*}
 * @param {unsigned int}
 */
createWithTexture : function () {},

/**
 * @method CCParticleBatchNode
 * @constructor
 */
CCParticleBatchNode : function () {},

};

/**
 * @class CCParticleSystem
 */
cc.ParticleSystem = {

/**
 * @method getStartSizeVar
 * @return A value converted from C/C++ "float"
 */
getStartSizeVar : function () {},

/**
 * @method getTexture
 * @return A value converted from C/C++ "cocos2d::CCTexture2D*"
 */
getTexture : function () {},

/**
 * @method isFull
 * @return A value converted from C/C++ "bool"
 */
isFull : function () {},

/**
 * @method getBatchNode
 * @return A value converted from C/C++ "cocos2d::CCParticleBatchNode*"
 */
getBatchNode : function () {},

/**
 * @method getStartColor
 * @return A value converted from C/C++ "cocos2d::ccColor4F"
 */
getStartColor : function () {},

/**
 * @method getPositionType
 * @return A value converted from C/C++ "cocos2d::tCCPositionType"
 */
getPositionType : function () {},

/**
 * @method setPosVar
 * @param {cocos2d::CCPoint}
 */
setPosVar : function () {},

/**
 * @method getEndSpin
 * @return A value converted from C/C++ "float"
 */
getEndSpin : function () {},

/**
 * @method setRotatePerSecondVar
 * @param {float}
 */
setRotatePerSecondVar : function () {},

/**
 * @method getStartSpinVar
 * @return A value converted from C/C++ "float"
 */
getStartSpinVar : function () {},

/**
 * @method getEndSpinVar
 * @return A value converted from C/C++ "float"
 */
getEndSpinVar : function () {},

/**
 * @method stopSystem
 */
stopSystem : function () {},

/**
 * @method init
 * @return A value converted from C/C++ "bool"
 */
init : function () {},

/**
 * @method getEndSizeVar
 * @return A value converted from C/C++ "float"
 */
getEndSizeVar : function () {},

/**
 * @method setRotation
 * @param {float}
 */
setRotation : function () {},

/**
 * @method setTangentialAccel
 * @param {float}
 */
setTangentialAccel : function () {},

/**
 * @method setScaleY
 * @param {float}
 */
setScaleY : function () {},

/**
 * @method setScaleX
 * @param {float}
 */
setScaleX : function () {},

/**
 * @method getRadialAccel
 * @return A value converted from C/C++ "float"
 */
getRadialAccel : function () {},

/**
 * @method setStartRadius
 * @param {float}
 */
setStartRadius : function () {},

/**
 * @method setRotatePerSecond
 * @param {float}
 */
setRotatePerSecond : function () {},

/**
 * @method setEndSize
 * @param {float}
 */
setEndSize : function () {},

/**
 * @method getGravity
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 */
getGravity : function () {},

/**
 * @method getTangentialAccel
 * @return A value converted from C/C++ "float"
 */
getTangentialAccel : function () {},

/**
 * @method setEndRadius
 * @param {float}
 */
setEndRadius : function () {},

/**
 * @method getAngle
 * @return A value converted from C/C++ "float"
 */
getAngle : function () {},

/**
 * @method getSpeed
 * @return A value converted from C/C++ "float"
 */
getSpeed : function () {},

/**
 * @method setEndColor
 * @param {cocos2d::ccColor4F}
 */
setEndColor : function () {},

/**
 * @method setStartSpin
 * @param {float}
 */
setStartSpin : function () {},

/**
 * @method setDuration
 * @param {float}
 */
setDuration : function () {},

/**
 * @method initWithTotalParticles
 * @return A value converted from C/C++ "bool"
 * @param {unsigned int}
 */
initWithTotalParticles : function () {},

/**
 * @method setTexture
 * @param {cocos2d::CCTexture2D*}
 */
setTexture : function () {},

/**
 * @method getPosVar
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 */
getPosVar : function () {},

/**
 * @method updateWithNoTime
 */
updateWithNoTime : function () {},

/**
 * @method isBlendAdditive
 * @return A value converted from C/C++ "bool"
 */
isBlendAdditive : function () {},

/**
 * @method getAngleVar
 * @return A value converted from C/C++ "float"
 */
getAngleVar : function () {},

/**
 * @method setPositionType
 * @param {cocos2d::tCCPositionType}
 */
setPositionType : function () {},

/**
 * @method getEndRadius
 * @return A value converted from C/C++ "float"
 */
getEndRadius : function () {},

/**
 * @method getSourcePosition
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 */
getSourcePosition : function () {},

/**
 * @method setLifeVar
 * @param {float}
 */
setLifeVar : function () {},

/**
 * @method setTotalParticles
 * @param {unsigned int}
 */
setTotalParticles : function () {},

/**
 * @method setEndColorVar
 * @param {cocos2d::ccColor4F}
 */
setEndColorVar : function () {},

/**
 * @method updateQuadWithParticle
 * @param {tCCParticle*}
 * @param {cocos2d::CCPoint}
 */
updateQuadWithParticle : function () {},

/**
 * @method getAtlasIndex
 * @return A value converted from C/C++ "unsigned int"
 */
getAtlasIndex : function () {},

/**
 * @method getStartSize
 * @return A value converted from C/C++ "float"
 */
getStartSize : function () {},

/**
 * @method setStartSpinVar
 * @param {float}
 */
setStartSpinVar : function () {},

/**
 * @method resetSystem
 */
resetSystem : function () {},

/**
 * @method setAtlasIndex
 * @param {unsigned int}
 */
setAtlasIndex : function () {},

/**
 * @method setTangentialAccelVar
 * @param {float}
 */
setTangentialAccelVar : function () {},

/**
 * @method setEndRadiusVar
 * @param {float}
 */
setEndRadiusVar : function () {},

/**
 * @method isActive
 * @return A value converted from C/C++ "bool"
 */
isActive : function () {},

/**
 * @method setRadialAccelVar
 * @param {float}
 */
setRadialAccelVar : function () {},

/**
 * @method setStartSize
 * @param {float}
 */
setStartSize : function () {},

/**
 * @method setSpeed
 * @param {float}
 */
setSpeed : function () {},

/**
 * @method getStartSpin
 * @return A value converted from C/C++ "float"
 */
getStartSpin : function () {},

/**
 * @method getRotatePerSecond
 * @return A value converted from C/C++ "float"
 */
getRotatePerSecond : function () {},

/**
 * @method initParticle
 * @param {tCCParticle*}
 */
initParticle : function () {},

/**
 * @method setEmitterMode
 * @param {int}
 */
setEmitterMode : function () {},

/**
 * @method getDuration
 * @return A value converted from C/C++ "float"
 */
getDuration : function () {},

/**
 * @method setSourcePosition
 * @param {cocos2d::CCPoint}
 */
setSourcePosition : function () {},

/**
 * @method getRadialAccelVar
 * @return A value converted from C/C++ "float"
 */
getRadialAccelVar : function () {},

/**
 * @method setBlendAdditive
 * @param {bool}
 */
setBlendAdditive : function () {},

/**
 * @method setLife
 * @param {float}
 */
setLife : function () {},

/**
 * @method setAngleVar
 * @param {float}
 */
setAngleVar : function () {},

/**
 * @method setRotationIsDir
 * @param {bool}
 */
setRotationIsDir : function () {},

/**
 * @method setEndSizeVar
 * @param {float}
 */
setEndSizeVar : function () {},

/**
 * @method setAngle
 * @param {float}
 */
setAngle : function () {},

/**
 * @method setBatchNode
 * @param {cocos2d::CCParticleBatchNode*}
 */
setBatchNode : function () {},

/**
 * @method getTangentialAccelVar
 * @return A value converted from C/C++ "float"
 */
getTangentialAccelVar : function () {},

/**
 * @method getEmitterMode
 * @return A value converted from C/C++ "int"
 */
getEmitterMode : function () {},

/**
 * @method setEndSpinVar
 * @param {float}
 */
setEndSpinVar : function () {},

/**
 * @method initWithFile
 * @return A value converted from C/C++ "bool"
 * @param {const char*}
 */
initWithFile : function () {},

/**
 * @method getSpeedVar
 * @return A value converted from C/C++ "float"
 */
getSpeedVar : function () {},

/**
 * @method setStartColor
 * @param {cocos2d::ccColor4F}
 */
setStartColor : function () {},

/**
 * @method getRotatePerSecondVar
 * @return A value converted from C/C++ "float"
 */
getRotatePerSecondVar : function () {},

/**
 * @method getEndSize
 * @return A value converted from C/C++ "float"
 */
getEndSize : function () {},

/**
 * @method getLife
 * @return A value converted from C/C++ "float"
 */
getLife : function () {},

/**
 * @method setSpeedVar
 * @param {float}
 */
setSpeedVar : function () {},

/**
 * @method setAutoRemoveOnFinish
 * @param {bool}
 */
setAutoRemoveOnFinish : function () {},

/**
 * @method setGravity
 * @param {cocos2d::CCPoint}
 */
setGravity : function () {},

/**
 * @method postStep
 */
postStep : function () {},

/**
 * @method setEmissionRate
 * @param {float}
 */
setEmissionRate : function () {},

/**
 * @method getEndColorVar
 * @return A value converted from C/C++ "cocos2d::ccColor4F"
 */
getEndColorVar : function () {},

/**
 * @method getRotationIsDir
 * @return A value converted from C/C++ "bool"
 */
getRotationIsDir : function () {},

/**
 * @method setScale
 * @param {float}
 */
setScale : function () {},

/**
 * @method getEmissionRate
 * @return A value converted from C/C++ "float"
 */
getEmissionRate : function () {},

/**
 * @method getEndColor
 * @return A value converted from C/C++ "cocos2d::ccColor4F"
 */
getEndColor : function () {},

/**
 * @method getLifeVar
 * @return A value converted from C/C++ "float"
 */
getLifeVar : function () {},

/**
 * @method setStartSizeVar
 * @param {float}
 */
setStartSizeVar : function () {},

/**
 * @method setOpacityModifyRGB
 * @param {bool}
 */
setOpacityModifyRGB : function () {},

/**
 * @method addParticle
 * @return A value converted from C/C++ "bool"
 */
addParticle : function () {},

/**
 * @method getOpacityModifyRGB
 * @return A value converted from C/C++ "bool"
 */
getOpacityModifyRGB : function () {},

/**
 * @method getStartRadius
 * @return A value converted from C/C++ "float"
 */
getStartRadius : function () {},

/**
 * @method getParticleCount
 * @return A value converted from C/C++ "unsigned int"
 */
getParticleCount : function () {},

/**
 * @method getStartRadiusVar
 * @return A value converted from C/C++ "float"
 */
getStartRadiusVar : function () {},

/**
 * @method setStartColorVar
 * @param {cocos2d::ccColor4F}
 */
setStartColorVar : function () {},

/**
 * @method setEndSpin
 * @param {float}
 */
setEndSpin : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method setRadialAccel
 * @param {float}
 */
setRadialAccel : function () {},

/**
 * @method isAutoRemoveOnFinish
 * @return A value converted from C/C++ "bool"
 */
isAutoRemoveOnFinish : function () {},

/**
 * @method getTotalParticles
 * @return A value converted from C/C++ "unsigned int"
 */
getTotalParticles : function () {},

/**
 * @method setStartRadiusVar
 * @param {float}
 */
setStartRadiusVar : function () {},

/**
 * @method getEndRadiusVar
 * @return A value converted from C/C++ "float"
 */
getEndRadiusVar : function () {},

/**
 * @method getStartColorVar
 * @return A value converted from C/C++ "cocos2d::ccColor4F"
 */
getStartColorVar : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCParticleSystem*"
 * @param {const char*}
 */
create : function () {},

/**
 * @method createWithTotalParticles
 * @return A value converted from C/C++ "cocos2d::CCParticleSystem*"
 * @param {unsigned int}
 */
createWithTotalParticles : function () {},

/**
 * @method CCParticleSystem
 * @constructor
 */
CCParticleSystem : function () {},

};

/**
 * @class CCParticleSystemQuad
 */
cc.ParticleSystem = {

/**
 * @method initTexCoordsWithRect
 * @param {cocos2d::CCRect}
 */
initTexCoordsWithRect : function () {},

/**
 * @method setTextureWithRect
 * @param {cocos2d::CCTexture2D*}
 * @param {cocos2d::CCRect}
 */
setTextureWithRect : function () {},

/**
 * @method initIndices
 */
initIndices : function () {},

/**
 * @method setDisplayFrame
 * @param {cocos2d::CCSpriteFrame*}
 */
setDisplayFrame : function () {},

/**
 * @method createWithTotalParticles
 * @return A value converted from C/C++ "cocos2d::CCParticleSystemQuad*"
 * @param {unsigned int}
 */
createWithTotalParticles : function () {},

/**
 * @method CCParticleSystemQuad
 * @constructor
 */
CCParticleSystemQuad : function () {},

};

/**
 * @class CCParticleFire
 */
cc.ParticleFire = {

/**
 * @method init
 * @return A value converted from C/C++ "bool"
 */
init : function () {},

/**
 * @method initWithTotalParticles
 * @return A value converted from C/C++ "bool"
 * @param {unsigned int}
 */
initWithTotalParticles : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCParticleFire*"
 */
create : function () {},

/**
 * @method createWithTotalParticles
 * @return A value converted from C/C++ "cocos2d::CCParticleFire*"
 * @param {unsigned int}
 */
createWithTotalParticles : function () {},

/**
 * @method CCParticleFire
 * @constructor
 */
CCParticleFire : function () {},

};

/**
 * @class CCParticleFireworks
 */
cc.ParticleFireworks = {

/**
 * @method init
 * @return A value converted from C/C++ "bool"
 */
init : function () {},

/**
 * @method initWithTotalParticles
 * @return A value converted from C/C++ "bool"
 * @param {unsigned int}
 */
initWithTotalParticles : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCParticleFireworks*"
 */
create : function () {},

/**
 * @method createWithTotalParticles
 * @return A value converted from C/C++ "cocos2d::CCParticleFireworks*"
 * @param {unsigned int}
 */
createWithTotalParticles : function () {},

/**
 * @method CCParticleFireworks
 * @constructor
 */
CCParticleFireworks : function () {},

};

/**
 * @class CCParticleSun
 */
cc.ParticleSun = {

/**
 * @method init
 * @return A value converted from C/C++ "bool"
 */
init : function () {},

/**
 * @method initWithTotalParticles
 * @return A value converted from C/C++ "bool"
 * @param {unsigned int}
 */
initWithTotalParticles : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCParticleSun*"
 */
create : function () {},

/**
 * @method createWithTotalParticles
 * @return A value converted from C/C++ "cocos2d::CCParticleSun*"
 * @param {unsigned int}
 */
createWithTotalParticles : function () {},

/**
 * @method CCParticleSun
 * @constructor
 */
CCParticleSun : function () {},

};

/**
 * @class CCParticleGalaxy
 */
cc.ParticleGalaxy = {

/**
 * @method init
 * @return A value converted from C/C++ "bool"
 */
init : function () {},

/**
 * @method initWithTotalParticles
 * @return A value converted from C/C++ "bool"
 * @param {unsigned int}
 */
initWithTotalParticles : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCParticleGalaxy*"
 */
create : function () {},

/**
 * @method createWithTotalParticles
 * @return A value converted from C/C++ "cocos2d::CCParticleGalaxy*"
 * @param {unsigned int}
 */
createWithTotalParticles : function () {},

/**
 * @method CCParticleGalaxy
 * @constructor
 */
CCParticleGalaxy : function () {},

};

/**
 * @class CCParticleFlower
 */
cc.ParticleFlower = {

/**
 * @method init
 * @return A value converted from C/C++ "bool"
 */
init : function () {},

/**
 * @method initWithTotalParticles
 * @return A value converted from C/C++ "bool"
 * @param {unsigned int}
 */
initWithTotalParticles : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCParticleFlower*"
 */
create : function () {},

/**
 * @method createWithTotalParticles
 * @return A value converted from C/C++ "cocos2d::CCParticleFlower*"
 * @param {unsigned int}
 */
createWithTotalParticles : function () {},

/**
 * @method CCParticleFlower
 * @constructor
 */
CCParticleFlower : function () {},

};

/**
 * @class CCParticleMeteor
 */
cc.ParticleMeteor = {

/**
 * @method init
 * @return A value converted from C/C++ "bool"
 */
init : function () {},

/**
 * @method initWithTotalParticles
 * @return A value converted from C/C++ "bool"
 * @param {unsigned int}
 */
initWithTotalParticles : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCParticleMeteor*"
 */
create : function () {},

/**
 * @method createWithTotalParticles
 * @return A value converted from C/C++ "cocos2d::CCParticleMeteor*"
 * @param {unsigned int}
 */
createWithTotalParticles : function () {},

/**
 * @method CCParticleMeteor
 * @constructor
 */
CCParticleMeteor : function () {},

};

/**
 * @class CCParticleSpiral
 */
cc.ParticleSpiral = {

/**
 * @method init
 * @return A value converted from C/C++ "bool"
 */
init : function () {},

/**
 * @method initWithTotalParticles
 * @return A value converted from C/C++ "bool"
 * @param {unsigned int}
 */
initWithTotalParticles : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCParticleSpiral*"
 */
create : function () {},

/**
 * @method createWithTotalParticles
 * @return A value converted from C/C++ "cocos2d::CCParticleSpiral*"
 * @param {unsigned int}
 */
createWithTotalParticles : function () {},

/**
 * @method CCParticleSpiral
 * @constructor
 */
CCParticleSpiral : function () {},

};

/**
 * @class CCParticleExplosion
 */
cc.ParticleExplosion = {

/**
 * @method init
 * @return A value converted from C/C++ "bool"
 */
init : function () {},

/**
 * @method initWithTotalParticles
 * @return A value converted from C/C++ "bool"
 * @param {unsigned int}
 */
initWithTotalParticles : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCParticleExplosion*"
 */
create : function () {},

/**
 * @method createWithTotalParticles
 * @return A value converted from C/C++ "cocos2d::CCParticleExplosion*"
 * @param {unsigned int}
 */
createWithTotalParticles : function () {},

/**
 * @method CCParticleExplosion
 * @constructor
 */
CCParticleExplosion : function () {},

};

/**
 * @class CCParticleSmoke
 */
cc.ParticleSmoke = {

/**
 * @method init
 * @return A value converted from C/C++ "bool"
 */
init : function () {},

/**
 * @method initWithTotalParticles
 * @return A value converted from C/C++ "bool"
 * @param {unsigned int}
 */
initWithTotalParticles : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCParticleSmoke*"
 */
create : function () {},

/**
 * @method createWithTotalParticles
 * @return A value converted from C/C++ "cocos2d::CCParticleSmoke*"
 * @param {unsigned int}
 */
createWithTotalParticles : function () {},

/**
 * @method CCParticleSmoke
 * @constructor
 */
CCParticleSmoke : function () {},

};

/**
 * @class CCParticleSnow
 */
cc.ParticleSnow = {

/**
 * @method init
 * @return A value converted from C/C++ "bool"
 */
init : function () {},

/**
 * @method initWithTotalParticles
 * @return A value converted from C/C++ "bool"
 * @param {unsigned int}
 */
initWithTotalParticles : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCParticleSnow*"
 */
create : function () {},

/**
 * @method createWithTotalParticles
 * @return A value converted from C/C++ "cocos2d::CCParticleSnow*"
 * @param {unsigned int}
 */
createWithTotalParticles : function () {},

/**
 * @method CCParticleSnow
 * @constructor
 */
CCParticleSnow : function () {},

};

/**
 * @class CCParticleRain
 */
cc.ParticleRain = {

/**
 * @method init
 * @return A value converted from C/C++ "bool"
 */
init : function () {},

/**
 * @method initWithTotalParticles
 * @return A value converted from C/C++ "bool"
 * @param {unsigned int}
 */
initWithTotalParticles : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCParticleRain*"
 */
create : function () {},

/**
 * @method createWithTotalParticles
 * @return A value converted from C/C++ "cocos2d::CCParticleRain*"
 * @param {unsigned int}
 */
createWithTotalParticles : function () {},

/**
 * @method CCParticleRain
 * @constructor
 */
CCParticleRain : function () {},

};

/**
 * @class CCFileUtils
 */
cc.FileUtils = {

/**
 * @method isFileExist
 * @return A value converted from C/C++ "bool"
 * @param {std::string}
 */
isFileExist : function () {},

/**
 * @method isPopupNotify
 * @return A value converted from C/C++ "bool"
 */
isPopupNotify : function () {},

/**
 * @method purgeCachedEntries
 */
purgeCachedEntries : function () {},

/**
 * @method fullPathFromRelativeFile
 * @return A value converted from C/C++ "const char*"
 * @param {const char*}
 * @param {const char*}
 */
fullPathFromRelativeFile : function () {},

/**
 * @method getFileData
 * @return A value converted from C/C++ "unsigned char*"
 * @param {const char*}
 * @param {const char*}
 * @param {unsigned long*}
 */
getFileData : function () {},

/**
 * @method setFilenameLookupDictionary
 * @param {cocos2d::CCDictionary*}
 */
setFilenameLookupDictionary : function () {},

/**
 * @method addSearchResolutionsOrder
 * @param {const char*}
 */
addSearchResolutionsOrder : function () {},

/**
 * @method getFileDataFromZip
 * @return A value converted from C/C++ "unsigned char*"
 * @param {const char*}
 * @param {const char*}
 * @param {unsigned long*}
 */
getFileDataFromZip : function () {},

/**
 * @method fullPathForFilename
 * @return A value converted from C/C++ "std::string"
 * @param {const char*}
 */
fullPathForFilename : function () {},

/**
 * @method isAbsolutePath
 * @return A value converted from C/C++ "bool"
 * @param {std::string}
 */
isAbsolutePath : function () {},

/**
 * @method getWritablePath
 * @return A value converted from C/C++ "std::string"
 */
getWritablePath : function () {},

/**
 * @method addSearchPath
 * @param {const char*}
 */
addSearchPath : function () {},

/**
 * @method setPopupNotify
 * @param {bool}
 */
setPopupNotify : function () {},

/**
 * @method loadFilenameLookupDictionaryFromFile
 * @param {const char*}
 */
loadFilenameLookupDictionaryFromFile : function () {},

/**
 * @method purgeFileUtils
 */
purgeFileUtils : function () {},

/**
 * @method sharedFileUtils
 * @return A value converted from C/C++ "cocos2d::CCFileUtils*"
 */
sharedFileUtils : function () {},

};

/**
 * @class CCApplication
 */
cc.Application = {

/**
 * @method getTargetPlatform
 * @return A value converted from C/C++ "cocos2d::TargetPlatform"
 */
getTargetPlatform : function () {},

/**
 * @method setAnimationInterval
 * @param {double}
 */
setAnimationInterval : function () {},

/**
 * @method getCurrentLanguage
 * @return A value converted from C/C++ "cocos2d::ccLanguageType"
 */
getCurrentLanguage : function () {},

/**
 * @method sharedApplication
 * @return A value converted from C/C++ "cocos2d::CCApplication*"
 */
sharedApplication : function () {},

};

/**
 * @class CCShaderCache
 */
cc.ShaderCache = {

/**
 * @method reloadDefaultShaders
 */
reloadDefaultShaders : function () {},

/**
 * @method addProgram
 * @param {cocos2d::CCGLProgram*}
 * @param {const char*}
 */
addProgram : function () {},

/**
 * @method programForKey
 * @return A value converted from C/C++ "cocos2d::CCGLProgram*"
 * @param {const char*}
 */
programForKey : function () {},

/**
 * @method loadDefaultShaders
 */
loadDefaultShaders : function () {},

/**
 * @method sharedShaderCache
 * @return A value converted from C/C++ "cocos2d::CCShaderCache*"
 */
sharedShaderCache : function () {},

/**
 * @method purgeSharedShaderCache
 */
purgeSharedShaderCache : function () {},

/**
 * @method CCShaderCache
 * @constructor
 */
CCShaderCache : function () {},

};

/**
 * @class CCAnimationCache
 */
cc.AnimationCache = {

/**
 * @method animationByName
 * @return A value converted from C/C++ "cocos2d::CCAnimation*"
 * @param {const char*}
 */
animationByName : function () {},

/**
 * @method addAnimationsWithFile
 * @param {const char*}
 */
addAnimationsWithFile : function () {},

/**
 * @method init
 * @return A value converted from C/C++ "bool"
 */
init : function () {},

/**
 * @method addAnimationsWithDictionary
 * @param {cocos2d::CCDictionary*}
 */
addAnimationsWithDictionary : function () {},

/**
 * @method removeAnimationByName
 * @param {const char*}
 */
removeAnimationByName : function () {},

/**
 * @method addAnimation
 * @param {cocos2d::CCAnimation*}
 * @param {const char*}
 */
addAnimation : function () {},

/**
 * @method purgeSharedAnimationCache
 */
purgeSharedAnimationCache : function () {},

/**
 * @method sharedAnimationCache
 * @return A value converted from C/C++ "cocos2d::CCAnimationCache*"
 */
sharedAnimationCache : function () {},

/**
 * @method CCAnimationCache
 * @constructor
 */
CCAnimationCache : function () {},

};

/**
 * @class CCSpriteFrameCache
 */
cc.SpriteFrameCache = {

/**
 * @method addSpriteFrame
 * @param {cocos2d::CCSpriteFrame*}
 * @param {const char*}
 */
addSpriteFrame : function () {},

/**
 * @method removeUnusedSpriteFrames
 */
removeUnusedSpriteFrames : function () {},

/**
 * @method spriteFrameByName
 * @return A value converted from C/C++ "cocos2d::CCSpriteFrame*"
 * @param {const char*}
 */
spriteFrameByName : function () {},

/**
 * @method removeSpriteFramesFromFile
 * @param {const char*}
 */
removeSpriteFramesFromFile : function () {},

/**
 * @method init
 * @return A value converted from C/C++ "bool"
 */
init : function () {},

/**
 * @method removeSpriteFrames
 */
removeSpriteFrames : function () {},

/**
 * @method removeSpriteFramesFromTexture
 * @param {cocos2d::CCTexture2D*}
 */
removeSpriteFramesFromTexture : function () {},

/**
 * @method removeSpriteFrameByName
 * @param {const char*}
 */
removeSpriteFrameByName : function () {},

/**
 * @method purgeSharedSpriteFrameCache
 */
purgeSharedSpriteFrameCache : function () {},

/**
 * @method sharedSpriteFrameCache
 * @return A value converted from C/C++ "cocos2d::CCSpriteFrameCache*"
 */
sharedSpriteFrameCache : function () {},

};

/**
 * @class CCTextureCache
 */
cc.TextureCache = {

/**
 * @method dumpCachedTextureInfo
 */
dumpCachedTextureInfo : function () {},

/**
 * @method addUIImage
 * @return A value converted from C/C++ "cocos2d::CCTexture2D*"
 * @param {cocos2d::CCImage*}
 * @param {const char*}
 */
addUIImage : function () {},

/**
 * @method removeTextureForKey
 * @param {const char*}
 */
removeTextureForKey : function () {},

/**
 * @method textureForKey
 * @return A value converted from C/C++ "cocos2d::CCTexture2D*"
 * @param {const char*}
 */
textureForKey : function () {},

/**
 * @method snapshotTextures
 * @return A value converted from C/C++ "cocos2d::CCDictionary*"
 */
snapshotTextures : function () {},

/**
 * @method addPVRImage
 * @return A value converted from C/C++ "cocos2d::CCTexture2D*"
 * @param {const char*}
 */
addPVRImage : function () {},

/**
 * @method addImage
 * @return A value converted from C/C++ "cocos2d::CCTexture2D*"
 * @param {const char*}
 */
addImage : function () {},

/**
 * @method removeAllTextures
 */
removeAllTextures : function () {},

/**
 * @method removeUnusedTextures
 */
removeUnusedTextures : function () {},

/**
 * @method removeTexture
 * @param {cocos2d::CCTexture2D*}
 */
removeTexture : function () {},

/**
 * @method purgeSharedTextureCache
 */
purgeSharedTextureCache : function () {},

/**
 * @method reloadAllTextures
 */
reloadAllTextures : function () {},

/**
 * @method sharedTextureCache
 * @return A value converted from C/C++ "cocos2d::CCTextureCache*"
 */
sharedTextureCache : function () {},

/**
 * @method CCTextureCache
 * @constructor
 */
CCTextureCache : function () {},

};

/**
 * @class CCParallaxNode
 */
cc.ParallaxNode = {

/**
 * @method visit
 */
visit : function () {},

/**
 * @method removeAllChildrenWithCleanup
 * @param {bool}
 */
removeAllChildrenWithCleanup : function () {},

/**
 * @method removeChild
 * @param {cocos2d::CCNode*}
 * @param {bool}
 */
removeChild : function () {},

/**
 * @method getParallaxArray
 * @return A value converted from C/C++ "_ccArray*"
 */
getParallaxArray : function () {},

/**
 * @method setParallaxArray
 * @param {_ccArray*}
 */
setParallaxArray : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCParallaxNode*"
 */
create : function () {},

/**
 * @method CCParallaxNode
 * @constructor
 */
CCParallaxNode : function () {},

};

/**
 * @class CCTMXObjectGroup
 */
cc.TMXObjectGroup = {

/**
 * @method setPositionOffset
 * @param {cocos2d::CCPoint}
 */
setPositionOffset : function () {},

/**
 * @method objectNamed
 * @return A value converted from C/C++ "cocos2d::CCDictionary*"
 * @param {const char*}
 */
objectNamed : function () {},

/**
 * @method getPositionOffset
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 */
getPositionOffset : function () {},

/**
 * @method getObjects
 * @return A value converted from C/C++ "cocos2d::CCArray*"
 */
getObjects : function () {},

/**
 * @method setGroupName
 * @param {const char*}
 */
setGroupName : function () {},

/**
 * @method getProperties
 * @return A value converted from C/C++ "cocos2d::CCDictionary*"
 */
getProperties : function () {},

/**
 * @method getGroupName
 * @return A value converted from C/C++ "const char*"
 */
getGroupName : function () {},

/**
 * @method setProperties
 * @param {cocos2d::CCDictionary*}
 */
setProperties : function () {},

/**
 * @method propertyNamed
 * @return A value converted from C/C++ "cocos2d::CCString*"
 * @param {const char*}
 */
propertyNamed : function () {},

/**
 * @method setObjects
 * @param {cocos2d::CCArray*}
 */
setObjects : function () {},

/**
 * @method CCTMXObjectGroup
 * @constructor
 */
CCTMXObjectGroup : function () {},

};

/**
 * @class CCTMXLayerInfo
 */
cc.TMXLayerInfo = {

/**
 * @method setProperties
 * @param {cocos2d::CCDictionary*}
 */
setProperties : function () {},

/**
 * @method getProperties
 * @return A value converted from C/C++ "cocos2d::CCDictionary*"
 */
getProperties : function () {},

/**
 * @method CCTMXLayerInfo
 * @constructor
 */
CCTMXLayerInfo : function () {},

};

/**
 * @class CCTMXTilesetInfo
 */
cc.TMXTilesetInfo = {

/**
 * @method rectForGID
 * @return A value converted from C/C++ "cocos2d::CCRect"
 * @param {unsigned int}
 */
rectForGID : function () {},

/**
 * @method CCTMXTilesetInfo
 * @constructor
 */
CCTMXTilesetInfo : function () {},

};

/**
 * @class CCTMXMapInfo
 */
cc.TMXMapInfo = {

/**
 * @method getTileProperties
 * @return A value converted from C/C++ "cocos2d::CCDictionary*"
 */
getTileProperties : function () {},

/**
 * @method setObjectGroups
 * @param {cocos2d::CCArray*}
 */
setObjectGroups : function () {},

/**
 * @method setTileSize
 * @param {cocos2d::CCSize}
 */
setTileSize : function () {},

/**
 * @method initWithTMXFile
 * @return A value converted from C/C++ "bool"
 * @param {const char*}
 */
initWithTMXFile : function () {},

/**
 * @method getOrientation
 * @return A value converted from C/C++ "int"
 */
getOrientation : function () {},

/**
 * @method setTMXFileName
 * @param {const char*}
 */
setTMXFileName : function () {},

/**
 * @method setLayers
 * @param {cocos2d::CCArray*}
 */
setLayers : function () {},

/**
 * @method setStoringCharacters
 * @param {bool}
 */
setStoringCharacters : function () {},

/**
 * @method getStoringCharacters
 * @return A value converted from C/C++ "bool"
 */
getStoringCharacters : function () {},

/**
 * @method getParentElement
 * @return A value converted from C/C++ "int"
 */
getParentElement : function () {},

/**
 * @method getLayerAttribs
 * @return A value converted from C/C++ "int"
 */
getLayerAttribs : function () {},

/**
 * @method getLayers
 * @return A value converted from C/C++ "cocos2d::CCArray*"
 */
getLayers : function () {},

/**
 * @method getTilesets
 * @return A value converted from C/C++ "cocos2d::CCArray*"
 */
getTilesets : function () {},

/**
 * @method getParentGID
 * @return A value converted from C/C++ "unsigned int"
 */
getParentGID : function () {},

/**
 * @method setParentElement
 * @param {int}
 */
setParentElement : function () {},

/**
 * @method setProperties
 * @param {cocos2d::CCDictionary*}
 */
setProperties : function () {},

/**
 * @method setParentGID
 * @param {unsigned int}
 */
setParentGID : function () {},

/**
 * @method parseXMLString
 * @return A value converted from C/C++ "bool"
 * @param {const char*}
 */
parseXMLString : function () {},

/**
 * @method getTileSize
 * @return A value converted from C/C++ "cocos2d::CCSize"
 */
getTileSize : function () {},

/**
 * @method getObjectGroups
 * @return A value converted from C/C++ "cocos2d::CCArray*"
 */
getObjectGroups : function () {},

/**
 * @method setLayerAttribs
 * @param {int}
 */
setLayerAttribs : function () {},

/**
 * @method getTMXFileName
 * @return A value converted from C/C++ "const char*"
 */
getTMXFileName : function () {},

/**
 * @method setCurrentString
 * @param {const char*}
 */
setCurrentString : function () {},

/**
 * @method initWithXML
 * @return A value converted from C/C++ "bool"
 * @param {const char*}
 * @param {const char*}
 */
initWithXML : function () {},

/**
 * @method setOrientation
 * @param {int}
 */
setOrientation : function () {},

/**
 * @method setTileProperties
 * @param {cocos2d::CCDictionary*}
 */
setTileProperties : function () {},

/**
 * @method setMapSize
 * @param {cocos2d::CCSize}
 */
setMapSize : function () {},

/**
 * @method parseXMLFile
 * @return A value converted from C/C++ "bool"
 * @param {const char*}
 */
parseXMLFile : function () {},

/**
 * @method getMapSize
 * @return A value converted from C/C++ "cocos2d::CCSize"
 */
getMapSize : function () {},

/**
 * @method setTilesets
 * @param {cocos2d::CCArray*}
 */
setTilesets : function () {},

/**
 * @method getProperties
 * @return A value converted from C/C++ "cocos2d::CCDictionary*"
 */
getProperties : function () {},

/**
 * @method getCurrentString
 * @return A value converted from C/C++ "const char*"
 */
getCurrentString : function () {},

/**
 * @method formatWithTMXFile
 * @return A value converted from C/C++ "cocos2d::CCTMXMapInfo*"
 * @param {const char*}
 */
formatWithTMXFile : function () {},

/**
 * @method formatWithXML
 * @return A value converted from C/C++ "cocos2d::CCTMXMapInfo*"
 * @param {const char*}
 * @param {const char*}
 */
formatWithXML : function () {},

/**
 * @method CCTMXMapInfo
 * @constructor
 */
CCTMXMapInfo : function () {},

};

/**
 * @class CCTMXLayer
 */
cc.TMXLayer = {

/**
 * @method addChild
 * @param {cocos2d::CCNode*}
 * @param {int}
 * @param {int}
 */
addChild : function () {},

/**
 * @method positionAt
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 * @param {cocos2d::CCPoint}
 */
positionAt : function () {},

/**
 * @method setLayerOrientation
 * @param {unsigned int}
 */
setLayerOrientation : function () {},

/**
 * @method getTiles
 * @return A value converted from C/C++ "unsigned int*"
 */
getTiles : function () {},

/**
 * @method releaseMap
 */
releaseMap : function () {},

/**
 * @method setTiles
 * @param {unsigned int*}
 */
setTiles : function () {},

/**
 * @method getLayerSize
 * @return A value converted from C/C++ "cocos2d::CCSize"
 */
getLayerSize : function () {},

/**
 * @method setMapTileSize
 * @param {cocos2d::CCSize}
 */
setMapTileSize : function () {},

/**
 * @method getLayerOrientation
 * @return A value converted from C/C++ "unsigned int"
 */
getLayerOrientation : function () {},

/**
 * @method setProperties
 * @param {cocos2d::CCDictionary*}
 */
setProperties : function () {},

/**
 * @method setLayerName
 * @param {const char*}
 */
setLayerName : function () {},

/**
 * @method removeTileAt
 * @param {cocos2d::CCPoint}
 */
removeTileAt : function () {},

/**
 * @method initWithTilesetInfo
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCTMXTilesetInfo*}
 * @param {cocos2d::CCTMXLayerInfo*}
 * @param {cocos2d::CCTMXMapInfo*}
 */
initWithTilesetInfo : function () {},

/**
 * @method setupTiles
 */
setupTiles : function () {},

/**
 * @method getMapTileSize
 * @return A value converted from C/C++ "cocos2d::CCSize"
 */
getMapTileSize : function () {},

/**
 * @method propertyNamed
 * @return A value converted from C/C++ "cocos2d::CCString*"
 * @param {const char*}
 */
propertyNamed : function () {},

/**
 * @method setLayerSize
 * @param {cocos2d::CCSize}
 */
setLayerSize : function () {},

/**
 * @method getLayerName
 * @return A value converted from C/C++ "const char*"
 */
getLayerName : function () {},

/**
 * @method setTileSet
 * @param {cocos2d::CCTMXTilesetInfo*}
 */
setTileSet : function () {},

/**
 * @method removeChild
 * @param {cocos2d::CCNode*}
 * @param {bool}
 */
removeChild : function () {},

/**
 * @method getTileSet
 * @return A value converted from C/C++ "cocos2d::CCTMXTilesetInfo*"
 */
getTileSet : function () {},

/**
 * @method getProperties
 * @return A value converted from C/C++ "cocos2d::CCDictionary*"
 */
getProperties : function () {},

/**
 * @method tileAt
 * @return A value converted from C/C++ "cocos2d::CCSprite*"
 * @param {cocos2d::CCPoint}
 */
tileAt : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTMXLayer*"
 * @param {cocos2d::CCTMXTilesetInfo*}
 * @param {cocos2d::CCTMXLayerInfo*}
 * @param {cocos2d::CCTMXMapInfo*}
 */
create : function () {},

/**
 * @method CCTMXLayer
 * @constructor
 */
CCTMXLayer : function () {},

};

/**
 * @class CCTMXTiledMap
 */
cc.TMXTiledMap = {

/**
 * @method propertiesForGID
 * @return A value converted from C/C++ "cocos2d::CCDictionary*"
 * @param {int}
 */
propertiesForGID : function () {},

/**
 * @method setObjectGroups
 * @param {cocos2d::CCArray*}
 */
setObjectGroups : function () {},

/**
 * @method setTileSize
 * @param {cocos2d::CCSize}
 */
setTileSize : function () {},

/**
 * @method setMapSize
 * @param {cocos2d::CCSize}
 */
setMapSize : function () {},

/**
 * @method getTileSize
 * @return A value converted from C/C++ "cocos2d::CCSize"
 */
getTileSize : function () {},

/**
 * @method getObjectGroups
 * @return A value converted from C/C++ "cocos2d::CCArray*"
 */
getObjectGroups : function () {},

/**
 * @method initWithXML
 * @return A value converted from C/C++ "bool"
 * @param {const char*}
 * @param {const char*}
 */
initWithXML : function () {},

/**
 * @method initWithTMXFile
 * @return A value converted from C/C++ "bool"
 * @param {const char*}
 */
initWithTMXFile : function () {},

/**
 * @method objectGroupNamed
 * @return A value converted from C/C++ "cocos2d::CCTMXObjectGroup*"
 * @param {const char*}
 */
objectGroupNamed : function () {},

/**
 * @method getMapSize
 * @return A value converted from C/C++ "cocos2d::CCSize"
 */
getMapSize : function () {},

/**
 * @method getProperties
 * @return A value converted from C/C++ "cocos2d::CCDictionary*"
 */
getProperties : function () {},

/**
 * @method setMapOrientation
 * @param {int}
 */
setMapOrientation : function () {},

/**
 * @method setProperties
 * @param {cocos2d::CCDictionary*}
 */
setProperties : function () {},

/**
 * @method layerNamed
 * @return A value converted from C/C++ "cocos2d::CCTMXLayer*"
 * @param {const char*}
 */
layerNamed : function () {},

/**
 * @method getMapOrientation
 * @return A value converted from C/C++ "int"
 */
getMapOrientation : function () {},

/**
 * @method propertyNamed
 * @return A value converted from C/C++ "cocos2d::CCString*"
 * @param {const char*}
 */
propertyNamed : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTMXTiledMap*"
 * @param {const char*}
 */
create : function () {},

/**
 * @method createWithXML
 * @return A value converted from C/C++ "cocos2d::CCTMXTiledMap*"
 * @param {const char*}
 * @param {const char*}
 */
createWithXML : function () {},

/**
 * @method CCTMXTiledMap
 * @constructor
 */
CCTMXTiledMap : function () {},

};

/**
 * @class CCTileMapAtlas
 */
cc.TileMapAtlas = {

/**
 * @method initWithTileFile
 * @return A value converted from C/C++ "bool"
 * @param {const char*}
 * @param {const char*}
 * @param {int}
 * @param {int}
 */
initWithTileFile : function () {},

/**
 * @method releaseMap
 */
releaseMap : function () {},

/**
 * @method getTGAInfo
 * @return A value converted from C/C++ "sImageTGA*"
 */
getTGAInfo : function () {},

/**
 * @method tileAt
 * @return A value converted from C/C++ "ccColor3B"
 * @param {cocos2d::CCPoint}
 */
tileAt : function () {},

/**
 * @method setTile
 * @param {cocos2d::ccColor3B}
 * @param {cocos2d::CCPoint}
 */
setTile : function () {},

/**
 * @method setTGAInfo
 * @param {sImageTGA*}
 */
setTGAInfo : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::CCTileMapAtlas*"
 * @param {const char*}
 * @param {const char*}
 * @param {int}
 * @param {int}
 */
create : function () {},

/**
 * @method CCTileMapAtlas
 * @constructor
 */
CCTileMapAtlas : function () {},

};

/**
 * @class CCTimer
 */
cc.Timer = {

/**
 * @method getInterval
 * @return A value converted from C/C++ "float"
 */
getInterval : function () {},

/**
 * @method setInterval
 * @param {float}
 */
setInterval : function () {},

/**
 * @method initWithScriptHandler
 * @return A value converted from C/C++ "bool"
 * @param {int}
 * @param {float}
 */
initWithScriptHandler : function () {},

/**
 * @method update
 * @param {float}
 */
update : function () {},

/**
 * @method getScriptHandler
 * @return A value converted from C/C++ "int"
 */
getScriptHandler : function () {},

/**
 * @method timerWithScriptHandler
 * @return A value converted from C/C++ "cocos2d::CCTimer*"
 * @param {int}
 * @param {float}
 */
timerWithScriptHandler : function () {},

/**
 * @method CCTimer
 * @constructor
 */
CCTimer : function () {},

};

/**
 * @class CCScheduler
 */
cc.Scheduler = {

/**
 * @method setTimeScale
 * @param {float}
 */
setTimeScale : function () {},

/**
 * @method getTimeScale
 * @return A value converted from C/C++ "float"
 */
getTimeScale : function () {},

/**
 * @method CCScheduler
 * @constructor
 */
CCScheduler : function () {},

};

/**
 * @class SimpleAudioEngine
 */
cc.AudioEngine = {

/**
 * @method stopAllEffects
 */
stopAllEffects : function () {},

/**
 * @method getBackgroundMusicVolume
 * @return A value converted from C/C++ "float"
 */
getBackgroundMusicVolume : function () {},

/**
 * @method isBackgroundMusicPlaying
 * @return A value converted from C/C++ "bool"
 */
isBackgroundMusicPlaying : function () {},

/**
 * @method getEffectsVolume
 * @return A value converted from C/C++ "float"
 */
getEffectsVolume : function () {},

/**
 * @method setBackgroundMusicVolume
 * @param {float}
 */
setBackgroundMusicVolume : function () {},

/**
 * @method stopEffect
 * @param {unsigned int}
 */
stopEffect : function () {},

/**
 * @method pauseAllEffects
 */
pauseAllEffects : function () {},

/**
 * @method preloadBackgroundMusic
 * @param {const char*}
 */
preloadBackgroundMusic : function () {},

/**
 * @method resumeBackgroundMusic
 */
resumeBackgroundMusic : function () {},

/**
 * @method rewindBackgroundMusic
 */
rewindBackgroundMusic : function () {},

/**
 * @method willPlayBackgroundMusic
 * @return A value converted from C/C++ "bool"
 */
willPlayBackgroundMusic : function () {},

/**
 * @method unloadEffect
 * @param {const char*}
 */
unloadEffect : function () {},

/**
 * @method preloadEffect
 * @param {const char*}
 */
preloadEffect : function () {},

/**
 * @method setEffectsVolume
 * @param {float}
 */
setEffectsVolume : function () {},

/**
 * @method pauseEffect
 * @param {unsigned int}
 */
pauseEffect : function () {},

/**
 * @method resumeAllEffects
 */
resumeAllEffects : function () {},

/**
 * @method pauseBackgroundMusic
 */
pauseBackgroundMusic : function () {},

/**
 * @method resumeEffect
 * @param {unsigned int}
 */
resumeEffect : function () {},

/**
 * @method end
 */
end : function () {},

/**
 * @method sharedEngine
 * @return A value converted from C/C++ "CocosDenshion::SimpleAudioEngine*"
 */
sharedEngine : function () {},

};
