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

- (CalendarTableViewCell *)prepareCell: (NSDictionary*) thisEvent theCell: (CalendarTableViewCell*) cell {
    float height = cell.frame.size.width/283.5f*60.0f;
    
    //highlightView objects
    UIView *highlightView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, height, cell.frame.size.width, 64.0f)];
    highlightView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.9f];
    
    UILabel *hood = [[UILabel alloc] initWithFrame:CGRectMake(7.0f, 4.0f, 153.0f, 22.0f)];
    hood.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0];
    hood.textAlignment = NSTextAlignmentLeft;
    hood.textColor = [UIColor colorWithRed:235.0/255.0 green:119.0/255.0 blue:24.0/255.0 alpha:1.0];
    hood.shadowColor = [UIColor lightGrayColor];
    hood.shadowOffset = CGSizeMake(0.0f, 0.0f);
    hood.text = [thisEvent objectForKey:@"date"];
    [hood sizeToFit];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(7.0f, 18.0f, 153.0f, 22.0f)];
    title.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:18.0];
    title.textAlignment = NSTextAlignmentLeft;
    title.textColor = [UIColor blackColor];
    title.text = [thisEvent objectForKey:@"post_title"];
    [title sizeToFit];
    
    UILabel *cats = [[UILabel alloc] initWithFrame:CGRectMake(7.0f, 39.0f, cell.frame.size.width, 22.0f)];
    cats.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:12.0];
    cats.textAlignment = NSTextAlignmentLeft;
    cats.textColor = [UIColor blackColor];
    cats.numberOfLines = 0;
    cats.text = [thisEvent objectForKey:@"post_sub"];
    [cats sizeToFit];
    
    UILabel *main_text = [[UILabel alloc] initWithFrame:CGRectMake(7.0f, 60.0f, cell.frame.size.width-14.0f, 22.0f)];
    main_text.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
    main_text.textAlignment = NSTextAlignmentLeft;
    main_text.textColor = [UIColor blackColor];
    main_text.numberOfLines = 0;
    main_text.text = [thisEvent objectForKey:@"post_text"];
    [main_text sizeToFit];
    
    //add labels to highlightView
    [highlightView addSubview:title];
    [highlightView addSubview:hood];
    [highlightView addSubview:cats];
    [highlightView addSubview:main_text];
    
    //more Detail Objects
    UILabel *sub_title = [[UILabel alloc] initWithFrame:CGRectMake(6.0f, 81.0f, 309.0f, 22.0f)];
    sub_title.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:16.0];
    sub_title.textAlignment = NSTextAlignmentLeft;
    sub_title.textColor = [UIColor blackColor];
    [sub_title sizeToFit];
    
    
    //add all the views
    [cell.contentView addSubview:highlightView];
    [cell.contentView addSubview:sub_title];
    
    return cell;
}

@end
