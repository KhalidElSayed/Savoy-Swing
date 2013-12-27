//
//  BannerEvents.m
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/18/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "BannerEvents.h"
#import "SSCAppDelegate.h"

@implementation BannerEvents

static SSCAppDelegate *theAppDel;

-(id) init {
    self = [super self];
    if ( self ) {
        _allEvents = [[NSArray alloc] init];
        _indicesSorted = [[NSMutableArray alloc] init];
        _allEventImages = [[NSMutableDictionary alloc] init];
        
        theAppDel = [[UIApplication sharedApplication] delegate];
    }
    return self;
}

-(void) generateEvents {
    NSLog(@"Accessing Banner Events Loaded");
    NSString *strURL = @"http://www.savoyswing.org/wp-content/plugins/ssc_iphone_app/lib/processMobileApp.php?appSend&allBanners";
    NSData *dataURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
    NSString *strResult = [[NSString alloc] initWithData:dataURL encoding:NSUTF8StringEncoding];
    if ( ![strResult length] == 0 ) {
        NSData *theData = [strResult dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        _allEvents = [NSJSONSerialization JSONObjectWithData:theData options:kNilOptions error:&e];
        [self loadImagesToMemory];
    }
}

-(void) loadImagesToMemory {
    NSLog(@"Loading Banner Events to Memory");
    [theAppDel.theLoadingScreen changeLabelText:@"Saving Events to Memory"];
    NSInteger counter = 1;
    for (NSInteger i = 0;i<[_allEvents count];i++ ){
        for (NSInteger j = 0;j<[[_allEvents objectAtIndex:i] count];j++ ){
            NSDictionary *thisEvent = [[_allEvents objectAtIndex:i] objectAtIndex:j];
            if ([thisEvent objectForKey:@"image_url"] && ![[thisEvent objectForKey:@"image_url"] isEqualToString:@""]){
                NSData *dataFromURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:[thisEvent objectForKey:@"image_url"]]];
                UIImage *theImage = [UIImage imageWithData: dataFromURL];
                NSString *thisKey = [thisEvent objectForKey:@"post_id"];
                [_allEventImages setObject:theImage forKey:thisKey];
                
                [theAppDel.theLoadingScreen changeLabelText:[NSString stringWithFormat:@"Loaded %d Events to Memory",counter]];
                counter++;
            }
        }
    }
    NSLog(@"Banner Events Loaded");
}

-(NSArray*) getWeeklyBanners {
    return [[_allEvents objectAtIndex:0] copy];
}


-(NSArray*) getOtherFrequentBanners {
    if ([[_allEvents objectAtIndex:1] count]>1 && ![_indicesSorted containsObject:@"1"]){
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
        [_indicesSorted addObject:@"1"];
    }
    return [[_allEvents objectAtIndex:1] copy];
}

-(NSArray*) getSpecificDateBanners {
    if ([[_allEvents objectAtIndex:2] count]>1 && ![_indicesSorted containsObject:@"2"]){
        NSArray *sortedArray = [[[_allEvents objectAtIndex:2] copy] sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"MM/dd/yyyy"];
            //first
            NSString *date_string_a = [(NSDictionary*)a objectForKey:@"date"];
            NSArray *dateData_a = [date_string_a componentsSeparatedByString:@" | "];
            NSString *beginDate_a = [dateData_a objectAtIndex:0];
            if ([beginDate_a rangeOfString:@"specific:"].location != NSNotFound) {
                beginDate_a = [beginDate_a stringByReplacingOccurrencesOfString:@"specific:"
                                                                 withString:@""];
            }
            NSDate *first;
            if (beginDate_a) {
                first = [dateFormat dateFromString:beginDate_a];
            } else {
                first = [[NSDate alloc] init];
            }
            //second
            NSString *date_string_b = [(NSDictionary*)b objectForKey:@"date"];
            NSArray *dateData_b = [date_string_b componentsSeparatedByString:@" | "];
            NSString *beginDate_b = [dateData_b objectAtIndex:0];
            if ([beginDate_b rangeOfString:@"specific:"].location != NSNotFound) {
                beginDate_b = [beginDate_b stringByReplacingOccurrencesOfString:@"specific:"
                                                                 withString:@""];
            }
            NSDate *second;
            if (beginDate_b) {
                second = [dateFormat dateFromString:beginDate_b];
            } else {
                second = [[NSDate alloc] init];
            }
            return [first compare: second];
        }];
        NSArray *tempArray = @[[[_allEvents objectAtIndex:0] copy],
                               [[_allEvents objectAtIndex:1] copy],
                               sortedArray,
                               [[_allEvents objectAtIndex:3] copy]];
        _allEvents = nil;
        _allEvents = tempArray;
        [_indicesSorted addObject:@"2"];
        
    }
    return [[_allEvents objectAtIndex:2] copy];
}

-(NSArray*) getSpecialBanners {
    return [[_allEvents objectAtIndex:3] copy];
}


@end
