//
//  BannerEvents.m
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/18/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "BannerEvents.h"

@implementation BannerEvents

-(id) init {
    self = [super self];
    if ( self ) {
        _allEvents = [[NSArray alloc] init];
    }
    return self;
}

-(void) generateEvents {
    NSString *strURL = @"http://www.savoyswing.org/wp-content/plugins/ssc_iphone_app/lib/processMobileApp.php?appSend&allBanners";
    NSData *dataURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
    NSString *strResult = [[NSString alloc] initWithData:dataURL encoding:NSUTF8StringEncoding];
    if ( ![strResult length] == 0 ) {
        NSData *theData = [strResult dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        _allEvents = [NSJSONSerialization JSONObjectWithData:theData options:kNilOptions error:&e];
    }
}

-(NSArray*) getWeeklyBanners {
    NSDictionary *weekdays = @{@"Monday"   :@0,
                               @"Tuesday"  :@1,
                               @"Wednesday":@2,
                               @"Thursday" :@3,
                               @"Friday"   :@4,
                               @"Saturday" :@5,
                               @"Sunday"   :@6};
    NSArray *sortedArray = [[[_allEvents objectAtIndex:0] copy] sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber *first = (NSNumber*)[weekdays objectForKey:[(NSDictionary*)a objectForKey:@"weekday"]];
        NSNumber *second = (NSNumber*)[weekdays objectForKey:[(NSDictionary*)b objectForKey:@"weekday"]];
        return [first compare: second];
    }];
    NSArray *tempArray = @[sortedArray,[[_allEvents objectAtIndex:1] copy]];
    _allEvents = nil;
    _allEvents = tempArray;
    return [[_allEvents objectAtIndex:0] copy];
}

-(NSArray*) getSpecialBanners {
    return [[_allEvents objectAtIndex:1] copy];
}

-(NSArray*) sortWeeklyBanners {
    return [[NSArray alloc] init];
    
}

-(NSArray*) sortSpecialBanners {
    return [[NSArray alloc] init];
}


@end
