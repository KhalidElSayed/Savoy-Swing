//
//  CalendarTableViewCell.h
//  Savoy Swing
//
//  Created by Steven Stevenson on 12/11/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCAppDelegate.h"

@interface CalendarTableViewCell : UITableViewCell


@property (nonatomic, strong) NSDate *theDate;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *sub_title;
@property (nonatomic, strong) UILabel *main_text;
@property (nonatomic, strong) UIImageView *google_stamp;
@property (nonatomic, strong) NSDictionary *thisEvent;

- (void)prepareCell: (NSDictionary*) thisEvent onDate: (id) theDate;
- (void)addGoogleInfo;

@end
