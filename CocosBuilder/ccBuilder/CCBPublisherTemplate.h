//
//  CCBPublisherTemplate.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 11/27/12.
//
//

#import <Foundation/Foundation.h>

@interface CCBPublisherTemplate : NSObject
{
    NSString* contents;
}

@property (nonatomic,retain) NSString* contents;

- (id) initWithTemplateFile:(NSString*)fileName;

+ (id) templateWithFile:(NSString*)fileName;

- (void) setString:(NSString*)str forMarker:(NSString*)marker;

- (void) setStrings:(NSArray*)strs forMarker:(NSString*)marker prefix:(NSString*)prefix suffix:(NSString*)suffix;

- (void) writeToFile:(NSString*)fileName;

@end
