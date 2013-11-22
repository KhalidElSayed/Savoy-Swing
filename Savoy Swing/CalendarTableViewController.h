//
//  CalendarTableViewController.h
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/18/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalendarTableViewController : UITableViewController{
	IBOutlet UITableView *demoTableView;
	NSMutableDictionary *selectedIndexes;
    NSMutableDictionary *banner_events_weekly;
    NSMutableArray *days;
    NSMutableDictionary *theCells;
}

@property (nonatomic, strong) NSArray *mondays;
@property (nonatomic, strong) NSArray *tuesdays;
@property (nonatomic) int basicCellHeight;

@end
