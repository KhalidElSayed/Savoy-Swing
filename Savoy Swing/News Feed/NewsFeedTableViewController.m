//
//  NewsFeedTableViewController.m
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/18/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "NewsFeedTableViewController.h"
#import "SWRevealViewController.h"
#import "SSCNewsFeeds.h"
#import "STTwitter.h"
#import "SSCData.h"
#import "NewsFeedFooterView.h"
#import "NewsFeedHeaderView.h"

@interface NewsFeedTableViewController  ()
@property (nonatomic, strong) STTwitterAPI* _twitter;
@end

@implementation NewsFeedTableViewController

@synthesize home_background;
@synthesize imageArr;
@synthesize basicCellHeight;
@synthesize newsSettings;
@synthesize detailView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //basic Cell Height
    self.basicCellHeight = 120.0f;
    
    theAppDel = (SSCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //setup header title
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:22.0];
    label.textAlignment = NSTextAlignmentCenter;
    // ^-Use UITextAlignmentCenter for older SDKs.
    label.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = label;
    label.text = NSLocalizedString(@"News Feed", @"");
    [label sizeToFit];
    
    
    // set the custom view for "pull to refresh". See DemoTableHeaderView.xib.
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NewsFeedHeaderView" owner:self options:nil];
    NewsFeedHeaderView *headerView = (NewsFeedHeaderView *)[nib objectAtIndex:0];
    headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 55.0f);
    [self setHeaderView: headerView];
    
    // set the custom view for "load more". See DemoTableFooterView.xib.
    nib = [[NSBundle mainBundle] loadNibNamed:@"NewsFeedFooterView" owner:self options:nil];
    NewsFeedFooterView *footerView = (NewsFeedFooterView *)[nib objectAtIndex:0];
    self.footerView = footerView;
    
    // set the first image slider view
    nib = [[NSBundle mainBundle] loadNibNamed:@"NewsFeedImageSliderView" owner:self options:nil];
    _imageSlider =[nib objectAtIndex:0];
    
    // set the generic table cell
    nib = [[NSBundle mainBundle] loadNibNamed:@"NewsFeedEmptyCell" owner:self options:nil];
    _BasicCell =[nib objectAtIndex:0];
    
    self.tableView.separatorColor = [UIColor groupTableViewBackgroundColor];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.tintColor = [UIColor whiteColor];
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    //sub control views
    self.newsSettings = [self.storyboard instantiateViewControllerWithIdentifier:@"newsSettings"];
    self.detailView = [self.storyboard instantiateViewControllerWithIdentifier:@"detailView"];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _newsSettingsButton.tintColor = [UIColor whiteColor];
    _newsSettingsButton.target = self;
    _newsSettingsButton.action = @selector(showNewsSettings:);
    
    UIColor *backgroundColor = [UIColor colorWithRed:235.0/255.0 green:119.0/255.0 blue:24.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.barTintColor = backgroundColor;
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}


-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    facebookActive = theAppDel.newsFeedFacebookActive;
    twitterActive = theAppDel.newsFeedTwitterActive;
    
    loadingLabel.text = @"Initializing Features";
    [self startLoading];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //put graphic image for loading graphic
    self.navigationController.navigationBarHidden = YES;
    loaderImageView =[[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    
    UIImage *theImage = [UIImage imageNamed:@"R4Default.png"];
    loaderImageView.image = theImage;
    imageIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    loadingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    loadingLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:22.0];
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.textColor = [UIColor whiteColor];
    loadingLabel.text = @"Loading Application Data";
    [loadingLabel sizeToFit];
    loadingLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, loadingLabel.frame.size.height);
    loadingLabel.center = CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height / 2)+160);
    
    [self.view addSubview:loaderImageView];
    [self.view addSubview: imageIndicator];
    [imageIndicator startAnimating];
    imageIndicator.center = CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height / 2)+120);
    [self.view addSubview:loadingLabel];
}

- (void) startLoading {
    [self makeFeeds];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    theAppDel.newsFeedData = _allData;
    _TwitterStatuses = nil;
    _FacebookPosts = nil;
    self.navigationController.title = @"News";
}


-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (_refreshImage != nil ) {
        [_refreshImage invalidate];
        _refreshImage = nil;
    }
    theAppDel.newsFeedData = _allData;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
