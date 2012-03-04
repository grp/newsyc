//
//  EntryBodyRenderer.m
//  newsyc
//
//  Created by Grant Paul on 2/26/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import "HNEntryBodyRenderer.h"
#import "HNEntry.h"

#import "XMLDocument.h"
#import "XMLElement.h"

@implementation HNEntryBodyRenderer
@synthesize entry;

- (CTFontRef)fontForFont:(UIFont *)font {
    CTFontRef ref = CTFontCreateWithName((CFStringRef) [font fontName], [font pointSize], NULL);
    return ref;
}

- (UIColor *)colorFromHexString:(NSString *)hex {
    if ([hex hasPrefix:@"#"]) hex = [hex substringFromIndex:1];
    
    NSScanner *scanner = [NSScanner scannerWithString:hex];
    [scanner setCharactersToBeSkipped:[NSCharacterSet symbolCharacterSet]]; 
    
    NSUInteger color;
    [scanner scanHexInt:&color]; 
    
    CGFloat red   = ((color & 0xFF0000) >> 16) / 255.0f;
    CGFloat green = ((color & 0x00FF00) >>  8) / 255.0f;
    CGFloat blue  = ((color & 0x0000FF) >>  0) / 255.0f;

    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}

- (NSAttributedString *)createAttributedString {
    NSString *body = [entry body];
    if ([body length] == 0) return [[[NSAttributedString alloc] init] autorelease];
    
    NSNumber *fontUseSmall = [[NSUserDefaults standardUserDefaults] objectForKey:@"interface-small-text"] ?: [NSNumber numberWithBool:YES];
    CGFloat fontSize = [fontUseSmall boolValue] ? 12.0f : 14.0f;
    
    CTFontRef fontBody = [self fontForFont:[UIFont systemFontOfSize:fontSize]];
    CTFontRef fontCode = [self fontForFont:[UIFont fontWithName:@"Courier New" size:fontSize]];
    CTFontRef fontItalic = [self fontForFont:[UIFont italicSystemFontOfSize:fontSize]];
    
    CGColorRef colorBody = [[UIColor blackColor] CGColor];
    CGColorRef colorLink = [[UIColor blueColor] CGColor];
    
    __block NSMutableAttributedString *bodyAttributed = [[NSMutableAttributedString alloc] init];
    __block NSMutableDictionary *currentAttributes = [NSMutableDictionary dictionary];
        
    void(^formatBody)(NSMutableDictionary *, XMLElement *) = ^(NSMutableDictionary *attributes, XMLElement *element) {
        [attributes setObject:(id) colorBody forKey:(NSString *) kCTForegroundColorAttributeName];
        [attributes setObject:(id) fontBody forKey:(NSString *) kCTFontAttributeName];
    };
    
    void(^formatFont)(NSMutableDictionary *, XMLElement *) = ^(NSMutableDictionary *attributes, XMLElement *element) {
        NSString *colorText = [element attributeWithName:@"color"];
        CGColorRef color = [[self colorFromHexString:colorText] CGColor];
        
        [attributes setObject:(id) color forKey:(NSString *) kCTForegroundColorAttributeName];
    };
    
    void(^formatCode)(NSMutableDictionary *, XMLElement *) = ^(NSMutableDictionary *attributes, XMLElement *element) {
        [attributes setObject:(id) fontCode forKey:(NSString *) kCTFontAttributeName];
        [attributes setObject:(id) kCFBooleanTrue forKey:@"PreserveWhitepace"];
    };
    
    void(^formatItalic)(NSMutableDictionary *, XMLElement *) = ^(NSMutableDictionary *attributes, XMLElement *element) {
        [attributes setObject:(id) fontItalic forKey:(NSString *) kCTFontAttributeName];
    };
    
    void(^formatLink)(NSMutableDictionary *, XMLElement *) = ^(NSMutableDictionary *attributes, XMLElement *element) {
        NSString *href = [element attributeWithName:@"href"];
        
        [attributes setObject:(id) colorLink forKey:(NSString *) kCTForegroundColorAttributeName];
        if (href != nil) [attributes setObject:href forKey:@"LinkDestination"];
        else [attributes setObject:@"hi there" forKey:@"LinkDestination"];
    };

    void(^formatParagraph)(NSMutableDictionary *, XMLElement *) = ^(NSMutableDictionary *attributes, XMLElement *element) {
        NSAttributedString *childString = [[NSAttributedString alloc] initWithString:@"\n\n" attributes:nil];
        [bodyAttributed appendAttributedString:childString];
    };
    
    void (^formatNewline)(NSMutableDictionary *, XMLElement *) = ^(NSMutableDictionary *attributes, XMLElement *element) {
        NSAttributedString *childString = [[NSAttributedString alloc] initWithString:@"\n" attributes:nil];
        [bodyAttributed appendAttributedString:childString];
    };
    
    NSDictionary *tagActions = [NSDictionary dictionaryWithObjectsAndKeys:
        [[formatParagraph copy] autorelease], @"p",
        [[formatCode copy] autorelease], @"code",
        [[formatItalic copy] autorelease], @"i",
        [[formatLink copy] autorelease], @"a",
        [[formatFont copy] autorelease], @"font",
        [[formatNewline copy] autorelease], @"br",
        [[formatBody copy] autorelease], @"body",
    nil];

    __block void(^formatChildren)(XMLElement *) = ^(XMLElement *element) {
        for (XMLElement *child in [element children]) {
            if (![child isTextNode]) {
                NSMutableDictionary *savedAttributes = [currentAttributes mutableCopy];
                
                NSAttributedString *(^formatAction)(NSMutableDictionary *, XMLElement *element) = [tagActions objectForKey:[child tagName]];
                if (formatAction != NULL) formatAction(currentAttributes, child);
                
                formatChildren(child);
                
                currentAttributes = savedAttributes;
            } else {
                NSString *content = [child content];
                
                // strip out whitespace not in <code> when 
                if (![[currentAttributes objectForKey:@"PreserveWhitepace"] boolValue]) {
                    while ([content rangeOfString:@"  "].location != NSNotFound) {
                        content = [content stringByReplacingOccurrencesOfString:@"  " withString:@" "];
                    }
                    
                    content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                }
                
                NSAttributedString *childString = [[NSAttributedString alloc] initWithString:content attributes:currentAttributes];
                [bodyAttributed appendAttributedString:childString];
            }
        }
    };
    
    // ensure body has a root element
    body = [NSString stringWithFormat:@"<body>%@</body>", body];
    
    XMLDocument *xml = [[XMLDocument alloc] initWithHTMLData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    formatChildren([xml firstElementMatchingPath:@"/"]);
    
    return [bodyAttributed autorelease];
}

- (CGSize)sizeForWidth:(CGFloat)width {
    CGSize size = CGSizeZero;
    size.width = width;
    size.height = CGFLOAT_MAX;
    
    size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [attributed length]), NULL, size, NULL);
    return size;
}

