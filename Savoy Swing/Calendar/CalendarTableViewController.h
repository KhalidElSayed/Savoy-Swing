//
//  CalendarlTableViewController.h
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/18/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCAppDelegate.h"
#import "CalendarHorizontalCell.h"

@interface CalendarTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, HorizontalCellDelegate> {
    SSCAppDelegate *theAppDel;
    
    //IBOutlet UITableView *the_tableView;
	NSMutableDictionary *selectedIndexes;
    NSInteger basicCellHeight;
    
    NSMutableDictionary *allWeeklyBannerEvents;
    NSMutableArray *allDays;
    NSMutableDictionary *theImages;
    
    
    //preloading image
    UIView *preloaderView;
    UIImageView *loaderImageView;
    UILabel *loadingLabel;
    UIActivityIndicatorView *imageIndicator;
    
    //calendar switch
    UISegmentedControl *calendar_switch;
}

//preloading image
@property (strong, nonatomic) IBOutlet UITableView *theTableView;

//calendar date cell
@property (nonatomic, retain) CalendarHorizontalCell *horizontalDateCell;
//monthly calendar data
@property (strong,nonatomic) NSMutableArray *currentDateCells;
@property (strong,nonatomic) NSDate *currentDate;
@property (strong,nonatomic) NSMutableDictionary *specificDateEvents;


-(void) startLoading;

@end


@interface CalendarCellView : UIView

@end
