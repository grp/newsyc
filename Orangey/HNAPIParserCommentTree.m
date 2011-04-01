//
//  HNAPIParserCommentTree.m
//  Orangey
//
//  Created by Grant Paul on 3/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNAPIParserCommentTree.h"
#import "XMLDocument.h"

@implementation HNAPIParserCommentTree

- (id)parseString:(NSString *)string options:(NSDictionary *)options {
    XMLDocument *document = [[XMLDocument alloc] initWithHTMLData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableArray *result = [NSMutableArray array];
    NSMutableArray *lasts = [NSMutableArray array];
    
    // XXX: this xpath is very ugly. (note: position()>1 is required to avoid the page header, and is lame)
    NSArray *comments = [document elementsMatchingPath:@"//table//tr[position()>1]//td//table//tr"];
    
    for (int i = 0; i < [comments count]; i++) {
        XMLElement *comment = [comments objectAtIndex:i];
        
        NSNumber *depth = nil;
        NSNumber *points = [NSNumber numberWithInt:0];
        NSString *body = nil;
        NSString *user = nil;
        NSNumber *identifier = nil;
        NSString *date = nil;
        NSMutableArray *children = nil;
        
        for (XMLElement *element in [comment children]) {
            if ([[element attributeWithName:@"class"] isEqual:@"default"]) {
                for (XMLElement *element2 in [element children]) {
                    if ([[element2 tagName] isEqual:@"div"]) {
                        for (XMLElement *element3 in [element2 children]) {
                            if ([[element3 attributeWithName:@"class"] isEqual:@"comhead"]) {
                                NSString *content = [element3 content];
                                
                                // XXX: is there any better way of doing this?
                                int start = [content rangeOfString:@"</a> "].location;
                                if (start != NSNotFound) content = [content substringFromIndex:start + [@"</a> " length]];
                                int end = [content rangeOfString:@" ago"].location;
                                if (end != NSNotFound) date = [content substringToIndex:end];
                                
                                for (XMLElement *element4 in [element3 children]) {
                                    NSString *content = [element4 content];
                                    NSString *tag = [element4 tagName];
                                    
                                    if ([tag isEqual:@"a"]) {
                                        NSString *href = [element4 attributeWithName:@"href"];
                                        
                                        if ([href hasPrefix:@"user?id="]) {
                                            user = content;
                                        } else if ([href hasPrefix:@"item?id="]) {
                                            identifier = [NSNumber numberWithInt:[[href substringFromIndex:[@"item?id=" length]] intValue]];
                                        }
                                    } else if ([tag isEqual:@"span"]) {
                                        int end = [content rangeOfString:@" "].location;
                                        if (end != NSNotFound) points = [NSNumber numberWithInt:[[content substringToIndex:end] intValue]];
                                    }
                                }
                            }
                        }
                    } else if ([[element2 attributeWithName:@"class"] isEqual:@"comment"]) {
                        // XXX: strip out _reply_ link (or "----") at the bottom (when logged in), if necessary?
                        body = [element2 content];
                    }
                }
            } else {
                for (XMLElement *element2 in [element children]) {
                    if ([[element2 tagName] isEqual:@"img"] && [[element2 attributeWithName:@"src"] isEqual:@"http://ycombinator.com/images/s.gif"]) {
                        // Yes, really: HN uses a 1x1 gif to indent comments. It's like 1999 all over again. :(
                        int width = [[element2 attributeWithName:@"width"] intValue];
                        // Each comment is "indented" by setting the width to "depth * 40", so divide to get the depth.
                        depth = [NSNumber numberWithInt:width / 40];
                    }
                }
            }
        }
        
        if (depth != nil) children = [NSMutableArray array];
        
        if (user == nil && [body isEqual:@"[deleted]"]) {
            // XXX: handle deleted comments
            NSLog(@"Bug: Ignoring deleted comment.");
            continue;
            
            identifier = [NSNumber numberWithInt:0];
            user = @"[deleted]";
            body = nil;
            points = nil;
        }
        
        // XXX: should this be more strict about what's a valid comment?
        if (user != nil && identifier != nil) {
            NSMutableDictionary *item = [NSMutableDictionary dictionary];
            [item setObject:user forKey:@"user"];
            if (body != nil) [item setObject:body forKey:@"body"];
            if (date != nil) [item setObject:date forKey:@"date"];
            if (points != nil) [item setObject:points forKey:@"points"];
            if (children != nil) [item setObject:children forKey:@"children"];
            [item setObject:identifier forKey:@"identifier"];
        
            if ([lasts count] >= [depth intValue]) [lasts removeObjectsInRange:NSMakeRange([depth intValue], [lasts count] - [depth intValue])];
            [lasts addObject:item];
        
            if ([depth intValue] == 0) {
                [result addObject:item];
            } else {
                NSMutableArray *children = [[lasts objectAtIndex:[depth intValue] - 1] objectForKey:@"children"];
                [children addObject:item];
            }
        }
    }
        
    [document release];
    
    NSMutableDictionary *item = [NSMutableDictionary dictionary];
    [item setObject:result forKey:@"children"];
    return item;
}

@end
