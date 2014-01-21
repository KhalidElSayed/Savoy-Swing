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

@interface NewsFeedTableViewController : STableViewController 

//the methods
-(void) startLoading;
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
