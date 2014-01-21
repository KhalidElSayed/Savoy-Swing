//
//  SSCNewsFeeds.m
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/19/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "SSCNewsFeeds.h"
#import "STTwitter.h"
#import "SSCAppDelegate.h"

@interface SSCNewsFeeds  () {
    
    BOOL twitterReady;
    BOOL facebookReady;
    BOOL wordpressReady;
    BOOL postsSorted;
    BOOL dataReady;
    
    BOOL twitterActive;
    BOOL wordpressActive;
    BOOL facebookActive;
    
    BOOL updateNewer;
    BOOL updateOlder;
    
    NSString *newFacebookPostLink;
    NSString *laterFacebookPostLink;
    NSString *newestTwitterID;
    NSString *oldestTwitterID;
    
    NSString *twitter_username;
    NSString *tweet_list;
    NSString *twitterConsumerName;
    NSString *twitterConsumerKey;
    NSString *twitterConsumerSecret;
    NSString *twitterOathToken;
    NSString *twitterOathTokenSecret;
    
    NSString *wordpress_urlToFeed;
    
    NSString *facebook_username;
    NSString *facebookClient_id;
    NSString *facebookClient_secret;
    
}

@property (nonatomic, strong) STTwitterAPI* _twitter;

@end

@implementation SSCNewsFeeds

@synthesize status_update;
static SSCAppDelegate *theAppDel;

-(id) init {
    self = [super self];
    if (self) {
        theAppDel = [[UIApplication sharedApplication] delegate];
        twitterActive = NO;
        facebookActive = NO;
        wordpressActive = NO;
        
        twitterReady = NO;
        facebookReady = NO;
        wordpressReady = NO;
        postsSorted = NO;
        
        dataReady = NO;
        
        status_update = @"No Feeds Setup";
    }
    return self;
}

-(void) addTwitterFeed: (NSString*) username andTweetList: (NSString*) tweetList andParams: (NSArray*) params {
    [theAppDel.theLoadingScreen changeLabelText:@"Setting Up Twitter"];
    twitter_username = username;
    tweet_list = tweetList;
    twitterActive = YES;
    if (params && [params count] == 5) {
        twitterConsumerName = params[0];
        twitterConsumerKey = params[1];
        twitterConsumerSecret = params[2];
        twitterOathToken = params[3];
        twitterOathTokenSecret = params[4];
    }
}

-(void) addFacebookFeed: (NSString *) username andParams: (NSArray*) params{
    [theAppDel.theLoadingScreen changeLabelText:@"Setting Up Facebook"];
    facebook_username = username;
    facebookActive = YES;
    if (params && [params count] == 2) {
        facebookClient_id = params[0];
        facebookClient_secret = params[1];
    }
}

-(void) addWordpressFeed: (NSString *) urlToFeed {
    [theAppDel.theLoadingScreen changeLabelText:@"Setting up SavoySwing.org"];
    wordpress_urlToFeed = urlToFeed;
    wordpressActive = YES;
}

-(BOOL) hasFeeds {
    return (facebookActive || twitterActive || wordpressActive);
}

-(BOOL) postsReady {
    return (facebookReady && twitterReady && wordpressActive && postsSorted);
}

-(BOOL) allDone {
    return dataReady;
}

-(BOOL) readyToSort {
    return twitterReady && facebookReady && wordpressReady;
}

-(void) generateFeeds {
    dataReady = NO;
    _allData = [[NSMutableArray alloc] init];
    if ([self hasFeeds]) {
        if (twitterActive) {
            [self makeTwitterFeed: nil];
        } else {
            twitterReady = YES;
        }
        if (wordpressActive) {
            [self makeWordpressFeed:nil];
        } else {
            wordpressReady = YES;
        }
        if (facebookActive) {
            [self makeFacebookFeed: nil];
        } else {
            facebookReady = YES;
        }
        _sortCellLoader = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(sortObjects) userInfo:nil repeats:YES];
        _finishedLoader = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(finalizeData) userInfo:nil repeats:YES];
    }
}

