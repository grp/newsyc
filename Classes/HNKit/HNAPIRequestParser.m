//
//  HNAPIRequestParser.m
//  newsyc
//
//  Created by Grant Paul on 3/12/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNKit.h"
#import "HNAPIRequestParser.h"
#import "XMLDocument.h"
#import "XMLElement.h"
#import "NSString+Tags.h"

typedef enum {
    kHNPageLayoutTypeUnknown,
    kHNPageLayoutTypeEnclosed, // <table> inside <tr>[3]
    kHNPageLayoutTypeHeaderFooter, // <table>[1:2] inside <tr>[3]
    kHNPageLayoutTypeExposed // <tr>[3:]
} HNPageLayoutType;

@implementation HNAPIRequestParser

- (NSDictionary *)parseUserProfileWithString:(NSString *)string {
    NSScanner *scanner = [NSScanner scannerWithString:string];
    NSString *key = nil, *value = nil;
    
    NSString *start = @"<tr><td valign=top>";
    NSString *mid = @":</td><td>";
    NSString *end = @"</td></tr>";
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    while ([scanner isAtEnd] == NO) {
        [scanner scanUpToString:start intoString:NULL];
        [scanner scanUpToString:mid intoString:&key];
        [scanner scanUpToString:end intoString:&value];
        if ([key hasPrefix:start]) key = [key substringFromIndex:[start length]];
        if ([value hasPrefix:mid]) value = [value substringFromIndex:[mid length]];
        
        if ([key isEqual:@"about"]) {
            // XXX: hacky method to extract text from a textarea
            if ([value rangeOfString:@"<textarea"].location != NSNotFound) {
                NSString *tempValue = [value substringFromIndex:[value rangeOfString:@"<textarea"].location + [value rangeOfString:@"<textarea"].length];
                
                if ([tempValue rangeOfString:@">"].location != NSNotFound) {
                    tempValue = [tempValue substringFromIndex:[tempValue rangeOfString:@">"].location + [tempValue rangeOfString:@">"].length];
                    if ([tempValue rangeOfString:@"\n"].location == 0) {
                        tempValue = [tempValue substringFromIndex:[tempValue rangeOfString:@"\n"].location + [tempValue rangeOfString:@"\n"].length];
                    }
                    
                    if ([tempValue rangeOfString:@"</textarea>"].location != NSNotFound) {
                        value = [tempValue substringToIndex:[tempValue rangeOfString:@"</textarea>"].location];
                    }
                }
            }
                        
            [result setObject:value forKey:@"about"];
        } else if ([key isEqual:@"karma"]) {
            [result setObject:value forKey:@"karma"];
        } else if ([key isEqual:@"avg"]) {
            [result setObject:value forKey:@"average"];
        } else if ([key isEqual:@"created"]) {
            [result setObject:value forKey:@"created"];
        }
    }
    
    return result;
}

- (HNPageLayoutType)pageLayoutTypeForDocument:(XMLDocument *)document {
    NSArray *elements = [document elementsMatchingPath:@"//body/center/table/tr"];
    
    if ([elements count] >= 4) {
        XMLElement *tr = [elements objectAtIndex:2];
        XMLElement *td = [[tr children] lastObject];
        
        if (td != nil) {
            if ([[td children] count] == 0) {
                return kHNPageLayoutTypeExposed;
            } else {
                NSArray *tables = [[td children] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(XMLElement *object, NSDictionary *bindings) {
                    return [[object tagName] isEqualToString:@"table"];
                }]];
                
                NSArray *linebreaks = [[td children] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(XMLElement *object, NSDictionary *bindings) {
                    return [[object tagName] isEqualToString:@"br"];
                }]];
                
                // XXX: This is horrible hack.
                // This is because when there is only a header, make sure
                // that the header isn't considered to be replying to itself
                // There are two <br> tags in that case, so use those to guess.
                if ([tables count] >= 2 || [linebreaks count] == 2) {
                    return kHNPageLayoutTypeHeaderFooter;
                } else if ([tables count] == 1) {
                    return kHNPageLayoutTypeEnclosed;
                }
            }
        }
    }
    
    return kHNPageLayoutTypeUnknown;
}

- (BOOL)rootElementIsSubmission:(XMLDocument *)document {
    return [document firstElementMatchingPath:@"//body/center/table/tr[3]/td/table//td[@class='title']"] != nil;
}

- (XMLElement *)rootElementForDocument:(XMLDocument *)document pageLayoutType:(HNPageLayoutType)type {
    if (type == kHNPageLayoutTypeHeaderFooter) {
        return [document firstElementMatchingPath:@"//body/center/table/tr[3]/td/table[1]"];
    } else {
        return nil;
    }
}

