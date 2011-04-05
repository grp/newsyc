//
//  NSURL+Parameters.h
//  Telekinesis
//
//  Created by Nicholas Jitkoff on 6/14/07.
//  Copyright 2007 Xuzz Productions, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (Parameters) 
- (NSArray *)parameterArray;
- (NSDictionary *)parameterDictionary;
@end