-(void) finalizeData {
    if ([self postsReady]) {
        if ( _finishedLoader ) {
            [_finishedLoader invalidate];
        }
        if (updateNewer){
            updateNewer = NO;
            [_allData addObjectsFromArray:_archivedData];
            _archivedData = nil;
        } else if (updateOlder) {
            updateOlder = NO;
            [_archivedData addObjectsFromArray:_allData];
            _allData = [_archivedData mutableCopy];
            _archivedData = nil;
        }
        theAppDel.theLoadingScreen.loadingLabel.text = @"Finishing News Feeds";
        [theAppDel.theLoadingScreen.loadingLabel sizeThatFits:CGSizeMake(320, 50)];
        dataReady = YES;
    }
}

-(void) sortObjects {
    if ([self readyToSort]) {
        NSLog(@"Sorting News Feeds");
        [_sortCellLoader invalidate];
        _sortCellLoader = nil;
        _allData = [[NSMutableArray alloc] init];
        _facebookTrackedIndices = [[NSMutableDictionary alloc] init];
        NSInteger fb_count = 0;
        NSInteger twi_count = 0;
        NSInteger wp_count = 0;
        NSInteger runningTotal = 0;
        NSInteger totalData =([_FacebookPosts count]+[_TwitterStatuses count]+[_WordpressPosts count]);
        for (NSInteger i=0; i<totalData;i++ ){
            //facebook date
            NSDate *fb_date;
            if (fb_count < [_FacebookPosts count]) {
                NSDictionary *fb_obj = [_FacebookPosts objectAtIndex:fb_count];
                if (![fb_obj valueForKeyPath:@"message"]) {
                    fb_count++;
                    totalData--;
                    continue;
                }
                NSString *fb_unformDate =[fb_obj valueForKeyPath:@"created_time"];
                NSDateFormatter *fb_dateFormatter = [[NSDateFormatter alloc] init];
                [fb_dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
                fb_date = [fb_dateFormatter dateFromString:fb_unformDate];
            }
            
            //twitter date
            NSDate *twi_date;
            if (twi_count < [_TwitterStatuses count]) {
                NSData *twi_obj = [_TwitterStatuses objectAtIndex:twi_count];
                //remove if possibly retweeting self occured (may be unnecessary in current twitter API)
                if ([twi_obj valueForKeyPath:@"retweeted_status"] &&
                    ![[twi_obj valueForKey:@"reteeted_status.user.screen_name"] isEqualToString:twitter_username]) {
                    twi_count++;
                    totalData--;
                    continue;
                }
                NSString *twi_unformDate = [twi_obj valueForKeyPath:@"created_at"];
                NSDateFormatter *twi_dateFormatter = [[NSDateFormatter alloc] init];
                [twi_dateFormatter setDateFormat:@"E MMM d HH:mm:ss +0000 yyyy"];
                twi_date = [twi_dateFormatter dateFromString:twi_unformDate];
                NSTimeInterval secondsInEightHours = -8 * 60 * 60;
                twi_date = [twi_date dateByAddingTimeInterval:secondsInEightHours];
            }
            
            //wordpress date
            NSDate *wp_date;
            if (wp_count < [_WordpressPosts count]) {
                NSData *wp_obj = [_WordpressPosts objectAtIndex:wp_count];
                
                NSString *wp_unformDate = [wp_obj valueForKeyPath:@"post_date"];
                NSDateFormatter *wp_dateFormatter = [[NSDateFormatter alloc] init];
                [wp_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                wp_date = [wp_dateFormatter dateFromString:wp_unformDate];
            }
            
            NSDate *mostRecentNews = nil;
            NSString *mostRecentType = @"";
            NSInteger mostRecentIndex = -1;
            if (twi_date && fb_date) {
                //find most recent date
                switch ([fb_date compare: twi_date]) {
                    case NSOrderedAscending:{
                        mostRecentNews = twi_date;
                        mostRecentType = @"Twitter";
                        mostRecentIndex = twi_count;
                        break;
                    }
                    case NSOrderedSame: {
                        mostRecentNews = fb_date;
                        mostRecentType = @"Facebook";
                        mostRecentIndex = fb_count;
                        break;
                    }
                    case NSOrderedDescending: {
                        mostRecentNews = fb_date;
                        mostRecentType = @"Facebook";
                        mostRecentIndex = fb_count;
                        break;
                    }
                }
            } else {
                mostRecentNews = (fb_date) ? fb_date : twi_date;
                mostRecentType = (fb_date) ? @"Facebook" : @"Twitter";
                mostRecentIndex = (fb_date) ? fb_count : twi_count;
            }
            if (mostRecentNews && wp_date) {
                //find most recent date
                switch ([mostRecentNews compare: wp_date]) {
                    case NSOrderedAscending:{
                        mostRecentNews = wp_date;
                        mostRecentType = @"Wordpress";
                        mostRecentIndex = wp_count;
                        break;
                    }
                    case NSOrderedSame: {
                        break;
                    }
                    case NSOrderedDescending: {
                        break;
                    }
                }
            } else {
                mostRecentNews = (wp_date) ? wp_date : mostRecentNews;
                mostRecentType = (wp_date) ? @"Wordpress" : mostRecentType;
                mostRecentIndex = (wp_date) ? wp_count : mostRecentIndex;
            }
            if ([mostRecentType isEqualToString:@"Twitter"]) {
                [_allData addObject:[_TwitterStatuses objectAtIndex:mostRecentIndex]];
                twi_count++;
                runningTotal++;
            } else if ([mostRecentType isEqualToString:@"Facebook"]){
                [_allData addObject:[_FacebookPosts objectAtIndex:mostRecentIndex]];
                [_facebookTrackedIndices setObject:[NSString stringWithFormat:@"%d",runningTotal] forKey:[[_FacebookPosts objectAtIndex:mostRecentIndex]objectForKey:@"id"]];
                fb_count++;
                runningTotal++;
            } else if ([mostRecentType isEqualToString:@"Wordpress"]){
                [_allData addObject:[_WordpressPosts objectAtIndex:mostRecentIndex]];
                wp_count++;
                runningTotal++;
            }
            
        }
        NSLog(@"Data Sorted (total entries: %d)",[_allData count]);
        [theAppDel.theLoadingScreen changeLabelText:@"News Sorted"];
        
        postsSorted = YES;
        dataReady = YES;
    }
}

-(NSMutableArray*) getData {
    if (dataReady) {
        return _allData;
    }
    return nil;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////         Updating Feeds          //////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*
 *
 *      Request more feeds
 *
 */
-(void) getUpdatedPosts: (NSString*) type {
    _archivedData = [_allData mutableCopy];
    twitterReady = NO;
    facebookReady = NO;
    postsSorted = NO;
    dataReady = NO;
     if (twitterActive) {
         [self makeTwitterFeed:type];
     } else{
         twitterReady = YES;
     }
     if (facebookActive) {
         [self makeFacebookFeed:type];
     }else{
         twitterReady = YES;
     }
    if (wordpressActive) {
        [self makeWordpressFeed:type];
    } else{
        wordpressReady = YES;
    }
    if ([type isEqualToString:@"new"]) {
        updateNewer = YES;
    } else if ([type isEqualToString:@"old"]) {
        updateOlder = YES;
    }
    _sortCellLoader = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(sortObjects) userInfo:nil repeats:YES];
    _finishedLoader = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(finalizeData) userInfo:nil repeats:YES];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////           Feed Update          ///////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
 *
 *      Facebook Feed
 */
-(NSDictionary*) refreshFacebookFeedAndReturnPostForID: (NSString *) facebookID {
    NSURL *feedURL = [NSURL URLWithString:[theAppDel.theFeed.facebookFeedURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *feedData = [NSData dataWithContentsOfURL:feedURL];
    NSDictionary *returnPost;
    if (feedData) {
        NSError *err;
        NSDictionary *facebookData = [NSJSONSerialization JSONObjectWithData:feedData
                                                                     options:kNilOptions
                                                                       error:&err];
        if (!err) {
            _FacebookPosts = [facebookData objectForKey:@"data"];
            for (NSInteger i=0;i<[_FacebookPosts count];i++ ) {
                NSDictionary *fbPost = [_FacebookPosts objectAtIndex:i];
                NSString *allDataIndex = [self.facebookTrackedIndices objectForKey:[fbPost objectForKey:@"id"]];
                if ( allDataIndex ) {
                    [_allData replaceObjectAtIndex:allDataIndex.integerValue withObject:fbPost];
                }
                if ([[fbPost objectForKey:@"id"] isEqualToString:facebookID]) {
                    returnPost = fbPost;
                }
            }
        }
    }
    return returnPost;
}

-(void) refreshFacebookFeed {
    [self refreshFacebookFeedAndReturnPostForID:@""];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////         Feed Creation          ///////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
 *
 *      Facebook Feed
 *
 */
-(void)makeFacebookFeed: (NSString*) type {
    NSString *strResult = nil;
    if (![type isEqualToString:@"new"] && ![type isEqualToString:@"old"]) {
        NSString *mainURL = @"https://graph.facebook.com/oauth/access_token";
        NSString *requestString =[NSString stringWithFormat:@"client_id=%@&client_secret=%@&grant_type=client_credentials"
                                  ,facebookClient_id,
                                  facebookClient_secret];
        
        NSString *combinedURLString = [NSString stringWithFormat:@"%@?%@",mainURL,requestString];
        NSData *dataURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:combinedURLString]];
        strResult = [[NSString alloc] initWithData:dataURL encoding:NSUTF8StringEncoding];
    }
    if (strResult || [type isEqualToString:@"new"] || [type isEqualToString:@"old"]) {
        self.facebookAccess_Token = strResult;
        NSError *err;
        NSString *searchURL = @"";
        if ( strResult ) {
            self.facebookFeedURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/feed?%@",facebook_username, self.facebookAccess_Token ];
            searchURL =  self.facebookFeedURL ;
        } else if ([type isEqualToString:@"new"]) {
            searchURL = newFacebookPostLink;
        } else if ([type isEqualToString:@"old"]) {
            searchURL = laterFacebookPostLink;
        }
        NSURL *feedURL = [NSURL URLWithString:[searchURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSData *feedData = [NSData dataWithContentsOfURL:feedURL];
        
        if (feedData) {
            NSDictionary *facebookData = [NSJSONSerialization JSONObjectWithData:feedData
                                                                         options:kNilOptions
                                                                           error:&err];
            if (!err) {
                _FacebookPosts = [facebookData objectForKey:@"data"];
                if ([facebookData objectForKey:@"paging"]) {
                    newFacebookPostLink = [[facebookData objectForKey:@"paging"] objectForKey:@"previous"];
                    laterFacebookPostLink = [[facebookData objectForKey:@"paging"] objectForKey:@"next"];
                }
                NSLog(@"Facebook Feed Success!");
                theAppDel.theLoadingScreen.loadingLabel.text = @"Facebook Feed Loaded!";
                [theAppDel.theLoadingScreen.loadingLabel sizeThatFits:CGSizeMake(320, 50)];
                [theAppDel.theLoadingScreen.loadingLabel setNeedsDisplay];
                facebookReady = YES;
            } else {
                NSLog(@"-- error: %@",err);
            }
        } else {
            NSLog(@"-- error: no Response!");
        }
    } else {
        NSLog(@"-- error: no Token Received!");
    }
}

/*
 *
 *      Twitter Feed
 *
 */
-(void) makeWordpressFeed: (NSString*) type {
    NSData *dataURL;
    if ([type isEqualToString:@"new"]) {
        NSString *excludes = @"";
        for (NSDictionary *post in _WordpressPosts) {
            excludes = [NSString stringWithFormat:@"%@%@,",excludes,[post objectForKey:@"post_id"]];
        }
        _WordpressPosts = @[];
        wordpress_urlToFeed = [NSString stringWithFormat:@"%@%@",wordpress_urlToFeed,excludes];
        dataURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:wordpress_urlToFeed]];
    } else {
        wordpress_urlToFeed = [NSString stringWithFormat:@"%@&excludingPosts=",wordpress_urlToFeed];
        dataURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:wordpress_urlToFeed]];
    }
    NSString *strResult = [[NSString alloc] initWithData:dataURL encoding:NSUTF8StringEncoding];
    if ( ![strResult length] == 0 ) {
        NSData *theData = [strResult dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        _WordpressPosts = [NSJSONSerialization JSONObjectWithData:theData options:kNilOptions error:&e];
        self.status_update = @"SavoySwing.org Feed Loaded!";
        NSLog(@"Wordpress Feed Success!");
    }
    wordpressReady = YES;
}


/*
 *
 *      Twitter Feed
 *
 */
-(void) makeTwitterFeed: (NSString*) type {
    __twitter =
    [STTwitterAPI twitterAPIWithOAuthConsumerName:twitterConsumerName
                                      consumerKey:twitterConsumerKey
                                   consumerSecret:twitterConsumerSecret
                                       oauthToken:twitterOathToken
                                 oauthTokenSecret:twitterOathTokenSecret];
    
    if (tweet_list) {
        [self getTweetList:tweet_list username:twitter_username requestType:type];
    } else {
        
        [self getTweetAccount:twitter_username requestType:type];
    }
}

/*
 *
 *      get Tweet List from Twitter User
 *
 */
-(void) getTweetList: (NSString *) listSlug username: (NSString*) username requestType: (NSString*) type {
    NSString *sinceID;
    NSString *maxID;
    if ([type isEqualToString:@"new"]) {
        sinceID = newestTwitterID;
        NSLog(@"loading newest Tweets from: %@",sinceID);
    } else if ([type isEqualToString:@"old"] ) {
        maxID = oldestTwitterID;
    }
    
    if ((![type isEqualToString:@"new"] && ![type isEqualToString:@"new"]) ||
        ([type isEqualToString:@"new"] && sinceID) ||
        ([type isEqualToString:@"old"] && maxID)) {
        [__twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
            
            [__twitter getListsStatusesForSlug:listSlug screenName:username ownerID:nil sinceID:sinceID maxID:maxID count:@"25" includeEntities:nil includeRetweets:nil
                                  successBlock:^(NSArray *statuses) {
                                      self.TwitterStatuses = statuses;
                                      if ([statuses  count] > 1) {
                                          newestTwitterID = [[statuses objectAtIndex:0] valueForKey:@"id"];
                                          oldestTwitterID = [[statuses objectAtIndex:([statuses count]-1)] valueForKey:@"id"];
                                      }
                                      twitterReady = YES;
                                      [theAppDel.theLoadingScreen changeLabelText:@"Twitter Feed Loaded!"];
                                      NSLog(@"Twitter Feed Success!");
                                  } errorBlock:^(NSError *error) {
                                      NSLog(@"-- error: %@", error);
                                      twitterReady = YES;
                                  }];
            
        } errorBlock:^(NSError *error) {
            NSLog(@"-- error %@", error);
            twitterReady = YES;
        }];
    } else {
        twitterReady = YES;
    }
}

/*
 *
 *      get Twitter User Tweets
 *
 */
-(void) getTweetAccount: (NSString*) accountName requestType: (NSString*) type {
    
    NSString *sinceID;
    NSString *maxID;
    if ([type isEqualToString:@"new"]) {
        sinceID = newestTwitterID;
        NSLog(@"loading newest Tweets from: %@",sinceID);
    } else if ([type isEqualToString:@"old"] ) {
        maxID = oldestTwitterID;
    }
    
    if ((![type isEqualToString:@"new"] && ![type isEqualToString:@"new"]) ||
        ([type isEqualToString:@"new"] && sinceID) ||
        ([type isEqualToString:@"old"] && maxID)) {
        [__twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
            
            [__twitter getUserTimelineWithScreenName:accountName sinceID:sinceID maxID:maxID count:25
                                        successBlock:^(NSArray *statuses) {
                                            self.TwitterStatuses = statuses;
                                            if ([statuses  count] > 0) {
                                                newestTwitterID = [[statuses objectAtIndex:0] valueForKey:@"id"];
                                                oldestTwitterID = [[statuses objectAtIndex:([statuses count]-1)] valueForKey:@"id"];
                                            }
                                            twitterReady = YES;
                                            [theAppDel.theLoadingScreen changeLabelText:@"Twitter Feed Loaded!"];
                                            NSLog(@"Twitter Feed Success!");
                                        } errorBlock:^(NSError *error) {
                                            NSLog(@"-- error with Timeline acquisition: %@", error);
                                            twitterReady = YES;
                                        }];
            
        } errorBlock:^(NSError *error) {
            NSLog(@"-- error with Credentials %@", error);
            twitterReady = YES;
        }];
    } else {
        twitterReady = YES;
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////         Cell Creation          ///////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSString*) getFeedText: (NSDictionary*) entry {
    NSString* text = @"";
    if ([entry valueForKeyPath:@"message"]) {
        text = [entry valueForKeyPath:@"message"];
    } else if ( [entry valueForKeyPath:@"text"] ) {
        text = [entry valueForKeyPath:@"text"];
    } else if ( [entry valueForKeyPath:@"post_content"] ) {
        text = [entry valueForKeyPath:@"post_content"];
    }
    return text;
}

/*
 *
 *      see Cell Height
 *
 */
-(float) thisCellHeight: (NSInteger) dataIndex {
    float totalHeight = 43; //start of text
    NSString *text;
    NSDictionary *entry = [_allData objectAtIndex:dataIndex];
    text = [self getFeedText:entry];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(77.0f, 43.0f, 180, 180.0f)];
    textLabel.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:14.0];
    textLabel.textAlignment = NSTextAlignmentLeft;
    textLabel.text = text;
    textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    textLabel.numberOfLines = 0;
    [textLabel sizeToFit];
    
    totalHeight += textLabel.frame.size.height; //sum value according to size of text
    totalHeight += 20; //padding on bottom
    
    return totalHeight;
}

