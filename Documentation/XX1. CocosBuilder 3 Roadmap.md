# CocosBuilder 3 Roadmap
Overall goal is to create a complete stable integrated environment for Cocos2d JS (and cocos2d-x/iphone).

## JavaScript improvements

### Integrated visual debugger
Set and remove breakpoints from the text editor, automatically connect to the debugger using the IP number received from rendevouz & CocosPlayer connection. Send debugger commands through JS console and display returned results in CocosBuilder console. Also improve display of cc.log, and possibly hide output from CCLog. Buttons for continue, step, show current line in text view.

[Github Issue](https://github.com/cocos2d/cocos2d-js/issues/5)

### Improved text editor
In the text editor, add support for:

- Better syntax coloring
- Syntax check using jslint or jshint
- Better autocomplete, with all cocos2d default objects built in (and if possible - using output from jslint/jshint)
- Drop down menu for quick jumps to different functions in the file
- Better text editor support for JS Debugger

[Github Issue](https://github.com/cocos2d/cocos2d-js/issues/11)

### Export sounds to multiple formats
Currently all sounds are converted to mp3 for HTML5 by the publisher. It will need to be converted to ogg also, as mp3 is not supported by all browsers.

[Github Issue](https://github.com/cocos2d/cocos2d-js/issues/27)

### Scaling options for Android
Add different preset options for how to scale the graphic context for Android. These should include (but there could be more options):

- Using the native resolution of the device
- Using the closest iOS resolution and letterbox
- Using the closest iOS resolution's width and adjust the height to keep the x/y aspect ratio

This depends on [Cocos2d-x plist-file for initial configuration](https://github.com/cocos2d/cocos2d-js/issues/6) being done.

[Github Issue](https://github.com/cocos2d/cocos2d-js/issues/28)

### Include Chipmunk libs in HTML5 publish
CocosBuilder should include Chipmunk as part of publishing for HTML5. This should be optional and set with a checkbox in the project settings.

[Github Issue](https://github.com/cocos2d/cocos2d-js/issues/39)

### Run in browser
Add a menu option to run a project directly in the web browser.

- This includes, publishing to HTML5 (already done)
- Running a web-server at some local port
- Opening a web browser (possibly configurable which one, or selecting from a sub - menu) with the correct local address to the published files

[Github Issue](https://github.com/cocos2d/cocos2d-js/issues/12)

## Ease of use and polish

### Preview of assets
When a file is selected in the project view, a preview of the file should be displayed. Preview includes:

- Image, sound etc
- Size of image or sound
- Different versions of an image (iphone, iphonehd etc)

### Easier to create new ccb- and JS-files
Add button for creating new files at bottom of project view.

### Add files by drag and drop
Make it possible to drag and drop files between folders, and to import images to Resources folder by dropping them on the project view. It should also be possilbe to delete files from within CocosBuilder.

### Hide/lock layers
Add option to hide and/or lock a node in the node graph. A hidden node is not visible in CocosBuilder, but the visible property will not be affected on export. This feature is just to aid editing.

### Save all
Option to save all open CCB files (without closing them).

### Save files before publishing
Option to save all files before publishing. Currently changes to ccb-files are not exported until the file has been saved.

[Github Issue](https://github.com/cocos2d/cocos2d-js/issues/13)

## Publisher

### Options for generating sprite sheets for Android
Add the option to have a different compression settings for sprite sheets when publishing for Android. For instance, it is possible that the user wants to publish to PVRTC on iOS, but these are not supported on Android so it should be possible to use another compression type for Android. In future, different compression types for web could also be an option.

[Github Issue](https://github.com/cocos2d/cocos2d-js/issues/31)

## Error handling

### Check for invalid resources
Check for invalid resources, both when used inside CocosBuilder and during publishing process. Improve the error window that is displayed if publishing fails. Catch more error during the publishing process (overflow in sprite sheets, invalid ccb-files etc).

### Warn if project is not setup correctly
Display a warning if project is not setup correctly. Specifically when setting the resource path inside the publishing path which will cause infinite recursion.

[Github Issue](https://github.com/cocos2d/cocos2d-js/issues/32)

## CCBReader

### cocos2d-x
Simplify connections to cocos2d-x by auto-generating the glue code. Currently the CCBReader for cocos2d-x requires the user to write glue code for mapping name of functions to the actual functions, also when creating classes the class names needs to be mapped to the actual classes. (This is because c++ lacks introspection and reflection.)

Examples of current glue code:

    CCB_MEMBERVARIABLEASSIGNER_GLUE(this, "sprtBurst", CCSprite *, this->mSprtBurst);
    CCB_SELECTORRESOLVER_CCMENUITEM_GLUE(this, "pressedA:", MenuTestLayer::onMenuItemAClicked);

This glue code could be moved to a single class, which would handle all lookups for selectors, member variables and classes. CocosBuilder should generate this class, thus the user would not need to worry about the glue code. Methods that were not implemented would generate compiler warnings, which also would be helpful when trouble shooting.

[Github Issue](https://github.com/cocos2d/cocos2d-js/issues/8)

## Documentation

### Update CocosBuilder documentation
Update CocosBuilder's documetation to include all updates related to CocosBuilder 3.

[Github Issue](https://github.com/cocos2d/cocos2d-js/issues/29)

### Tutorials
Create tutorials for using CocosBuilder. In particular:

- Tutorial for setting everything up and getting started
- Tutorial for animations
- Tutorial for using multiple resolutions in a single file and handling resources
- Tutorial for creating a simple game from start to finish and run it on iOS and Android

[Github Issue](https://github.com/cocos2d/cocos2d-js/issues/30)

## Possible additions
These are ideas that possibly also could make it into CocosBuilder 3.

### Simplified installation of CocosPlayer
Add a menu option to CocosBuilder to automatically install CocosPlayer in Simulator or on a device (user will need to have provisioning profiles and certificates setup for this to work). When hitting _Run in CocosPlayer_, CocosPlayer could be automatically launched in Simulator if no device is connected.

[Github Issue](https://github.com/cocos2d/cocos2d-js/issues/35)

### Integration with cocos2d command line tool
Use Cocos2d command line tool for publishing files, creating new projects and possibly communicating with CocosPlayer. (This assumes that the command line tool is finished.)

[Github Issue](https://github.com/cocos2d/cocos2d-js/issues/36)