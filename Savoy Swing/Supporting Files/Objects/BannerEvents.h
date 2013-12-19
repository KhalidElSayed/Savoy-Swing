//
//  BannerEvents.h
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/18/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BannerEvents : NSObject

@property (strong, nonatomic) NSArray *allEvents;
@property (strong, nonatomic) NSMutableArray *indicesSorted;
@property (strong, nonatomic) NSMutableDictionary *allEventImages;
@property (strong, nonatomic) NSTimer *processDataRequest;

-(void) generateEvents;
-(NSArray*) getWeeklyBanners;
-(NSArray*) getOtherFrequentBanners;
-(NSArray*) getSpecificDateBanners;
-(NSArray*) getSpecialBanners;

@end
