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
#import <sys/socket.h>
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>

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
    [reloadDataTimer invalidate];
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [reloadDataTimer invalidate];
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

-(void) makeNewFeedsWithNews:(BOOL)addNews withBanners:(BOOL)addBanners {
    if (addNews) {
        self.makingNewFeeds = YES;
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
    reloadDataTimer = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(retrieveNewData) userInfo:nil repeats:YES];
}

-(void) retrieveNewData {
    if ([self hasConnectivity]) {
        NSLog(@"detecting new news feeds...");
        NSInteger prevCount = [_theFeed.allData count];
        [_theFeed getUpdatedPosts:@"new"];
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

-(void)loadImages {
    //setup image
    if (self.imageArr == nil ) {
        self.imageArr = [[NSMutableArray alloc]  init];
        // GET information (update to POST if possible)
        NSString *strURL = [NSString stringWithFormat:@"http://www.savoyswing.org/wp-content/plugins/ssc_iphone_app/lib/processMobileApp.php?appSend&sliders"];
        NSData *dataURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
        NSString *strResult = [[NSString alloc] initWithData:dataURL encoding:NSUTF8StringEncoding];
        NSData *theData = [strResult dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        NSArray *imageStrArr = [NSJSONSerialization JSONObjectWithData:theData options:kNilOptions error:&e];
        for (int i=1; i < [imageStrArr count]; i++ ){
            if ( [strResult length] == 0 ) {
                break;
            } else {
                UIImage *thisImage = [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:[imageStrArr objectAtIndex:i]]]];
                [self.imageArr addObject:thisImage];
                [self.theLoadingScreen changeLabelText:[NSString stringWithFormat:@"Loaded %d Images",i]];
            }
        }
    }
}

@end
