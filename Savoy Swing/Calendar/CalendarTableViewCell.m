//
//  CalendarTableViewCell.m
//  Savoy Swing
//
//  Created by Steven Stevenson on 12/11/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "CalendarTableViewCell.h"

@interface CalendarTableViewCell()  {
    SSCAppDelegate *theAppDel;
    NSMutableDictionary *approvedGoogleData;
}

@end

@implementation CalendarTableViewCell

- (void)setFrame:(CGRect)frame {
    float inset = 10.0f;
    frame.origin.x += inset;
    frame.size.width -= 2 * inset;
    [super setFrame:frame];
}

#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addGoogleInfo{
        theAppDel = (SSCAppDelegate*)[[UIApplication sharedApplication] delegate];
        if ([theAppDel hasConnectivity] && self.thisEvent && [[self.thisEvent objectForKey:@"google_urls"] isKindOfClass: [NSArray class]]){
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        
            NSArray *allGoogleIDS = [self.thisEvent objectForKey:@"google_urls"];
            if ( allGoogleIDS ) {
                NSArray *weekdays = [self.thisEvent objectForKey:@"weekdays"];
                [formatter setDateFormat:@"EEEE"];
                NSString *this_day = [formatter stringFromDate:self.theDate];
                NSString *googleID = @"";
                NSString *begin_time = @"";
                
                if ([weekdays count] == 2 && [[weekdays objectAtIndex:1] rangeOfString:@","].location != NSNotFound) {
                    NSString *dayNameWeekly = [weekdays objectAtIndex:0];
                    if ([dayNameWeekly rangeOfString:@" : "].location != NSNotFound) {
                        NSArray *dayHour =[dayNameWeekly componentsSeparatedByString:@" : "];
                        dayNameWeekly = [dayHour objectAtIndex:0];
                        begin_time = [dayHour objectAtIndex:1];
                        if ([begin_time rangeOfString:@" - "].location != NSNotFound) {
                            NSArray *timeSplit =[begin_time  componentsSeparatedByString:@" - "];
                            begin_time = timeSplit[0];
                        }
                    }
                    NSArray *freqTypes = [[weekdays objectAtIndex:1] componentsSeparatedByString:@","];
                    for (NSInteger i=0;i<[freqTypes count];i++) {
                        [formatter setDateFormat:@"F"];
                        NSString *thisWeek = [formatter stringFromDate:self.theDate];
                        if ([thisWeek isEqualToString:[freqTypes objectAtIndex:i]]) {
                            googleID = [allGoogleIDS objectAtIndex:i];
                            break;
                        }
                    }
                } else {
                    for (NSInteger i=0;i<[weekdays count];i++) {
                        NSString *dayNameWeekly = [weekdays objectAtIndex:i];
                        if ([dayNameWeekly rangeOfString:@" : "].location != NSNotFound) {
                            NSArray *dayHour =[dayNameWeekly componentsSeparatedByString:@" : "];
                            dayNameWeekly = [dayHour objectAtIndex:0];
                            begin_time = [dayHour objectAtIndex:1];
                            if ([begin_time rangeOfString:@" - "].location != NSNotFound) {
                                NSArray *timeSplit =[begin_time  componentsSeparatedByString:@" - "];
                                begin_time = timeSplit[0];
                            }
                        }
                        if ([this_day isEqualToString: dayNameWeekly] ) {
                            googleID = [allGoogleIDS objectAtIndex:i];
                            break;
                        }
                    }
                }
                if ( ![googleID isEqualToString:@""]) {
                    double beginDouble = [begin_time doubleValue];
                    beginDouble = (beginDouble+800.0f);
                    NSInteger beginInt = (int)(beginDouble + (beginDouble>0 ? 0.5 : -0.5));
                    NSInteger dayDiff = (beginInt+2400-100)/beginInt;
                    beginInt = beginInt % 2400;
                    NSString *theTime = (beginInt <1000) ? [NSString stringWithFormat:@"0%d", beginInt] : [NSString stringWithFormat:@"%d", beginInt];

                    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
                    [dateComponents setDay:+dayDiff];
                    self.theDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self.theDate options:0];
                    
                    [formatter setDateFormat:@"yyyyMMdd"];
                    NSString *thisDate = [formatter stringFromDate:self.theDate];
                    NSString *timeInUTC = [NSString stringWithFormat:@"_%@T%@00Z",thisDate,theTime];   //format: @"_20131221T050000Z";
                    NSString *strURL = [NSString stringWithFormat:@"%@%@?alt=json",googleID,timeInUTC];
                    NSData *dataURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
                    NSString *strResult = [[NSString alloc] initWithData:dataURL encoding:NSUTF8StringEncoding];
                    if ( ![strResult length] == 0 ) {
                        NSData *theData = [strResult dataUsingEncoding:NSUTF8StringEncoding];
                        NSError *e;
                        NSDictionary *googleData = [NSJSONSerialization JSONObjectWithData:theData options:kNilOptions error:&e];
                        NSDictionary *googleEntry = [googleData objectForKey:@"entry"];
                        [approvedGoogleData setValue:[[googleEntry objectForKey:@"title"] objectForKey:@"$t"] forKey:@"post_title"];
                        [self reloadForGoogleData];
                    }
                }
            }
        }
}

