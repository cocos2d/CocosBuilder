/**
 * @module cocos2dx_extension
 */
var cc = cc || {};

/**
 * @class CCBReader
 */
cc._Reader = {

/**
 * @method getOwnerCallbackNames
 * @return A value converted from C/C++ "cocos2d::CCArray*"
 */
getOwnerCallbackNames : function () {},

/**
 * @method setCCBRootPath
 * @param {const char*}
 */
setCCBRootPath : function () {},

/**
 * @method getOwnerCallbackNodes
 * @return A value converted from C/C++ "cocos2d::CCArray*"
 */
getOwnerCallbackNodes : function () {},

/**
 * @method readSoundKeyframesForSeq
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::extension::CCBSequence*}
 */
readSoundKeyframesForSeq : function () {},

/**
 * @method getCCBRootPath
 * @return A value converted from C/C++ "std::string"
 */
getCCBRootPath : function () {},

/**
 * @method getOwnerOutletNodes
 * @return A value converted from C/C++ "cocos2d::CCArray*"
 */
getOwnerOutletNodes : function () {},

/**
 * @method readUTF8
 * @return A value converted from C/C++ "std::string"
 */
readUTF8 : function () {},

/**
 * @method getOwnerOutletNames
 * @return A value converted from C/C++ "cocos2d::CCArray*"
 */
getOwnerOutletNames : function () {},

/**
 * @method setAnimationManager
 * @param {cocos2d::extension::CCBAnimationManager*}
 */
setAnimationManager : function () {},

/**
 * @method readCallbackKeyframesForSeq
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::extension::CCBSequence*}
 */
readCallbackKeyframesForSeq : function () {},

/**
 * @method getAnimationManagersForNodes
 * @return A value converted from C/C++ "cocos2d::CCArray*"
 */
getAnimationManagersForNodes : function () {},

/**
 * @method getNodesWithAnimationManagers
 * @return A value converted from C/C++ "cocos2d::CCArray*"
 */
getNodesWithAnimationManagers : function () {},

/**
 * @method getAnimationManager
 * @return A value converted from C/C++ "cocos2d::extension::CCBAnimationManager*"
 */
getAnimationManager : function () {},

};

/**
 * @class CCControl
 */
cc.Control = {

/**
 * @method setEnabled
 * @param {bool}
 */
setEnabled : function () {},

/**
 * @method getState
 * @return A value converted from C/C++ "unsigned int"
 */
getState : function () {},

/**
 * @method isOpacityModifyRGB
 * @return A value converted from C/C++ "bool"
 */
isOpacityModifyRGB : function () {},

/**
 * @method sendActionsForControlEvents
 * @param {unsigned int}
 */
sendActionsForControlEvents : function () {},

/**
 * @method setSelected
 * @param {bool}
 */
setSelected : function () {},

/**
 * @method getTouchLocation
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 * @param {cocos2d::CCTouch*}
 */
getTouchLocation : function () {},

/**
 * @method isEnabled
 * @return A value converted from C/C++ "bool"
 */
isEnabled : function () {},

/**
 * @method isTouchInside
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCTouch*}
 */
isTouchInside : function () {},

/**
 * @method setOpacityModifyRGB
 * @param {bool}
 */
setOpacityModifyRGB : function () {},

/**
 * @method needsLayout
 */
needsLayout : function () {},

/**
 * @method hasVisibleParents
 * @return A value converted from C/C++ "bool"
 */
hasVisibleParents : function () {},

/**
 * @method isSelected
 * @return A value converted from C/C++ "bool"
 */
isSelected : function () {},

/**
 * @method init
 * @return A value converted from C/C++ "bool"
 */
init : function () {},

/**
 * @method setHighlighted
 * @param {bool}
 */
setHighlighted : function () {},

/**
 * @method registerWithTouchDispatcher
 */
registerWithTouchDispatcher : function () {},

/**
 * @method isHighlighted
 * @return A value converted from C/C++ "bool"
 */
isHighlighted : function () {},

/**
 * @method CCControl
 * @constructor
 */
CCControl : function () {},

};