/*
 *
 *
 *      ///////////////////////////// General Feed Methods
 *
 *
 */
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

-(void) makeFeeds {
    if (!theAppDel.newsFeedData) {
        loadingLabel.text = @"Loading News Feeds";
        if (twitterActive) {
            [self makeTweetFeed: nil];
        } else {
            twitterReady = YES;
        }
        if (facebookActive) {
            [self makeFacebookFeed:@"SavoySwingClub" requestType:nil];
        } else {
            facebookReady = YES;
        }
        _sortCellLoader = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(sortInitialObjects) userInfo:nil repeats:YES];
    } else {
        _allData = theAppDel.newsFeedData;
        [self initializeCellData];
    }
    
}

-(void) sortInitialObjects {
    [self sortObjects];
    [self performSelector:@selector(initializeCellData) withObject:nil afterDelay:2.0];
}

-(void) sortObjects {
    if (twitterReady && facebookReady) {
        loadingLabel.text = @"Sorting News Feed";
        [_sortCellLoader invalidate];
        _sortCellLoader = nil;
        if ( !_FacebookPosts ) {
            _allData =  [_TwitterStatuses mutableCopy];
        } else {
            _allData = [[NSMutableArray alloc] init];
            
            NSInteger fb_count = 0;
            NSInteger twi_count = 0;
            NSInteger totalData =([_FacebookPosts count]+[_TwitterStatuses count]);
            for (int i=0; i<totalData;i++ ){
                //facebook date
                NSDate *fb_date;
                if (fb_count < [_FacebookPosts count]) {
                    NSDictionary *fb_obj = [_FacebookPosts objectAtIndex:fb_count];
                    if (![fb_obj valueForKeyPath:@"message"]) {
                        fb_count++;
                        totalData--;
                        continue;
                    }
                    NSString *fb_unformDate =[fb_obj valueForKeyPath:@"created_time"];
                    NSDateFormatter *fb_dateFormatter = [[NSDateFormatter alloc] init];
                    [fb_dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
                    fb_date = [fb_dateFormatter dateFromString:fb_unformDate];
                }
                
                //twitter date
                NSDate *twi_date;
                if (twi_count < [_TwitterStatuses count]) {
                    NSData *twi_obj = [_TwitterStatuses objectAtIndex:twi_count];
                    NSString *twi_unformDate = [twi_obj valueForKeyPath:@"created_at"];
                    NSDateFormatter *twi_dateFormatter = [[NSDateFormatter alloc] init];
                    [twi_dateFormatter setDateFormat:@"E MMM d HH:mm:ss +0000 yyyy"];
                    twi_date = [twi_dateFormatter dateFromString:twi_unformDate];
                }
                
                if (twi_date && fb_date) {
                    //find most recent date
                    switch ([fb_date compare: twi_date]) {
                        case NSOrderedAscending:{
                            [_allData addObject:[_TwitterStatuses objectAtIndex:twi_count]];
                            twi_count++;
                            break;
                        }
                        case NSOrderedSame: {
                            
                            [_allData addObject:[_FacebookPosts objectAtIndex:fb_count]];
                            fb_count++;
                            break;
                        }
                        case NSOrderedDescending: {
                            
                            [_allData addObject:[_FacebookPosts objectAtIndex:fb_count]];
                            fb_count++;
                            break;
                        }
                    }
                } else if (twi_date) {
                    
                    [_allData addObject:[_TwitterStatuses objectAtIndex:twi_count]];
                    twi_count++;
                } else if (fb_date){
                    
                    [_allData addObject:[_FacebookPosts objectAtIndex:fb_count]];
                    fb_count++;
                }
            }
        }
        NSLog(@"Data Sorted (total entries: %d)",[_allData count]);
        loadingLabel.text = @"Finalizing Display";
    }
}

-(void) initializeCellData {
    
    
    _refreshImage = [NSTimer scheduledTimerWithTimeInterval:12.0 target:self selector:@selector(switchImageView) userInfo:nil repeats:YES];

    [self.tableView reloadData];
    
    [self setHeaderView:self.headerView];
    
    [self loadImages];
    [UIView animateWithDuration:0.25
                          delay:.5
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         loaderImageView.alpha = 0;
                     }completion:^(BOOL finished){
                         self.navigationController.navigationBarHidden = NO;
                         [imageIndicator removeFromSuperview];
                         [loadingLabel removeFromSuperview];
                         [loaderImageView removeFromSuperview];
                     }];


}

