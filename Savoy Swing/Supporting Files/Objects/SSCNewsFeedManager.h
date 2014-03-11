//
//  SSCNewsFeeds.h
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/19/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSCNewsFeed.h"
#import "SSCNewsPost.h"

@interface SSCNewsFeedManager : NSObject

@property (atomic) NSURLSession *theURLSession;
@property (nonatomic) SSCNewsFeed *allFeeds;
@property (nonatomic) NSArray *hiddenFeeds;

+(SSCNewsFeedManager*) sharedManager;

-(void) tellFacebookToLikePost:(SSCNewsPost*) thePost;
-(void) getNewsPosts;
-(void) getNewerNewPosts:(NSDate *) time;
-(void) getOlderNewsPosts:(NSDate *) time;

@end
