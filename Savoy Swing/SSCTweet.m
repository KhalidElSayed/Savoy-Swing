//
//  SSCTweet.m
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/20/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "SSCTweet.h"

@implementation SSCTweet

@synthesize text;
@synthesize screenName;
@synthesize dateString;

-(id)initWithStatus: (NSDictionary*) status {
    self = [super init];
    if (self) {
        self.text = [status valueForKey:@"text"];
        self.screenName = [status valueForKeyPath:@"user.screen_name"];
        self.dateString = [status valueForKey:@"created_at"];
    }
    return self;
}

@end