/**
 * @class CCScale9Sprite
 */
cc.Scale9Sprite = {

/**
 * @method getCapInsets
 * @return A value converted from C/C++ "cocos2d::CCRect"
 */
getCapInsets : function () {},

/**
 * @method setOpacityModifyRGB
 * @param {bool}
 */
setOpacityModifyRGB : function () {},

/**
 * @method updateWithBatchNode
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCSpriteBatchNode*}
 * @param {cocos2d::CCRect}
 * @param {bool}
 * @param {cocos2d::CCRect}
 */
updateWithBatchNode : function () {},

/**
 * @method setInsetBottom
 * @param {float}
 */
setInsetBottom : function () {},

/**
 * @method isOpacityModifyRGB
 * @return A value converted from C/C++ "bool"
 */
isOpacityModifyRGB : function () {},

/**
 * @method setInsetTop
 * @param {float}
 */
setInsetTop : function () {},

/**
 * @method init
 * @return A value converted from C/C++ "bool"
 */
init : function () {},

/**
 * @method setPreferredSize
 * @param {cocos2d::CCSize}
 */
setPreferredSize : function () {},

/**
 * @method setSpriteFrame
 * @param {cocos2d::CCSpriteFrame*}
 */
setSpriteFrame : function () {},

/**
 * @method getInsetBottom
 * @return A value converted from C/C++ "float"
 */
getInsetBottom : function () {},

/**
 * @method resizableSpriteWithCapInsets
 * @return A value converted from C/C++ "cocos2d::extension::CCScale9Sprite*"
 * @param {cocos2d::CCRect}
 */
resizableSpriteWithCapInsets : function () {},

/**
 * @method setContentSize
 * @param {cocos2d::CCSize}
 */
setContentSize : function () {},

/**
 * @method getInsetRight
 * @return A value converted from C/C++ "float"
 */
getInsetRight : function () {},

/**
 * @method getOriginalSize
 * @return A value converted from C/C++ "cocos2d::CCSize"
 */
getOriginalSize : function () {},

/**
 * @method getInsetTop
 * @return A value converted from C/C++ "float"
 */
getInsetTop : function () {},

/**
 * @method setInsetLeft
 * @param {float}
 */
setInsetLeft : function () {},

/**
 * @method getPreferredSize
 * @return A value converted from C/C++ "cocos2d::CCSize"
 */
getPreferredSize : function () {},

/**
 * @method setCapInsets
 * @param {cocos2d::CCRect}
 */
setCapInsets : function () {},

/**
 * @method getInsetLeft
 * @return A value converted from C/C++ "float"
 */
getInsetLeft : function () {},

/**
 * @method setInsetRight
 * @param {float}
 */
setInsetRight : function () {},

/**
 * @method CCScale9Sprite
 * @constructor
 */
CCScale9Sprite : function () {},

};

/**
 * @class CCControlButton
 */