- (NSArray *)contentRowsForDocument:(XMLDocument *)document pageLayoutType:(HNPageLayoutType)type {
    if (type == kHNPageLayoutTypeEnclosed) {
        NSArray *elements = [document elementsMatchingPath:@"//body/center/table/tr[3]/td/table/tr"];
        return elements;
    } else if (type == kHNPageLayoutTypeExposed) {
        NSArray *elements = [document elementsMatchingPath:@"//body/center/table/tr"];
        return [elements subarrayWithRange:NSMakeRange(3, [elements count] - 3)];
    } else if (type == kHNPageLayoutTypeHeaderFooter) {
        NSArray *elements = [document elementsMatchingPath:@"//body/center/table/tr[3]/td/table[2]/tr"];
        return elements;
    } else {
        return nil;
    }
}

- (NSDictionary *)parseSubmissionWithElements:(NSArray *)elements {
    XMLElement *first = [elements objectAtIndex:0];
    XMLElement *second = [elements objectAtIndex:1];
    XMLElement *fourth = nil;
    if ([elements count] >= 4) fourth = [elements objectAtIndex:3];
    
    // These have a number of edge cases (e.g. "discuss"),
    // so use sane default values in case of one of those.
    NSNumber *points = [NSNumber numberWithInt:0];
    NSNumber *comments = [NSNumber numberWithInt:0];
    
    NSString *title = nil;
    NSString *user = nil;
    NSNumber *identifier = nil;
    NSString *body = nil;
    NSString *date = nil;
    NSString *href = nil;
    HNMoreToken more = nil;
    
    for (XMLElement *element in [first children]) {
        if ([[element attributeWithName:@"class"] isEqual:@"title"]) {
            for (XMLElement *element2 in [element children]) {
                if ([[element2 tagName] isEqual:@"a"] && ![[element2 content] isEqual:@"scribd"]) {
                    title = [element2 content];
                    href = [element2 attributeWithName:@"href"];
                    
                    // In "ask HN" posts, we need to extract the id (and fix the URL) here.
                    if ([href hasPrefix:@"item?id="]) {
                        identifier = [NSNumber numberWithInt:[[href substringFromIndex:[@"item?id=" length]] intValue]];
                        href = nil;
                    }
                }
            }
        }
    }
    
    for (XMLElement *element in [second children]) {
        if ([[element attributeWithName:@"class"] isEqual:@"subtext"]) {
            NSString *content = [element content];
            
            // XXX: is there any better way of doing this?
            int start = [content rangeOfString:@"</a> "].location;
            if (start != NSNotFound) content = [content substringFromIndex:start + [@"</a> " length]];
            int end = [content rangeOfString:@" ago"].location;
            if (end != NSNotFound) date = [content substringToIndex:end];
            
            for (XMLElement *element2 in [element children]) {
                NSString *content = [element2 content];
                NSString *tag = [element2 tagName];
                
                if ([tag isEqual:@"a"]) {
                    if ([[element2 attributeWithName:@"href"] hasPrefix:@"user?id="]) {
                        user = [content stringByRemovingHTMLTags];
                        user = [user stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    } else if ([[element2 attributeWithName:@"href"] hasPrefix:@"item?id="]) {
                        int end = [content rangeOfString:@" "].location;
                        if (end != NSNotFound) comments = [NSNumber numberWithInt:[[content substringToIndex:end] intValue]];
                        
                        identifier = [NSNumber numberWithInt:[[[element2 attributeWithName:@"href"] substringFromIndex:[@"item?id=" length]] intValue]];
                    }
                } else if ([tag isEqual:@"span"]) {
                    int end = [content rangeOfString:@" "].location;
                    if (end != NSNotFound) points = [NSNumber numberWithInt:[[content substringToIndex:end] intValue]];
                }
            }
        } else if ([[element attributeWithName:@"class"] isEqual:@"title"] && [[[[element content] stringByRemovingHTMLTags] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@"More"]) {
            for (XMLElement *element2 in [element children]) {
                if ([[element2 tagName] isEqualToString:@"a"]) {
                    NSString *morehref = [element2 attributeWithName:@"href"];
                    
                    // XXX: this breaks the second news page when not logged in, since that now uses /news2 rather than /x?fnid= for performance reasons.
                    if ([morehref hasPrefix:@"/x?fnid="]) {
                        more = [morehref substringFromIndex:[@"/x?fnid=" length]];
                    }
                }
            }
        }
    }
    
    for (XMLElement *element in [fourth children]) {
        if ([[element tagName] isEqual:@"td"]) {
            BOOL isReplyForm = NO;
            NSString *content = [element content];
            
            for (XMLElement *element2 in [element children]) {
                if ([[element2 tagName] isEqual:@"form"]) {
                    isReplyForm = YES;
                    break;
                }
            }
            
            if ([content length] > 0 && !isReplyForm) {
                body = content;
            }
        }
    }
    
    if (more != nil) {
        return [NSDictionary dictionaryWithObject:more forKey:@"more"];
    } else if (user != nil && title != nil && identifier != nil) {
        // XXX: better sanity checks?
        NSMutableDictionary *item = [NSMutableDictionary dictionary];
        [item setObject:user forKey:@"user"];
        [item setObject:points forKey:@"points"];
        [item setObject:title forKey:@"title"];
        [item setObject:comments forKey:@"numchildren"];
        if (href != nil) [item setObject:href forKey:@"url"];
        [item setObject:date forKey:@"date"];
        if (body != nil) [item setObject:body forKey:@"body"];
        if (more != nil) [item setObject:more forKey:@"more"];
        [item setObject:identifier forKey:@"identifier"];
        return item;
    } else {
        NSLog(@"Bug: Ignoring unparsable submission.");
        return nil;
    }
}

- (NSDictionary *)parseCommentWithElement:(XMLElement *)comment {
    NSNumber *depth = nil;
    NSNumber *points = [NSNumber numberWithInt:0];
    NSString *body = nil;
    NSString *user = nil;
    NSNumber *identifier = nil;
    NSString *date = nil;
    NSNumber *parent = nil;
    NSNumber *submission = nil;
    NSString *more = nil;
    
    for (XMLElement *element in [comment children]) {
        if ([[element tagName] isEqual:@"tr"]) {
            comment = element;
            break;
        }
    }
    
    for (XMLElement *element in [comment children]) {
        if ([[element attributeWithName:@"class"] isEqual:@"title"] && [[[[element content] stringByRemovingHTMLTags] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@"More"]) {
            for (XMLElement *element2 in [element children]) {
                if ([[element2 tagName] isEqualToString:@"a"]) {
                    NSString *morehref = [element2 attributeWithName:@"href"];
                    
                    if ([morehref hasPrefix:@"/x?fnid="]) {
                        more = [morehref substringFromIndex:[@"/x?fnid=" length]];
                    }
                }
            }
        } else if ([[element tagName] isEqual:@"td"]) {
            for (XMLElement *element2 in [element children]) {
                if ([[element2 tagName] isEqual:@"table"]) {
                    for (XMLElement *element3 in [element2 children]) {
                        if ([[element3 tagName] isEqual:@"tr"]) {
                            comment = element3;
                            goto found;
                        }
                    }
                }
            }
        }
    } found:;
    
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
                                        user = [content stringByRemovingHTMLTags];
                                        user = [user stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                    } else if ([href hasPrefix:@"item?id="] && [content isEqual:@"link"]) {
                                        identifier = [NSNumber numberWithInt:[[href substringFromIndex:[@"item?id=" length]] intValue]];
                                    } else if ([href hasPrefix:@"item?id="] && [content isEqual:@"parent"]) {
                                        parent = [NSNumber numberWithInt:[[href substringFromIndex:[@"item?id=" length]] intValue]];
                                    } else if ([href hasPrefix:@"item?id="]) {
                                        submission = [NSNumber numberWithInt:[[href substringFromIndex:[@"item?id=" length]] intValue]];
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
        } else if ([[element attributeWithName:@"class"] isEqual:@"title"] && [[[[element content] stringByRemovingHTMLTags] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@"More"]) {
            for (XMLElement *element2 in [element children]) {
                if ([[element2 tagName] isEqualToString:@"a"]) {
                    NSString *morehref = [element2 attributeWithName:@"href"];
                        
                    if ([morehref hasPrefix:@"/x?fnid="]) {
                        more = [morehref substringFromIndex:[@"/x?fnid=" length]];
                    }
                }
            }
        } else {
            for (XMLElement *element2 in [element children]) {
                if ([[element2 tagName] isEqual:@"img"] && [[element2 attributeWithName:@"src"] hasSuffix:@"://ycombinator.com/images/s.gif"]) {
                    // Yes, really: HN uses a 1x1 gif to indent comments. It's like 1999 all over again. :(
                    int width = [[element2 attributeWithName:@"width"] intValue];
                    // Each comment is "indented" by setting the width to "depth * 40", so divide to get the depth.
                    depth = [NSNumber numberWithInt:(width / 40)];
                }
            }
        }
    }
    
    if (user == nil && [body isEqual:@"[deleted]"]) {
        // XXX: handle deleted comments
        NSLog(@"Bug: Ignoring deleted comment.");
        return nil;
    }
    
    if (more != nil) {
        return [NSDictionary dictionaryWithObject:more forKey:@"more"];
    } else if (user != nil && identifier != nil) {
        // XXX: should this be more strict about what's a valid comment?
        NSMutableDictionary *item = [NSMutableDictionary dictionary];
        [item setObject:user forKey:@"user"];
        if (body != nil) [item setObject:body forKey:@"body"];
        if (date != nil) [item setObject:date forKey:@"date"];
        if (points != nil) [item setObject:points forKey:@"points"];
        if (depth != nil) [item setObject:[NSMutableArray array] forKey:@"children"];
        if (depth != nil) [item setObject:depth forKey:@"depth"];
        if (parent != nil) [item setObject:parent forKey:@"parent"];
        if (submission != nil) [item setObject:submission forKey:@"submission"];

        [item setObject:identifier forKey:@"identifier"];
        
        return item;
    } else {
        NSLog(@"Bug: Unable to parse comment.");
        return nil;
    }
}

- (NSDictionary *)parseCommentTreeInDocument:(XMLDocument *)document {
    HNPageLayoutType type = [self pageLayoutTypeForDocument:document];
    
    XMLElement *rootElement = [self rootElementForDocument:document pageLayoutType:type];
    NSMutableDictionary *root = nil;
    if (rootElement != nil) {
        NSDictionary *item = nil;
        if ([self rootElementIsSubmission:document]) 
            item = [self parseSubmissionWithElements:[rootElement children]];
        else 
            item = [self parseCommentWithElement:[[rootElement children] objectAtIndex:0]];
        root = [[item mutableCopy] autorelease];
    }
    if (root == nil) root = [NSMutableDictionary dictionary];
    [root setObject:[NSMutableArray array] forKey:@"children"];
    
    NSArray *comments = [self contentRowsForDocument:document pageLayoutType:type];
    NSMutableArray *lasts = [NSMutableArray array];
    [lasts addObject:root];
    
    NSString *moreToken = nil;
    
    for (int i = 0; i < [comments count]; i++) {
        XMLElement *element = [comments objectAtIndex:i];
        if ([[element content] length] == 0) continue;
        NSDictionary *comment = [self parseCommentWithElement:element];
        if (comment == nil) continue;
        
        if ([comment objectForKey:@"more"] != nil) {
            moreToken = [comment objectForKey:@"more"];
            continue;
        }
        
        NSDictionary *parent = nil;
        NSNumber *depth = [comment objectForKey:@"depth"];
        
        if (depth != nil) {
            if ([depth intValue] >= [lasts count]) continue;
            if ([lasts count] >= [depth intValue])
                [lasts removeObjectsInRange:NSMakeRange([depth intValue] + 1, [lasts count] - [depth intValue] - 1)];
            parent = [lasts lastObject];
            [lasts addObject:comment];
        } else {
            parent = root;
        }
        
        NSMutableArray *children = [parent objectForKey:@"children"];
        [children addObject:comment];
    }
    
    if (moreToken != nil) [root setObject:moreToken forKey:@"more"];
    
    return root;
}

- (NSDictionary *)parseSubmissionsInDocument:(XMLDocument *)document {
    HNPageLayoutType type = [self pageLayoutTypeForDocument:document];
    NSArray *submissions = [self contentRowsForDocument:document pageLayoutType:type];
    
    NSMutableArray *result = [NSMutableArray array];
    NSString *moreToken = nil;

    // Three rows are used per submission.
    for (int i = 0; i < [submissions count]; i += 3) {
        XMLElement *first = [submissions objectAtIndex:i];
        XMLElement *second = i + 1 < [submissions count] ? [submissions objectAtIndex:i + 1] : nil;
        XMLElement *third = i + 2 < [submissions count] ? [submissions objectAtIndex:i + 2] : nil;
        
        NSDictionary *submission = [self parseSubmissionWithElements:[NSArray arrayWithObjects:first, second, third, nil]];
        if (submission != nil) {
            if ([submission objectForKey:@"more"] != nil) {
                moreToken = [submission objectForKey:@"more"];
            } else {
                [result addObject:submission];
            }
        }
    }
    
    NSMutableDictionary *item = [NSMutableDictionary dictionary];
    [item setObject:result forKey:@"children"];
    if (moreToken != nil) [item setObject:moreToken forKey:@"more"];
    return item;
}

- (NSDictionary *)parseWithString:(NSString *)string {
    NSDictionary *result = nil;
    XMLDocument *document = [[XMLDocument alloc] initWithHTMLData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    
    // XXX: these are quite random and not perfect
    XMLElement *userLabel = [document firstElementMatchingPath:@"//body/center/table/tr[3]/td/form/table/tr/td"];
    XMLElement *commentSpan = [document firstElementMatchingPath:@"//span[@class='comment']"];
        
    if (userLabel != nil && [[userLabel content] hasPrefix:@"user:"]) {
        result = [self parseUserProfileWithString:string];
    } else if (commentSpan != nil) {
        result = [self parseCommentTreeInDocument:document];
    } else {
        result = [self parseSubmissionsInDocument:document];
    }
    
    [document release];
    return result;
}

- (void)dealloc {
    [super dealloc];
}

@end
