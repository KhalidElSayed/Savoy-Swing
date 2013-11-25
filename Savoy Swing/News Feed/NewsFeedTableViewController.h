//
//  NewsFeedTableViewController.h
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/18/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsFeedSettingsViewController.h"
#import "NewsFeedDetailViewController.h"
#import "SSCAppDelegate.h"
#import "STableViewController.h"

@interface NewsFeedTableViewController : STableViewController {
    BOOL twitterReady;
    BOOL facebookReady;
    SSCAppDelegate *theAppDel;
    UIImageView *loaderImageView;
    UILabel *loadingLabel;
    UIActivityIndicatorView *imageIndicator;
    BOOL twitterActive;
    BOOL facebookActive;
    NSString *newFacebookPostLink;
    NSString *laterFacebookPostLink;
    NSString *newestTwitterID;
    NSString *oldestTwitterID;
    
    //testing
    NSMutableArray *items;
}

@property (strong, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *newsSettingsButton;
@property (strong, nonatomic) NewsFeedDetailViewController *detailView;
@property (strong, nonatomic) UIImageView *home_background;
@property (strong,retain) NSMutableArray *imageArr;
@property (nonatomic) CGFloat basicCellHeight;
@property (strong, retain) NewsFeedSettingsViewController *newsSettings;
@property (strong)  NSTimer *refreshImage;
@property (strong)  NSTimer *tweetLoader;
@property (strong)  NSTimer *sortCellLoader;
@property (nonatomic, strong) NSArray *TwitterStatuses;
@property (nonatomic, strong) NSArray *FacebookPosts;
@property (nonatomic, strong) NSMutableArray *allData;
@property (nonatomic, strong) NSMutableArray *archivedData;
@property (strong) NSMutableDictionary *theCells;
// The view used for "load more"
@property (nonatomic, retain) UITableViewCell *imageSlider;
@property (nonatomic, retain) UITableViewCell *BasicCell;
@end
