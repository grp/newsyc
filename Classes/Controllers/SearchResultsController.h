//
//  SearchResultsController.h
//  newsyc
//
//  Created by Quin Hoxie on 6/3/11.
//

#import <UIKit/UIKit.h>


@interface SearchResultsController : UITableViewController {
	NSMutableArray *entries;
}

@property (nonatomic, retain) NSMutableArray *entries;

@end
