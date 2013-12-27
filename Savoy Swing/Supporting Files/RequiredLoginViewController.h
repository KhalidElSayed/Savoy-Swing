//
//  RequiredLoginViewController.h
//  Savoy Swing
//
//  Created by Stevenson on 12/24/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCAppDelegate.h"
#import "LoginLogoutViewController.h"

@interface RequiredLoginViewController : UIViewController {
    UIView *membershipCardView;
    SSCAppDelegate *theAppDel;
}

@property (strong, nonatomic) LoginLogoutViewController *loginController;

-(void) sendToLoginPage;

@end
