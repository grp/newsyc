//
//  XMLDocument.m
//  newsyc
//
//  Created by Grant Paul on 3/10/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

// Lazy-loading-ish wrapper for libxml2.
// Not the most amazing stuff, but hey, it works fine.
// (Somewhat inspired by "Hpple", but rewritten.)

#import "XMLDocument.h"
#import "XMLElement.h"

@implementation XMLDocument

- (void)dealloc {
    xmlFreeDoc(document);
    [super dealloc];
}

- (id)initWithData:(NSData *)data isXML:(BOOL)xml {
    if ((self = [super init])) {
        document = (xml ? xmlReadMemory : htmlReadMemory)([data bytes], [data length], "", NULL, xml ? XML_PARSE_RECOVER : HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);
        
        if (document == NULL) {
            [self autorelease];
            return nil;
        }
    }

    return self;
}

- (xmlDocPtr)document {
    return document;
}

- (id)initWithXMLData:(NSData *)data_ {
    return [self initWithData:data_ isXML:YES];
}

- (id)initWithHTMLData:(NSData *)data_ {
  return [self initWithData:data_ isXML:NO];
}

- (NSArray *)elementsMatchingPath:(NSString *)query {
    xmlXPathContextPtr xpathCtx;
    xmlXPathObjectPtr xpathObj;
    
    xpathCtx = xmlXPathNewContext(document);
    if (xpathCtx == NULL) return nil;
    
    xpathObj = xmlXPathEvalExpression((xmlChar *) [query cStringUsingEncoding:NSUTF8StringEncoding], xpathCtx);
    if (xpathObj == NULL) return nil;
    
    xmlNodeSetPtr nodes = xpathObj->nodesetval;
    if (nodes == NULL) return nil;
    
    NSMutableArray *result = [NSMutableArray array];
    for (int i = 0; i < nodes->nodeNr; i++) {
        XMLElement *element = [[XMLElement alloc] initWithNode:nodes->nodeTab[i] inDocument:self];
        [result addObject:[element autorelease]];
    }
    
    xmlXPathFreeObject(xpathObj);
    xmlXPathFreeContext(xpathCtx);
    
    return result;
}

- (XMLElement *)firstElementMatchingPath:(NSString *)xpath {
    NSArray *elements = [self elementsMatchingPath:xpath];
    
    if ([elements count] >= 1) {
        return [elements objectAtIndex:0];
    } else {
        return nil;
    }
}

@end
