//
//  SSCViewController.m
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/25/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import "HomeViewController.h"
#import "SSCRevealViewController.h"

@interface HomeViewController ()  <UITableViewDelegate, UITableViewDataSource> {
    SSCAppDelegate *theAppDel;
    UIActivityIndicatorView *first_news_loading;
}

@property (strong, nonatomic) NewsFeedDetailViewController *detailView;
@property (weak, nonatomic) IBOutlet UIButton *fullSite;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet HomeView *Home_info_view;
@property (strong, nonatomic) NSTimer *singleNewsTimer;

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    theAppDel = (SSCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIColor *backgroundColor = [UIColor colorWithRed:235.0/255.0 green:119.0/255.0 blue:24.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.barTintColor = backgroundColor;
    self.view.backgroundColor = [UIColor clearColor];
    
    //setup header title
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:22.0];
    label.textAlignment = NSTextAlignmentCenter;
    // ^-Use UITextAlignmentCenter for older SDKs.
    label.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = label;
    label.text = NSLocalizedString(@"Savoy Swing Club", @"");
    [label sizeToFit];
    
    _Home_info_view.news_teaser.delegate = self;
    _Home_info_view.news_teaser.dataSource = self;
    _Home_info_view.news_teaser.backgroundColor = [UIColor clearColor];
    _Home_info_view.layer.cornerRadius = 5;
    _Home_info_view.layer.masksToBounds = YES;
    
    [_fullSite addTarget:self action:@selector(openFullSite) forControlEvents:UIControlEventTouchUpInside];
    [_Home_info_view.moreCommunity addTarget:self action:@selector(openFullSite) forControlEvents:UIControlEventTouchUpInside];
    [_Home_info_view.moreEducation addTarget:self action:@selector(openFullSite) forControlEvents:UIControlEventTouchUpInside];
    
    UINavigationBar *bar = [self.navigationController navigationBar];
    [bar setTintColor:[UIColor whiteColor]];
    
    _sidebarButton.tintColor = [UIColor whiteColor];
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    _detailView = [self.storyboard instantiateViewControllerWithIdentifier:@"detailView"];
}

-(void) viewWillAppear: (BOOL)animated {
    _singleNewsTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(putNewsFeedSingle) userInfo:nil repeats:YES];
}

-(void) viewWillDisappear:(BOOL)animated {
    [_singleNewsTimer invalidate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) openFullSite {
    NSString *theURL = @"https://www.savoyswing.org";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:theURL]];
}

-(void) putNewsFeedSingle {
    NSLog(@"Detecting home news post update...");
    if ([theAppDel.theFeed allDone]) {
        [_singleNewsTimer invalidate];
        _singleNewsTimer = [NSTimer scheduledTimerWithTimeInterval:100.0 target:self selector:@selector(putNewsFeedSingle) userInfo:nil repeats:YES];
        [_Home_info_view.news_teaser reloadData];
    }
}

-(void) returnToNewsFeedDetail:(id)sender {
    [self.detailView dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UITableViewDataSource
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    if (indexPath.section ==0 && indexPath.row   == 0 ) {
        return 100.0f;
    } else if (indexPath.section ==0 && indexPath.row == 1 ){
        return 33.0f;
    }
    return 0.0f;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    theAppDel = (SSCAppDelegate *)[[UIApplication sharedApplication] delegate];
    UITableViewCell *cell;
    if (indexPath.section == 0 && indexPath.row == 0 && [theAppDel.theFeed allDone]) {
        first_news_loading = nil;
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        
        if ([[theAppDel.theFeed.allData objectAtIndex:0] objectForKey:@"created_at"]) {
            cell = [theAppDel.theFeed addTwitterCell:cell withIndex:0];
        } else if ([[theAppDel.theFeed.allData objectAtIndex:0] objectForKey:@"created_time"]) {
            cell = [theAppDel.theFeed addFacebookCell:cell withIndex:0];
        } else if ([[theAppDel.theFeed.allData objectAtIndex:0] objectForKey:@"post_date"]) {
            cell = [theAppDel.theFeed addWordpressCell:cell withIndex:0];
        }
        UILabel *title = (UILabel*)[cell viewWithTag:1];
        title.frame = CGRectMake(20.0f, 8.0f, 219.0f, 22.0f);
        UILabel *date = (UILabel*)[cell viewWithTag:2];
        date.frame = CGRectMake(20.0f, 25.0f, 219.0f, 22.0f);
        UILabel *text = (UILabel*)[cell viewWithTag:3];
        text.frame = CGRectMake(20.0f, 40.0f, 219.0f, 56.0f);
        cell.backgroundColor = [UIColor colorWithWhite:0.0f alpha:.1f];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
    } else if (indexPath.section ==0 && indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"newsMore" forIndexPath:indexPath];
    } else {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"newsTeaser"];
        first_news_loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [first_news_loading startAnimating];
        first_news_loading.center = CGPointMake(140.0f, 50.0f);
        [cell addSubview:first_news_loading];
    }
    return cell;
}


#pragma mark UITableViewDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && indexPath.section == 0){
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
        
        if ( [[theAppDel.theFeed.allData objectAtIndex:indexPath.row] objectForKey:@"created_at"]) {
            isTwitter = YES;
        } else if ( [[theAppDel.theFeed.allData objectAtIndex:indexPath.row] objectForKey:@"created_time"]) {
            isFacebook = YES;
        } else if ( [[theAppDel.theFeed.allData objectAtIndex:indexPath.row] objectForKey:@"post_date"]) {
            isWordpress = YES;
        }
        //NSLog(@"%@", [theAppDel.theFeed.allData objectAtIndex:[self rowsOrSectionsReturn:indexPath]-1]);
        if (isFacebook) {
            self.detailView.post_type = @"Facebook";
            NSDictionary *fbPost = [theAppDel.theFeed.allData objectAtIndex:indexPath.row];
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
            NSDictionary *status = [theAppDel.theFeed.allData objectAtIndex:indexPath.row];
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
            
            NSDictionary *post = [theAppDel.theFeed.allData objectAtIndex:indexPath.row];
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
        
        [[self navigationController] pushViewController:self.detailView animated:YES];
    }
}

@end

#pragma mark - Home UIView

@implementation HomeView

@end