/*
 *
 *      making Twitter Cell
 *
 */
-(UITableViewCell *) addFacebookCell: (UITableViewCell *) theCell withIndex: (NSInteger) dataIndex {
    NSDictionary *fbPost = [_allData objectAtIndex:dataIndex];
    NSString *title = [NSString stringWithFormat:@"%@:",[fbPost valueForKeyPath:@"from.name"]];
    NSString *dateFormatter = @"yyyy-MM-dd'T'HH:mm:ssZ";
    NSString *date = [fbPost valueForKeyPath:@"created_time"];
    NSString *text = [fbPost valueForKeyPath:@"message"];
    
    return [self makeCell:theCell title:title date:date dateFormat:dateFormatter text:text errCheck:@"facebook"];
}

/*
 *
 *      making Wordpress Cell
 *
 */
-(UITableViewCell *) addWordpressCell: (UITableViewCell *) theCell withIndex: (NSInteger) dataIndex {
    NSDictionary *wpPost = [_allData objectAtIndex:dataIndex];
    NSString *title = [NSString stringWithFormat:@"%@",[wpPost valueForKeyPath:@"post_title"]];
    NSString *dateFormatter = @"yyyy-MM-dd HH:mm:ss";
    NSString *date = [wpPost valueForKeyPath:@"post_date"];
    NSString *text = [wpPost valueForKeyPath:@"post_content"];
    
    return [self makeCell:theCell title:title date:date dateFormat:dateFormatter text:text errCheck:@"wordpress"];
}

