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
    
    CGFloat fontSize = 13.0f;
    
    CTFontRef fontBody = [self fontForFont:[UIFont systemFontOfSize:fontSize]];
    CTFontRef fontCode = [self fontForFont:[UIFont fontWithName:@"Courier New" size:fontSize]];
    CTFontRef fontItalic = [self fontForFont:[UIFont italicSystemFontOfSize:fontSize]];
    CTFontRef fontSmallParagraphBreak = [self fontForFont:[UIFont systemFontOfSize:floorf(fontSize * 2.0f / 3.0f)]];
    
    CGColorRef colorBody = [[UIColor blackColor] CGColor];
    CGColorRef colorLink = [[UIColor blueColor] CGColor];
    
    __block NSMutableAttributedString *bodyAttributed = [[NSMutableAttributedString alloc] init];
    __block NSMutableDictionary *currentAttributes = [NSMutableDictionary dictionary];
    
    BOOL(^hasContent)() = ^BOOL () {
        return [[[bodyAttributed string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] != 0;
    };
        
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
        [attributes setObject:[NSNumber numberWithInt:arc4random()] forKey:@"LinkIdentifier"];
    };

    void(^formatParagraph)(NSMutableDictionary *, XMLElement *) = ^(NSMutableDictionary *attributes, XMLElement *element) {
        if (!hasContent()) return;
        
        NSAttributedString *newlineString = [[NSAttributedString alloc] initWithString:@"\n" attributes:attributes];
        [bodyAttributed appendAttributedString:[newlineString autorelease]];
        
        NSMutableDictionary *blankLineAttributes = [[attributes mutableCopy] autorelease];
        [blankLineAttributes setObject:(id) fontSmallParagraphBreak forKey:(NSString *) kCTFontAttributeName];
        NSAttributedString *blankLineString = [[NSAttributedString alloc] initWithString:@"\n" attributes:blankLineAttributes];
        [bodyAttributed appendAttributedString:[blankLineString autorelease]];
    };
    
    void (^formatNewline)(NSMutableDictionary *, XMLElement *) = ^(NSMutableDictionary *attributes, XMLElement *element) {
        if (!hasContent()) return;
        
        NSAttributedString *childString = [[NSAttributedString alloc] initWithString:@"\n" attributes:nil];
        [bodyAttributed appendAttributedString:[childString autorelease]];
    };
    
    NSDictionary *tagActions = [NSDictionary dictionaryWithObjectsAndKeys:
        [[formatParagraph copy] autorelease], @"p",
        [[formatCode copy] autorelease], @"pre",
        [[formatItalic copy] autorelease], @"i",
        [[formatLink copy] autorelease], @"a",
        [[formatFont copy] autorelease], @"font",
        [[formatNewline copy] autorelease], @"br",
        [[formatBody copy] autorelease], @"body",
    nil];

    __block void(^formatChildren)(XMLElement *) = ^(XMLElement *element) {
        for (XMLElement *child in [element children]) {
            if (![child isTextNode]) {
                NSMutableDictionary *savedAttributes = [[currentAttributes mutableCopy] autorelease];
                
                NSAttributedString *(^formatAction)(NSMutableDictionary *, XMLElement *element) = [tagActions objectForKey:[child tagName]];
                if (formatAction != NULL) formatAction(currentAttributes, child);
                
                formatChildren(child);
                
                currentAttributes = savedAttributes;
            } else {
                NSString *content = [child content];
                
                // strip out whitespace not in <pre> when 
                if (![[currentAttributes objectForKey:@"PreserveWhitepace"] boolValue]) {
                    while ([content rangeOfString:@"  "].location != NSNotFound) {
                        content = [content stringByReplacingOccurrencesOfString:@"  " withString:@" "];
                    }
                    
                    content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                } else {
                    NSString *prefix = @"  ";
                    
                    if ([content hasPrefix:prefix]) {
                        content = [content substringFromIndex:[prefix length]];
                    }
                    
                    content = [content stringByReplacingOccurrencesOfString:[@"\n" stringByAppendingString:prefix] withString:@"\n"];
                    
                    if (hasContent()) {
                        content = [content stringByAppendingString:@"\n"];
                    }
                }
                
                NSAttributedString *childString = [[NSAttributedString alloc] initWithString:content attributes:currentAttributes];
                [bodyAttributed appendAttributedString:[childString autorelease]];
            }
        }
    };
    
    // ensure body has a root element
    body = [NSString stringWithFormat:@"<body>%@</body>", body];
    
    XMLDocument *xml = [[XMLDocument alloc] initWithHTMLData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    formatChildren([xml firstElementMatchingPath:@"/"]);
    [xml release];
    
    CFRelease(fontBody);
    CFRelease(fontCode);
    CFRelease(fontItalic);
    
    return [bodyAttributed autorelease];
}

- (CGSize)sizeForWidth:(CGFloat)width {
    CGSize size = CGSizeZero;
    size.width = width;
    size.height = CGFLOAT_MAX;
    
    size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [attributed length]), NULL, size, NULL);
    return size;
}

