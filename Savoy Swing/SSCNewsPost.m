//
//  SSCNewsPost.m
//  Savoy Swing
//
//  Created by Stevenson on 1/21/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "SSCNewsPost.h"

@implementation SSCNewsPost

-(id)initWithPostType:(NSString*) post_type {
    self = [super init];
    if (self) {
        _post_type = post_type;
    }
    return self;
}

-(void) downloadUserImage {
    if (self.imageURLString) {
        _isDownloading = YES;
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self imageURLString]]];
        _image = [UIImage imageWithData:imageData];
        _isDownloading = NO;
    }
}

@end
