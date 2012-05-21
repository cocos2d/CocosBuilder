var director = CCDirector.sharedDirector;

function run()
{
	var scene = CCBReader.sceneWithNodeGraphFromFile("HelloJavaScript.ccbi");
	
	director.runWithScene(scene);
	
	log("test");
}

run();