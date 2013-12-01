//
//  CalendarTableViewController.h
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/18/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCAppDelegate.h"

@interface CalendarTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    SSCAppDelegate *theAppDel;
    
    //IBOutlet UITableView *the_tableView;
	NSMutableDictionary *selectedIndexes;
    NSInteger basicCellHeight;
    
    NSMutableDictionary *allBannerEvents;
    NSMutableArray *allDays;
    NSMutableDictionary *theImages;
    
    
    //preloading image
    UIView *preloaderView;
    UIImageView *loaderImageView;
    UILabel *loadingLabel;
    UIActivityIndicatorView *imageIndicator;
}

//preloading image
@property (strong, nonatomic) IBOutlet UITableView *theTableView;


-(void) startLoading;

@end


@interface CalendarCellView : UIView

@end
