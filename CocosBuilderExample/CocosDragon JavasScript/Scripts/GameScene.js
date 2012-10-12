var GameScene = function(){};
var sharedGameScene;

GameScene.prototype.onDidLoadFromCCB = function()
{
    sharedGameScene = this;
    
    this.score = 0;
    
    var level = cc.Reader.load("Level.ccbi");
    
    this.rootNode.addChild(level);
    
};

GameScene.prototype.setScore = function(score)
{
    this.score = score;
    this.scoreLabel.setString(""+score);
}

GameScene.prototype.getScore = function()
{
    return this.score;
}

GameScene.prototype.handleGameOver = function()
{
    var scene = cc.Reader.loadAsScene("MainMenuScene.ccbi");
    cc.Director.getInstance().replaceScene(scene);
}

GameScene.prototype.handleLevelComplete = function()
{
    var scene = cc.Reader.loadAsScene("MainMenuScene.ccbi");
    cc.Director.getInstance().replaceScene(scene);
}