cc.ControlButton = {

/**
 * @method setTitleColorDispatchTable
 * @param {cocos2d::CCDictionary*}
 */
setTitleColorDispatchTable : function () {},

/**
 * @method isPushed
 * @return A value converted from C/C++ "bool"
 */
isPushed : function () {},

/**
 * @method setSelected
 * @param {bool}
 */
setSelected : function () {},

/**
 * @method setTitleLabel
 * @param {cocos2d::CCNode*}
 */
setTitleLabel : function () {},

/**
 * @method ccTouchBegan
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCTouch*}
 * @param {cocos2d::CCEvent*}
 */
ccTouchBegan : function () {},

/**
 * @method setTitleTTFSizeForState
 * @param {float}
 * @param {unsigned int}
 */
setTitleTTFSizeForState : function () {},

/**
 * @method setAdjustBackgroundImage
 * @param {bool}
 */
setAdjustBackgroundImage : function () {},

/**
 * @method ccTouchEnded
 * @param {cocos2d::CCTouch*}
 * @param {cocos2d::CCEvent*}
 */
ccTouchEnded : function () {},

/**
 * @method setHighlighted
 * @param {bool}
 */
setHighlighted : function () {},

/**
 * @method setBackgroundSpriteDispatchTable
 * @param {cocos2d::CCDictionary*}
 */
setBackgroundSpriteDispatchTable : function () {},

/**
 * @method setZoomOnTouchDown
 * @param {bool}
 */
setZoomOnTouchDown : function () {},

/**
 * @method getTitleDispatchTable
 * @return A value converted from C/C++ "cocos2d::CCDictionary*"
 */
getTitleDispatchTable : function () {},

/**
 * @method setLabelAnchorPoint
 * @param {cocos2d::CCPoint}
 */
setLabelAnchorPoint : function () {},

/**
 * @method ccTouchCancelled
 * @param {cocos2d::CCTouch*}
 * @param {cocos2d::CCEvent*}
 */
ccTouchCancelled : function () {},

/**
 * @method getLabelAnchorPoint
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 */
getLabelAnchorPoint : function () {},

/**
 * @method initWithBackgroundSprite
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::extension::CCScale9Sprite*}
 */
initWithBackgroundSprite : function () {},

/**
 * @method getTitleTTFSizeForState
 * @return A value converted from C/C++ "float"
 * @param {unsigned int}
 */
getTitleTTFSizeForState : function () {},

/**
 * @method setTitleDispatchTable
 * @param {cocos2d::CCDictionary*}
 */
setTitleDispatchTable : function () {},

/**
 * @method setOpacity
 * @param {unsigned char}
 */
setOpacity : function () {},

/**
 * @method init
 * @return A value converted from C/C++ "bool"
 */
init : function () {},

/**
 * @method setTitleTTFForState
 * @param {const char*}
 * @param {unsigned int}
 */
setTitleTTFForState : function () {},

/**
 * @method setPreferredSize
 * @param {cocos2d::CCSize}
 */
setPreferredSize : function () {},

/**
 * @method setTitleLabelForState
 * @param {cocos2d::CCNode*}
 * @param {unsigned int}
 */
setTitleLabelForState : function () {},

/**
 * @method ccTouchMoved
 * @param {cocos2d::CCTouch*}
 * @param {cocos2d::CCEvent*}
 */
ccTouchMoved : function () {},

/**
 * @method getOpacity
 * @return A value converted from C/C++ "unsigned char"
 */
getOpacity : function () {},

/**
 * @method getCurrentTitleColor
 * @return A value converted from C/C++ "cocos2d::ccColor3B"
 */
getCurrentTitleColor : function () {},

/**
 * @method getTitleColorDispatchTable
 * @return A value converted from C/C++ "cocos2d::CCDictionary*"
 */
getTitleColorDispatchTable : function () {},

/**
 * @method setEnabled
 * @param {bool}
 */
setEnabled : function () {},

/**
 * @method getBackgroundSpriteForState
 * @return A value converted from C/C++ "cocos2d::extension::CCScale9Sprite*"
 * @param {unsigned int}
 */
getBackgroundSpriteForState : function () {},

/**
 * @method getHorizontalOrigin
 * @return A value converted from C/C++ "int"
 */
getHorizontalOrigin : function () {},

/**
 * @method setMargins
 * @param {int}
 * @param {int}
 */
setMargins : function () {},

/**
 * @method needsLayout
 */
needsLayout : function () {},

/**
 * @method initWithTitleAndFontNameAndFontSize
 * @return A value converted from C/C++ "bool"
 * @param {std::string}
 * @param {const char*}
 * @param {float}
 */
initWithTitleAndFontNameAndFontSize : function () {},

/**
 * @method setTitleBMFontForState
 * @param {const char*}
 * @param {unsigned int}
 */
setTitleBMFontForState : function () {},

/**
 * @method getTitleTTFForState
 * @return A value converted from C/C++ "const char*"
 * @param {unsigned int}
 */
getTitleTTFForState : function () {},

/**
 * @method getBackgroundSprite
 * @return A value converted from C/C++ "cocos2d::extension::CCScale9Sprite*"
 */
getBackgroundSprite : function () {},

/**
 * @method getTitleColorForState
 * @return A value converted from C/C++ "const ccColor3B"
 * @param {unsigned int}
 */
getTitleColorForState : function () {},

/**
 * @method setTitleColorForState
 * @param {ccColor3B}
 * @param {unsigned int}
 */
setTitleColorForState : function () {},

/**
 * @method doesAdjustBackgroundImage
 * @return A value converted from C/C++ "bool"
 */
doesAdjustBackgroundImage : function () {},

/**
 * @method setBackgroundSpriteFrameForState
 * @param {cocos2d::CCSpriteFrame*}
 * @param {unsigned int}
 */
setBackgroundSpriteFrameForState : function () {},

/**
 * @method setBackgroundSpriteForState
 * @param {cocos2d::extension::CCScale9Sprite*}
 * @param {unsigned int}
 */
setBackgroundSpriteForState : function () {},

/**
 * @method getTitleLabelDispatchTable
 * @return A value converted from C/C++ "cocos2d::CCDictionary*"
 */
getTitleLabelDispatchTable : function () {},

/**
 * @method initWithLabelAndBackgroundSprite
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCNode*}
 * @param {cocos2d::extension::CCScale9Sprite*}
 */
initWithLabelAndBackgroundSprite : function () {},

/**
 * @method setTitleLabelDispatchTable
 * @param {cocos2d::CCDictionary*}
 */
setTitleLabelDispatchTable : function () {},

/**
 * @method getTitleLabel
 * @return A value converted from C/C++ "cocos2d::CCNode*"
 */
getTitleLabel : function () {},

/**
 * @method getPreferredSize
 * @return A value converted from C/C++ "cocos2d::CCSize"
 */
getPreferredSize : function () {},

/**
 * @method getVerticalMargin
 * @return A value converted from C/C++ "int"
 */
getVerticalMargin : function () {},

/**
 * @method getBackgroundSpriteDispatchTable
 * @return A value converted from C/C++ "cocos2d::CCDictionary*"
 */
getBackgroundSpriteDispatchTable : function () {},

/**
 * @method getTitleLabelForState
 * @return A value converted from C/C++ "cocos2d::CCNode*"
 * @param {unsigned int}
 */
getTitleLabelForState : function () {},

/**
 * @method getCurrentTitle
 * @return A value converted from C/C++ "cocos2d::CCString*"
 */
getCurrentTitle : function () {},

/**
 * @method getTitleBMFontForState
 * @return A value converted from C/C++ "const char*"
 * @param {unsigned int}
 */
getTitleBMFontForState : function () {},

/**
 * @method setTitleForState
 * @param {cocos2d::CCString*}
 * @param {unsigned int}
 */
setTitleForState : function () {},

/**
 * @method setBackgroundSprite
 * @param {cocos2d::extension::CCScale9Sprite*}
 */
setBackgroundSprite : function () {},

/**
 * @method getZoomOnTouchDown
 * @return A value converted from C/C++ "bool"
 */
getZoomOnTouchDown : function () {},

/**
 * @method getTitleForState
 * @return A value converted from C/C++ "cocos2d::CCString*"
 * @param {unsigned int}
 */
getTitleForState : function () {},

/**
 * @method CCControlButton
 * @constructor
 */
CCControlButton : function () {},

};

