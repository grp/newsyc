//
//  InstapaperAPI.h
//  newsyc
//
//  Created by Grant Paul on 3/10/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "NSString+URLEncoding.h"

#define kInstapaperAPIRootURL [NSURL URLWithString:@"https://instapaper.com/api/"]
#define kInstapaperAPIAuthenticationURL [NSURL URLWithString:[[kInstapaperAPIRootURL absoluteString] stringByAppendingString:@"authenticate"]]
#define kInstapaperAPIAddItemURL [NSURL URLWithString:[[kInstapaperAPIRootURL absoluteString] stringByAppendingString:@"add"]]
