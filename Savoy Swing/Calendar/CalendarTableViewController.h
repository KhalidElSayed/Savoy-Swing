//
//  CalendarTableViewController.h
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/18/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalendarTableViewController : UITableViewController {
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
@property (strong)  NSTimer *loadingScreenText;


-(void) startLoading;

@end
