//
//  SSCAppDelegate.m
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/17/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "SSCAppDelegate.h"
#import "TestFlight.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <Social/Social.h>

@interface SSCAppDelegate() {
    NSTimer *reloadDataTimer;
}

@end

@implementation SSCAppDelegate


@synthesize user;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TestFlight takeOff:@"b0affd4b-5867-49f6-8773-5064c47cf767"];
    _newsFeedFacebookActive = YES;
    _newsFeedTwitterActive = YES;
    _newsFeedWordpressActive = YES;
    self.makingNewFeeds = NO;
    self.loadingInfo = @"";
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    //[reloadDataTimer invalidate];
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //[reloadDataTimer invalidate];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    self.facebookUserID = nil;
    if (self.facebookAccount) {
        [self refreshFacebookAccount];    }
    //reloadDataTimer = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(retrieveNewData) userInfo:nil repeats:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void) makeNewFeedsWithNews:(BOOL)addNews withBanners:(BOOL)addBanners {
    if (addNews) {
        self.makingNewFeeds = YES;
        _theFeed = [[SSCNewsFeedManager alloc] init];
        SSCData *SSC_DATA = [[SSCData alloc] init];
        if ( _newsFeedFacebookActive ) {
            NSArray *facebookParams = @[SSC_DATA.facebookClient_id,
                                        SSC_DATA.facebookClient_secret];
            [_theFeed addFacebookFeed:@"SavoySwingClub" andParams:facebookParams];
        }
        if (_newsFeedTwitterActive ) {
            NSArray *twitterParams = @[SSC_DATA.twitterConsumerName,
                                       SSC_DATA.twitterConsumerKey,
                                       SSC_DATA.twitterConsumerSecret,
                                       SSC_DATA.twitterOathToken,
                                       SSC_DATA.twitterOathTokenSecret];
            //[theFeed addTwitterFeed:@"savoyswing" andTweetList:nil];      //for user tweets only
            [_theFeed addTwitterFeed:@"savoyswing" andTweetList:@"seattle-swing-feeds" andParams:twitterParams];
        }
        if (_newsFeedWordpressActive) {
            [_theFeed addWordpressFeed:@"http://www.savoyswing.org/wp-content/plugins/ssc_iphone_app/lib/processMobileApp.php?appSend&newsFeed"];
        }
        
        if ( [_theFeed hasFeeds]) {
            [_theFeed generateFeeds];
        }
    }
    
    if (addBanners) {
        _theBanners = [[BannerEvents alloc]init];
        [_theBanners generateEvents];
    }
    self.makingNewFeeds = NO;
}

-(void) retrieveDataTimer {
    //reloadDataTimer = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(retrieveNewData) userInfo:nil repeats:YES];
}

-(void) retrieveNewData {
    if ([self hasConnectivity]) {
        NSLog(@"detecting new news feeds...");
        NSInteger prevCount = [_theFeed.allData count];
        [_theFeed getUpdatedPosts:@"new"];
        if (self.facebookAccount) {
            [self refreshFacebookAccount];
        }
        NSInteger nextCount = [_theFeed.allData count];
        if (nextCount > prevCount) {
            _containsNewData = YES;
        }
    }
}

-(void) getAbout {
    NSString *strURL = @"http://www.savoyswing.org/wp-content/plugins/ssc_iphone_app/lib/processMobileApp.php?appSend&aboutSSC";
    NSData *dataURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
    NSString *strResult = [[NSString alloc] initWithData:dataURL encoding:NSUTF8StringEncoding];
    if ( ![strResult length] == 0 ) {
        _aboutText = strResult;
    }

}

/*
 Connectivity testing code pulled from Apple's Reachability Example: http://developer.apple.com/library/ios/#samplecode/Reachability
 */
-(BOOL)hasConnectivity {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    if(reachability != NULL) {
        //NetworkStatus retVal = NotReachable;
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
            if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
            {
                // if target host is not reachable
                return NO;
            }
            
            if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
            {
                // if target host is reachable and no connection is required
                //  then we'll assume (for now) that your on Wi-Fi
                return YES;
            }
            
            
            if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
                 (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
            {
                // ... and the connection is on-demand (or on-traffic) if the
                //     calling application is using the CFSocketStream or higher APIs
                
                if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
                {
                    // ... and no [user] intervention is needed
                    return YES;
                }
            }
            
            if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
            {
                // ... but WWAN connections are OK if the calling application
                //     is using the CFNetwork (CFSocketStream?) APIs.
                return YES;
            }
        }
    }
    
    return NO;
}

