//
//  NewsFeedTableViewController.m
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/18/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "NewsFeedTableViewController.h"
#import "SSCRevealViewController.h"
#import "NewsFeedFooterView.h"
#import "NewsFeedHeaderView.h"
#import "SSCNewsPost.h"

@interface NewsFeedTableViewController() {
    SSCAppDelegate *theAppDel;
    
    //preloading image
    UIImageView *loaderImageView;
    
    //news loading
    BOOL loadingFromMemory;
}

@property (strong, retain) NewsFeedSettingsViewController *newsSettings;
@property (strong, nonatomic) NewsFeedDetailViewController *detailView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *newsSettingsButton;

@end

@implementation NewsFeedTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //sub control views
    self.newsSettings = [self.storyboard instantiateViewControllerWithIdentifier:@"newsSettings"];
    self.detailView = [self.storyboard instantiateViewControllerWithIdentifier:@"detailView"];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _newsSettingsButton.tintColor = [UIColor whiteColor];
    _newsSettingsButton.target = self;
    _newsSettingsButton.action = @selector(showNewsSettings:);
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

-(void) setup {
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _sidebarButton.tintColor = [UIColor whiteColor];
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startLoading];
}



-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.startTableCells = YES;
    [self.tableView reloadData];
}


-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (_refreshImage != nil ) {
        [_refreshImage invalidate];
        _refreshImage = nil;
    }
    if (_detectData != nil ) {
        [_detectData invalidate];
        _detectData = nil;
    }
}

-(void) returnToNewsFeedDetail:(id)sender {
    [self.detailView dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Drawing Methods

#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) startLoading {
    if (!theAppDel.facebookAccount)
        [theAppDel getFacebookAccount];
    
    loadingFromMemory = NO;
    _detectData = [NSTimer scheduledTimerWithTimeInterval:100.0 target:self selector:@selector(newNewsPostDetected) userInfo:nil repeats:YES];
    self.finalizedTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(finalizeFeed) userInfo:nil repeats:YES];
}

-(void) finalizeFeed {
    if ([theAppDel.theFeed allDone]) {
        [self.finalizedTimer invalidate];
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
                             [theAppDel.theLoadingScreen removeFromSuperview];
                         }];
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
    
    [[self navigationController] presentViewController:navigationController animated:YES completion:nil];;
}

-(void) returnToNewsFeedSettings:(id)sender {
    [self.newsSettings dismissViewControllerAnimated:YES completion:nil];
}

-(void) removePreviousCellInfoFromView: (UITableViewCell*) cell {
    for(UIView *view in cell.contentView.subviews){
        if ([view isKindOfClass:[UIView class]]) {
            [view removeFromSuperview];
        }
    }
}

#pragma mark - Pull to Refresh
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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

-(void) refreshFacebookAccount {
    [theAppDel.theFeed refreshFacebookFeed];
}

- (BOOL) refresh
{
    if (![super refresh] || ![theAppDel hasConnectivity]) {
        [self refreshFailed];
        return NO;
    }
    
    [self performSelectorInBackground:@selector(refreshFacebookAccount) withObject:nil];
    [theAppDel.theFeed getUpdatedPosts:@"new"];
    [self performSelector:@selector(refreshCompleted) withObject:nil afterDelay:2.0];
    return YES;
}

- (void) refreshFailed {
    NewsFeedHeaderView *hv = (NewsFeedHeaderView *)self.headerView;
    [hv.activityIndicator startAnimating];
    hv.title.text = @"No Connection Found";
    [self performSelector:@selector(refreshCompleted) withObject:nil afterDelay:2.0];
}

- (void) refreshCompleted {
    if ([theAppDel.theFeed allDone]) {
        [self.tableView reloadData];
        [super refreshCompleted];
    }
}

#pragma mark - Load More
////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) willBeginLoadingMore
{
    NewsFeedFooterView *fv = (NewsFeedFooterView *)self.footerView;
    [fv.activityIndicator startAnimating];
}


- (void) loadMoreCompleted
{
    [super loadMoreCompleted];
    
    NewsFeedFooterView *fv = (NewsFeedFooterView *)self.footerView;
    [fv.activityIndicator stopAnimating];
    
    if (!self.canLoadMore) {
        fv.infoLabel.hidden = NO;
        [self.tableView reloadData];
        [super refreshCompleted];
    }
}

- (BOOL) loadMore
{
    /*
    if (![super loadMore])
        return NO;
    [theAppDel.theFeed getUpdatedPosts:@"old"];
    [self performSelector:@selector(loadMoreCompleted) withObject:nil afterDelay:2.0];
    return YES;
    
    return YES;
    */
    return NO;
}


