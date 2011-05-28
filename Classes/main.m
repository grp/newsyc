//
//  main.m
//  newsyc
//
//  Created by Grant Paul on 3/3/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

int main(int argc, char **argv) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int ret = UIApplicationMain(argc, argv, nil, @"AppDelegate");
    [pool release];
    return ret;
}