/**
 * @class CCScrollView
 */
cc.ScrollView = {

/**
 * @method isClippingToBounds
 * @return A value converted from C/C++ "bool"
 */
isClippingToBounds : function () {},

/**
 * @method setContainer
 * @param {cocos2d::CCNode*}
 */
setContainer : function () {},

/**
 * @method setContentOffsetInDuration
 * @param {cocos2d::CCPoint}
 * @param {float}
 */
setContentOffsetInDuration : function () {},

/**
 * @method setZoomScaleInDuration
 * @param {float}
 * @param {float}
 */
setZoomScaleInDuration : function () {},

/**
 * @method ccTouchBegan
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCTouch*}
 * @param {cocos2d::CCEvent*}
 */
ccTouchBegan : function () {},

/**
 * @method getContainer
 * @return A value converted from C/C++ "cocos2d::CCNode*"
 */
getContainer : function () {},

/**
 * @method ccTouchEnded
 * @param {cocos2d::CCTouch*}
 * @param {cocos2d::CCEvent*}
 */
ccTouchEnded : function () {},

/**
 * @method getDirection
 * @return A value converted from C/C++ "cocos2d::extension::CCScrollViewDirection"
 */
getDirection : function () {},

/**
 * @method getZoomScale
 * @return A value converted from C/C++ "float"
 */
getZoomScale : function () {},

/**
 * @method updateInset
 */
updateInset : function () {},

/**
 * @method initWithViewSize
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCSize}
 * @param {cocos2d::CCNode*}
 */
initWithViewSize : function () {},

/**
 * @method pause
 * @param {cocos2d::CCObject*}
 */
pause : function () {},

/**
 * @method setDirection
 * @param {cocos2d::extension::CCScrollViewDirection}
 */
setDirection : function () {},

/**
 * @method setBounceable
 * @param {bool}
 */
setBounceable : function () {},

/**
 * @method setContentOffset
 * @param {cocos2d::CCPoint}
 * @param {bool}
 */
setContentOffset : function () {},

/**
 * @method isDragging
 * @return A value converted from C/C++ "bool"
 */
isDragging : function () {},

/**
 * @method init
 * @return A value converted from C/C++ "bool"
 */
init : function () {},

/**
 * @method isBounceable
 * @return A value converted from C/C++ "bool"
 */
isBounceable : function () {},

/**
 * @method getContentSize
 * @return A value converted from C/C++ "cocos2d::CCSize"
 */
getContentSize : function () {},

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
 * @method getContentOffset
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 */
getContentOffset : function () {},

/**
 * @method resume
 * @param {cocos2d::CCObject*}
 */
resume : function () {},

/**
 * @method setClippingToBounds
 * @param {bool}
 */
setClippingToBounds : function () {},

/**
 * @method setViewSize
 * @param {cocos2d::CCSize}
 */
setViewSize : function () {},

/**
 * @method getViewSize
 * @return A value converted from C/C++ "cocos2d::CCSize"
 */
getViewSize : function () {},

/**
 * @method maxContainerOffset
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 */
maxContainerOffset : function () {},

/**
 * @method setContentSize
 * @param {cocos2d::CCSize}
 */
setContentSize : function () {},

/**
 * @method isTouchMoved
 * @return A value converted from C/C++ "bool"
 */
isTouchMoved : function () {},

/**
 * @method isNodeVisible
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCNode*}
 */
isNodeVisible : function () {},

/**
 * @method ccTouchCancelled
 * @param {cocos2d::CCTouch*}
 * @param {cocos2d::CCEvent*}
 */
ccTouchCancelled : function () {},

/**
 * @method minContainerOffset
 * @return A value converted from C/C++ "cocos2d::CCPoint"
 */
minContainerOffset : function () {},

/**
 * @method registerWithTouchDispatcher
 */
registerWithTouchDispatcher : function () {},

/**
 * @method CCScrollView
 * @constructor
 */
CCScrollView : function () {},

};

