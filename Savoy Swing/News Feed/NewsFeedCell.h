//
//  NewsFeedCell.h
//  Savoy Swing
//
//  Created by Stevenson on 12/10/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCAppDelegate.h"
#import "SSCNewsPost.h"

@interface NewsFeedCell : UITableViewCell

@property (nonatomic) SSCNewsPost *the_post;
@property (nonatomic) UIView *cell_back;


@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *dateLabel;
@property (nonatomic) UILabel *textLabel;
@property (nonatomic) UIImageView *imageView;

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier height: (float) height;
-(void) drawCell;
@end