/*
 *
 *      making Twitter Cell
 *
 */
-(UITableViewCell *) addTwitterCell: (UITableViewCell*) theCell withIndex: (NSInteger) dataIndex {
    NSDictionary *status = [_allData objectAtIndex:dataIndex];
    NSString *title = [NSString stringWithFormat:@"@%@:",[status valueForKeyPath:@"user.screen_name"]];
    NSString *dateFormatter = @"E MMM d HH:mm:ss +0000 yyyy";
    NSString *twit_date = [status valueForKeyPath:@"created_at"];
    
    NSDateFormatter *theFormatter = [[NSDateFormatter alloc] init];
    [theFormatter setDateFormat:dateFormatter];
    NSDate *thisDate = [theFormatter dateFromString:twit_date];
    NSTimeInterval secondsInEightHours = -8 * 60 * 60;
    thisDate = [thisDate dateByAddingTimeInterval:secondsInEightHours];
    NSString *date = [theFormatter stringFromDate:thisDate];
    NSString *text = [status valueForKeyPath:@"text"];

    return [self makeCell:theCell title:title date:date dateFormat:dateFormatter text:text errCheck:@"twitter"];
}

-(UITableViewCell*) makeCell: (UITableViewCell*) theCell
                       title: (NSString*) title
                        date: (NSString*) date
                  dateFormat: (NSString*) dateFormat
                        text: (NSString*) text
                    errCheck: (NSString*) errCheck {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(77.0f, 13.0f, 219.0f, 22.0f)];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:17.0];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = title;
    [titleLabel sizeToFit];
    titleLabel.tag = 1;
    
    NSString *twitterDate = date;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    NSDate *thisDate = [dateFormatter dateFromString:twitterDate];
    [dateFormatter setDateFormat:@"E MMM, d yyyy hh:mm"];
    NSString *thisDateText = [dateFormatter stringFromDate:thisDate];
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(77.0f, 32.0f, 219.0f, 22.0f)];
    dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:11.5];
    dateLabel.textAlignment = NSTextAlignmentLeft;
    dateLabel.textColor = [UIColor whiteColor];
    dateLabel.text = thisDateText;
    [dateLabel sizeToFit];
    dateLabel.tag = 2;
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(77.0f, 43.0f, 180, 180.0f)];
    textLabel.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:14.0];
    textLabel.textAlignment = NSTextAlignmentLeft;
    textLabel.textColor = [UIColor whiteColor];
    textLabel.text = text;
    textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    textLabel.numberOfLines = 0;
    textLabel.tag = 3;
    [textLabel sizeToFit];
    
    NSError *errRegex = NULL;
    if ([errCheck  isEqual: @"twitter"]) {
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:@"RT @.*: "
                                      options:NSRegularExpressionCaseInsensitive
                                      error:&errRegex];
        
        [regex enumerateMatchesInString:textLabel.text options:0
                                  range:NSMakeRange(0, [textLabel.text length])
                             usingBlock:^(NSTextCheckingResult *match,
                                          NSMatchingFlags flags, BOOL *stop) {
                                 
                                 NSString *matchFull = [textLabel.text substringWithRange:[match range]];
                                 titleLabel.text = matchFull;
                                 [titleLabel sizeToFit];
                                 
                                 textLabel.text = [textLabel.text stringByReplacingOccurrencesOfString:titleLabel.text withString:@""];
                                 [textLabel sizeToFit];
                             }];
        
    } else if ([errCheck  isEqual: @"facebook"]) {
        NSRange foundRange = [textLabel.text rangeOfString:@"\n"];
        if (foundRange.location != NSNotFound) {
            textLabel.text = [textLabel.text stringByReplacingOccurrencesOfString:@"\n"
                                                                       withString:@""
                                                                          options:0
                                                                            range:foundRange];
        }

    }
    
    [theCell addSubview:titleLabel];
    [theCell addSubview:dateLabel];
    [theCell addSubview:textLabel];
    return theCell;
}

@end
