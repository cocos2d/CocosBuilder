# Suggested improvements

CocosBuilder was originally written as a tool for personal use only, and it was all done in my spare time. Therefore speed of implementation was one of the main goals. Before adding new features to CocosBuilder, I suggest the following updates and changes to make the program more easily extendable in the future:

* Update the version of Cocos2D used to Cocos2D 2.
* Add a new thread mode to Cocos2D, so it can run on the main thread. Code for this can be taken from CCDirectorMac, CCEventDispacher and MacGLView in the CocosBuilder project. All additions are marked with "#pragma mark CCB ADDITION START/END".
* Add some missing properties to Cocos2D (these are also marked with "#pragma mark …"
* Add a category function that lists all properties of a CCNode (or one of its subclasses), including information of how they can be edited. Use this information to dynamically build the inspector panel GUI. This change would remove the need to list all properties in the AppDelegate.
* Move code for the tree view and inspector to their own classes instead of the AppDelegate.
* Save and load CocosBuilder-documents with a marshaling algorithm instead of the CCBReader/Writer. Use categories to achieve this.


# Known bugs

* When reloading a projects assets, sometimes the program hangs or images get corrupted. This is due to a threading bug in the IKImageViewer which is used to display previews of the assets. The best solution would be to write an own implementation of the assets viewer (which would also make it look better).
* The templates feature works, but is not yet completed. For instance, there are no error checks if a template is missing when loading a document and the loader needs to be optimized (it's quite slow at the moment). This feature is not in the version that is online.


# Overall structure

CCBReader/CCBWriter can read and write Cocos2D node graphs to a plist file. It can also save extra properties associated with each node. At run time i (in CocosBuilder) these are associated with the nodes through the nodes tag. Each node has an individual tag, and a dictionary is stored for each tag number. Extra properties can be, for instance, if an object should be scaled proportionally or if it is collapsed in the tree view.

One of the design goals was to alter Cocos2D as little as possible, but in a few places this was necessary. All modifications has been marked with "#pragma mark CCB ADDITION".

The most important classes are CocosBuilderAppDelegate and CocosScene. The app-delegate is the glue that binds all functions of CocosBuilder together and CocosScene is the Cocos2D scene that is used to display the node graph currently being worked on.

To add support for new node types, currently code needs to be added in a few different places. Properties needs to be added to the app delegate, code for adding the node in CocosScene, code for serialization in CCBReader/Writer. Also, a menu item needs to be added an connected with the app delegate. This process would be greatly simplified if the suggested improvements were implemented first.