-(void)reloadForGoogleData {
    if (approvedGoogleData) {
        CGFloat ongoingHeight = self.title.frame.origin.y;
        self.title.frame = CGRectMake(7.0f, ongoingHeight, self.frame.size.width-14, 22.0f);
        self.title.numberOfLines = 0;
        self.title.text = [approvedGoogleData objectForKey:@"post_title"];
        
        [self.title sizeToFit];
        ongoingHeight += self.title.frame.size.height;
        
        self.sub_title.frame = CGRectMake(7.0f, ongoingHeight, self.frame.size.width, 22.0f);
        self.sub_title.numberOfLines = 0;
        self.sub_title.text = [self.thisEvent objectForKey:@"post_sub"];
        [self.sub_title sizeToFit];
        ongoingHeight += self.sub_title.frame.size.height;
        
        
        ongoingHeight += 14;
        self.main_text.frame =  CGRectMake(7.0f, ongoingHeight, self.frame.size.width-14.0f, 22.0f);
        self.main_text.numberOfLines = 0;
        self.main_text.text = [self.thisEvent objectForKey:@"post_text"];
        [self.main_text sizeToFit];
        ongoingHeight += self.main_text.frame.size.height;
        

        self.google_stamp.image = [UIImage imageNamed:@"google_stamp.png"];
    }
}

