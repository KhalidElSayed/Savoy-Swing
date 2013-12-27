//
//  RequiredLoginViewController.m
//  Savoy Swing
//
//  Created by Stevenson on 12/24/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "RequiredLoginViewController.h"
#import "SSCRevealViewController.h"

@interface RequiredLoginViewController ()

@end

@implementation RequiredLoginViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    theAppDel = [[UIApplication sharedApplication] delegate];
    self.loginController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginView"];
    membershipCardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width*2)];
    membershipCardView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.7f];
}

-(void) backToRevealToggle {
    [self.revealViewController revealToggleAnimated:YES];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    if ( ![self isLoggedIn] ){
        [self performSelector:@selector(sendToLoginPage) withObject:nil afterDelay:.01];
    } else {
        if ([[theAppDel.user objectForKey:@"status"] isEqualToString:@"PAID"]) {
            [self makeMembershipCard];
        } else {
            [self makeVoidCard];
        }
    }
}

-(void) sendToLoginPage {
    UIImage *barItemImage = [UIImage imageNamed:@"menu.png"];
    UIBarButtonItem *backRevealItem = [[UIBarButtonItem alloc] initWithImage:barItemImage style:UIBarButtonItemStylePlain target:self action:@selector(backToRevealToggle)];
    self.loginController.navigationItem.leftBarButtonItem = backRevealItem;
    [[self navigationController] pushViewController:self.loginController animated:YES];
}


-(void) returnToUserPage:(id)sender {
    [self.loginController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL) isLoggedIn {
    return theAppDel.user != nil;
}

-(void) makeVoidCard {
    UIImageView *cardBackground = [[UIImageView alloc] initWithFrame:CGRectMake(40, 20, self.view.bounds.size.height-80, self.view.bounds.size.width-40)];
    UIImage *theCard = [UIImage imageNamed:@"ssc_card_med_inactive.tif"];
    cardBackground.image = theCard;
    [membershipCardView addSubview:cardBackground];
}

-(void) makeMembershipCard {
    
    UIImageView *cardBackground = [[UIImageView alloc] initWithFrame:CGRectMake(40, 20, self.view.bounds.size.height-80, self.view.bounds.size.width-40)];
    UIImage *theCard = [UIImage imageNamed:@"ssc_card_med_active.tif"];
    cardBackground.image = theCard;
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(300, 158, 200, 20)];
    nameLabel.text = [theAppDel.user objectForKey:@"name"];
    [nameLabel sizeToFit];
    UILabel *idLabel = [[UILabel alloc] initWithFrame:CGRectMake(300, 181, 200, 20)];
    idLabel.text = [theAppDel.user objectForKey:@"unique_id"];
    [idLabel sizeToFit];
    UILabel *exp_dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(300, 202, 200, 20)];
    exp_dateLabel.text = [theAppDel.user objectForKey:@"exp_date"];
    [exp_dateLabel sizeToFit];
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(300, 225, 200, 20)];
    statusLabel.text = [theAppDel.user objectForKey:@"status"];
    [statusLabel sizeToFit];
    
    
    [membershipCardView addSubview:cardBackground];
    [membershipCardView addSubview:nameLabel];
    [membershipCardView addSubview:idLabel];
    [membershipCardView addSubview:exp_dateLabel];
    [membershipCardView addSubview:statusLabel];
}

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration  {
    if ( toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        self.navigationController.navigationBar.hidden = YES;
        //check if reveal occured and remove if so
        
        if ([self.revealViewController frontViewPosition] == FrontViewPositionRight) {
            [self.revealViewController revealToggleAnimated:YES];
        }
        [self.view addSubview:membershipCardView];
    } else if ( toInterfaceOrientation == UIInterfaceOrientationPortrait ) {
        self.navigationController.navigationBar.hidden = NO;
        [membershipCardView removeFromSuperview];
    }
}


@end
