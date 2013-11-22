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

@interface NewsFeedTableViewController  ()
@property (nonatomic, strong) STTwitterAPI* _twitter;
@end

@implementation NewsFeedTableViewController

@synthesize home_background;
@synthesize imageArr;
@synthesize basicCellHeight;
@synthesize newsSettings;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //basic Cell Height
    self.basicCellHeight = 100.0f;
    
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
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.tintColor = [UIColor whiteColor];
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    //self.newsSettings =
    self.newsSettings = [self.storyboard instantiateViewControllerWithIdentifier:@"newsSettings"];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _newsSettingsButton.tintColor = [UIColor whiteColor];
    _newsSettingsButton.target = self;
    _newsSettingsButton.action = @selector(showNewsSettings:);
    
    UIColor *backgroundColor = [UIColor colorWithRed:235.0/255.0 green:119.0/255.0 blue:24.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.barTintColor = backgroundColor;
    //self.view.backgroundColor = backgroundColor;
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}


-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"News Feed Appeared");
    facebookActive = theAppDel.newsFeedFacebookActive;
    twitterActive = theAppDel.newsFeedTwitterActive;
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startLoading) userInfo:nil repeats:NO];
}

-(void) viewWillAppear:(BOOL)animated {
    
    //put graphic image for loading graphic
    self.navigationController.navigationBarHidden = YES;
    loaderImageView =[[UIImageView alloc] initWithFrame:CGRectMake(0.0f, -20.0f, self.view.frame.size.width, self.view.frame.size.height)];
    
    UIImage *theImage = [UIImage imageNamed:@"R4Default.png"];
    loaderImageView.image = theImage;
    imageIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [imageIndicator startAnimating];
    imageIndicator.center = CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height / 2)+100);
    
    loadingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    loadingLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:22.0];
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.textColor = [UIColor whiteColor];
    loadingLabel.text = @"Loading News Feeds";
    [loadingLabel sizeToFit];
    loadingLabel.center = CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height / 2)+150);
    
    [self.view addSubview:loaderImageView];
    [self.view addSubview: imageIndicator];
    [self.view addSubview:loadingLabel];
}

- (void) startLoading {
    [self makeFeeds];
}

-(void) viewWillDisappear:(BOOL)animated {
    NSLog(@"News Will Disappear");
    theAppDel.newsFeedCells = _theCells;
    _TwitterStatuses = nil;
    _FacebookPosts = nil;
    _theCells = nil;
    _allData = nil;
    [self.tableView reloadData];
    self.navigationController.title = @"News";
}


/*
 *
 *
 *      ///////////////////////////// General Feed Methods
 *
 *
 */
-(void) makeFeeds {
    if (!theAppDel.newsFeedCells) {
        [_theCells removeAllObjects];
        [self.tableView reloadData];
        _theCells = [[NSMutableDictionary alloc] init];
        if (twitterActive) {
            [self makeTweetFeed];
        } else {
            twitterReady = YES;
        }
        if (facebookActive) {
            [self makeFacebookFeed];
        } else {
            facebookReady = YES;
        }
        _sortCellLoader = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(sortObjects) userInfo:nil repeats:YES];
    } else {
        _theCells = theAppDel.newsFeedCells;
        [self initializeCellData];
    }
    
}

-(void) sortObjects {
    if (twitterReady && facebookReady) {
        [_sortCellLoader invalidate];
        if ( !_FacebookPosts ) {
            _allData =  [_TwitterStatuses mutableCopy];
        } else {
            NSLog(@"Sorting Data into one");
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
    }
    [self initializeCellData];
}

-(void) initializeCellData {
    NSLog(@"Initializing Cell Data...");
    
    
    [self.tableView reloadData];
    [self.tableView beginUpdates];
    _refreshImage = [NSTimer scheduledTimerWithTimeInterval:12.0 target:self selector:@selector(switchImageView) userInfo:nil repeats:YES];
    for (int i=0; i<[self numberOfSectionsInTableView:self.tableView]; i++){
        for (int j=0; j<[self.tableView numberOfRowsInSection:i]; j++ ) {
            NSIndexPath *thisPath = [NSIndexPath indexPathForRow:j inSection:i];
            UITableViewCell *theCell = [self tableView:self.tableView cellForRowAtIndexPath:thisPath];
            [_theCells setObject:theCell forKey:thisPath];
        }
    }
    [self.tableView endUpdates];
    [self.tableView reloadData];
    [self loadImages];
    
    
    [UIView animateWithDuration:0.5
                          delay:1.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         loaderImageView.alpha = 0;
                     }completion:^(BOOL finished){
                         self.navigationController.navigationBarHidden = NO;
                         [loaderImageView removeFromSuperview];
                         [imageIndicator removeFromSuperview];
                         [loadingLabel removeFromSuperview];
                     }];
}

