//------------------------------------------------------------------
//
// JavaScript sample
//
//------------------------------------------------------------------

//
// For a more complete sample, see "JS Watermelon With Me" bundled with cocos2d-iphone
//

// Loads cocos2d, chipmunk constants and helper functions
require("jsb_constants.js");
require("MainMenuScene.js");
require("GameScene.js");
require("Level.js");
require("Dragon.js");
require("Coin.js");
require("Bomb.js");
require("Explosion.js");
require("EndCoin.js");

//------------------------------------------------------------------
//
// Main entry point
//
//------------------------------------------------------------------
function run()
{
    cc.log("run");
    
    var director = cc.Director.getInstance();
    
    cc.log("director: "+director);
    
    cc.AudioEngine.getInstance().playBackgroundMusic("music.mp3");
    cc.AudioEngine.getInstance().setEffectsVolume(0.5);
    
    var scene = cc.Reader.loadAsScene("MainMenuScene.ccbi");
    
    //var runningScene = director.getRunningScene();
    //if( runningScene === null )
    //    director.runWithScene( scene );
    //else
        director.replaceScene( cc.TransitionFade.create(0.5, scene ) );
}

run();


