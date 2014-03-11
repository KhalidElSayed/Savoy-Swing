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
        
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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

#pragma mark - Draw Subviews to Cell

-(void) drawCell {
    // post type //
    NSString *post_type = [self.the_post post_type];
    
    // post date Format //
    NSString *dateFormat;
    
    // post avatar image View //
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(11.0f, 20.0f, 50.0f, 50.0f)];
    UIImage *theImage;

    if ([post_type isEqualToString:@"Twitter"]) {
        dateFormat = TWITTER_DATE_FORMAT;
        theImage = [UIImage imageNamed:@"twitter-icon.png"];
    } else if ([post_type isEqualToString:@"Facebook"]) {
        dateFormat = FACEBOOK_DATE_FORMAT;
        theImage = [UIImage imageNamed:@"facebook-icon.png"];
    } else if ([post_type isEqualToString:@"Wordpress"]) {
        dateFormat = WORDPRESS_DATE_FORMAT;
        theImage = [UIImage imageNamed:@"ssc_logo_old.png"];
    }
    
    if (theImage ) {
        self.imageView.image = theImage;
        [self addSubview:self.imageView];
    }
    
    // post date //
    NSString *date = [self.the_post dateString];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    NSDate *thisDate = [dateFormatter dateFromString:date];
    [dateFormatter setDateFormat:GENERAL_DATE_FORMAT];
    NSString *thisDateText = [dateFormatter stringFromDate:thisDate];
    

    
    [self makeCellSubViewsWithDateString:thisDateText];
}

-(void) makeCellSubViewsWithDateString: (NSString*) dateString {
    // post title //
    NSString *title = [self.the_post title];
    
    // post text //
    NSString *text = [self.the_post text];
    
    //label drawings
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(77.0f, 13.0f, 219.0f, 22.0f)];
    self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:17.0];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.text = title;
    [self.titleLabel sizeToFit];
    self.titleLabel.tag = 1;
    
    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(77.0f, 32.0f, 219.0f, 22.0f)];
    self.dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:11.5];
    self.dateLabel.textAlignment = NSTextAlignmentLeft;
    self.dateLabel.textColor = [UIColor whiteColor];
    self.dateLabel.text = dateString;
    [self.dateLabel sizeToFit];
    self.dateLabel.tag = 2;
    
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(77.0f, 43.0f, 180, 180.0f)];
    self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:14.0];
    self.textLabel.textAlignment = NSTextAlignmentLeft;
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.text = text;
    self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.textLabel.numberOfLines = 0;
    [self.textLabel sizeToFit];
    self.textLabel.tag = 3;
    
    NSError *errRegex = NULL;
    if ([[self.the_post  post_type] isEqual: @"Twitter"]) {
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:@"RT @.*: "
                                      options:NSRegularExpressionCaseInsensitive
                                      error:&errRegex];
        
        [regex enumerateMatchesInString:text options:0
                                  range:NSMakeRange(0, [text length])
                             usingBlock:^(NSTextCheckingResult *match,
                                          NSMatchingFlags flags, BOOL *stop) {
                                 
                                 NSString *matchFull = [text substringWithRange:[match range]];
                                 self.titleLabel.text = matchFull;
                                 [self.titleLabel sizeToFit];
                                 
                                 self.textLabel.text = [self.textLabel.text stringByReplacingOccurrencesOfString:self.titleLabel.text withString:@""];
                                 [self.textLabel sizeToFit];
                             }];
        
    } else if ([[self.the_post  post_type]  isEqual: @"Facebook"]) {
        NSRange foundRange = [self.textLabel.text rangeOfString:@"\n"];
        if (foundRange.location != NSNotFound) {
            self.textLabel.text = [self.textLabel.text stringByReplacingOccurrencesOfString:@"\n"
                                                                       withString:@""
                                                                          options:0
                                                                            range:foundRange];
        }
        
    }
    
    if ([self.titleLabel superview]) {
        [self addSubview:self.titleLabel];
    }
    if ([self.dateLabel superview] ) {
        [self addSubview:self.dateLabel];
    } if ([self.textLabel superview]) {
        [self addSubview:self.textLabel];
    }
}

@end