/*
 *
 *
 *      ///////////////////////////// Facebook Feed Methods!
 *
 *
 */
-(void)makeFacebookFeed {
    NSString *mainURL = @"https://graph.facebook.com/oauth/access_token";
    NSString *requestString =[NSString stringWithFormat:@"client_id=%@&client_secret=%@&grant_type=client_credentials"
                              ,@"1422669574628832",
                              @"ae143b9cea5708bb164ef0ab7e33590f"];
    
    NSString *combinedURLString = [NSString stringWithFormat:@"%@?%@",mainURL,requestString];
    NSData *dataURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:combinedURLString]];
    NSString *strResult = [[NSString alloc] initWithData:dataURL encoding:NSUTF8StringEncoding];
    NSString *accessToken;
    if (strResult) {
        accessToken = strResult;
        NSError *err;
        NSString *feedURLString = [NSString stringWithFormat:@"https://graph.facebook.com/SavoySwingClub/feed?%@",accessToken ];
        NSURL *feedURL = [NSURL URLWithString:[feedURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSData *feedData = [NSData dataWithContentsOfURL:feedURL];
        
        if (feedData) {
            NSDictionary *facebookData = [NSJSONSerialization JSONObjectWithData:feedData
                                                                 options:kNilOptions
                                                                   error:&err];
            
            if (!err) {
                _FacebookPosts = [facebookData objectForKey:@"data"];
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
    
    NSDictionary *fbPost = [_allData objectAtIndex:indexPath.row];
    
    UILabel *tag = [[UILabel alloc] initWithFrame:CGRectMake(77.0f, 3.0f, 219.0f, 22.0f)];
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
    
    UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(77.0f, 19.0f, 219.0f, 22.0f)];
    date.tag = 101;
    date.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:12.0];
    date.textAlignment = NSTextAlignmentLeft;
    date.textColor = [UIColor blackColor];
    date.text = thisDateText;
    [date sizeToFit];
    
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(77.0f, 33.0f, 219.0f, 56.0f)];
    text.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:14.0];
    text.textAlignment = NSTextAlignmentLeft;
    text.textColor = [UIColor blackColor];
    text.text = [fbPost valueForKeyPath:@"message"];
    text.lineBreakMode = NSLineBreakByWordWrapping;
    text.numberOfLines = 0;
    [text sizeToFit];
    
    [theCell.contentView addSubview:tag];
    [theCell.contentView addSubview:date];
    [theCell.contentView addSubview:text];
    
    
    //NSLog(@"creating with date: %@ (Index: %d)",thisDateText,(indexPath.row-facebookStart));

    return theCell;
}

/*
 *
 *
 *      ///////////////////////////// Twitter Feed Methods!
 *
 *
 */
-(void) makeTweetFeed {
    __twitter =
    [STTwitterAPI twitterAPIWithOAuthConsumerName:@"Savoy Swing Club"
                                      consumerKey:@"CNUcYnUkb69u3g7Y9WFWfA"
                                   consumerSecret:@"kIpZ3gXqgBsinody7yOzfiaLQboQKkqts9WsrlXY"
                                       oauthToken:@"36991268-FnGEuHvRSnN5XelEGDwQOUNNmDLZYTYCYkqu34eDc"
                                 oauthTokenSecret:@"GxhtLFdV5piN7w6QLaAMs0O8YrRaJVtGTctqrcwru46Ew"];
    [self getTweetAccount];
    //[self getTweetList:@"seattle-swing-feeds"];   //custom made list in Twitter including different tweet accounts
}

