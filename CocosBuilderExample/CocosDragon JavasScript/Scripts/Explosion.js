var Explosion = function()
{
    this.radius = 15;
};

Explosion.prototype.onDidLoadFromCCB = function()
{
    this.rootNode.animationManager.setCompletedAnimationCallback(this, this.onAnimationComplete);
}

Explosion.prototype.onUpdate = function()
{};

Explosion.prototype.handleCollisionWith = function(gameObjectController)
{};

Explosion.prototype.onAnimationComplete = function(animationManager)
{
    this.isScheduledForRemove = true;
}