//
//  HNUser.h
//  newsyc
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HNObject.h"

@interface HNUser : HNObject {
    NSInteger karma;
    float average;
    NSString *created;
    NSString *about;
}

@property (nonatomic, assign) NSInteger karma;
@property (nonatomic, assign) float average;
@property (nonatomic, copy) NSString *created;
@property (nonatomic, copy) NSString *about;

+ (id)userWithIdentifier:(id)identifier_;

@end
