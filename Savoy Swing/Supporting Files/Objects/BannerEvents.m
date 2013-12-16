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
    /*
    if ([[_allEvents objectAtIndex:0] count]>1){
        NSDictionary *weekdays = @{@"Monday"   :@0,
                                   @"Tuesday"  :@1,
                                   @"Wednesday":@2,
                                   @"Thursday" :@3,
                                   @"Friday"   :@4,
                                   @"Saturday" :@5,
                                   @"Sunday"   :@6};
        NSArray *sortedArray = [[[_allEvents objectAtIndex:0] copy] sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSNumber *first = (NSNumber*)[weekdays objectForKey:[(NSArray*)[(NSDictionary*)a objectForKey:@"weekdays"] objectAtIndex:0]];
            NSNumber *second = (NSNumber*)[weekdays objectForKey:[(NSArray*)[(NSDictionary*)a objectForKey:@"weekdays"] objectAtIndex:0]];
            return [first compare: second];
        }];
        NSArray *tempArray = @[sortedArray,
                               [[_allEvents objectAtIndex:1] copy],
                               [[_allEvents objectAtIndex:2] copy],
                               [[_allEvents objectAtIndex:3] copy]];
        _allEvents = nil;
        _allEvents = tempArray;
    }
    */
    return [[_allEvents objectAtIndex:0] copy];
}


-(NSArray*) getOtherFrequentBanners {
    if ([[_allEvents objectAtIndex:1] count]>1){
        NSDictionary *weekdays = @{@"Monday"   :@0,
                                   @"Tuesday"  :@1,
                                   @"Wednesday":@2,
                                   @"Thursday" :@3,
                                   @"Friday"   :@4,
                                   @"Saturday" :@5,
                                   @"Sunday"   :@6};
        NSArray *sortedArray = [[[_allEvents objectAtIndex:1] copy] sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSString *date_string_a = [(NSDictionary*)a objectForKey:@"date"];
            NSArray *dateData_a = [date_string_a componentsSeparatedByString:@" | "];
            NSNumber *first = (NSNumber*)[weekdays objectForKey:[dateData_a objectAtIndex:0]];
            NSString *date_string_b = [(NSDictionary*)b objectForKey:@"date"];
            NSArray *dateData_b = [date_string_b componentsSeparatedByString:@" | "];
            NSNumber *second = (NSNumber*)[weekdays objectForKey:[dateData_b objectAtIndex:0]];
            return [first compare: second];
        }];
        
        NSArray *tempArray = @[[[_allEvents objectAtIndex:0] copy],
                               sortedArray,
                               [[_allEvents objectAtIndex:2] copy],
                               [[_allEvents objectAtIndex:3] copy]];
        _allEvents = nil;
        _allEvents = tempArray;
    }
    return [[_allEvents objectAtIndex:1] copy];
}

-(NSArray*) getSpecificDateBanners {
    return [[_allEvents objectAtIndex:2] copy];
}

-(NSArray*) getSpecialBanners {
    return [[_allEvents objectAtIndex:3] copy];
}

-(NSArray*) sortWeeklyBanners {
    return [[NSArray alloc] init];
    
}

-(NSArray*) sortSpecialBanners {
    return [[NSArray alloc] init];
}


@end
