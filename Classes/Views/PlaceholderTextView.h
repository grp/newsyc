//
//  PlaceholderTextView.h
//  newsyc
//
//  Created by Grant Paul on 4/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@interface PlaceholderTextView : UITextView {
    UILabel *placeholderLabel;
    NSString *placeholder;
}

@property (nonatomic, copy) NSString *placeholder;

@end
