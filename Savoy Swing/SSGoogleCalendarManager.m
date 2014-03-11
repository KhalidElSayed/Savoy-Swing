//
//  SSImagesManager.m
//  Savoy Swing
//
//  Created by Stevenson on 1/30/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "SSGoogleCalendarManager.h"

@implementation SSGoogleCalendarManager

+(SSGoogleCalendarManager*) sharedManager {
    static dispatch_once_t pred;
    static SSGoogleCalendarManager *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[SSGoogleCalendarManager alloc] init];
    });
    
    return shared;
}

-(void) downloadImagesFromURLString: (NSString*) urlString {
    
}

@end
