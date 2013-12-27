//
//  MembershipViewController.m
//  Savoy Swing
//
//  Created by Steven Stevenson on 12/1/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "MembershipViewController.h"

@interface MembershipViewController ()

@end

@implementation MembershipViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.logout_button setTarget:self];
    [self.logout_button setAction:@selector(logout)];
    
    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;
    
    self.sectionNames = @[@"Welcome User,",
                          @"Membership Supports the Community",
                          @"Calculate your Savings!",
                          @"Benefits, Benefits, Benefits",
                          @"Support What You Want!",
                          @"Vote to Build Your Community"];
    
    self.contentForRow = @[@"There are new and exciting things happening everyday in Seattle’s lindy hop community, and Savoy Swing Club is here to help you understand the art and joy of this historical purely American dance. \n\nYour Savoy Swing Club Passport is your ticket to user all the SSC benefits. Simply rotate any of the Member Areas (Highlighted Orange in Navigation Menu) \n\nAnd as always, if you have any questions or comments, please don’t hesitate to contact us. \n\nSincerely, \n\nSavoy Swing Club",
                           @"Savoy Swing Club supports the dancing community by providing opportunities to learn and social dance. Becoming a member means you will be directly supporting the nationally renowned Seattle Swing dance community and receive some great benefits to help you save money while you support the scene.",
                           @"Interested in learning ways to save some money dancing every night of the week? Use our online calculator to determine how much you can save attending many of the events throughout Seattle. You can put in the some information that pertains to how you spend your money on dancing, and we will show how much money you save by being a Savoy Swing Club Member. \n\nFor More info, check out https://www.savoyswing.org/members/membership-calculator/",
                           @"Membership benefits include: \nWeekly Dance Discounts: \n\nSavoy Swing Club: \n$2 off admission for Savoy Mondays (regularly $5) \n$2 off admission for Blues Underground (regularly $5) \n$15 off series classes and workshops \nWeekly SSC newsletter, vote in club elections \n\nEastside Stomp: (SSC Passport must be shown)* \n$1 off Tuesday Night Stomp \n$1 off Friday Night Stomp \n$5 off regular series classes (full series only, drop-ins not included) \n$5 off selected workshops at Eastside Stomp \n$10 off private lessons with Ben White \n\nHepCat Productions: \nDiscounted classes \n\nRegional Dance Discounts: \nSeattle Lindy Exchange \nKiller Diller Weekend \nCamp Jitterbug ($20 off) \nVancouver Jazz Dance Festival ",
                           @"To make it easier to see where your money will go, we have outlined a few specific donation areas that Savoy Swing Club will use to build that specific area of the community. If you have any questions or would like to talk to someone on the phone or in person – email president@savoyswing.org. \n\nIf you want to use part of your membership to help support certain aspects of SSC, we are glad to discuss your interests. All donations can be tax-deductible as Savoy Swing Club is the only nonprofit organization focused solely on building Lindy Hop through the northwest.",
                           @"Savoy Swing Club is governed by a board of directors. The SSC board meets monthly. If you would like to attend a meeting or if you have questions about the board’s activities, please contact secretary@savoyswing.org for more details."];
}



-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.theTableView reloadData];
}

-(void) logout{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Logout"
                          message:@"Are you sure you want to logout?"
                          delegate:self
                          cancelButtonTitle:@"Yes"
                          otherButtonTitles:@"No", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // when leaving this application to safari, we will prompt the user, this function handle the response
    switch(buttonIndex)
    {
        case 0:
            NSLog(@"User chose to logout");
            theAppDel.user = nil;
            [self sendToLoginPage];
            break;
        case 1: // Stay
            break;
    }
}

-(NSString*)sectionNames:(NSInteger) index {
    if (index == 0 && theAppDel.user) {
        NSArray *firstLast = [[theAppDel.user objectForKey:@"name"] componentsSeparatedByString:@" "];
        return [NSString stringWithFormat:@"Welcome %@,", [firstLast objectAtIndex:0]];
    }
    return [self.sectionNames objectAtIndex:index];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return [self.sectionNames count];
}


- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 50)];
    UILabel *tempLabel=[[UILabel alloc]initWithFrame:CGRectMake(5,0,310,44)];
    if ( section == 0 ) {
        tempLabel.textAlignment = NSTextAlignmentLeft;
    } else {
        tempLabel.textAlignment = NSTextAlignmentCenter;
    }
    tempLabel.backgroundColor=[UIColor clearColor];
    tempLabel.shadowOffset = CGSizeMake(0,2);
    tempLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:17];
    tempLabel.text = [self sectionNames:section];
    
    if (section == 0 ) {
        headerView.backgroundColor = [UIColor clearColor];
        tempLabel.textColor = [UIColor whiteColor];
    } else {
        headerView.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
        tempLabel.textColor = [UIColor darkGrayColor];
    }
    
    [headerView addSubview:tempLabel];
    return headerView;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 ) {
        UILabel *info = [[UILabel alloc] initWithFrame:CGRectMake(130, 5, 160, 10)];
        info.numberOfLines = 0;
        info.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0];
        info.text = [self.contentForRow objectAtIndex:indexPath.section];
        [info sizeToFit];
        return 10+info.frame.size.height;
    } else {
        UILabel *info = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 280, 10)];
        info.numberOfLines = 0;
        info.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0];
        info.text = [self.contentForRow objectAtIndex:indexPath.section];
        [info sizeToFit];
        return 10+info.frame.size.height;
    }
    return 100;
}

-(CGFloat)tableView: (UITableView*) tableView heightForHeaderInSection:(NSInteger)section {
    return 50.0f;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MembershipInfoTableCell *cell;
    if (indexPath.section == 0) {
        cell = [[MembershipInfoTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"membershipInfo"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.backgroundColor = [UIColor whiteColor];
        UIImageView *sideView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 120, 170)];
        UIImage *theImage = [UIImage imageNamed:@"down_banner.jpg"];
        sideView.image = theImage;
        [cell addSubview:sideView];
        
        UILabel *info = [[UILabel alloc] initWithFrame:CGRectMake(130, 5, 160, 10)];
        info.numberOfLines = 0;
        info.textColor = [UIColor darkGrayColor];
        info.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0];
        info.text = [self.contentForRow objectAtIndex:indexPath.section];
        [info sizeToFit];
        
        [cell addSubview:info];
        
    } else {
        cell = [[MembershipInfoTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"membershipInfo"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.backgroundColor = [UIColor colorWithWhite:1 alpha:.8];
        
        UILabel *info = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 280, 10)];
        info.numberOfLines = 0;
        info.textColor = [UIColor darkGrayColor];
        info.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0];
        info.text = [self.contentForRow objectAtIndex:indexPath.section];
        [info sizeToFit];

        [cell addSubview:info];
    }
    return cell;
}


@end

@implementation MembershipInfoTableCell


- (void)setFrame:(CGRect)frame {
    float inset = 10.0f;
    frame.origin.x += inset;
    frame.size.width -= 2 * inset;
    [super setFrame:frame];
}

@end