- (NSURL *)linkURLAtPoint:(CGPoint)point forWidth:(CGFloat)width rects:(NSSet **)rects {
    CGSize size = [self sizeForWidth:width];
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    // flip it into CoreText coordinates
    point.y = size.height - point.y;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, rect);
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);    
    NSArray *lines = (NSArray *) CTFrameGetLines(frame);
    
    CGPoint *origins = (CGPoint *) calloc(sizeof(CGPoint), [lines count]);
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);
    
    CGRect (^computeLineRect)(CTLineRef, int) = ^CGRect (CTLineRef line, int index) {                    
        CGRect lineRect;
        lineRect.origin.x = 0;
        lineRect.origin.y = origins[index].y;
        
        CGFloat ascent, descent, leading;
        lineRect.size.width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        lineRect.size.height = ascent + descent;
        
        return lineRect;
    };
    
    CGRect (^computeRunRect)(CTRunRef, CTLineRef, CGRect) = ^CGRect (CTRunRef run, CTLineRef line, CGRect lineRect) {                    
        CGRect runRect;
        CGFloat ascent, descent;
        runRect.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
        runRect.size.height = ascent + descent;
        runRect.origin.x = lineRect.origin.x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
        runRect.origin.y = lineRect.origin.y - descent;
        
        return runRect;
    };
    
    for (int i = 0; i < [lines count]; i++) {
        CTLineRef line = (CTLineRef) [lines objectAtIndex:i];
        CGRect lineBounds = computeLineRect(line, i);
        
        CGFloat ascent, descent, leading;
        CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
                
        // if the bottom of the line is less than the point
        if (lineBounds.origin.y - descent < point.y) {
            NSArray *runs = (NSArray *) CTLineGetGlyphRuns(line);
                        
            for (int j = 0; j < [runs count]; j++) {
                CTRunRef run = (CTRunRef) [runs objectAtIndex:j];
                CGRect runBounds = computeRunRect(run, line, lineBounds);
                
                if (runBounds.origin.x + runBounds.size.width > point.x) {
                    NSDictionary *attributes = (NSDictionary *) CTRunGetAttributes(run);
                    NSURL *url = [NSURL URLWithString:[attributes objectForKey:@"LinkDestination"]];
                    NSNumber *linkIdentifier = [attributes objectForKey:@"LinkIdentifier"];
                    
                    if (linkIdentifier != nil && rects != NULL) {
                        NSMutableSet *runRects = [NSMutableSet set];
                        
                        for (int k = 0; k < [lines count]; k++) {
                            CTLineRef line = (CTLineRef) [lines objectAtIndex:k];
                            NSArray *runs = (NSArray *) CTLineGetGlyphRuns(line);

                            for (int l = 0; l < [runs count]; l++) {
                                CTRunRef run = (CTRunRef) [runs objectAtIndex:l];
                                NSDictionary *attributes = (NSDictionary *) CTRunGetAttributes(run);

                                NSNumber *runIdentifier = [attributes objectForKey:@"LinkIdentifier"];
                                if ([runIdentifier isEqual:linkIdentifier]) {
                                    CGRect lineRect = computeLineRect(line, k);
                                    CGRect runRect = computeRunRect(run, line, lineRect);
                                    
                                    // flip it back into the top-left coordinate system
                                    runRect.origin.y = size.height - (runRect.origin.y + runRect.size.height);
                                    
                                    NSValue *rectValue = [NSValue valueWithCGRect:runRect];
                                    [runRects addObject:rectValue];
                                }
                            }
                        }
                        
                        *rects = (NSSet *) runRects;
                    }
                    
                    free(origins);
                    CFRelease(frame);
                    CFRelease(path);
                    return url;
                }
            }
            
            free(origins);
            CFRelease(frame);
            CFRelease(path);
            return nil;
        }
    }
    
    free(origins);
    CFRelease(frame);
    CFRelease(path);
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

- (void)prepare {
    if (framesetter != NULL) CFRelease(framesetter);
    [attributed release];
    
    attributed = [[self createAttributedString] retain];
    framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef) attributed);
}

- (id)initWithEntry:(HNEntry *)entry_ {
    if ((self = [super init])) {
        entry = entry_;
        [self prepare];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepare) name:kHNObjectLoadingStateChangedNotification object:entry];
    }
    
    return self;
}

- (void)dealloc {
    CFRelease(framesetter);
    [attributed release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

@end