-(void) getNewerFeeds {
    twitterReady = NO;
    facebookReady = NO;
    if (twitterActive) {
        [self makeTweetFeed: @"new"];
    } else{
        twitterReady = YES;
    }
    if (facebookActive) {
        [self makeFacebookFeed:@"SavoySwingClub" requestType:@"new"];
    }else{
        twitterReady = NO;
    }
}

-(void) getOlderFeeds {
    twitterReady = NO;
    facebookReady = NO;
    if (twitterActive) {
        [self makeTweetFeed: @"old"];
    }else{
        twitterReady = YES;
    }
    if (facebookActive) {
        [self makeFacebookFeed:@"SavoySwingClub" requestType:@"old"];
    }else{
        twitterReady = NO;
    }
}

-(BOOL) listByRows {
    return YES;
}

-(NSInteger) rowsOrSectionsReturn: (NSIndexPath*) indexPath {
    if ([self listByRows]) {
        return indexPath.row;
    } else {
        return indexPath.section;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
/*
 *
 *
 *      ///////////////////////////// Facebook Feed Methods!
 *
 *
 */
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)makeFacebookFeed: (NSString*) urlName requestType: (NSString*) type {
    NSString *strResult;
    NSString *feedURLString;
    if (![type isEqualToString:@"new"] && ![type isEqualToString:@"old"]) {
        SSCData *sscData = [SSCData new];
        NSString *mainURL = @"https://graph.facebook.com/oauth/access_token";
        NSString *requestString =[NSString stringWithFormat:@"client_id=%@&client_secret=%@&grant_type=client_credentials"
                                  ,sscData.facebookClient_id,
                                  sscData.facebookClient_secret];
        
        NSString *combinedURLString = [NSString stringWithFormat:@"%@?%@",mainURL,requestString];
        NSData *dataURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:combinedURLString]];
        strResult = [[NSString alloc] initWithData:dataURL encoding:NSUTF8StringEncoding];
    }
    if (strResult || [type isEqualToString:@"new"] || [type isEqualToString:@"old"]) {
        NSString *accessToken = strResult;
        NSError *err;
        if ( strResult ) {
            feedURLString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/feed?%@",urlName,accessToken ];
        } else if ([type isEqualToString:@"new"]) {
            feedURLString = newFacebookPostLink;
        } else if ([type isEqualToString:@"old"]) {
            feedURLString = laterFacebookPostLink;
        }
        NSURL *feedURL = [NSURL URLWithString:[feedURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSData *feedData = [NSData dataWithContentsOfURL:feedURL];
        
        if (feedData) {
            NSDictionary *facebookData = [NSJSONSerialization JSONObjectWithData:feedData
                                                                 options:kNilOptions
                                                                   error:&err];
            if (!err) {
                _FacebookPosts = [facebookData objectForKey:@"data"];
                if ([facebookData objectForKey:@"paging"]) {
                    newFacebookPostLink = [[facebookData objectForKey:@"paging"] objectForKey:@"previous"];
                    laterFacebookPostLink = [[facebookData objectForKey:@"paging"] objectForKey:@"next"];
                }
                NSLog(@"Facebook Feed Success!");
                facebookReady = YES;
            } else {
                NSLog(@"-- error: %@",err);
            }
        } else {
            NSLog(@"-- error: no Response!");
        }
    } else {
        NSLog(@"-- error: no Token Received!");
    }
}

-(UITableViewCell *) addFacebookCell: (UITableViewCell *) theCell withPath: (NSIndexPath *) indexPath {
    NSDictionary *fbPost = [_allData objectAtIndex:[self rowsOrSectionsReturn:indexPath]-1];
    
    UILabel *tag = [[UILabel alloc] initWithFrame:CGRectMake(77.0f, 13.0f, 219.0f, 22.0f)];
    tag.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:17.0];
    tag.textAlignment = NSTextAlignmentLeft;
    tag.textColor = [UIColor blackColor];
    tag.text = [NSString stringWithFormat:@"%@:",[[fbPost valueForKeyPath:@"from"] valueForKey:@"name"]];
    [tag sizeToFit];
    
    NSString *fbDate =[fbPost valueForKeyPath:@"created_time"];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSDate *thisDate = [dateFormatter dateFromString:fbDate];
    [dateFormatter setDateFormat:@"E MMM, d yyyy hh:mm"];
    NSString *thisDateText = [dateFormatter stringFromDate:thisDate];
    
    UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(77.0f, 32.0f, 219.0f, 22.0f)];
    date.tag = 101;
    date.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:11.5];
    date.textAlignment = NSTextAlignmentLeft;
    date.textColor = [UIColor blackColor];
    date.text = thisDateText;
    [date sizeToFit];
    
    
    NSString *message =[fbPost valueForKeyPath:@"message"];
    NSRange foundRange = [message rangeOfString:@"\n"];
    if (foundRange.location != NSNotFound) {
        message = [message stringByReplacingOccurrencesOfString:@"\n"
                                            withString:@""
                                               options:0
                                                 range:foundRange];
    }
    
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(77.0f, 43.0f, 219.0f, 56.0f)];
    text.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:14.0];
    text.textAlignment = NSTextAlignmentLeft;
    text.textColor = [UIColor blackColor];
    text.text = message;
    text.lineBreakMode = NSLineBreakByWordWrapping;
    text.numberOfLines = 0;
    //[text sizeToFit];
    
    [theCell.contentView addSubview:tag];
    [theCell.contentView addSubview:date];
    [theCell.contentView addSubview:text];
    
    return theCell;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
