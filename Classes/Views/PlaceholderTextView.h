//
//  PlaceholderTextView.h
//  newsyc
//
//  Created by Grant Paul on 4/1/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

// For some unknown reason, UITextView doesn't have a "placeholder"
// property like UITextField does. I have no idea why Apple didn't
// include that, but this adds it using UILabel and a bunch of
// probably-broken logic.

@interface PlaceholderTextView : UITextView {
    UILabel *placeholderLabel;
    NSString *placeholder;
}

@property (nonatomic, copy) NSString *placeholder;

@end