/**
 * @class CCBAnimationManager
 */
cc.AnimationManager = {

/**
 * @method moveAnimationsFromNode
 * @param {cocos2d::CCNode*}
 * @param {cocos2d::CCNode*}
 */
moveAnimationsFromNode : function () {},

/**
 * @method setAutoPlaySequenceId
 * @param {int}
 */
setAutoPlaySequenceId : function () {},

/**
 * @method getDocumentCallbackNames
 * @return A value converted from C/C++ "cocos2d::CCArray*"
 */
getDocumentCallbackNames : function () {},

/**
 * @method actionForSoundChannel
 * @return A value converted from C/C++ "cocos2d::CCObject*"
 * @param {cocos2d::extension::CCBSequenceProperty*}
 */
actionForSoundChannel : function () {},

/**
 * @method setBaseValue
 * @param {cocos2d::CCObject*}
 * @param {cocos2d::CCNode*}
 * @param {const char*}
 */
setBaseValue : function () {},

/**
 * @method getDocumentOutletNodes
 * @return A value converted from C/C++ "cocos2d::CCArray*"
 */
getDocumentOutletNodes : function () {},

/**
 * @method addNode
 * @param {cocos2d::CCNode*}
 * @param {cocos2d::CCDictionary*}
 */
addNode : function () {},

/**
 * @method getLastCompletedSequenceName
 * @return A value converted from C/C++ "std::string"
 */
getLastCompletedSequenceName : function () {},

/**
 * @method setRootNode
 * @param {cocos2d::CCNode*}
 */
setRootNode : function () {},

/**
 * @method addDocumentOutletName
 * @param {std::string}
 */
addDocumentOutletName : function () {},

/**
 * @method getSequences
 * @return A value converted from C/C++ "cocos2d::CCArray*"
 */
getSequences : function () {},

/**
 * @method getRootContainerSize
 * @return A value converted from C/C++ "cocos2d::CCSize"
 */
getRootContainerSize : function () {},

/**
 * @method setDocumentControllerName
 * @param {std::string}
 */
setDocumentControllerName : function () {},

/**
 * @method getContainerSize
 * @return A value converted from C/C++ "cocos2d::CCSize"
 * @param {cocos2d::CCNode*}
 */
getContainerSize : function () {},

/**
 * @method actionForCallbackChannel
 * @return A value converted from C/C++ "cocos2d::CCObject*"
 * @param {cocos2d::extension::CCBSequenceProperty*}
 */
actionForCallbackChannel : function () {},

/**
 * @method getDocumentOutletNames
 * @return A value converted from C/C++ "cocos2d::CCArray*"
 */
getDocumentOutletNames : function () {},

/**
 * @method init
 * @return A value converted from C/C++ "bool"
 */
init : function () {},

/**
 * @method getKeyframeCallbacks
 * @return A value converted from C/C++ "cocos2d::CCArray*"
 */
getKeyframeCallbacks : function () {},

/**
 * @method runAnimationsForSequenceNamedTweenDuration
 * @param {const char*}
 * @param {float}
 */
runAnimationsForSequenceNamedTweenDuration : function () {},

/**
 * @method setRootContainerSize
 * @param {cocos2d::CCSize}
 */
setRootContainerSize : function () {},

/**
 * @method runAnimationsForSequenceIdTweenDuration
 * @param {int}
 * @param {float}
 */
runAnimationsForSequenceIdTweenDuration : function () {},

/**
 * @method getRunningSequenceName
 * @return A value converted from C/C++ "const char*"
 */
getRunningSequenceName : function () {},

/**
 * @method getAutoPlaySequenceId
 * @return A value converted from C/C++ "int"
 */
getAutoPlaySequenceId : function () {},

/**
 * @method addDocumentCallbackName
 * @param {std::string}
 */
addDocumentCallbackName : function () {},

/**
 * @method getRootNode
 * @return A value converted from C/C++ "cocos2d::CCNode*"
 */
getRootNode : function () {},

/**
 * @method addDocumentOutletNode
 * @param {cocos2d::CCNode*}
 */
addDocumentOutletNode : function () {},

/**
 * @method setDelegate
 * @param {cocos2d::extension::CCBAnimationManagerDelegate*}
 */
setDelegate : function () {},

/**
 * @method addDocumentCallbackNode
 * @param {cocos2d::CCNode*}
 */
addDocumentCallbackNode : function () {},

/**
 * @method setCallFunc
 * @param {cocos2d::CCCallFunc*}
 * @param {std::string}
 */
setCallFunc : function () {},

/**
 * @method getDelegate
 * @return A value converted from C/C++ "cocos2d::extension::CCBAnimationManagerDelegate*"
 */
getDelegate : function () {},

/**
 * @method runAnimationsForSequenceNamed
 * @param {const char*}
 */
runAnimationsForSequenceNamed : function () {},

/**
 * @method getDocumentCallbackNodes
 * @return A value converted from C/C++ "cocos2d::CCArray*"
 */
getDocumentCallbackNodes : function () {},

/**
 * @method setSequences
 * @param {cocos2d::CCArray*}
 */
setSequences : function () {},

/**
 * @method debug
 */
debug : function () {},

/**
 * @method getDocumentControllerName
 * @return A value converted from C/C++ "std::string"
 */
getDocumentControllerName : function () {},

/**
 * @method CCBAnimationManager
 * @constructor
 */
CCBAnimationManager : function () {},

};

