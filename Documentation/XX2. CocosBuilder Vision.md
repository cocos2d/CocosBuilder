# CocosBuilder Vision
This document describes ideas for possible future features of CocosBuilder. The shorter term road map is covered [here](https://github.com/cocos2d/CocosBuilder/blob/develop/Documentation/XX1.%20CocosBuilder%203%20Roadmap.md).

## Coding
Simplify coding for non-programmers by making it possible to associate code snippets directly with buttons or other callbacks. In addition, code snippets for common tasks (such as playing sounds, switching to another scene) could be packaged as behaviors that could be dragged and dropped to buttons without any coding at all.

For more advanced programmers it should be possible to make prefabs, much like how it works in Unity.

Adding a more structured, object oriented language on top of JavaScript would help when developing large project. This could be HaXe or some similar language. An added benefit could be that HaXe could be compiled to either JavaScript (with very thin bindings) and to C++ for native performance.

## Animations
The animation editor should be extended to have support for splines and visual paths. Boned animation should use real, visual, bones and could be applied different themes. Support for inverse kinematics.

## Mesh sprites
Sprites made up of arbitrary meshes. Meshes could be animated using code or through CocosBuilder. Scale9Sprite could be a subclass to the mesh sprite.

## Physics
A physics editor should be built into CocosBuilder. It should be possible to assign physics attributes and shapes to any ccb-files. Joints and other restrictions should also be possible to setup visually.

## Shader editor and effects
Make it possible to create and edit shaders. CocosBuilder should come bundled with a default set of shaders for shadows, glow, blur etc. Properties of the shaders should be animatable on the time line.

## Localization support
All strings used inside CocosBuilder should be localizable, it should be possible to preview different languages in the same way that it is possible to quickly preview different resolution setups.

## Better UI components
CocosBuilder should have built in support for scroll views, table views, configurable buttons, text fields, sliders, check boxes, dialog popups etc. In addition, there should be better support for laying out dialog boxes and other UI components.

## Tile-less editor
It is already possible to build levels or maps using CocosBuilder. This should be improved by adding better previews of resources, images, sprite sheets and ccb-files so it is quicker to see which objects to drag into the scene.

## Tiled editor
CocosBuilder could have a built in tiled editor. This would be a very powerful feature in combination with the Tile-less editor when building game maps.

## 3D/2.5D support
Add support to Cocos2d similar to Cocos3d. Add support for doing 3d animations/compositing inside CocosBuilder.