-(void) getFacebookAccount {
    if(!self.accountStore)
        self.accountStore = [[ACAccountStore alloc] init];
    if (!self.facebookAccount) {
        ACAccountType *facebookTypeAccount = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        
        SSCData *SSC_DATA = [[SSCData alloc] init];
        [self.accountStore requestAccessToAccountsWithType:facebookTypeAccount
                                                        options:@{ACFacebookAppIdKey: SSC_DATA.facebookClient_id,
                                                                  ACFacebookPermissionsKey: @[@"read_stream",@"email"],
                                                                  ACFacebookAudienceKey: ACFacebookAudienceEveryone}
                                                     completion:^(BOOL granted, NSError *error) {
                                                         if(granted){
                                                             NSLog(@"Facbeook Account Loaded");
                                                             NSArray *accounts = [self.accountStore accountsWithAccountType:facebookTypeAccount];
                                                             self.facebookAccount = [accounts lastObject];
                                                             [self getPublishStream];
                                                             [self getFacebookID];
                                                         }else{
                                                             // ouch
                                                             NSLog(@"Fail");
                                                             NSLog(@"Error: %@", error);
                                                         }
                                                     }];
    }
}

-(void) refreshFacebookAccount {
    self.facebookAccount = nil;
    [self getFacebookAccount];
}

-(void)getPublishStream {
    ACAccountType *facebookAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier: ACAccountTypeIdentifierFacebook];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        SSCData *SSC_DATA = [[SSCData alloc] init];
        
        NSDictionary *facebookOptions = @{ACFacebookAppIdKey : SSC_DATA.facebookClient_id,
                                          ACFacebookPermissionsKey : @[@"publish_stream"],
                                          ACFacebookAudienceKey : ACFacebookAudienceEveryone };
        
        [self.accountStore requestAccessToAccountsWithType:facebookAccountType options:facebookOptions completion:^(BOOL granted,
                                                                                                                         NSError *error) {
            if (granted) {
                self.facebookAccount = [[self.accountStore accountsWithAccountType:facebookAccountType]
                                             lastObject];
                dispatch_async(dispatch_get_main_queue(), ^{ [[NSNotificationCenter defaultCenter]
                                                              postNotificationName:@"FacebookAccountAccessGranted" object:nil];
                    if (error) {
                        NSLog(@"error for publish_stream: %@",error);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Facebook Public Stream"
                                                                                message:@"There was an error retrieving your Facebook account, make sure you have an account setup in Settings and that access is granted for Savoy Swing"
                                                                               delegate:nil
                                                                      cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                            [alertView show];
                        });
                    }
                    
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Facebook Public Stream"
                                                                        message:@"Access to Facebook was not granted. Please go to the device settings and allow access for Savoy Swing"
                                                                       delegate:nil
                                                              cancelButtonTitle:@"Dismiss"
                                                              otherButtonTitles:nil];
                    [alertView show];
                });
            }
        }];
    });
    
    
    
}

-(void) getFacebookID {
    if (!self.facebookUserID) {
        NSURL *idURL = [NSURL URLWithString:@"https://graph.facebook.com/me"];
        SLRequest *idrequest = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                                  requestMethod:SLRequestMethodGET
                                                            URL:idURL
                                                     parameters:nil];
        idrequest.account = self.facebookAccount;
        
        [idrequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (error) {
                NSLog(@"Error getting Facebook Account: %@",error);
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Facebook ID"
                                                                        message:@"There was an error retrieving your Facebook fnfo, make sure you have an account setup in Settings and that access is granted for Savoy Swing"
                                                                       delegate:nil
                                                              cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                    [alertView show];
                });
            } else {
                NSError *jsonError;
                NSDictionary *facebookData = [NSJSONSerialization JSONObjectWithData:responseData
                                                                             options:kNilOptions
                                                                               error:&jsonError];
                if (jsonError) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"Error getting Facebook Account: %@",jsonError);
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Facebook ID"
                                                                            message:@"There was an error retrieving your Facebook fnfo, make sure you have an account setup in Settings and that access is granted for Savoy Swing"
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                        [alertView show];
                    });
                } else {
                    if ([facebookData objectForKey:@"error"]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"Error getting Facebook Account: %@",[facebookData objectForKey:@"error"]);
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Facebook ID"
                                                                                message:@"There was an error retrieving your Facebook fnfo, make sure you have an account setup in Settings and that access is granted for Savoy Swing"
                                                                               delegate:nil
                                                                      cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                            [alertView show];
                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.facebookUserID = [facebookData objectForKey:@"id"];
                            
                            
                        });
                    }
                }
            }
        }];
    }
}


@end
