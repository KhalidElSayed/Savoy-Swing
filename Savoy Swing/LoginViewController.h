//
//  LoginViewController.h
//  SSC Mobile Passport v2
//
//  Created by Steven Stevenson on 10/11/12.
//  Copyright (c) 2012 Savoy Swing Club. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RegisterViewController;

@interface LoginViewController : UIViewController <UITextFieldDelegate> {
    NSTimer *timer;
}
@property (strong, nonatomic) IBOutlet UIScrollView *scroll;
@property (retain, nonatomic) IBOutlet UITextField *user_textfield;
@property (retain, nonatomic) IBOutlet UITextField *pass_textfield;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *status;
@property (weak, nonatomic) IBOutlet UIButton *login_button;

- (IBAction)loginSubmit:(id)sender;
- (IBAction)backgroundTouch:(id)sender;

@end