/*
 *
 *
 *      ///////////////////////////// Twitter Feed Methods!
 *
 *
 */
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

-(void) makeTweetFeed: (NSString*) type {
    SSCData *sscData = [SSCData new];
    __twitter =
    [STTwitterAPI twitterAPIWithOAuthConsumerName:sscData.twitterConsumerName
                                      consumerKey:sscData.twitterConsumerKey
                                   consumerSecret:sscData.twitterConsumerSecret
                                       oauthToken:sscData.twitterOathToken
                                 oauthTokenSecret:sscData.twitterOathTokenSecret];
    [self getTweetAccount:@"savoyswing" requestType:type];
    //[self getTweetList:@"seattle-swing-feeds"];   //custom made list in Twitter including different tweet accounts
}

/*
-(void) getTweetList: (NSString *) listSlug requestType: (NSString*) type {
    [__twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
        
        NSString *sinceID;
        NSString *maxID;
        if ([type isEqualToString:@"new"]) {
            sinceID = newestTwitterID;
        } else if ([type isEqualToString:@"old"]) {
            maxID = oldestTwitterID;
        }
        
        //NSLog(@"Access granted for %@", username);
        
        [__twitter getListsStatusesForSlug:listSlug screenName:@"savoyswing" ownerID:nil sinceID:sinceID maxID:maxID count:@"25" includeEntities:nil includeRetweets:nil
                              successBlock:^(NSArray *statuses) {
                                  self.TwitterStatuses = statuses;
                                  if ([statuses  count] > 1) {
                                      newestTwitterID = [[statuses objectAtIndex:0] valueForKey:@"id"];
                                      oldestTwitterID = [[statuses objectAtIndex:([statuses count]-1)] valueForKey:@"id"];
                                  }
                                  twitterReady = YES;
                                  NSLog(@"Twitter Feed Success!");
                              } errorBlock:^(NSError *error) {
                                  NSLog(@"-- error: %@", error);
                                  twitterReady = YES;
                              }];
        
    } errorBlock:^(NSError *error) {
        NSLog(@"-- error %@", error);
        twitterReady = YES;
    }];
}
*/
 
