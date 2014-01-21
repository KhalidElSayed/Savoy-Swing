//
//  NotificationView.h
//  Savoy Swing
//
//  Created by Stevenson on 12/26/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationView : UIView

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *noti_act_ind;
@property (weak,nonatomic) IBOutlet UILabel *message;

-(void) showNotificationView;
-(void) hideNotificationView;
@end
