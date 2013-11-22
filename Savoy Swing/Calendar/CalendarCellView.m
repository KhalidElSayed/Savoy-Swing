//
//  CalendarCellvIew.m
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/18/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "CalendarCellView.h"
#import "BannerEvent.h"

@implementation CalendarCellView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setBackgroundColor:(UIColor *)backgroundColor {
    CGFloat alpha = CGColorGetAlpha(backgroundColor.CGColor);
    if (alpha != 0) {
        [super setBackgroundColor:backgroundColor];
    }
}

@end
