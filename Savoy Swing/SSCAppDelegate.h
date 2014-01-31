//
//  SSCAppDelegate.h
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/17/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCRevealViewController.h"
#import "SSCNewsFeedManager.h"
#import "BannerEvents.h"
#import "loadingScreenImageView.h"
#import "SSCData.h"
#import <Accounts/Accounts.h>

@interface SSCAppDelegate : UIResponder <UIApplicationDelegate> 

@property (nonatomic) BOOL containsNewData;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSDictionary *user;
@property (strong, nonatomic) SSCNewsFeedManager *theFeed;
@property (strong, nonatomic) BannerEvents *theBanners;
@property (nonatomic) BOOL makingNewFeeds;
@property (strong, nonatomic) NSString *loadingInfo;
@property (strong, nonatomic) NSString *aboutText;
@property (nonatomic) BOOL newsFeedTwitterActive;
@property (nonatomic) BOOL newsFeedFacebookActive;
@property (nonatomic) BOOL newsFeedWordpressActive;
@property (nonatomic) UILabel *loginSidebarButton;
@property (strong, nonatomic) loadingScreenImageView *theLoadingScreen;
@property (strong,retain) NSMutableArray *imageArr;

@property (nonatomic, retain) ACAccountStore *accountStore;
@property (nonatomic, retain) ACAccount *facebookAccount;
@property (nonatomic, retain) NSString *facebookUserID;

-(void) makeNewFeedsWithNews:(BOOL)addNews withBanners:(BOOL)addBanners;
-(void) retrieveDataTimer;
-(void) retrieveNewData;
-(void) getAbout;
-(BOOL) hasConnectivity;
-(void)loadImages;
-(void) getFacebookAccount;
-(void) refreshFacebookAccount;
-(void) getPublishStream;
-(void) getFacebookID;
@end
