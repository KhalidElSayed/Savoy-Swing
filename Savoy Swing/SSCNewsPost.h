//
//  SSCNewsPost.h
//  Savoy Swing
//
//  Created by Stevenson on 1/21/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSCNewsPost : NSObject

@property (nonatomic) NSString *post_type;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *dateString;
@property (nonatomic) NSString *text;
@property (nonatomic) NSString *imageURLString;
@property (nonatomic) UIImage *image;
@property (nonatomic) NSString *avatar;
@property (nonatomic) NSDictionary *meta;

@property (nonatomic) BOOL isDownloading;

-(void) downloadUserImage;

@end
