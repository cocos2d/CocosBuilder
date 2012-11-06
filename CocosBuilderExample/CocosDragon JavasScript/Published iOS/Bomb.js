var Bomb = function()
{
    this.radius = 15;
};

Bomb.prototype.onUpdate = function()
{};

Bomb.prototype.handleCollisionWith = function(gameObjectController)
{
    if (gameObjectController.controllerName == "Dragon")
    {
        cc.AudioEngine.getInstance().playEffect("Explo.caf");
        
        // Collided with the dragon, remove object and add an exposion instead
        this.isScheduledForRemove = true;
        
        var explosion = cc.Reader.load("Explosion.ccbi");
        explosion.setPosition(this.rootNode.getPosition());
        
        this.rootNode.getParent().addChild(explosion);
    }
};