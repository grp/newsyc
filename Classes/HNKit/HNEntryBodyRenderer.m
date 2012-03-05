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
    
    CGColorRef colorBody = [[UIColor blackColor] CGColor];
    CGColorRef colorLink = [[UIColor blueColor] CGColor];
    
    __block BOOL preserveWhitespace = NO;
    __block NSMutableAttributedString *(^formatElementChildren)(XMLElement *) = nil;
    
    NSAttributedString *(^formatText)(XMLElement *) = ^NSAttributedString *(XMLElement *element) {
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        [attributes setObject:(id) colorBody forKey:(NSString *) kCTForegroundColorAttributeName];
        [attributes setObject:(id) fontBody forKey:(NSString *) kCTFontAttributeName];
        
        NSString *content = [element content];
        
        // strip out whitespace not in <code> when 
        if (!preserveWhitespace) {
            while ([content rangeOfString:@"  "].location != NSNotFound) {
                content = [content stringByReplacingOccurrencesOfString:@"  " withString:@" "];
            }
         
            content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        }
        
        NSAttributedString *contentAttributed = [[NSAttributedString alloc] initWithString:content attributes:attributes];
        return [contentAttributed autorelease];
    };
    
    NSAttributedString *(^formatFont)(XMLElement *) = ^NSAttributedString *(XMLElement *element) {
        NSMutableAttributedString *attributedElement = formatElementChildren(element);

        NSString *colorText = [element attributeWithName:@"color"];
        CGColorRef color = [[self colorFromHexString:colorText] CGColor];
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        [attributes setObject:(id) color forKey:(NSString *) kCTForegroundColorAttributeName];
        [attributedElement addAttributes:attributes range:NSMakeRange(0, [attributedElement length])];
        
        return attributedElement;
    };
    
    NSAttributedString *(^formatCode)(XMLElement *) = ^NSAttributedString *(XMLElement *element) {
        preserveWhitespace = YES;
        NSMutableAttributedString *attributedElement = formatElementChildren(element);
        preserveWhitespace = NO;
        
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        [attributes setObject:(id) fontCode forKey:(NSString *) kCTFontAttributeName];
        [attributedElement addAttributes:attributes range:NSMakeRange(0, [attributedElement length])];

        return attributedElement;
    };
    
    NSAttributedString *(^formatItalic)(XMLElement *) = ^NSAttributedString *(XMLElement *element) {
        NSMutableAttributedString *attributedElement = formatElementChildren(element);
        
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        [attributes setObject:(id) fontItalic forKey:(NSString *) kCTFontAttributeName];
        [attributedElement addAttributes:attributes range:NSMakeRange(0, [attributedElement length])];
        
        return attributedElement;
    };
    
    NSAttributedString *(^formatLink)(XMLElement *) = ^NSAttributedString *(XMLElement *element) {
        NSMutableAttributedString *attributedElement = formatElementChildren(element);
        
        NSString *href = [element attributeWithName:@"href"];
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        [attributes setObject:(id) colorLink forKey:(NSString *) kCTForegroundColorAttributeName];
        if (href != nil) [attributes setObject:href forKey:@"LinkDestination"];
        [attributedElement addAttributes:attributes range:NSMakeRange(0, [attributedElement length])];
        
        return attributedElement;
    };

    NSAttributedString *(^formatParagraph)(XMLElement *) = ^NSAttributedString *(XMLElement *element) {
        NSMutableAttributedString *attributedElement = [[[NSMutableAttributedString alloc] init] autorelease];
        
        NSAttributedString *paragraphAttributed = [[NSAttributedString alloc] initWithString:@"\n\n" attributes:nil];
        [attributedElement appendAttributedString:paragraphAttributed];
        [paragraphAttributed release];
        
        [attributedElement appendAttributedString:formatElementChildren(element)];
        
        return attributedElement;
    };
    
    NSAttributedString *(^formatNewline)(XMLElement *) = ^NSAttributedString *(XMLElement *element) {
        NSMutableAttributedString *attributedElement = formatElementChildren(element);
        
        NSAttributedString *newlineAttributed = [[NSAttributedString alloc] initWithString:@"\n" attributes:nil];
        [attributedElement appendAttributedString:newlineAttributed];
        [newlineAttributed release];
        
        return attributedElement;
    };
    
    NSDictionary *tagActions = [NSDictionary dictionaryWithObjectsAndKeys:
        [[formatParagraph copy] autorelease], @"p",
        [[formatCode copy] autorelease], @"code",
        [[formatItalic copy] autorelease], @"i",
        [[formatLink copy] autorelease], @"a",
        [[formatFont copy] autorelease], @"font",
        [[formatNewline copy] autorelease], @"br",
    nil];

    __block NSAttributedString *(^formatChildren)(XMLElement *) = ^NSAttributedString *(XMLElement *element) {
        NSMutableAttributedString *formatAttributed = [[[NSMutableAttributedString alloc] init] autorelease];
        
        NSAttributedString *(^formatAction)(XMLElement *element) = [tagActions objectForKey:[element tagName]];
        
        if (formatAction != NULL) {
            [formatAttributed appendAttributedString:formatAction(element)];
        } else {
            [formatAttributed appendAttributedString:formatElementChildren(element)];
        }
        
        return formatAttributed;
    };
    
    formatElementChildren = ^NSMutableAttributedString *(XMLElement *element) {
        NSMutableAttributedString *attributedElement = [[[NSMutableAttributedString alloc] init] autorelease];
        
        for (XMLElement *child in [element children]) {
            if ([child isTextNode]) {
                [attributedElement appendAttributedString:formatText(child)];

            } else {
                [attributedElement appendAttributedString:formatChildren(child)];
            }
        }
        
        return attributedElement;
    };
    
    XMLDocument *xml = [[XMLDocument alloc] initWithHTMLData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    NSAttributedString *bodyAttributed = formatChildren([xml firstElementMatchingPath:@"/"]);
    [xml release];
    
    CFRelease(fontBody);
    CFRelease(fontCode);
    CFRelease(fontItalic);
    
    return bodyAttributed;
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
                    
                    CFRelease(frame);
                    CFRelease(path);
                    return url;
                }
            }
            
            CFRelease(frame);
            CFRelease(path);
            return nil;
        }
    }
    
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
