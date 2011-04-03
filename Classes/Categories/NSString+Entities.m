//
//  NSString+HTML.m
//  MWFeedParser
//
//  Copyright (c) 2010 Michael Waterfall
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  1. The above copyright notice and this permission notice shall be included
//     in all copies or substantial portions of the Software.
//  
//  2. This Software cannot be used to archive or collect data such as (but not
//     limited to) that of events, news, experiences and activities, for the 
//     purpose of any concept relating to diary/journal keeping.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "NSString+Entities.h"


@implementation NSString (Entities)

- (NSString *)stringByDecodingHTMLEntities {
    NSUInteger myLength = [self length];
    NSUInteger ampIndex = [self rangeOfString:@"&" options:NSLiteralSearch].location;
    
    if (ampIndex == NSNotFound) return self;
    
    NSMutableString *result = [NSMutableString stringWithCapacity:(myLength * 1.25f)];
    
    // First iteration doesn't need to scan to & since we did that already, but for code simplicity's sake we'll do it again with the scanner.
    NSScanner *scanner = [NSScanner scannerWithString:self];
    [scanner setCharactersToBeSkipped:nil];
    
    NSCharacterSet *boundaryCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" \t\n\r;"];
    
    do {
        NSString *nonEntityString;
        if ([scanner scanUpToString:@"&" intoString:&nonEntityString]) {
            [result appendString:nonEntityString];
        }
        
        if ([scanner isAtEnd]) goto finish;
        
        if ([scanner scanString:@"&amp;" intoString:NULL]) {
            [result appendString:@"&"];
        } else if ([scanner scanString:@"&apos;" intoString:NULL]) {
            [result appendString:@"'"];
        } else if ([scanner scanString:@"&quot;" intoString:NULL]) {
            [result appendString:@"\""];
        } else if ([scanner scanString:@"&lt;" intoString:NULL]) {
            [result appendString:@"<"];
        } else if ([scanner scanString:@"&gt;" intoString:NULL]) {
            [result appendString:@">"];
        } else if ([scanner scanString:@"&#" intoString:NULL]) {
            BOOL gotNumber;
            unsigned charCode;
            NSString *xForHex = @"";
            
            // Is it hex or decimal?
            if ([scanner scanString:@"x" intoString:&xForHex]) {
                gotNumber = [scanner scanHexInt:&charCode];
            }
            else {
                gotNumber = [scanner scanInt:(int*)&charCode];
            }
            
            if (gotNumber) {
                [result appendFormat:@"%C", charCode];
                [scanner scanString:@";" intoString:NULL];
            } else {
                NSString *unknownEntity = nil;
                [scanner scanUpToCharactersFromSet:boundaryCharacterSet intoString:&unknownEntity];
                [result appendFormat:@"&#%@%@", xForHex, unknownEntity];
            }
        } else {
            NSString *amp;
            
            [scanner scanString:@"&" intoString:&amp];      //an isolated & symbol
            [result appendString:amp];
        }
    } while (![scanner isAtEnd]);
    
finish:
    return result;
}

@end
