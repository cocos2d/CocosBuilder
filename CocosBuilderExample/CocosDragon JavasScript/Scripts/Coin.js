var Coin = function()
{
    this.radius = 15;
};

Coin.prototype.onUpdate = function()
{};

Coin.prototype.handleCollisionWith = function(gameObjectController)
{
    if (gameObjectController.controllerName == "Dragon")
    {
        cc.AudioEngine.getInstance().playEffect("Coin.caf");
        this.isScheduledForRemove = true;
    }
};