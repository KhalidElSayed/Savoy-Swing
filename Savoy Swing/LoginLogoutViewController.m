//
//  LoginLogoutViewController.m
//  Savoy Swing
//
//  Created by Stevenson on 12/21/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "LoginLogoutViewController.h"
#import "SSCRevealViewController.h"

@interface LoginLogoutViewController ()

@end

@implementation LoginLogoutViewController

bool isKeyboardVisible = NO;
bool isLoggingIn = NO;

/////// Load Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    theAppDel = [[UIApplication sharedApplication] delegate];
    
    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;
    self.theTableView.layer.cornerRadius = 5;
    self.theTableView.layer.masksToBounds = YES;
    
    self.status.hidden = YES;
    self.status.center = self.login_button.center;
    self.login_button.layer.cornerRadius = 5;
    self.login_button.layer.masksToBounds = YES;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardAppeared:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDisappeared:) name:UIKeyboardWillHideNotification object:nil];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}


/////// Other Methods

- (void) keyboardAppeared: (NSNotification *) notification {
    if ( !isKeyboardVisible ) {
        isKeyboardVisible = YES;
    }
    NSDictionary *info=[notification userInfo];
    CGSize keyboardSize=[[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self.view setFrame:CGRectMake(0,-(keyboardSize.height/2),320,self.view.frame.size.height)];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem.enabled = NO;
}

-(void) keyboardDisappeared: (NSNotification *) notification {
    [self.view setFrame:CGRectMake(0,0,320,self.view.frame.size.height)];
    self.navigationItem.leftBarButtonItem.enabled = YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ( self.pass_textfield.isFirstResponder ) {
        [self.pass_textfield resignFirstResponder];
    } else {
        [self.user_textfield resignFirstResponder];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ( textField == self.pass_textfield ) {
        [textField resignFirstResponder];
        [self login];
    } else {
        [self.pass_textfield becomeFirstResponder];
    }
    return YES;
}

- (IBAction)backgroundTouch:(id)sender {
    [self.user_textfield resignFirstResponder];
    [self.pass_textfield resignFirstResponder];
}

- (IBAction)loginSubmit:(id)sender {
    [self login];
}

- (void) login{
    isLoggingIn = YES;
    //process and load
    [self.user_textfield resignFirstResponder];
    [self.pass_textfield resignFirstResponder];
    [self loginLoading];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(loginAction) userInfo:nil repeats:NO];
}

- (void) loginAction {
    if ([self.user_textfield.text isEqualToString:@""] ||
        [self.pass_textfield.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Fields" message:@"Please Fill-in All Fields" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        // GET information (update to POST if possible)
        NSString *strURL = [NSString stringWithFormat:@"http://www.savoyswing.org/wp-content/plugins/ssc_iphone_app/lib/processMobileApp.php?appSend=yes&verifyLogin=yes&username=%@&pwd=%@", self.user_textfield.text, self.pass_textfield.text];
        NSData *dataURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
        NSString *strResult = [[NSString alloc] initWithData:dataURL encoding:NSUTF8StringEncoding];
        if (![strResult length] == 0 ) {
            if ( [strResult isEqualToString:@"0"]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wrong Username/Password" message:@"Your login information is incorrect." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            } else {
                NSData *theData = [strResult dataUsingEncoding:NSUTF8StringEncoding];
                NSError *e;
                NSDictionary *user = [NSJSONSerialization JSONObjectWithData:theData options:kNilOptions error:&e];
                /*
                NSDictionary *user_temp = @{ @"username" : @"awkLindyTurtle",
                                     @"name" : @"Steven Stevenson",
                                     @"unique_id" : @"1003",
                                     @"exp_date" : @"4/1/2015",
                                     @"status"  : @"PAID",
                                     @"email" : @"steven@steveandleah.com",
                                     @"add1" : @"2432 1st Ave. North",
                                     @"add2" : @"",
                                     @"city" : @"Seattle",
                                     @"state" : @"WA",
                                     @"zip" : @"98109",
                                     @"phone" : @"206-251-5191"};
                */
                theAppDel.user = user;
                
                [[self navigationController] popViewControllerAnimated:YES];
            }
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Sorry, we are experiencing some technical difficulties. Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    isLoggingIn = NO;
    [self loginLoading];
}

-(void) loginLoading {
    if ( isLoggingIn ) {
        self.login_button.enabled = NO;
        self.login_button.hidden = YES;
        self.status.hidden = NO;
        [self.status startAnimating];
    } else {
        self.status.hidden = YES;
        self.login_button.enabled = YES;
        self.login_button.hidden = NO;
        [self.status stopAnimating];
    }
}


/////// TableView Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        UsernameCell *cell = [[UsernameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"user_cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        self.user_textfield = cell.user_textfield;
        cell.user_textfield.delegate = self;
        return cell;
    } else if (indexPath.row == 1 ) {
        PasswordCell *cell = [[PasswordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"pass_cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        self.pass_textfield = cell.pass_textfield;
        cell.pass_textfield.delegate = self;
        return cell;
    }
    return nil;
}

@end

@implementation UsernameCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.user_textfield = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, self.frame.size.width-20, self.frame.size.height-20)];
        [self addSubview:self.user_textfield];
    }
    return self;
}

@end

@implementation PasswordCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.pass_textfield = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, self.frame.size.width-20, self.frame.size.height-20)];
        self.pass_textfield.secureTextEntry = YES;
        [self addSubview:self.pass_textfield];
    }
    return self;
}

@end
