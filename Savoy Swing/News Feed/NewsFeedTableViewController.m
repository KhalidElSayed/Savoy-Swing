//
//  NewsFeedTableViewController.m
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/18/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "NewsFeedTableViewController.h"
#import "SWRevealViewController.h"
#import "NewsFeedFooterView.h"
#import "NewsFeedHeaderView.h"

#pragma convert to newsfeed class
#import "STTwitter.h"

@interface NewsFeedTableViewController  ()
@property (nonatomic, strong) STTwitterAPI* _twitter;
@end

@implementation NewsFeedTableViewController

@synthesize home_background;
@synthesize imageArr;
@synthesize basicCellHeight;
@synthesize newsSettings;
@synthesize detailView;

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
/*
 *
 *
 *      ///////////////////////////// View listeners
 *
 *
 */
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad
{
    
    UIColor *backgroundColor = [UIColor colorWithRed:235.0/255.0 green:119.0/255.0 blue:24.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.barTintColor = backgroundColor;
    self.view.backgroundColor = [UIColor lightGrayColor];
    
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
    loadingLabel.text = @"Compiling News Data";
    [loadingLabel sizeToFit];
    loadingLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, loadingLabel.frame.size.height);
    loadingLabel.center = CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height / 2)+160);
    
    [self.view addSubview:loaderImageView];
    [self.view addSubview: imageIndicator];
    [imageIndicator startAnimating];
    imageIndicator.center = CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height / 2)+120);
    [self.view addSubview:loadingLabel];
}



-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self performSelector:@selector(startLoading) withObject:self afterDelay:1.0];
}

-(void) startLoading {
    loadingFromMemory = NO;
    loadingLabel.text = theAppDel.theFeed.status_update;
    _loadingScreenText = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateLoadingScreen) userInfo:nil repeats:YES];
    if ([theAppDel.theFeed allDone]) {
        loadingFromMemory = YES;
        [self finalizeFeed];
        
    } else {
        _finalizeData = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(finalizeFeed) userInfo:nil repeats:YES];
    }
}

-(void) updateLoadingScreen {
    loadingLabel.text = theAppDel.theFeed.status_update;
}


-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (_refreshImage != nil ) {
        [_refreshImage invalidate];
        _refreshImage = nil;
    }
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


-(void) finalizeFeed {
    if (loadingFromMemory || [theAppDel.theFeed allDone]) {
        if (_finalizeData) {
            [_finalizeData invalidate];
        }
        _refreshImage = [NSTimer scheduledTimerWithTimeInterval:12.0 target:self selector:@selector(switchImageView) userInfo:nil repeats:YES];
        
        [self.tableView reloadData];
        
        [self setHeaderView:self.headerView];
        
        [self loadImages];
        [_loadingScreenText invalidate];
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
    [theAppDel.theFeed getUpdatedPosts:@"new"];
    [self performSelector:@selector(refreshCompleted) withObject:nil afterDelay:2.0];
    return YES;
}

- (void) refreshCompleted {
    if ([theAppDel.theFeed allDone]) {
        [self.tableView reloadData];
        [super refreshCompleted];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Load More

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
    if (![super loadMore])
        return NO;
    [theAppDel.theFeed getUpdatedPosts:@"old"];
    [self performSelector:@selector(loadMoreCompleted) withObject:nil afterDelay:2.0];
    return YES;
    
    return YES;
}
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
    
    if ( [[theAppDel.theFeed.allData objectAtIndex:[self rowsOrSectionsReturn:indexPath]-1] objectForKey:@"created_at"]) {
        isTwitter = YES;
    } else if ( [[theAppDel.theFeed.allData objectAtIndex:[self rowsOrSectionsReturn:indexPath]-1] objectForKey:@"created_time"]) {
        isFacebook = YES;
    }
    //NSLog(@"%@", [theAppDel.theFeed.allData objectAtIndex:[self rowsOrSectionsReturn:indexPath]-1]);
    if (isFacebook) {
        self.detailView.post_type = @"Facebook";
        NSDictionary *fbPost = [theAppDel.theFeed.allData objectAtIndex:[self rowsOrSectionsReturn:indexPath]-1];
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
        NSDictionary *status = [theAppDel.theFeed.allData objectAtIndex:[self rowsOrSectionsReturn:indexPath]-1];
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
        if (theAppDel.theFeed.allData) {
            return [theAppDel.theFeed.allData count];
        } else {
            return 1;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self listByRows]) {
        if (theAppDel.theFeed.allData) {
            return [theAppDel.theFeed.allData count];
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
    } else if ([[theAppDel.theFeed.allData objectAtIndex:[self rowsOrSectionsReturn:indexPath]-1] objectForKey:@"created_at"]) {
        //twitter post
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [self removePreviousCellInfoFromView:cell];
         UIImage *theImage = [UIImage imageNamed:@"twitter-icon.png"];
        soc_icon.image = theImage;
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UIView *topSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, cell.frame.size.width, 10.0f)];
        topSeparator.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        [cell addSubview:topSeparator];
        [cell addSubview:soc_icon];
        [theAppDel.theFeed addTwitterCell:cell withIndex:[self rowsOrSectionsReturn:indexPath]-1];
    } else if ([[theAppDel.theFeed.allData objectAtIndex:[self rowsOrSectionsReturn:indexPath]-1] objectForKey:@"created_time"]) {
        //facebook post
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [self removePreviousCellInfoFromView:cell];
        UIImage *theImage = [UIImage imageNamed:@"facebook-icon.png"];
        soc_icon.image = theImage;
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UIView *topSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, cell.frame.size.width, 10.0f)];
        topSeparator.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        [cell addSubview:topSeparator];
        [cell addSubview:soc_icon];
        [theAppDel.theFeed addFacebookCell:cell withIndex:[self rowsOrSectionsReturn:indexPath]-1];
    }
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier];
    }
    return cell;
}

@end
