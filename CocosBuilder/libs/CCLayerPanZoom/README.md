CCLayerPanZoom
=============

This class represents the layer that can be scrolled and scaled with one or two fingers.   
CCLayerPanZoom have two modes: sheet mode and frame mode.  
In all modes you can receive click event through CCLayerPanZoomDelegate callback.  
Other delegate callbacks are: "clicked at point", "touch position updated" and "touch move began at position".  

Sheet Mode
--------------

In this mode you can scroll layer with swipes and zoom it with pinch in/out gestures, like in Google Maps app (see "Simple sheet test").  
Also, in sheet mode it's possible to have "ruber edges" like in many iOS apps for sliding parts of the intraface (see "Advanced sheet test").  


Frame Mode
--------------

In frame mode you can zoom layer with PinchIn/Out (like in first mode) but scrolling is different: it starts if touch is at layer's edge zones (configurable).   
This will come in handy when you'll need to move objects at layer with drag & drop, i.e. in map edit mode.
See "Frame test".  


Usage
=============

1. Add CCLayerPanZoom.h & CCLayerPanZoom.m to your project.
2. Import CCLayerPanZoom.h when you want to use it.
3. Make sure that you enable multitouch in your glView.
4. Create CCLayerPanZoom instance and add some children to it.
5. Assign the delegate if you need it.
6. Set mode for the layer.
7. If you want to use kCCLayerPanZoomModeSheet:
   * Set ruberEffectRatio if you want to use "ruber effect" (scrolling/zooming outside of panBoundsRect).
   * Also you can change rubberEffectRecoveryTime - in that time layer will recover to normal zoom/position.
8. If you want to use kCCLayerPanZoomModeFrame:
   * Set topFrameMargin, leftFrameMargin, bottomFrameMargin and rightFrameMargin to define distances from edges of panBoundingRect.
   * Set maxSpeed and minSpeed for autoscrolling when touch is in zone near edge of panBoundingRect.
9. Set maxScale and minScale factor for the layer.
10. Set maxTouchDistanceToClick for the layer. This is the max distance that touch can be drag before click (fuzzy shaky touch ;) ).




