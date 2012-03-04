//
//  XMLElement.h
//  newsyc
//
//  Created by Grant Paul on 3/10/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import <libxml/tree.h>
#import <libxml/parser.h>
#import <libxml/HTMLparser.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>

@class XMLDocument;
@interface XMLElement : NSObject {
    xmlNodePtr node;
    XMLDocument *document;
    
    NSArray *cachedChildren;
    NSDictionary *cachedAttributes;
    NSString *cachedContent;
}

- (id)initWithNode:(xmlNodePtr)node_ inDocument:(XMLDocument *)document_;
- (NSString *)content;
- (NSString *)tagName;
- (NSArray *)children;
- (NSDictionary *)attributes;
- (NSString *)attributeWithName:(NSString *)name;
- (BOOL)isTextNode;

@end
