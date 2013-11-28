//
//  SSCViewController.m
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/25/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import "HomeViewController.h"
#import "SWRevealViewController.h"

@interface HomeViewController ()

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
    self.view.backgroundColor = [UIColor whiteColor];
    
    //setup header title
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:22.0];
    label.textAlignment = NSTextAlignmentCenter;
    // ^-Use UITextAlignmentCenter for older SDKs.
    label.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = label;
    label.text = NSLocalizedString(@"Savoy Swing Club", @"");
    [label sizeToFit];
    
    _Home_info_view.news_teaser.delegate = _Home_info_view;
    _Home_info_view.news_teaser.dataSource = _Home_info_view;
    _Home_info_view.news_teaser.backgroundColor = [UIColor clearColor];
    _Home_info_view.layer.cornerRadius = 5;
    _Home_info_view.layer.masksToBounds = YES;
    
    [_fullSite addTarget:self action:@selector(openFullSite) forControlEvents:UIControlEventTouchUpInside];
    [_Home_info_view.moreCommunity addTarget:self action:@selector(openFullSite) forControlEvents:UIControlEventTouchUpInside];
    [_Home_info_view.moreEducation addTarget:self action:@selector(openFullSite) forControlEvents:UIControlEventTouchUpInside];
    
    _singleNewsTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(putNewsFeedSingle) userInfo:nil repeats:YES];
    
    _sidebarButton.tintColor = [UIColor whiteColor];
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

-(void) openFullSite {
    NSString *theURL = @"https://www.savoyswing.org";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:theURL]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) putNewsFeedSingle {
    if ([theAppDel.theFeed allDone]) {
        [_singleNewsTimer invalidate];
        [_Home_info_view.news_teaser reloadData];
    }
}

@end



@implementation HomeView

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    if (indexPath.section ==0 && indexPath.row   == 0 ) {
        return 100.0f;
    } else if (indexPath.section ==0 && indexPath.row == 1 ){
        return 33.0f;
    }
    return 0.0f;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    theAppDel = (SSCAppDelegate *)[[UIApplication sharedApplication] delegate];
    UITableViewCell *cell;
    if (indexPath.section == 0 && indexPath.row == 0 && [theAppDel.theFeed allDone]) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        
        if ([[theAppDel.theFeed.allData objectAtIndex:0] objectForKey:@"created_at"]) {
            cell = [theAppDel.theFeed addTwitterCell:cell withIndex:0];
        } else if ([[theAppDel.theFeed.allData objectAtIndex:0] objectForKey:@"created_time"]) {
            cell = [theAppDel.theFeed addFacebookCell:cell withIndex:0];
        }
        UILabel *title = (UILabel*)[cell viewWithTag:1];
        title.frame = CGRectMake(20.0f, 13.0f, 219.0f, 22.0f);
        UILabel *date = (UILabel*)[cell viewWithTag:2];
        date.frame = CGRectMake(20.0f, 32.0f, 219.0f, 22.0f);
        UILabel *text = (UILabel*)[cell viewWithTag:3];
        text.frame = CGRectMake(20.0f, 43.0f, 219.0f, 56.0f);
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    } else if (indexPath.section ==0 && indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"newsMore" forIndexPath:indexPath];
    } else {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"newsTeaser"];
    }
    return cell;
}

@end