- (void)prepareCell: (NSDictionary*) thisEvent onDate: (id) theDate{
    self.theDate = theDate;
    self.thisEvent = thisEvent;
    NSString *dateString = @"";
    NSString *withOccurrence = @"";
    if ( [theDate isKindOfClass:[NSDate class]] ) {
        //configure date for display
        NSString *dateInfo = [thisEvent objectForKey:@"date"];
        if ([dateInfo rangeOfString:@" | "].location != NSNotFound) {
            NSArray *days =[dateInfo componentsSeparatedByString:@" | "];
            NSString *thisDay;
            for (NSInteger i=0;i<[days count];i++) {
                NSMutableArray *hours = [[NSMutableArray alloc] init];
                if ([[days objectAtIndex:i] rangeOfString:@","].location == NSNotFound) {
                    if ([[days objectAtIndex:i] rangeOfString:@" : "].location != NSNotFound) {
                        NSArray *dayHours =[[days objectAtIndex:i] componentsSeparatedByString:@" : "];
                        if ([dayHours count] == 2 && [[dayHours objectAtIndex:1] rangeOfString:@" - "].location != NSNotFound) {
                            thisDay = [dayHours objectAtIndex:0];
                            NSArray *theseHours =[[dayHours objectAtIndex:1] componentsSeparatedByString:@" - "];
                            [hours addObject:[theseHours objectAtIndex:0]];
                            [hours addObject:[theseHours objectAtIndex:1]];
                        } else {
                            [hours addObject:[dayHours objectAtIndex:0]];
                        }
                    } else {
                        thisDay = [days objectAtIndex:i];
                        break;
                    }
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"EEEE"];
                    NSString *this_day = [formatter stringFromDate:theDate];
                    if ([thisDay isEqualToString:this_day] && [hours count] > 0) {
                        NSString *start = [hours objectAtIndex:0];
                        NSInteger startHour = [[start substringToIndex:[start length] - 2] doubleValue];
                        NSString *amPM_start = @"am";
                        if (startHour > 12 ) {
                            amPM_start = @"pm";
                        }
                        startHour = startHour%12;
                        NSString *startMinute = [start substringFromIndex: [start length] - 2];
                        
                        if ( [hours count] == 2) {
                            NSString *endTime = [hours objectAtIndex:1];
                            NSInteger endHour = [[endTime substringToIndex:[endTime length] - 2] doubleValue];
                            NSString *amPM_end = @"am";
                            if (endHour > 12  ) {
                                amPM_end = @"pm";
                            }
                            endHour = endHour %12;
                            NSString *endMinute = [endTime substringFromIndex: [endTime length] - 2];
                            dateString = [NSString stringWithFormat:@"%d:%@ %@ - %d:%@ %@",startHour,startMinute,amPM_start,endHour,endMinute,amPM_end];
                        } else  {
                            dateString = [NSString stringWithFormat:@"Start Time: %d:%@ %@",startHour,startMinute,amPM_start];
                        }
                    }
                } else {
                    if (![thisDay isEqualToString:@""]) {
                        BOOL multiple_days = NO;
                        NSString *withNumerical = [days objectAtIndex:i];
                        if ([[withNumerical componentsSeparatedByString:@","] count] > 2) {
                            multiple_days = YES;
                        }
                        withNumerical = [withNumerical stringByReplacingOccurrencesOfString:@"1," withString:@"1st "];
                        withNumerical = [withNumerical stringByReplacingOccurrencesOfString:@"2," withString:@"2nd "];
                        withNumerical = [withNumerical stringByReplacingOccurrencesOfString:@"3," withString:@"3rd "];
                        withNumerical = [withNumerical stringByReplacingOccurrencesOfString:@"4," withString:@"4th "];
                        withNumerical = [withNumerical stringByReplacingOccurrencesOfString:@"5," withString:@"5th "];
                        if (multiple_days) {
                            withOccurrence = [NSString stringWithFormat:@" (%@%@s)",withNumerical,thisDay];
                        } else {
                            withOccurrence = [NSString stringWithFormat:@" (%@%@)",withNumerical,thisDay];
                        }
                    }
                }
            }
        } else {
            NSMutableArray *hours = [[NSMutableArray alloc] init];
            NSString *thisDay;
            if ([dateInfo rangeOfString:@" : "].location != NSNotFound) {
                NSArray *dayHours =[dateInfo componentsSeparatedByString:@" : "];
                if ([dayHours count] == 2 && [[dayHours objectAtIndex:1] rangeOfString:@" - "].location != NSNotFound) {
                    thisDay = [dayHours objectAtIndex:0];
                    NSArray *theseHours =[[dayHours objectAtIndex:1] componentsSeparatedByString:@" - "];
                    [hours addObject:[theseHours objectAtIndex:0]];
                    [hours addObject:[theseHours objectAtIndex:1]];
                } else {
                    [hours addObject:[dayHours objectAtIndex:0]];
                }
            } else {
                thisDay = dateInfo;
            }
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"EEEE"];
            NSString *this_day = [formatter stringFromDate:theDate];
            if ([thisDay isEqualToString:this_day] && [hours count] > 0) {
                NSString *start = [hours objectAtIndex:0];
                NSInteger startHour = [[start substringToIndex:[start length] - 2] doubleValue];
                NSString *amPM_start = @"am";
                if (startHour > 12 ) {
                    amPM_start = @"pm";
                }
                startHour = startHour%12;
                NSString *startMinute = [start substringFromIndex: [start length] - 2];
                
                if ( [hours count] == 2) {
                    NSString *endTime = [hours objectAtIndex:1];
                    NSInteger endHour = [[endTime substringToIndex:[endTime length] - 2] doubleValue];
                    NSString *amPM_end = @"am";
                    if (endHour > 12  ) {
                        amPM_end = @"pm";
                    }
                    endHour = endHour %12;
                    NSString *endMinute = [endTime substringFromIndex: [endTime length] - 2];
                    dateString = [NSString stringWithFormat:@"%d:%@ %@ - %d:%@ %@",startHour,startMinute,amPM_start,endHour,endMinute,amPM_end];
                } else  {
                    dateString = [NSString stringWithFormat:@"Start Time: %d:%@ %@",startHour,startMinute,amPM_start];
                }
            }
        }
    } else if ( [theDate isKindOfClass:[NSString class]]) {
        NSString *dateInfo = [thisEvent objectForKey:@"date"];
        if ([dateInfo rangeOfString:@" | "].location != NSNotFound) {
            NSArray *days =[dateInfo componentsSeparatedByString:@" | "];
            NSString *thisDay;
            for (NSInteger i=0;i<[days count];i++) {
                NSMutableArray *hours = [[NSMutableArray alloc] init];
                if ([[days objectAtIndex:i] rangeOfString:@","].location == NSNotFound) {
                    if ([[days objectAtIndex:i] rangeOfString:@" : "].location != NSNotFound) {
                        NSArray *dayHours =[[days objectAtIndex:i] componentsSeparatedByString:@" : "];
                        if ([dayHours count] == 2 && [[dayHours objectAtIndex:1] rangeOfString:@" - "].location != NSNotFound) {
                            thisDay = [dayHours objectAtIndex:0];
                            NSArray *theseHours =[[dayHours objectAtIndex:1] componentsSeparatedByString:@" - "];
                            [hours addObject:[theseHours objectAtIndex:0]];
                            [hours addObject:[theseHours objectAtIndex:1]];
                        } else {
                            [hours addObject:[dayHours objectAtIndex:1]];
                        }
                    } else {
                        thisDay = [days objectAtIndex:i];
                        break;
                    }
                    NSString *this_day = theDate;
                    if ([thisDay isEqualToString:this_day] && [hours count] > 0) {
                        NSString *start = [hours objectAtIndex:0];
                        NSInteger startHour = [[start substringToIndex:[start length] - 2] doubleValue];
                        NSString *amPM_start = @"am";
                        if (startHour > 12 ) {
                            amPM_start = @"pm";
                        }
                        startHour = startHour%12;
                        NSString *startMinute = [start substringFromIndex: [start length] - 2];
                        
                        if ( [hours count] == 2) {
                            NSString *endTime = [hours objectAtIndex:1];
                            NSInteger endHour = [[endTime substringToIndex:[endTime length] - 2] doubleValue];
                            NSString *amPM_end = @"am";
                            if (endHour > 12  ) {
                                amPM_end = @"pm";
                            }
                            endHour = endHour %12;
                            NSString *endMinute = [endTime substringFromIndex: [endTime length] - 2];
                            dateString = [NSString stringWithFormat:@"%d:%@ %@ - %d:%@ %@",startHour,startMinute,amPM_start,endHour,endMinute,amPM_end];
                        } else  {
                            dateString = [NSString stringWithFormat:@"Start Time: %d:%@ %@",startHour,startMinute,amPM_start];
                        }
                    }
                } else {
                    if (![thisDay isEqualToString:@""]) {
                        BOOL multiple_days = NO;
                        NSString *withNumerical = [days objectAtIndex:i];
                        if ([[withNumerical componentsSeparatedByString:@","] count] > 2) {
                            multiple_days = YES;
                        }
                        withNumerical = [withNumerical stringByReplacingOccurrencesOfString:@"1," withString:@"1st "];
                        withNumerical = [withNumerical stringByReplacingOccurrencesOfString:@"2," withString:@"2nd "];
                        withNumerical = [withNumerical stringByReplacingOccurrencesOfString:@"3," withString:@"3rd "];
                        withNumerical = [withNumerical stringByReplacingOccurrencesOfString:@"4," withString:@"4th "];
                        withNumerical = [withNumerical stringByReplacingOccurrencesOfString:@"5," withString:@"5th "];
                        if (multiple_days) {
                            withOccurrence = [NSString stringWithFormat:@" (%@%@s)",withNumerical,thisDay];
                        } else {
                            withOccurrence = [NSString stringWithFormat:@" (%@%@)",withNumerical,thisDay];
                        }
                    }
                }
            }
        } else {
            NSMutableArray *hours = [[NSMutableArray alloc] init];
            NSString *thisDay;
            if ([dateInfo rangeOfString:@" : "].location != NSNotFound) {
                NSArray *dayHours =[dateInfo componentsSeparatedByString:@" : "];
                if ([dayHours count] == 2 && [[dayHours objectAtIndex:1] rangeOfString:@" - "].location != NSNotFound) {
                    thisDay = [dayHours objectAtIndex:0];
                    NSArray *theseHours =[[dayHours objectAtIndex:1] componentsSeparatedByString:@" - "];
                    [hours addObject:[theseHours objectAtIndex:0]];
                    [hours addObject:[theseHours objectAtIndex:1]];
                } else {
                    [hours addObject:[dayHours objectAtIndex:0]];
                }
            }
            NSString *start = [hours objectAtIndex:0];
            NSInteger startHour = [[start substringToIndex:[start length] - 2] doubleValue];
            NSString *amPM_start = @"am";
            if (startHour > 12 ) {
                amPM_start = @"pm";
            }
            startHour = startHour%12;
            NSString *startMinute = [start substringFromIndex: [start length] - 2];
            
            if ( [hours count] == 2) {
                NSString *endTime = [hours objectAtIndex:1];
                NSInteger endHour = [[endTime substringToIndex:[endTime length] - 2] doubleValue];
                NSString *amPM_end = @"am";
                if (endHour > 12  ) {
                    amPM_end = @"pm";
                }
                endHour = endHour %12;
                NSString *endMinute = [endTime substringFromIndex: [endTime length] - 2];
                dateString = [NSString stringWithFormat:@"%d:%@ %@ - %d:%@ %@",startHour,startMinute,amPM_start,endHour,endMinute,amPM_end];
            } else  {
                dateString = [NSString stringWithFormat:@"Start Time: %d:%@ %@",startHour,startMinute,amPM_start];
            }
        }
    }
    float ongoingHeight = 0.0;
    //standard height of cell
    float height = self.frame.size.width/283.5f*60.0f;
    
    //highlightView objects
    UIView *highlightView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, height, self.frame.size.width-14, 64.0f)];
    highlightView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.9f];
    
    
    
    
    ongoingHeight += 4.0f;
    UILabel *hood = [[UILabel alloc] initWithFrame:CGRectMake(7.0f, ongoingHeight, self.frame.size.width-14, 22.0f)];
    hood.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0];
    hood.textAlignment = NSTextAlignmentLeft;
    hood.textColor = [UIColor colorWithRed:235.0/255.0 green:119.0/255.0 blue:24.0/255.0 alpha:1.0];
    hood.numberOfLines = 0;
    hood.shadowColor = [UIColor lightGrayColor];
    hood.shadowOffset = CGSizeMake(0.0f, 0.0f);
    hood.text = [NSString stringWithFormat:@"%@%@",dateString,withOccurrence];
    [hood sizeToFit];
    ongoingHeight += hood.frame.size.height;
    
    self.title = [[UILabel alloc] initWithFrame:CGRectMake(7.0f, ongoingHeight, self.frame.size.width-14, 22.0f)];
    self.title.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:18.0];
    self.title.textAlignment = NSTextAlignmentLeft;
    self.title.textColor = [UIColor blackColor];
    self.title.numberOfLines = 2;
    self.title.tag = 1001;
    self.title.text = [thisEvent objectForKey:@"post_title"];

    [self.title sizeToFit];
    ongoingHeight += self.title.frame.size.height;
    
    self.sub_title = [[UILabel alloc] initWithFrame:CGRectMake(7.0f, ongoingHeight, self.frame.size.width, 22.0f)];
    self.sub_title.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:12.0];
    self.sub_title.textAlignment = NSTextAlignmentLeft;
    self.sub_title.textColor = [UIColor blackColor];
    self.sub_title.numberOfLines = 0;
    self.sub_title.text = [thisEvent objectForKey:@"post_sub"];
    [self.sub_title sizeToFit];
    ongoingHeight += self.sub_title.frame.size.height;
    
    
    ongoingHeight += 14;
    self.main_text = [[UILabel alloc] initWithFrame:CGRectMake(7.0f, ongoingHeight, self.frame.size.width-14.0f, 22.0f)];
    self.main_text.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
    self.main_text.textAlignment = NSTextAlignmentLeft;
    self.main_text.textColor = [UIColor blackColor];
    self.main_text.numberOfLines = 0;
    self.main_text.text = [thisEvent objectForKey:@"post_text"];
    [self.main_text sizeToFit];
    ongoingHeight += self.main_text.frame.size.height;
    
    
    self.google_stamp = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-50, -20, 50, 50)];
    self.google_stamp.image = [UIImage imageNamed:@"google_stamp_x.png"];

    [highlightView addSubview:self.google_stamp];
    
    //add labels to highlightView
    [highlightView addSubview:self.title];
    [highlightView addSubview:hood];
    [highlightView addSubview:self.sub_title];
    [highlightView addSubview:self.main_text];
    
    //add all the views
    [self.contentView insertSubview:highlightView belowSubview:self.contentView];
    
    
    if ( [theDate isKindOfClass:[NSDate class]] ) {
        approvedGoogleData = [[NSMutableDictionary alloc] init];
        [self performSelectorInBackground:@selector(addGoogleInfo) withObject:nil];
    }
}

@end
