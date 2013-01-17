//
//  APIDocsWindow.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 1/9/13.
//
//

#import <Cocoa/Cocoa.h>

#import <WebKit/WebKit.h>

@interface APIDocsWindow : NSWindowController
{
    IBOutlet WebView* webView;
}

@end
