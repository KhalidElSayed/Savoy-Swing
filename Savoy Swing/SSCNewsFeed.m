//
//  SSCNewsFeed.m
//  Savoy Swing
//
//  Created by Stevenson on 1/21/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "SSCNewsPost.h"
#import "SSCNewsFeed.h"

@interface SSCNewsFeed() 

@end

@implementation SSCNewsFeed

-(id)init {
    self = [super init];
    if (self) {
        self.feedData = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)makeFeed: (NSDictionary*) dataDict {
    NSArray *feedItems = [dataDict objectForKey:@"items"];
    for (id item in feedItems) {
        if ([item isKindOfClass:[NSDictionary class]]) {
            SSCNewsPost *thisPost = [[SSCNewsPost alloc] init];
            thisPost.post_type = [item objectForKey:@"post_type"];
            thisPost.title = [item objectForKey:@"title"];
            thisPost.dateString = [item objectForKey:@"dateString"];
            thisPost.text = [item objectForKey:@"text"];
            thisPost.imageURLString = [item objectForKey:@"imageString"];
            thisPost.meta = [item objectForKey:@"meta"];
            
            [self.feedData addObject:thisPost];
        }
    }
}

@end
