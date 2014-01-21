//
//  SSCNewsFeeds.h
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/19/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSCNewsFeeds : NSObject 

@property (strong, nonatomic) NSString *status_update;
@property (nonatomic, strong) NSArray *TwitterStatuses;
@property (nonatomic, strong) NSArray *WordpressPosts;
@property (nonatomic, strong) NSArray *FacebookPosts;
@property (strong, nonatomic) NSTimer *sortCellLoader;
@property (strong, nonatomic) NSTimer *finishedLoader;
@property (strong, nonatomic) NSTimer *tweetLoader;
@property (strong, nonatomic) NSMutableArray *allData;
@property (strong, nonatomic) NSMutableArray *archivedData;

@property (strong, nonatomic) NSString *facebookAccess_Token;
@property (strong, nonatomic) NSMutableDictionary *facebookTrackedIndices;
@property (strong, nonatomic) NSString *facebookFeedURL;

-(void) addTwitterFeed: (NSString*) username andTweetList: (NSString*) tweetList andParams: (NSArray*) params;
-(void) addWordpressFeed: (NSString *) urlToFeed;
-(void) addFacebookFeed: (NSString *) username andParams: (NSArray*) params;
-(NSDictionary*) refreshFacebookFeedAndReturnPostForID: (NSString *) facebookID;
-(void) refreshFacebookFeed;
-(BOOL) hasFeeds;
-(BOOL) postsReady;
-(BOOL) allDone;
-(void) generateFeeds;
-(NSMutableArray*) getData;
-(void) getUpdatedPosts: (NSString*) type;
-(float) thisCellHeight: (NSInteger) dataIndex;
-(UITableViewCell *) addFacebookCell: (UITableViewCell *) theCell withIndex: (NSInteger) dataIndex;
-(UITableViewCell *) addWordpressCell: (UITableViewCell *) theCell withIndex: (NSInteger) dataIndex;
-(UITableViewCell *) addTwitterCell: (UITableViewCell*) theCell withIndex: (NSInteger) dataIndex;
-(UITableViewCell*) makeCell: (UITableViewCell*) theCell
                       title: (NSString*) title
                        date: (NSString*) date
                  dateFormat: (NSString*) dateFormat
                        text: (NSString*) text
                    errCheck: (NSString*) errCheck;
@end
