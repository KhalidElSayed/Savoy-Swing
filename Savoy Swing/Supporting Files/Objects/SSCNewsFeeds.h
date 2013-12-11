//
//  SSCNewsFeeds.h
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/19/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSCNewsFeeds : NSObject {
    
    BOOL twitterReady;
    BOOL facebookReady;
    BOOL postsSorted;
    BOOL dataReady;
    
    BOOL twitterActive;
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
    
    
    NSString *facebook_username;
    NSString *facebookClient_id;
    NSString *facebookClient_secret;
}

@property (strong, nonatomic) NSString *status_update;
@property (nonatomic, strong) NSArray *TwitterStatuses;
@property (nonatomic, strong) NSArray *FacebookPosts;
@property (strong, nonatomic) NSTimer *sortCellLoader;
@property (strong, nonatomic) NSTimer *finishedLoader;
@property (strong, nonatomic) NSTimer *tweetLoader;
@property (strong, nonatomic) NSMutableArray *allData;
@property (strong, nonatomic) NSMutableArray *archivedData;

-(void) addTwitterFeed: (NSString*) username andTweetList: (NSString*) tweetList andParams: (NSArray*) params;
-(void) addFacebookFeed: (NSString *) username andParams: (NSArray*) params;
-(BOOL) hasFeeds;
-(BOOL) postsReady;
-(BOOL) allDone;
-(void) generateFeeds;
-(NSMutableArray*) getData;
-(void) getUpdatedPosts: (NSString*) type;
-(float) thisCellHeight: (NSInteger) dataIndex;
-(UITableViewCell *) addFacebookCell: (UITableViewCell *) theCell withIndex: (NSInteger) dataIndex;
-(UITableViewCell *) addTwitterCell: (UITableViewCell*) theCell withIndex: (NSInteger) dataIndex;
-(UITableViewCell*) makeCell: (UITableViewCell*) theCell
                       title: (NSString*) title
                        date: (NSString*) date
                  dateFormat: (NSString*) dateFormat
                        text: (NSString*) text
                    errCheck: (NSString*) errCheck;
@end
