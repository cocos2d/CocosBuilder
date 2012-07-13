var director = cc.Director.getInstance();

var scene = cc.Scene.create();

var node = cc.Node.create();

var sprite = cc.Sprite.create("logo.png");
sprite.setPosition (cc.p(160,240));
sprite.setScale(0.7);
node.addChild(sprite);

scene.addChild(node);

director.replaceScene(scene);

cc.log("Testing script!");