#pragma mark UITableViewDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != 0) {
        //setup header title
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:22.0];
        label.textAlignment = NSTextAlignmentCenter;
        // ^-Use UITextAlignmentCenter for older SDKs.
        label.textColor = [UIColor whiteColor];
        
        label.text = NSLocalizedString(@"News Post", @"");
        [label sizeToFit];
        
        [tableView deselectRowAtIndexPath:indexPath animated:TRUE];

        BOOL isFacebook = NO;
        BOOL isTwitter = NO;
        BOOL isWordpress = NO;
        NSString *name;
        NSString *date;
        NSString *message;
        NSString *image_url;
        
        if ( [[theAppDel.theFeed.allData objectAtIndex:[self rowsOrSectionsReturn:indexPath]-1] objectForKey:@"created_at"]) {
            isTwitter = YES;
        } else if ( [[theAppDel.theFeed.allData objectAtIndex:[self rowsOrSectionsReturn:indexPath]-1] objectForKey:@"created_time"]) {
            isFacebook = YES;
        } else if ( [[theAppDel.theFeed.allData objectAtIndex:[self rowsOrSectionsReturn:indexPath]-1] objectForKey:@"post_date"]) {
            isWordpress = YES;
        }
        if (isFacebook) {
            self.detailView.post_type = @"Facebook";
            NSDictionary *fbPost = [theAppDel.theFeed.allData objectAtIndex:[self rowsOrSectionsReturn:indexPath]-1];
            self.detailView.theFeedData = fbPost;
            
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
            
        } else if (isTwitter) {
            self.detailView.post_type = @"Twitter";
            NSDictionary *status = [theAppDel.theFeed.allData objectAtIndex:[self rowsOrSectionsReturn:indexPath]-1];
            self.detailView.theFeedData = status;
            name = [NSString stringWithFormat:@"@%@:",[status valueForKeyPath:@"user.screen_name"]];
            
            NSString *twitterDate =[status valueForKeyPath:@"created_at"];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"E MMM d HH:mm:ss +0000 yyyy"];
            NSDate *thisDate = [dateFormatter dateFromString:twitterDate];
            NSTimeInterval secondsInEightHours = -8 * 60 * 60;
            thisDate = [thisDate dateByAddingTimeInterval:secondsInEightHours];
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
        } else if (isWordpress) {
            self.detailView.post_type = @"Wordpress";
            NSDictionary *post = [theAppDel.theFeed.allData objectAtIndex:[self rowsOrSectionsReturn:indexPath]-1];
            self.detailView.theFeedData = post;
            
            name = [NSString stringWithFormat:@"%@",[post valueForKeyPath:@"post_title"]];
            
            NSString *postDate =[post valueForKeyPath:@"post_date"];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *thisDate = [dateFormatter dateFromString:postDate];
            [dateFormatter setDateFormat:@"E MMM, d yyyy hh:mm"];
            NSString *thisDateText = [dateFormatter stringFromDate:thisDate];
            date = thisDateText;
            
            message =[post valueForKeyPath:@"post_content"];
            image_url = @"https://www.savoyswing.org/wp-content/uploads/2011/10/300683_10150309277453001_136441543000_8193471_1958483267_n-150x150.jpg";
        }
        self.detailView.image_url = image_url;
        self.detailView.post_title = name;
        self.detailView.date_display = date;
        self.detailView.message = message;
        
        
        self.detailView.navigationItem.titleView = label;
        UIColor *backgroundColor = [UIColor colorWithRed:235.0/255.0 green:119.0/255.0 blue:24.0/255.0 alpha:1.0];
        self.detailView.navigationController.navigationBar.barTintColor = backgroundColor;
        self.detailView.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        
        UINavigationBar *bar = [self.navigationController navigationBar];
        [bar setTintColor:[UIColor whiteColor]];
        [[self navigationController] pushViewController:self.detailView animated:YES];
    }
}

#pragma mark UITableViewDataSource
////////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath  {
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0 ) {
        return 225.0f;
    }
    return [theAppDel.theFeed thisCellHeight:[self rowsOrSectionsReturn:indexPath]-1];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ( !self.startTableCells )
        return 0;
    if ([self listByRows]) {
        return 1;
    } else {
        // Return the number of sections.
        if (theAppDel.theFeed.allData) {
            return [theAppDel.theFeed.allData count];
        } else {
            return 1;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (theAppDel.theFeed.allData) {
        return [theAppDel.theFeed.allData count];
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0 ) {
        UITableViewCell *cell = _imageSlider;
        self.home_background = [[UIImageView alloc] initWithFrame:CGRectMake(-75.0f, 0.0f, 470.0f, 215.0f)];
        [cell addSubview: self.home_background];
        return cell;
    }
    
    NSString *CellIdentifier = @"Cell";
    NewsFeedCell *cell = [[NewsFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier height:[theAppDel.theFeed thisCellHeight:[self rowsOrSectionsReturn:indexPath]-1]];

    [cell setThe_post:(SSCNewsPost*)theAppDel.theFeed.allData];
    [cell drawCell];

    return cell;
}

@end
