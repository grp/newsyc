//
//  OrangeNavigationBar.h
//  newsyc
//
//  Created by Grant Paul on 9/28/13.
//
//

#import <UIKit/UIKit.h>

@class OrangeBarView;

@interface OrangeNavigationBar : UINavigationBar {
    OrangeBarView *barView;
    
    NSTimer *_partyTimer;
    float partyHue;
}

@property (nonatomic, assign) BOOL orange;

@property (nonatomic, assign) BOOL shouldParty;

@end
