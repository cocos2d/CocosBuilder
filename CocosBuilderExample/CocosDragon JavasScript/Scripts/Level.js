var kCDScrollFilterFactor = 0.1;
var kCDDragonTargetOffset = 80;


var Level = function(){};

Level.prototype.onDidLoadFromCCB = function()
{
    // Forward relevant touch events to controller (this)
    this.rootNode.onTouchesBegan = function( touches, event) {
        this.controller.onTouchesBegan(touches, event);
        return true;
    }
    this.rootNode.onTouchesMoved = function( touches, event) {
        this.controller.onTouchesMoved(touches, event);
        return true;
    }
    
    // Schedule callback
    this.rootNode.onUpdate = function(dt) {
        this.controller.onUpdate();
    }
    this.rootNode.schedule(this.rootNode.onUpdate);
};

Level.prototype.onTouchesBegan = function(touches, event)
{
    var loc = touches[0].getLocation();
    this.dragon.controller.xTarget = loc.x;
}

Level.prototype.onTouchesMoved = function(touches, event)
{
    var loc = touches[0].getLocation();
    this.dragon.controller.xTarget = loc.x;
}

Level.prototype.onUpdate = function(dt)
{
    // Iterate though all objects in the level layer
    var children = this.rootNode.getChildren();
    for (var i = 0; i < children.length; i++)
    {
        // Check if the child has a controller (only the updatable objects will have one)
        var gameObject = children[i];
        var gameObjectController = gameObject.controller;
        if (gameObjectController)
        {
            
            // Update all game objects
            gameObjectController.onUpdate();
            
            // Check for collisions with dragon
            if (gameObject !== this.dragon)
            {
                if (cc.pDistance(gameObject.getPosition(), this.dragon.getPosition()) < gameObjectController.radius + this.dragon.controller.radius)
                {
                    gameObjectController.handleCollisionWith(this.dragon.controller);
                    this.dragon.controller.handleCollisionWith(gameObjectController);
                }
            }
        }
    }
    
    // Check for objects to remove
    for (var i = children.length-1; i >=0; i--)
    {
        var gameObject = children[i];
        var gameObjectController = gameObject.controller;
        if (gameObjectController && gameObjectController.isScheduledForRemove)
        {
            this.rootNode.removeChild(gameObject, true);
        }
    }
    
    // Adjust position of the layer so dragon is visible
    var yTarget = kCDDragonTargetOffset - this.dragon.getPosition().y;
    var oldLayerPosition = this.rootNode.getPosition();
    
    var xNew = oldLayerPosition.x;
    var yNew = yTarget * kCDScrollFilterFactor + oldLayerPosition.y * (1 - kCDScrollFilterFactor);
    
    this.rootNode.setPosition(cc.p(xNew, yNew));
}