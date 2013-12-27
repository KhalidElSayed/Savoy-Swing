//
//  FeedBackViewController.h
//  Savoy Swing
//
//  Created by Stevenson on 12/26/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationView.h"

@interface FeedBackViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *subject_field;
@property (weak, nonatomic) IBOutlet UITextView *message_field;
@property (weak, nonatomic) IBOutlet UIButton *send_button;
@property (weak, nonatomic) IBOutlet NotificationView *noti_view;

- (IBAction)backgroundTouch:(id)sender;
-(IBAction) sendFeedbackAction:(id)sender;
@end