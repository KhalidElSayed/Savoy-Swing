//
//  SSCAppDelegate.h
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/17/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"

@interface SSCAppDelegate : UIResponder <UIApplicationDelegate> {
    NSString *user;
    BOOL didInitialize;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *user;
@property (strong, nonatomic) NSMutableArray *newsFeedData;
@property (nonatomic) BOOL didInitialize;
@property (nonatomic) BOOL newsFeedTwitterActive;
@property (nonatomic) BOOL newsFeedFacebookActive;

@end
