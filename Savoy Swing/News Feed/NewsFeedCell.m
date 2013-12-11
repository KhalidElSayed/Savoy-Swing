//
//  NewsFeedCell.m
//  Savoy Swing
//
//  Created by Stevenson on 12/10/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "NewsFeedCell.h"

@implementation NewsFeedCell

@synthesize cell_back;

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier height: (float) height {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        float heightOffset = 10.0f;
        self.cell_back = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                          heightOffset,
                                          self.frame.size.width,
                                          height-(2*heightOffset))];
        self.cell_back.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
        self.cell_back.tag = 2000;
        self.cell_back.layer.cornerRadius = 5;
        self.cell_back.layer.masksToBounds = YES;
        [self insertSubview:cell_back belowSubview:self.contentView];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    float inset = 15.0f;
    frame.origin.x += inset;
    frame.size.width -= 2 * inset;
    [super setFrame:frame];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if ( cell_back ){
        if (highlighted) {
            cell_back.backgroundColor = [UIColor colorWithWhite:3.0f alpha:0.3f];
        } else {
            cell_back.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
        }
    }
}

@end
