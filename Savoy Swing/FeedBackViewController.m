//
//  FeedBackViewController.m
//  Savoy Swing
//
//  Created by Stevenson on 12/26/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "FeedBackViewController.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@interface FeedBackViewController ()

@property (weak, nonatomic) IBOutlet UITextField *subject_field;
@property (weak, nonatomic) IBOutlet UITextView *message_field;
@property (weak, nonatomic) IBOutlet UIButton *send_button;
@property (weak, nonatomic) NotificationView *noti_view;

- (IBAction)backgroundTouch:(id)sender;
-(IBAction) sendFeedbackAction:(id)sender;

@end

@implementation FeedBackViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NotificationView" owner:self options:nil];
    self.noti_view = [nib objectAtIndex:0];
    
    self.noti_view.layer.cornerRadius = 5;
    self.noti_view.layer.masksToBounds = YES;
    self.noti_view.alpha = 0;
    [self.view addSubview:self.noti_view];
    self.noti_view.center = self.view.center;
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.subject_field.leftView = paddingView;
    self.subject_field.leftViewMode = UITextFieldViewModeAlways;
    
    self.message_field.layer.borderWidth = 1;
    self.message_field.layer.borderColor = [[UIColor grayColor] CGColor];
    
    self.subject_field.layer.borderWidth = 1;
    self.subject_field.layer.borderColor = [[UIColor grayColor] CGColor];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark UIAlertViewDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // when leaving this application to safari, we will prompt the user, this function handle the response
    switch(buttonIndex)
    {
        case 0:
            [self sendFeedback];
            break;
        case 1: // Stay
            self.send_button.enabled = YES;
            break;
    }
}

#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*) getMachine {
    NSString *machine;
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *name = malloc(size);
    sysctlbyname("hw.machine", name, &size, NULL, 0);
    machine = [NSString stringWithUTF8String:name];
    free(name);
    return machine;
}

- (IBAction)backgroundTouch:(id)sender {
    [self.subject_field resignFirstResponder];
    [self.message_field resignFirstResponder];
}

-(IBAction) sendFeedbackAction:(id)sender {
    self.send_button.enabled = NO;
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Send Feedback"
                          message:@"Are you ready to send Feedback?"
                          delegate:self
                          cancelButtonTitle:@"Yes"
                          otherButtonTitles:@"No", nil];
    [alert show];
}

-(void) sendFeedback {
    
    self.noti_view.message.text = @"Reaching Host";
    [self.noti_view showNotificationView];
    self.subject_field.enabled = NO;
    self.message_field.editable = NO;
    NSString *sendSubject = self.subject_field.text;
    NSString *sendMessage = self.message_field.text;
    [self performSelector:@selector(connectionTimedout) withObject:nil afterDelay:15];
    
    NSString *post = [NSString stringWithFormat:@"&feedbackSubject=%@&feedbackMessage=%@&machine=%@",sendSubject,sendMessage,[self getMachine]];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.savoyswing.org/wp-content/plugins/ssc_iphone_app/lib/processMobileApp.php?appSend&sendFeedback"]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
    [request setHTTPBody:postData];
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    if (conn) {
        self.noti_view.message.text = @"Sending Message";
    } else {
        self.noti_view.message.text = @"No Connection";
        [self performSelector:@selector(hideNotificationView) withObject:nil afterDelay:1.5];
    }
    

}

-(void) showNotificationView {
    [self.noti_view showNotificationView];
}

-(void) hideNotificationView {
    [self.noti_view hideNotificationView];
}

-(void) connectionTimedout {
    if ( self.noti_view.alpha != 0 ) {
        self.noti_view.message.text = @"Timed Out";
        self.send_button.enabled = YES;
        
        self.subject_field.enabled = YES;
        self.message_field.editable = YES;
        [self performSelector:@selector(hideNotificationView) withObject:nil afterDelay:1.5];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data {
    NSString *strResult = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",strResult);
    if ( [strResult isEqualToString:@"1"]) {
        self.noti_view.message.text = @"Message Sent";
        self.subject_field.text = @"";
        self.message_field.text = @"";
        self.send_button.enabled = YES;
        
        self.subject_field.enabled = YES;
        self.message_field.editable = YES;
        [self performSelector:@selector(hideNotificationView) withObject:nil afterDelay:1.5];
    } else {
        self.noti_view.message.text = @"Error Sending";
        self.send_button.enabled = YES;
        
        self.subject_field.enabled = YES;
        self.message_field.editable = YES;
        [self performSelector:@selector(hideNotificationView) withObject:nil afterDelay:1.5];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.noti_view.message.text = @"Error Sending";
    self.send_button.enabled = YES;
    
    self.subject_field.enabled = YES;
    self.message_field.editable = YES;
    [self performSelector:@selector(hideNotificationView) withObject:nil afterDelay:1.5];
}

@end
