//
//  BannerEvent.h
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/18/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BannerEvent : NSObject

@property (strong) NSString *title;
@property (strong) NSString *info;
@property (strong) NSString *sub_title;
@property (strong) NSString *location;
@property (strong) NSString *link;
@property (strong) NSString *image;
@property (strong) NSString *day;
@property (strong) NSString *neighborhood;
@property (strong) NSString *categories;

-(id)initWithID: (int) banner_id;

@end
