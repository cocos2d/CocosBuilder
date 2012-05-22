var director = CCDirector.sharedDirector;

// Load scene
var scene = CCBReader.sceneWithNodeGraphFromFile("HelloJavaScript.ccbi");
director.runWithScene(scene);

// Animate the burst in the background
[sprtBurst runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:10 angle:360]]];

// Respond to pressed button
function pressedMenuButton()
{
	[sprtLogo stopAllActions];
	
	var bounceOut = [CCEaseBounceOut actionWithAction:[CCScaleTo actionWithDuration:0.5 scale:1.5]];
	var bounceBack = [CCEaseBounceOut actionWithAction:[CCScaleTo actionWithDuration:0.5 scale:1]];
	var bounceSeq = [CCSequence actionsWithArray:[bounceOut, bounceBack]];
	[sprtLogo runAction:bounceSeq];
	
	log("pressedMenuButton");
}