-(void) getTweetAccount: (NSString*) accountName requestType: (NSString*) type {
    
    NSString *sinceID;
    NSString *maxID;
    if ([type isEqualToString:@"new"]) {
        sinceID = newestTwitterID;
        NSLog(@"loading newest Tweets from: %@",sinceID);
    } else if ([type isEqualToString:@"old"] ) {
        maxID = oldestTwitterID;
    }
    
    if ((![type isEqualToString:@"new"] && ![type isEqualToString:@"new"]) ||
        ([type isEqualToString:@"new"] && sinceID) ||
        ([type isEqualToString:@"old"] && maxID)) {
        [__twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
            
            [__twitter getUserTimelineWithScreenName:accountName sinceID:sinceID maxID:maxID count:25
                                        successBlock:^(NSArray *statuses) {
                                            self.TwitterStatuses = statuses;
                                            if ([statuses  count] > 0) {
                                                newestTwitterID = [[statuses objectAtIndex:0] valueForKey:@"id"];
                                                oldestTwitterID = [[statuses objectAtIndex:([statuses count]-1)] valueForKey:@"id"];
                                            }
                                            twitterReady = YES;
                                            NSLog(@"Twitter Feed Success!");
                                        } errorBlock:^(NSError *error) {
                                            NSLog(@"-- error with Timeline acquisition: %@", error);
                                            twitterReady = YES;
                                        }];
            
        } errorBlock:^(NSError *error) {
            NSLog(@"-- error with Credentials %@", error);
            twitterReady = YES;
        }];
    } else {
        twitterReady = YES;
    }
}

-(UITableViewCell *) addTwitterCell: (UITableViewCell *) theCell withPath: (NSIndexPath *) indexPath {
    NSDictionary *status = [_allData objectAtIndex:[self rowsOrSectionsReturn:indexPath]-1];
    
    UILabel *tag = [[UILabel alloc] initWithFrame:CGRectMake(77.0f, 13.0f, 219.0f, 22.0f)];
    tag.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:17.0];
    tag.textAlignment = NSTextAlignmentLeft;
    tag.textColor = [UIColor blackColor];
    tag.text = [NSString stringWithFormat:@"@%@:",[status valueForKeyPath:@"user.screen_name"]];
    [tag sizeToFit];
    
    NSString *twitterDate =[status valueForKeyPath:@"created_at"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"E MMM d HH:mm:ss +0000 yyyy"];
    NSDate *thisDate = [dateFormatter dateFromString:twitterDate];
    [dateFormatter setDateFormat:@"E MMM, d yyyy hh:mm"];
    NSString *thisDateText = [dateFormatter stringFromDate:thisDate];
    
    UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(77.0f, 32.0f, 219.0f, 22.0f)];
    date.tag = 101;
    date.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:11.5];
    date.textAlignment = NSTextAlignmentLeft;
    date.textColor = [UIColor blackColor];
    date.text = thisDateText;
    [date sizeToFit];
    
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(77.0f, 43.0f, 219.0f, 56.0f)];
    text.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:14.0];
    text.textAlignment = NSTextAlignmentLeft;
    text.textColor = [UIColor blackColor];
    text.text = [status valueForKeyPath:@"text"];
    text.lineBreakMode = NSLineBreakByWordWrapping;
    text.numberOfLines = 0;
    //[text sizeToFit];
    
    NSError *errRegex = NULL;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"RT @.*: "
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&errRegex];
    
    [regex enumerateMatchesInString:text.text options:0
                              range:NSMakeRange(0, [text.text length])
                         usingBlock:^(NSTextCheckingResult *match,
                                      NSMatchingFlags flags, BOOL *stop) {
                             
                             NSString *matchFull = [text.text substringWithRange:[match range]];
                             tag.text = matchFull;
                             [tag sizeToFit];
                             
                             text.text = [text.text stringByReplacingOccurrencesOfString:tag.text withString:@""];
                             [text sizeToFit];
                         }];
    
    [theCell.contentView addSubview:tag];
    [theCell.contentView addSubview:date];
    [theCell.contentView addSubview:text];
    
    return theCell;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
/*
 *
 *
 *      ///////////////////////////// Pull To Refresh
 *
 *
 *
 */
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Pull to Refresh

- (void) pinHeaderView
{
    [super pinHeaderView];
    
    NewsFeedHeaderView *hv = (NewsFeedHeaderView *)self.headerView;
    [hv.activityIndicator startAnimating];
    hv.title.text = @"Loading More News...";
}

- (void) unpinHeaderView
{
    [super unpinHeaderView];
    
    [[(NewsFeedHeaderView *)self.headerView activityIndicator] stopAnimating];
}