/**
 * @class CCTableViewCell
 */
cc.TableViewCell = {

/**
 * @method reset
 */
reset : function () {},

/**
 * @method setIdx
 * @param {unsigned int}
 */
setIdx : function () {},

/**
 * @method setObjectID
 * @param {unsigned int}
 */
setObjectID : function () {},

/**
 * @method getObjectID
 * @return A value converted from C/C++ "unsigned int"
 */
getObjectID : function () {},

/**
 * @method getIdx
 * @return A value converted from C/C++ "unsigned int"
 */
getIdx : function () {},

/**
 * @method CCTableViewCell
 * @constructor
 */
CCTableViewCell : function () {},

};

/**
 * @class CCTableView
 */
cc.TableView = {

/**
 * @method updateCellAtIndex
 * @param {unsigned int}
 */
updateCellAtIndex : function () {},

/**
 * @method setVerticalFillOrder
 * @param {cocos2d::extension::CCTableViewVerticalFillOrder}
 */
setVerticalFillOrder : function () {},

/**
 * @method scrollViewDidZoom
 * @param {cocos2d::extension::CCScrollView*}
 */
scrollViewDidZoom : function () {},

/**
 * @method ccTouchBegan
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCTouch*}
 * @param {cocos2d::CCEvent*}
 */
ccTouchBegan : function () {},

/**
 * @method getVerticalFillOrder
 * @return A value converted from C/C++ "cocos2d::extension::CCTableViewVerticalFillOrder"
 */
getVerticalFillOrder : function () {},

/**
 * @method removeCellAtIndex
 * @param {unsigned int}
 */
removeCellAtIndex : function () {},

/**
 * @method initWithViewSize
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCSize}
 * @param {cocos2d::CCNode*}
 */
initWithViewSize : function () {},

/**
 * @method scrollViewDidScroll
 * @param {cocos2d::extension::CCScrollView*}
 */
scrollViewDidScroll : function () {},

/**
 * @method reloadData
 */
reloadData : function () {},

/**
 * @method ccTouchCancelled
 * @param {cocos2d::CCTouch*}
 * @param {cocos2d::CCEvent*}
 */
ccTouchCancelled : function () {},

/**
 * @method ccTouchEnded
 * @param {cocos2d::CCTouch*}
 * @param {cocos2d::CCEvent*}
 */
ccTouchEnded : function () {},

/**
 * @method ccTouchMoved
 * @param {cocos2d::CCTouch*}
 * @param {cocos2d::CCEvent*}
 */
ccTouchMoved : function () {},

/**
 * @method _updateContentSize
 */
_updateContentSize : function () {},

/**
 * @method insertCellAtIndex
 * @param {unsigned int}
 */
insertCellAtIndex : function () {},

/**
 * @method cellAtIndex
 * @return A value converted from C/C++ "cocos2d::extension::CCTableViewCell*"
 * @param {unsigned int}
 */
cellAtIndex : function () {},

/**
 * @method dequeueCell
 * @return A value converted from C/C++ "cocos2d::extension::CCTableViewCell*"
 */
dequeueCell : function () {},

/**
 * @method CCTableView
 * @constructor
 */
CCTableView : function () {},

};

