var EndCoin = function()
{
    this.radius = 15;
};

EndCoin.prototype.onUpdate = function()
{};

EndCoin.prototype.handleCollisionWith = function(gameObjectController)
{
    if (gameObjectController.controllerName == "Dragon")
    {
        this.isScheduledForRemove = true;
        sharedGameScene.handleLevelComplete();
    }
};