-(void) getTweetList: (NSString *) listSlug {
    [__twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
        
        NSLog(@"Access granted for %@", username);
        
        [__twitter getListsStatusesForSlug:listSlug screenName:@"savoyswing" ownerID:nil sinceID:nil maxID:nil count:@"20" includeEntities:nil includeRetweets:nil
                              successBlock:^(NSArray *statuses) {
                                  self.TwitterStatuses = statuses;
                                  twitterReady = YES;
                                  NSLog(@"Twitter Feed Success!");
                                  NSLog(@"%@",self.TwitterStatuses);
                              } errorBlock:^(NSError *error) {
                                  NSLog(@"-- error: %@", error);
                                  twitterReady = YES;
                              }];
        
    } errorBlock:^(NSError *error) {
        NSLog(@"-- error %@", error);
        twitterReady = YES;
    }];
}

-(void) getTweetAccount {
    [__twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
        NSLog(@"Access granted for %@", username);
        
        [__twitter getUserTimelineWithScreenName:@"savoyswing"
                                           count: 25
                                    successBlock:^(NSArray *statuses) {
                                        self.TwitterStatuses = statuses;
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

-(UITableViewCell *) addTwitterCell: (UITableViewCell *) theCell withPath: (NSIndexPath *) indexPath {
    NSDictionary *status = [_allData objectAtIndex:indexPath.row];
    
    UILabel *tag = [[UILabel alloc] initWithFrame:CGRectMake(77.0f, 3.0f, 219.0f, 22.0f)];
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
    
    UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(77.0f, 19.0f, 219.0f, 22.0f)];
    date.tag = 101;
    date.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:12.0];
    date.textAlignment = NSTextAlignmentLeft;
    date.textColor = [UIColor blackColor];
    date.text = thisDateText;
    [date sizeToFit];
    
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(77.0f, 33.0f, 219.0f, 56.0f)];
    text.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:14.0];
    text.textAlignment = NSTextAlignmentLeft;
    text.textColor = [UIColor blackColor];
    text.text = [status valueForKeyPath:@"text"];
    text.lineBreakMode = NSLineBreakByWordWrapping;
    text.numberOfLines = 0;
    [text sizeToFit];
    
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

/*
 *
 *
 *      ///////////////////////////// Images Cell Methods
 *
 *
 *
 */

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
    self.newsSettings.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"< News"  style:UIBarButtonItemStylePlain target:self action:@selector(returnToNewsSettings:)];

    self.newsSettings.theAppDel = theAppDel;
    
    [[self navigationController] presentViewController:navigationController animated:YES completion:nil];;
}

-(void) returnToNewsSettings:(id)sender {
    [self.newsSettings dismissViewControllerAnimated:YES completion:nil];
}

/*
 *
 *
 *     ///////////////////////////// OVERRIDING METHODS
 *
 *
 */

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath  {
    return YES;
}

-(void) viewDidDisappear:(BOOL)animated {
    NSLog(@"Hiding News Feed");
    [super viewDidDisappear:animated];
    if (_refreshImage != nil ) {
        [_refreshImage invalidate];
        _refreshImage = nil;
    }
    theAppDel.newsFeedCells = _theCells;
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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (theAppDel.newsFeedCells == _theCells) {
        return [_theCells count];
    } else if (_allData) {
        return [_allData count];
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
    UIImageView *soc_icon = [[UIImageView alloc] initWithFrame:CGRectMake(11.0f, 25.0f, 50.0f, 50.0f)];
    if (![_theCells objectForKey:indexPath ]) {
        if (indexPath.section == 0 && indexPath.row == 0 ) {
            CellIdentifier = @"top_slider";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            self.home_background = [[UIImageView alloc] initWithFrame:CGRectMake(-75.0f, 0.0f, 470.0f, 215.0f)];
            [cell addSubview: self.home_background];
        } else if ([[_allData objectAtIndex:indexPath.row] objectForKey:@"created_at"]) {
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            [self removePreviousCellInfoFromView:cell];
             UIImage *theImage = [UIImage imageNamed:@"twitter-icon.png"];
            soc_icon.image = theImage;
            [cell addSubview:soc_icon];
            [self addTwitterCell:cell withPath:indexPath];
        } else if ([[_allData objectAtIndex:indexPath.row] objectForKey:@"created_time"]) {
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            [self removePreviousCellInfoFromView:cell];
            UIImage *theImage = [UIImage imageNamed:@"facebook-icon.png"];
            soc_icon.image = theImage;
            [cell addSubview:soc_icon];
            [self addFacebookCell:cell withPath:indexPath];
        }
    } else {
        cell = [_theCells objectForKey:indexPath];
    }
    return cell;
}

@end
