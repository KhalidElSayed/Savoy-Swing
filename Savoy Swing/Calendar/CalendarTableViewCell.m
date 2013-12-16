//
//  CalendarTableViewCell.m
//  Savoy Swing
//
//  Created by Steven Stevenson on 12/11/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "CalendarTableViewCell.h"

@implementation CalendarTableViewCell

- (void)setFrame:(CGRect)frame {
    float inset = 10.0f;
    frame.origin.x += inset;
    frame.size.width -= 2 * inset;
    [super setFrame:frame];
}

@end