/**
 * @class CCEditBox
 */
cc.EditBox = {

/**
 * @method setAnchorPoint
 * @param {cocos2d::CCPoint}
 */
setAnchorPoint : function () {},

/**
 * @method getText
 * @return A value converted from C/C++ "const char*"
 */
getText : function () {},

/**
 * @method setPlaceholderFontName
 * @param {const char*}
 */
setPlaceholderFontName : function () {},

/**
 * @method getPlaceHolder
 * @return A value converted from C/C++ "const char*"
 */
getPlaceHolder : function () {},

/**
 * @method setFontName
 * @param {const char*}
 */
setFontName : function () {},

/**
 * @method setPlaceholderFontSize
 * @param {int}
 */
setPlaceholderFontSize : function () {},

/**
 * @method setInputMode
 * @param {cocos2d::extension::EditBoxInputMode}
 */
setInputMode : function () {},

/**
 * @method setPlaceholderFontColor
 * @param {cocos2d::ccColor3B}
 */
setPlaceholderFontColor : function () {},

/**
 * @method setFontColor
 * @param {cocos2d::ccColor3B}
 */
setFontColor : function () {},

/**
 * @method setPlaceholderFont
 * @param {const char*}
 * @param {int}
 */
setPlaceholderFont : function () {},

/**
 * @method setFontSize
 * @param {int}
 */
setFontSize : function () {},

/**
 * @method initWithSizeAndBackgroundSprite
 * @return A value converted from C/C++ "bool"
 * @param {cocos2d::CCSize}
 * @param {cocos2d::extension::CCScale9Sprite*}
 */
initWithSizeAndBackgroundSprite : function () {},

/**
 * @method setPlaceHolder
 * @param {const char*}
 */
setPlaceHolder : function () {},

/**
 * @method setPosition
 * @param {cocos2d::CCPoint}
 */
setPosition : function () {},

/**
 * @method setReturnType
 * @param {cocos2d::extension::KeyboardReturnType}
 */
setReturnType : function () {},

/**
 * @method getMaxLength
 * @return A value converted from C/C++ "int"
 */
getMaxLength : function () {},

/**
 * @method setInputFlag
 * @param {cocos2d::extension::EditBoxInputFlag}
 */
setInputFlag : function () {},

/**
 * @method setText
 * @param {const char*}
 */
setText : function () {},

/**
 * @method setMaxLength
 * @param {int}
 */
setMaxLength : function () {},

/**
 * @method setContentSize
 * @param {cocos2d::CCSize}
 */
setContentSize : function () {},

/**
 * @method setFont
 * @param {const char*}
 * @param {int}
 */
setFont : function () {},

/**
 * @method setVisible
 * @param {bool}
 */
setVisible : function () {},

/**
 * @method create
 * @return A value converted from C/C++ "cocos2d::extension::CCEditBox*"
 * @param {cocos2d::CCSize}
 * @param {cocos2d::extension::CCScale9Sprite*}
 * @param {cocos2d::extension::CCScale9Sprite*}
 * @param {cocos2d::extension::CCScale9Sprite*}
 */
create : function () {},

/**
 * @method CCEditBox
 * @constructor
 */
CCEditBox : function () {},

};
