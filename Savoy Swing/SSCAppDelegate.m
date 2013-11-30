//
//  SSCAppDelegate.m
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/17/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "SSCAppDelegate.h"
#import "TestFlight.h"
#import "SSCData.h"

@implementation SSCAppDelegate


@synthesize user;
@synthesize didInitialize;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TestFlight takeOff:@"b0affd4b-5867-49f6-8773-5064c47cf767"];
    _newsFeedFacebookActive = YES;
    _newsFeedTwitterActive = YES;
    
    [self makeNewFeeds];
    
    reloadDataTimer = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(retrieveNewData) userInfo:nil repeats:YES];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [reloadDataTimer invalidate];
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self retrieveNewData];
    reloadDataTimer = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(retrieveNewData) userInfo:nil repeats:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


-(void) makeNewFeeds {
    _theFeed = [[SSCNewsFeeds alloc] init];
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
    
    if ([_theFeed hasFeeds]) {
        [_theFeed generateFeeds];
    }
}

-(void) retrieveNewData {
    NSLog(@"detecting new news feeds...");
    NSInteger prevCount = [_theFeed.allData count];
    [_theFeed getUpdatedPosts:@"new"];
    NSInteger nextCount = [_theFeed.allData count];
    if (nextCount > prevCount) {
        _containsNewData = YES;
    }
}

@end
