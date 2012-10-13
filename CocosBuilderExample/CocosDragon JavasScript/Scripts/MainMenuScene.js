var MainMenuScene = function(){};

MainMenuScene.prototype.onPressedPlay = function()
{
    var scene = cc.Reader.loadAsScene("GameScene.ccbi");
    cc.Director.getInstance().replaceScene(scene);
};