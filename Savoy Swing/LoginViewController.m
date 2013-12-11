//
//  LoginViewController.m
//  SSC Mobile Passport v2
//
//  Created by Steven Stevenson on 10/11/12.
//  Copyright (c) 2012 Savoy Swing Club. All rights reserved.
//

#import "LoginViewController.h"
#import "SSCAppDelegate.h"

@interface LoginViewController ()
@end

@implementation LoginViewController
@synthesize user_textfield, pass_textfield;
@synthesize scroll;
@synthesize status;
@synthesize login_button;
bool isKeyboardVisible = NO;
bool isLoggingIn = NO;

- (void)viewDidLoad
{
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    NSLog(@"App Started!");
    timer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(loginLoading) userInfo:nil repeats:YES];
    status.hidden = YES;
    user_textfield.delegate = self;
    pass_textfield.delegate = self;
    [super viewDidLoad];
    [scroll setScrollEnabled:YES];
    [scroll setContentSize:CGSizeMake(320, 650)];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardAppeared) name:UIKeyboardDidShowNotification object:nil];
    //initialize fields

}
     
- (void) keyboardAppeared {
    if ( !isKeyboardVisible ) {
        isKeyboardVisible = YES;
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    CGPoint offset = CGPointMake(0, 100);
    [scroll setContentOffset:offset];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ( pass_textfield.isFirstResponder ) {
        [pass_textfield resignFirstResponder];
    } else {
        [user_textfield resignFirstResponder];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ( textField == pass_textfield ) {
        [textField resignFirstResponder];
        [self login];
    } else {
        [pass_textfield becomeFirstResponder];
    }
    return YES;
}

- (IBAction)backgroundTouch:(id)sender {
    NSLog(@"remove keyboard");
    [user_textfield resignFirstResponder];
    [pass_textfield resignFirstResponder];
}

- (IBAction)loginSubmit:(id)sender {
    [self login];
}
    
- (void) login{
    isLoggingIn = YES;
    CGPoint offset = CGPointMake(0,0);
    [scroll setContentOffset:offset];
    //process and load
    [user_textfield resignFirstResponder];
    [pass_textfield resignFirstResponder];
    [self loginLoading];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(loginAction) userInfo:nil repeats:NO];
}

- (void) loginAction {
    if ([user_textfield.text isEqualToString:@""] ||
        [pass_textfield.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"alert" message:@"Please Fill-in All Fields" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        // GET information (update to POST if possible)
        NSString *strURL = [NSString stringWithFormat:@"http://www.savoyswing.org/wp-content/plugins/ssc_iphone_app/lib/processMobileApp.php?appSend=yes&verifyLogin=yes&username=%@&pwd=%@", user_textfield.text, pass_textfield.text];
        NSData *dataURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
        NSString *strResult = [[NSString alloc] initWithData:dataURL encoding:NSUTF8StringEncoding];
        if ( [strResult isEqualToString:@"1"]) {
            // move to next
            UIViewController *nextVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TabViewController"];
            nextVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController:nextVC animated:YES completion:nil];
            [user_textfield setDelegate:self];
            [user_textfield setEnablesReturnKeyAutomatically: TRUE];
            [user_textfield setReturnKeyType:UIReturnKeyDone];
            //SSCAppDelegate *appDel = (SSCAppDelegate *)[[UIApplication sharedApplication] delegate];
            //appDel.user = user_textfield.text;
        } else if ( [strResult isEqualToString:@""] ) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Please check your internet settings and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        } else {
            // invalid entry
            NSString *message = [NSString stringWithFormat:@"Your User and Password combination is incorrect. ( error: %@ )", strResult];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failure" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    isLoggingIn = NO;
}

-(void) loginLoading {
    if ( isLoggingIn ) {
        login_button.enabled = NO;
        login_button.hidden = YES;
        status.hidden = NO;
        [status startAnimating];
    } else {
        status.hidden = YES;
        login_button.enabled = YES;
        login_button.hidden = NO;
        [status stopAnimating];
    }
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
