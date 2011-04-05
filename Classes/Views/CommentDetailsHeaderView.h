//
//  CommentDetailsHeaderView.h
//  newsyc
//
//  Created by Grant Paul on 3/6/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "DetailsHeaderView.h"

#import "DTAttributedTextView.h"

@interface CommentDetailsHeaderView : DetailsHeaderView <UIActionSheetDelegate, DTAttributedTextViewDelegate> {
    DTAttributedTextView *textView;
    NSURL *savedURL;
}

@end