- (void) headerViewDidScroll:(BOOL)willRefreshOnRelease scrollView:(UIScrollView *)scrollView
{
    NewsFeedHeaderView *hv = (NewsFeedHeaderView *)self.headerView;
    if (willRefreshOnRelease)
        hv.title.text = @"Release to refresh...";
    else
        hv.title.text = @"Pull down to refresh...";
}

- (BOOL) refresh
{
    if (![super refresh])
        return NO;
    _archivedData = [_allData mutableCopy];
    _allData = nil;
    [self getNewerFeeds];
    _sortCellLoader = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(sortNewObjects) userInfo:nil repeats:YES];
    return YES;
}

-(void) sortNewObjects {
    [self sortObjects];
    if (!_sortCellLoader) {
        [self performSelector:@selector(refreshCompleted) withObject:nil afterDelay:2.0];
    }
}


- (void) refreshCompleted {
    NSLog(@"Refresh is Completed");
    [_allData addObjectsFromArray:_archivedData];

    [self.tableView reloadData];
    [super refreshCompleted];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Load More
/*
- (void) willBeginLoadingMore
{
    //NewsFeedFooterView *fv = (NewsFeedFooterView *)self.footerView;
    //[fv.activityIndicator startAnimating];
}

- (void) loadMoreCompleted
{
    [super loadMoreCompleted];
    
    NewsFeedFooterView *fv = (NewsFeedFooterView *)self.footerView;
    //[fv.activityIndicator stopAnimating];
    
    if (!self.canLoadMore) {
        // Do something if there are no more items to load
        
        // We can hide the footerView by: [self setFooterViewVisibility:NO];
        
        // Just show a textual info that there are no more items to load
        fv.infoLabel.hidden = NO;
    }
}

- (BOOL) loadMore
{
    if (![super loadMore])
        return NO;
    
    // Do your async loading here
    //_sortCellLoader = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(sortOlderObjects) userInfo:nil repeats:YES];
    // See -addItemsOnBottom for more info on what to do after loading more items
    
    return YES;
}

-(void) sortOlderObjects {
    [_sortCellLoader invalidate];
    [self sortObjects];
    [_archivedData addObjectsFromArray:_allData];
    _allData = _archivedData;
    [self.tableView reloadData];
    _archivedData = nil;
    [self loadMoreCompleted];
}
*/
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
/*
 *
 *
 *      ///////////////////////////// Images Cell Methods
 *
 *
 *
 */
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)loadImages {
    //setup image
    if (self.imageArr == nil ) {
        self.imageArr = [[NSMutableArray alloc]  init];
        for (int i=1; i < 5; i++ ){
            // GET information (update to POST if possible)
            NSString *strURL = [NSString stringWithFormat:@"http://www.savoyswing.org/wp-content/plugins/ssc_iphone_app/lib/processMobileApp.php?appSend=yes&sliders=%d",i];
            NSData *dataURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
            NSString *strResult = [[NSString alloc] initWithData:dataURL encoding:NSUTF8StringEncoding];
            if ( [strResult length] == 0 ) {
                break;
            } else {
                [self.imageArr addObject:strResult];
            }
        }
        if ( [self.imageArr count] != 0 ) {
            NSInteger indexArr = 0;
            self.home_background.image = [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:[imageArr objectAtIndex:indexArr]]]];
            indexArr++;
            NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
            
            if (standardUserDefaults) {
                [standardUserDefaults setObject:[NSNumber numberWithInt:(int)indexArr] forKey:@"indexArr"];
                [standardUserDefaults synchronize];
            }
        }
        CATransition *transition = [CATransition animation];
        transition.duration = 0.66f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        transition.delegate = self;
        [self.home_background.layer addAnimation:transition forKey:nil];
    }
}


-(void)switchImageView
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *index = nil;
    
    if (standardUserDefaults)
        index = [standardUserDefaults objectForKey:@"indexArr"];
    
    NSInteger indexArr = [index intValue];
    
    NSString *nextIMG = [self.imageArr objectAtIndex:indexArr];
    UIImage * toImage = [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:nextIMG]]];
    [UIView transitionWithView:self.view
                      duration:0.33f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.home_background.image = toImage;
                    } completion:NULL];
    indexArr++;
    if ( indexArr == [self.imageArr count]) {
        indexArr = 0;
    }
    [standardUserDefaults setObject:[NSNumber numberWithInt:(int)indexArr] forKey:@"indexArr"];
    [standardUserDefaults synchronize];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
