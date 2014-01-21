//
//  NotificationView.m
//  Savoy Swing
//
//  Created by Stevenson on 12/26/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "NotificationView.h"

@implementation NotificationView

#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) showNotificationView {
    [self.noti_act_ind startAnimating];
    [UIView animateWithDuration:1.5 animations:^(void) {
        self.alpha = 1;
    }];
}

-(void) hideNotificationView {
    [UIView animateWithDuration:1.0 animations:^(void) {
        self.alpha = 0;
    }];
    [self.noti_act_ind stopAnimating];
}

@end
