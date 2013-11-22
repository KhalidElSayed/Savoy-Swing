//
//  NewsFeedTableViewController.h
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/18/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsFeedSettingsViewController.h"

@interface NewsFeedTableViewController : UITableViewController {
    BOOL tweetsReady;
    BOOL twitterReady;
}

@property (strong, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *newsSettingsButton;
@property (strong, nonatomic) UIImageView *home_background;
@property (strong,retain) NSMutableArray *imageArr;
@property (strong, nonatomic) UIActivityIndicatorView *imageIndicator;
@property (nonatomic) CGFloat basicCellHeight;
@property (strong, retain) NewsFeedSettingsViewController *newsSettings;
@property (strong)  NSTimer *refreshImage;
@property (strong)  NSTimer *tweetLoader;
@property (nonatomic, strong) NSArray *TwitterStatuses;
@property (nonatomic, strong) NSDictionary *FacebookPosts;
@property (strong) NSMutableDictionary *theCells;
@property (nonatomic, strong) NSDictionary *allData;

@end
