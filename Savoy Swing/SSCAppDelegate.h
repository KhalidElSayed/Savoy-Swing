//
//  SSCAppDelegate.h
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/17/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
#import "SSCNewsFeeds.h"
#import "BannerEvents.h"

@interface SSCAppDelegate : UIResponder <UIApplicationDelegate> {
    NSTimer *reloadDataTimer;
}

@property (nonatomic) BOOL containsNewData;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSDictionary *user;
@property (strong, nonatomic) SSCNewsFeeds *theFeed;
@property (strong, nonatomic) BannerEvents *theBanners;
@property (strong, nonatomic) NSString *aboutText;
@property (nonatomic) BOOL newsFeedTwitterActive;
@property (nonatomic) BOOL newsFeedFacebookActive;

-(void) makeNewFeeds;
-(void) retrieveDataTimer;
-(void) retrieveNewData;
-(void) getAbout;
-(BOOL) hasConnectivity;
@end