/*
 *
 *
 *    ///////////////////////////// NEWS SETTINGS VIEW
 *
 *
 */

-(void) showNewsSettings:(id)sender {
    
    //setup header title
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:22.0];
    label.textAlignment = NSTextAlignmentCenter;
    // ^-Use UITextAlignmentCenter for older SDKs.
    label.textColor = [UIColor whiteColor];
    
    label.text = NSLocalizedString(@"News Settings", @"");
    [label sizeToFit];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController: self.newsSettings];
    navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    self.newsSettings.navigationItem.titleView = label;
    UIColor *backgroundColor = [UIColor colorWithRed:235.0/255.0 green:119.0/255.0 blue:24.0/255.0 alpha:1.0];
    self.newsSettings.navigationController.navigationBar.barTintColor = backgroundColor;
    self.newsSettings.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.newsSettings.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"< News"  style:UIBarButtonItemStylePlain target:self action:@selector(returnToNewsFeedSettings:)];

    self.newsSettings.theAppDel = theAppDel;
    
    [[self navigationController] presentViewController:navigationController animated:YES completion:nil];;
}

-(void) returnToNewsFeedSettings:(id)sender {
    [self.newsSettings dismissViewControllerAnimated:YES completion:nil];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
/*
 *
 *
 *     ///////////////////////////// tableView Methods
 *
 *
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //setup header title
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:22.0];
    label.textAlignment = NSTextAlignmentCenter;
    // ^-Use UITextAlignmentCenter for older SDKs.
    label.textColor = [UIColor whiteColor];
    
    label.text = NSLocalizedString(@"News Post", @"");
    [label sizeToFit];
    
	[tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController: self.detailView];
    navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    self.detailView.navigationItem.titleView = label;
    UIColor *backgroundColor = [UIColor colorWithRed:235.0/255.0 green:119.0/255.0 blue:24.0/255.0 alpha:1.0];
    self.detailView.navigationController.navigationBar.barTintColor = backgroundColor;
    self.detailView.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.detailView.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"< News"  style:UIBarButtonItemStylePlain target:self action:@selector(returnToNewsFeedDetail:)];

    BOOL isFacebook = NO;
    BOOL isTwitter = NO;
    NSString *name;
    NSString *date;
    NSString *message;
    NSString *image_url;
    
    if ( [[_allData objectAtIndex:[self rowsOrSectionsReturn:indexPath]-1] objectForKey:@"created_at"]) {
        isTwitter = YES;
    } else if ( [[_allData objectAtIndex:[self rowsOrSectionsReturn:indexPath]-1] objectForKey:@"created_time"]) {
        isFacebook = YES;
    }
    NSLog(@"%@", [_allData objectAtIndex:[self rowsOrSectionsReturn:indexPath]-1]);
    if (isFacebook) {
        self.detailView.post_type = @"Facebook";
        NSDictionary *fbPost = [_allData objectAtIndex:[self rowsOrSectionsReturn:indexPath]-1];
        name = [[fbPost valueForKeyPath:@"from"] valueForKey:@"name"];

        NSString *fbDate =[fbPost valueForKeyPath:@"created_time"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        NSDate *thisDate = [dateFormatter dateFromString:fbDate];
        [dateFormatter setDateFormat:@"E MMM, d yyyy hh:mm"];
        NSString *thisDateText = [dateFormatter stringFromDate:thisDate];
        date = thisDateText;
        
        message =[fbPost valueForKeyPath:@"message"];
        NSRange foundRange = [message rangeOfString:@"\n"];
        if (foundRange.location != NSNotFound) {
            message = [message stringByReplacingOccurrencesOfString:@"\n"
                                                         withString:@""
                                                            options:0
                                                              range:foundRange];
        }
        
        NSString *user_id = [[fbPost valueForKeyPath:@"from"] valueForKey:@"id"];;
        image_url = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square",user_id];
        
        if ( [fbPost valueForKey:@"likes"] ) {
            NSInteger likeDataCount = [[[fbPost valueForKey:@"likes"] valueForKey:@"data"] count];
            self.detailView.likeData = [[NSString alloc] initWithFormat:@"%d others liked this",likeDataCount];
        }
    } else if (isTwitter) {
        self.detailView.post_type = @"Twitter";
        NSDictionary *status = [_allData objectAtIndex:[self rowsOrSectionsReturn:indexPath]-1];
        name = [NSString stringWithFormat:@"@%@:",[status valueForKeyPath:@"user.screen_name"]];
        
        NSString *twitterDate =[status valueForKeyPath:@"created_at"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"E MMM d HH:mm:ss +0000 yyyy"];
        NSDate *thisDate = [dateFormatter dateFromString:twitterDate];
        [dateFormatter setDateFormat:@"E MMM, d yyyy hh:mm"];
        NSString *thisDateText = [dateFormatter stringFromDate:thisDate];
        date = thisDateText;
        
        message =[status valueForKeyPath:@"text"];
        NSRange foundRange = [message rangeOfString:@"\n"];
        if (foundRange.location != NSNotFound) {
            message = [message stringByReplacingOccurrencesOfString:@"\n"
                                                         withString:@""
                                                            options:0
                                                              range:foundRange];
        }
        
        if ([status valueForKey:@"retweeted_status"]) {
            image_url = [status valueForKeyPath:@"retweeted_status.user.profile_image_url"];
        } else {
            image_url = [status valueForKeyPath:@"user.profile_image_url"];
        }
    }
    self.detailView.image_url = image_url;
    self.detailView.post_title = name;
    self.detailView.date_display = date;
    self.detailView.message = message;
    
    [[self navigationController] presentViewController:navigationController animated:YES completion:nil];
}

-(void) returnToNewsFeedDetail:(id)sender {
    [self.detailView dismissViewControllerAnimated:YES completion:nil];
}


-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath  {
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0 ) {
        return 215.0f;
    }
    return self.basicCellHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self listByRows]) {
        return 1;
    } else {
        // Return the number of sections.
        if (theAppDel.newsFeedData) {
            return [theAppDel.newsFeedData count];
        } else if (_allData) {
            return [_allData count];
        } else {
            return 1;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self listByRows]) {
        // Return the number of rows.
        if (theAppDel.newsFeedData) {
            return [theAppDel.newsFeedData count];
        } else if (_allData) {
            return [_allData count];
        } else {
            return 1;
        }
    } else {
        return 1;
    }
}

-(void) removePreviousCellInfoFromView: (UITableViewCell*) cell {
    for(UIView *view in cell.contentView.subviews){
        if ([view isKindOfClass:[UIView class]]) {
            [view removeFromSuperview];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    NSString *CellIdentifier = @"Cell";
    UIImageView *soc_icon = [[UIImageView alloc] initWithFrame:CGRectMake(11.0f, 35.0f, 50.0f, 50.0f)];
    if (indexPath.section == 0 && indexPath.row == 0 ) {
        cell = _imageSlider;
        self.home_background = [[UIImageView alloc] initWithFrame:CGRectMake(-75.0f, 0.0f, 470.0f, 215.0f)];
        [cell addSubview: self.home_background];
    } else if ([[_allData objectAtIndex:[self rowsOrSectionsReturn:indexPath]-1] objectForKey:@"created_at"]) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [self removePreviousCellInfoFromView:cell];
         UIImage *theImage = [UIImage imageNamed:@"twitter-icon.png"];
        soc_icon.image = theImage;
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UIView *topSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, cell.frame.size.width, 10.0f)];
        topSeparator.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        [cell addSubview:topSeparator];
        [cell addSubview:soc_icon];
        [self addTwitterCell:cell withPath:indexPath];
    } else if ([[_allData objectAtIndex:[self rowsOrSectionsReturn:indexPath]-1] objectForKey:@"created_time"]) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        //cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        [self removePreviousCellInfoFromView:cell];
        UIImage *theImage = [UIImage imageNamed:@"facebook-icon.png"];
        soc_icon.image = theImage;
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UIView *topSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, cell.frame.size.width, 10.0f)];
        topSeparator.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        [cell addSubview:topSeparator];
        [cell addSubview:soc_icon];
        [self addFacebookCell:cell withPath:indexPath];
    }
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier];
    }
    return cell;
}

@end
