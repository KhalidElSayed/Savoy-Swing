//
//  SSCNewsFeed.h
//  Savoy Swing
//
//  Created by Stevenson on 1/21/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface SSCNewsFeed : NSObject
@property (nonatomic) NSMutableArray *feedData;
@property (nonatomic) NSMutableArray *filteredFeed;
@property (weak,nonatomic) NSOperationQueue *feedQueue;

// Acquire the Feed from the web //
-(void)makeFeed:(NSDictionary*) dataDict;

@end
