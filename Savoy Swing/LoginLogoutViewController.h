//
//  LoginLogoutViewController.h
//  Savoy Swing
//
//  Created by Stevenson on 12/21/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCAppDelegate.h"

@interface LoginLogoutViewController : UIViewController 

@end


@interface UsernameCell : UITableViewCell
@property (strong, nonatomic) UITextField *user_textfield;
@end

@interface PasswordCell : UITableViewCell
@property (strong, nonatomic) UITextField *pass_textfield;

@end