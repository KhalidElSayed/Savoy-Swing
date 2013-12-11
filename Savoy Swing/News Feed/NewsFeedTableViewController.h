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
#import "SSCNewsFeeds.h"
#import "NewsFeedCell.h"

@interface NewsFeedTableViewController : STableViewController {
    SSCAppDelegate *theAppDel;
    
    //preloading image
    UIImageView *loaderImageView;
    UILabel *loadingLabel;
    UIActivityIndicatorView *imageIndicator;
    
    //news loading
    BOOL loadingFromMemory;
}

@property (strong, retain) NewsFeedSettingsViewController *newsSettings;
@property (strong, nonatomic) NewsFeedDetailViewController *detailView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *newsSettingsButton;
@property (strong, nonatomic) UIImageView *home_background;
@property (strong,retain) NSMutableArray *imageArr;
@property (nonatomic) CGFloat basicCellHeight;
@property (strong)  NSTimer *refreshImage;
@property (strong)  NSTimer *detectData;
@property (nonatomic, strong) NSMutableArray *allData;
@property (nonatomic, strong) NSMutableArray *archivedData;
@property (nonatomic, retain) UITableViewCell *imageSlider;
@property (nonatomic, retain) UITableViewCell *BasicCell;

//preloading image
@property (strong)  NSTimer *loadingScreenText;

//convert to NewsFeed Class
@property (nonatomic, strong) NSArray *TwitterStatuses;
@property (nonatomic, strong) NSArray *FacebookPosts;
@property (strong)  NSTimer *sortCellLoader;
@property (strong)  NSTimer *tweetLoader;

//the methods
-(void) startLoading;
-(void) updateLoadingScreen;
-(void) finalizeFeed;
-(BOOL) listByRows;
-(NSInteger) rowsOrSectionsReturn: (NSIndexPath*) indexPath;
-(void) newNewsPostDetected;
-(void) pinHeaderView;
-(void) unpinHeaderView;
-(BOOL) refresh;
-(void) refreshCompleted;
-(void) willBeginLoadingMore;
-(void) loadMoreCompleted;
-(BOOL) loadMore;
-(void) loadImages;
-(void) switchImageView;
-(void) showNewsSettings:(id) sender;
-(void) returnToNewsFeedDetail:(id) sender;
-(void) removePreviousCellInfoFromView: (UITableViewCell*) cell;


@end
