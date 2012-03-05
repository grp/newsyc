//
//  XMLElement.m
//  newsyc
//
//  Created by Grant Paul on 3/10/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "XMLElement.h"
#import "XMLDocument.h"

static int XMLElementOutputWriteCallback(void *context, const char *buffer, int len) {
    NSMutableData *data = context;
    [data appendBytes:buffer length:len];
    return len;
}

static int XMLElementOutputCloseCallback(void *context) {
    NSMutableData *data = context;
    [data release];
    return 0;
}

@implementation XMLElement

- (void)dealloc {
    [cachedChildren release];
    [cachedAttributes release];
    [cachedContent release];
    [document release];
    
    [super dealloc];
}

- (id)initWithNode:(xmlNodePtr)node_ inDocument:(XMLDocument *)document_ {
    if ((self = [super init])) {
        node = node_;
        document = [document_ retain];
    }

    return self;
}

- (NSString *)content {
    if (cachedContent != nil) return cachedContent;
    
    NSMutableString *content = [[NSMutableString string] retain];
    
    if (![self isTextNode]) {
        xmlNodePtr children = node->children;
    
        while (children) {
            NSMutableData *data = [[NSMutableData alloc] init];
            xmlOutputBufferPtr buffer = xmlOutputBufferCreateIO(XMLElementOutputWriteCallback, XMLElementOutputCloseCallback, data, NULL);
            xmlNodeDumpOutput(buffer, [document document], children, 0, 0, "utf-8");
            xmlOutputBufferFlush(buffer);
            [content appendString:[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]];
            xmlOutputBufferClose(buffer);
            
            children = children->next;
        }
    } else {
        xmlChar *nodeContent = xmlNodeGetContent(node);
        [content appendString:[NSString stringWithUTF8String:(char *) nodeContent]];
        xmlFree(nodeContent);
    }
    
    cachedContent = content;
    return cachedContent;
}


- (NSString *)tagName {
    if ([self isTextNode]) return nil;
    
    char *nodeName = (char *) node->name;
    if (nodeName == NULL) nodeName = "";
    
    NSString *name = [NSString stringWithUTF8String:nodeName];
    return name;
}

- (NSArray *)children {
    if (cachedChildren != nil) return cachedChildren;
    
    xmlNodePtr list = node->children;
    NSMutableArray *children = [NSMutableArray array];
        
    while (list) {
        XMLElement *element = [[XMLElement alloc] initWithNode:list inDocument:document];
        [children addObject:[element autorelease]];
        
        list = list->next;
    }
    
    cachedChildren = [children retain];
    return cachedChildren;
}

- (NSDictionary *)attributes {
    if (cachedAttributes != nil) return cachedAttributes;
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    xmlAttrPtr list = node->properties;
    
    while (list) {
        NSString *name = nil, *value = nil;
        
        name = [NSString stringWithCString:(const char *) list->name encoding:NSUTF8StringEncoding];
        if (list->children != NULL && list->children->content != NULL) {
            value = [NSString stringWithCString:(const char *) list->children->content encoding:NSUTF8StringEncoding];
        }
        
        if (name != nil && value != nil) {
            [attributes setObject:value forKey:name];
        }
                    
        list = list->next;
    }

    cachedAttributes = [attributes retain];
    return cachedAttributes;
}

- (NSString *)attributeWithName:(NSString *)name {
    return [[self attributes] objectForKey:name];
}

- (BOOL)isTextNode {
    return node->type == XML_TEXT_NODE;
}

@end
