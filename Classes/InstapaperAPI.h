//
//  InstapaperAPI.h
//  newsyc
//
//  Created by Grant Paul on 3/10/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "StatusDelegate.h"
#import "NSString+URLEncoding.h"

#define kInstapaperAPIRootURL [NSURL URLWithString:@"https://instapaper.com/api/"]
#define kInstapaperAPIAuthenticateURL [NSURL URLWithString:[[kInstapaperAPIRootURL absoluteString] stringByAppendingString:@"authenticate"]]
#define kInstapaperAPIAddItemURL [NSURL URLWithString:[[kInstapaperAPIRootURL absoluteString] stringByAppendingString:@"add"]]

@interface InstapaperAPI : NSObject {
    NSString *username;
    NSString *password;
    id<StatusDelegate> delegate;
}

+ (id)sharedInstance;

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, assign) id<StatusDelegate> delegate;

- (BOOL)canAddItems;
- (void)addItemWithURL:(NSURL *)url title:(NSString *)title selection:(NSString *)selection;
- (void)addItemWithURL:(NSURL *)url title:(NSString *)title;
- (void)addItemWithURL:(NSURL *)url;

@end
