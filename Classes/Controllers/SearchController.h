//
//  SearchController.h
//  newsyc
//
//  Created by Quin Hoxie on 6/2/11.
//

#import <UIKit/UIKit.h>
#import "HNAPISearch.h"

@interface SearchController : UIViewController {
	IBOutlet UIButton *searchButton;
    IBOutlet UITextField *searchQuery;
	IBOutlet UISegmentedControl *facetControl;
	HNAPISearch *searchAPI;
}

@property (nonatomic, retain) IBOutlet UIButton *searchButton;
@property (nonatomic, retain) IBOutlet UITextField *searchQuery;
@property (nonatomic, retain) IBOutlet UISegmentedControl *facetControl;

-(IBAction)performSearch:(id)sender;
-(IBAction)textFieldReturn:(id)sender;
-(IBAction)backgroundTouched:(id)sender;
-(IBAction)facetSelected:(id)sender;

@end
