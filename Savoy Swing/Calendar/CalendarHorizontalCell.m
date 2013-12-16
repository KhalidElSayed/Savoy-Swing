//
//  CalendarHorizontalCell.m
//  Savoy Swing
//
//  Created by Stevenson on 12/14/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "CalendarHorizontalCell.h"

@implementation CalendarHorizontalCell


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier  {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self prepCalendarCells];
    }
    return self;
}

-(void) prepCalendarCells {
    self.horizontalTableView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    self.horizontalData = [[NSMutableArray alloc] init];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:[[NSDate alloc] init]];
    
    
    [components setHour:-[components hour]];
    [components setMinute:-[components minute]];
    [components setSecond:-[components second]];
    for (NSInteger i=0;i<31;i++) {
        [components setDay:i];
        NSDate *this_day = [cal dateByAddingComponents:components toDate:[[NSDate alloc] init] options:0];
        [self.horizontalData addObject:this_day];
        

    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_delegate updateMainTable:[self.horizontalData objectAtIndex:indexPath.row] withIndex:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HorizontalCell"];
    
    UIColor *ojColor = [UIColor colorWithRed:235.0/255.0 green:119.0/255.0 blue:24.0/255.0 alpha:1.0];
    
    CGAffineTransform rotateTable = CGAffineTransformMakeRotation(M_PI_2);
    UILabel *bigDate = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,150,100)];
    bigDate.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:35.0];
    bigDate.textAlignment = NSTextAlignmentCenter;
    bigDate.textColor = ojColor;
    bigDate.transform = rotateTable;
    bigDate.tag = 201;
    
    UILabel *monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0,150,100)];
    monthLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:18.0];
    monthLabel.textAlignment = NSTextAlignmentCenter;
    monthLabel.textColor = ojColor;
    monthLabel.transform = rotateTable;
    monthLabel.tag = 202;
    
    UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0,150,100)];
    weekdayLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:20.0];
    weekdayLabel.textAlignment = NSTextAlignmentCenter;
    weekdayLabel.textColor = ojColor;
    weekdayLabel.transform = rotateTable;
    weekdayLabel.tag = 202;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"d"];
    bigDate.text = [formatter stringFromDate:[self.horizontalData objectAtIndex:indexPath.row]];
    
    
    [formatter setDateFormat:@"MMMM"];
    monthLabel.text = [formatter stringFromDate:[self.horizontalData objectAtIndex:indexPath.row]];
    
    [formatter setDateFormat:@"EEEE"];
    weekdayLabel.text = [formatter stringFromDate:[self.horizontalData objectAtIndex:indexPath.row]];
    
    [cell addSubview:bigDate];
    //[cell addSubview:monthLabel];
    [cell addSubview:weekdayLabel];
    return cell;
}


@end