- (NSURL *)linkURLAtPoint:(CGPoint)point forWidth:(CGFloat)width runRect:(CGRect *)runrect {
    CGSize size = [self sizeForWidth:width];
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    // flip it into CoreText coordinates
    point.y = size.height - point.y;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, rect);
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);    
    NSArray *lines = (NSArray *) CTFrameGetLines(frame);
    
    CGPoint origins[[lines count]];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);
    
    for (int i = 0; i < [lines count]; i++) {
        CTLineRef line = (CTLineRef) [lines objectAtIndex:i];
        
        CGRect lineBounds;
        lineBounds.origin.x = 0;
        lineBounds.origin.y = origins[i].y;
        
        CGFloat ascent, descent, leading;
        lineBounds.size.width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        lineBounds.size.height = ascent + descent;
                
        // if the bottom of the line is less than the point
        if (lineBounds.origin.y - descent < point.y) {
            NSArray *runs = (NSArray *) CTLineGetGlyphRuns(line);
                        
            for (int j = 0; j < [runs count]; j++) {
                CTRunRef run = (CTRunRef) [runs objectAtIndex:j];
                
                CGRect runBounds;
                CGFloat ascent, descent;
                runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
                runBounds.size.height = ascent + descent;
                runBounds.origin.x = lineBounds.origin.x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
                runBounds.origin.y = lineBounds.origin.y - descent;
                
                if (runBounds.origin.x + runBounds.size.width > point.x) {
                    NSDictionary *attributes = (NSDictionary *) CTRunGetAttributes(run);
                    NSURL *url = [NSURL URLWithString:[attributes objectForKey:@"LinkDestination"]];
                    
                    if (runrect != NULL) {
                        // flip it back into the top-left coordinate system
                        runBounds.origin.y = size.height - (runBounds.origin.y + runBounds.size.height);
                        
                        *runrect = runBounds;
                    }
                                        
                    return url;
                }
            }
            
            return nil;
        }
    }
    
    return nil;
}

- (void)renderInContext:(CGContextRef)context rect:(CGRect)rect {
    CGContextSaveGState(context);
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGContextTranslateCTM(context, -rect.origin.x, -(rect.origin.y + rect.size.height));
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, rect);
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);    
    CTFrameDraw(frame, context);
    
    CGPathRelease(path);  
    CFRelease(frame);
    
    CGContextRestoreGState(context);  
}

- (id)initWithEntry:(HNEntry *)entry_ {
    if ((self = [super init])) {
        entry = entry_;
        
        attributed = [[self createAttributedString] retain];
        framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef) attributed);
    }
    
    return self;
}

- (void)dealloc {
    CFRelease(framesetter);
    [attributed release];
    
    [super dealloc];
}

@end
