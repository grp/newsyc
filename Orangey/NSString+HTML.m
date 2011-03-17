//
//  NSString+HTML.m
//  Orangey
//
//  Created by Grant Paul on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSString+HTML.h"

@implementation NSString (HTML)

- (NSString *)stringByRemovingXMLTags {
    NSString *html = self;
    NSScanner *scanner = [NSScanner scannerWithString:html];
    NSString *text = nil;
    
    while ([scanner isAtEnd] == NO) {
        [scanner scanUpToString:@"<" intoString:NULL]; 
        [scanner scanUpToString:@">" intoString:&text];
        
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@" "];
    }
    
    return html;
}

@end
