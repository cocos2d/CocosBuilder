// Constants
var kCDStartSpeed = 8;
var kCDCoinSpeed = 8;
var kCDStartTarget = 160;

var kCDTargetFilterFactor = 0.05;
var kCDSlowDownFactor = 0.995;
var kCDGravitySpeed = 0.1;
var kCDGameOverSpeed = -10;
var kCDDeltaToRotationFactor = 5;

var Dragon = function()
{
    this.xTarget = kCDStartTarget;
    this.ySpeed = kCDStartSpeed;
    this.radius = 25;
};

Dragon.prototype.onUpdate = function()
{
    // Calculate the new position
    var oldPosition = this.rootNode.getPosition();
    
    var xNew = this.xTarget * kCDTargetFilterFactor + oldPosition.x * (1-kCDTargetFilterFactor);
    var yNew = oldPosition.y + this.ySpeed;
    this.rootNode.setPosition(cc.p(xNew, yNew));
    
    // Update the vertical speed
    this.ySpeed = (this.ySpeed - kCDGravitySpeed) * kCDSlowDownFactor;
    
    // Tilt the dragon
    var xDelta = xNew - oldPosition.x;
    this.rootNode.setRotation(xDelta * kCDDeltaToRotationFactor);
    
    // Check for game over
    if (this.ySpeed < kCDGameOverSpeed)
    {
        sharedGameScene.handleGameOver();
    }
};

Dragon.prototype.handleCollisionWith = function(gameObjectController)
{
    if (gameObjectController.controllerName == "Coin")
    {
        // Took a coin
        this.ySpeed = kCDCoinSpeed;
        sharedGameScene.setScore(sharedGameScene.score+1);
    }
    else if (gameObjectController.controllerName == "Bomb")
    {
        // Hit a bomb
        if (this.ySpeed > 0) this.ySpeed = 0;
        
        this.rootNode.animationManager.runAnimationsForSequenceNamed("Hit");
    }
};