//
//  HNAPIParserItemCommentTree.m
//  Orangey
//
//  Created by Grant Paul on 3/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNAPIParserItemCommentTree.h"
#import "TFHpple.h"

@implementation HNAPIParserItemCommentTree

- (int)depthFromWidth:(int)width {
    return width / 40;
}

/*- (NSString *)extactTextFrom:(TFHppleElement *)e {
    NSMutableString *m = [[[e content] stringByAppendingString:@"\n\n"] mutableCopy] ?: [@"" mutableCopy];
    for (TFHppleElement *el in [e children]) {
        [m appendFormat:@"%@\n\n", [self extactTextFrom:el]];
    }
    if ([m length] >= 2) [m deleteCharactersInRange:NSMakeRange([m length] - 2, 2)];
    return m;
}*/

- (id)parseString:(NSString *)string options:(NSDictionary *)options {
    TFHpple *hpple = [[TFHpple alloc] initWithHTMLData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    NSMutableArray *result = [NSMutableArray array];
    
    NSMutableArray *lasts = [NSMutableArray array];
    
    NSArray *depths = [hpple elementsMatchingPath:@"//table//table//tr//td[1]//img[@src='http://ycombinator.com/images/s.gif']"];
    //NSArray *ups = [hpple elementsMatchingPath:@"//table//tr//td//table//tr//td//a[starts-with(@id,'up')]"];
    //NSArray *downs = [hpple elementsMatchingPath:@"//table//tr//td//table//tr//td//a[starts-with(@id,'down')]"];
    NSArray *bodies = [depths count] > 0 ? [hpple elementsMatchingPath:@"//table//table[last()]//span[@class='comment']"] : [hpple elementsMatchingPath:@"//table//table//span[@class='comment']"];
    NSArray *users = [hpple elementsMatchingPath:@"//table//table//tr//td[@class!='title']//span[@class='comhead']//a[starts-with(@href,'user?id=')]"];
    NSArray *links = [hpple elementsMatchingPath:@"//table//table//tr//td[@class!='title']//span[@class='comhead']//a[starts-with(@href,'item?id=')]"];
    NSArray *agos = [hpple elementsMatchingPath:@"//table//table//tr//td[@class!='title']//span[@class='comhead']"];
    NSArray *points = [hpple elementsMatchingPath:@"//table//table//tr//td[@class!='title']//span[@class='comhead']//span[starts-with(@id,'score')]"];
    
    for (int i = 0; i < [bodies count]; i++) {
        TFHppleElement *depth = [depths count] == 0 ? nil : [depths objectAtIndex:i];
        TFHppleElement *body = [bodies objectAtIndex:i];
        //TFHppleElement *up = [ups objectAtIndex:i];
        //TFHppleElement *down = [downs objectAtIndex:i];
        TFHppleElement *point = [points objectAtIndex:i];
        TFHppleElement *user = [users objectAtIndex:i];
        TFHppleElement *link = [links objectAtIndex:i];
        TFHppleElement *ago = [agos objectAtIndex:i];
        
        NSMutableDictionary *item = [NSMutableDictionary dictionary];
        NSString *pointscontent = [point content];
        NSNumber *numpoints = [NSNumber numberWithInt:[[pointscontent substringToIndex:[pointscontent rangeOfString:@" "].location] intValue]];
        [item setObject:numpoints forKey:@"points"];
        
        [item setObject:[user content] forKey:@"user"];
        
        NSLog(@"body: %@", [body content]);
        [item setObject:[body content] forKey:@"body"];
        
        NSString *identifiercontent = [[link objectForKey:@"href"] substringFromIndex:[@"item?id=" length]];
   
        [item setObject:[NSNumber numberWithInt:[identifiercontent intValue]] forKey:@"identifier"];
        
        int end = [[ago content] rangeOfString:@" ago"].location;
        if (end != NSNotFound) {
            NSString *agoval = [[ago content] substringToIndex:end];
            [item setObject:agoval forKey:@"ago"];
        }
        
        int level = [self depthFromWidth:[[depth objectForKey:@"width"] intValue]];
        
        if (depth != nil) {
            NSArray *children = [NSMutableArray array];
            [item setObject:children forKey:@"children"];
        }
        
        if ([lasts count] >= level) [lasts removeObjectsInRange:NSMakeRange(level, [lasts count] - level)];
        [lasts addObject:item];
        
        if (level == 0) [result addObject:item];
        else {
            NSMutableArray *ch = [[lasts objectAtIndex:level - 1] objectForKey:@"children"];
            if (ch == nil) {
                ch = [NSMutableArray array];
                [[lasts objectAtIndex:level - 1] setObject:ch forKey:@"children"];
            }
            [ch addObject:item];
        }
    }
    
    [hpple release];
    
    NSMutableDictionary *item = [NSMutableDictionary dictionary];
    [item setObject:result forKey:@"children"];
    return item;
}

@end
