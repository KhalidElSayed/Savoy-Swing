//
//  CalendarTableViewController.m
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/18/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "CalendarTableViewController.h"
#import "BannerEvents.h"
#import "CalendarTableViewCell.h"

@implementation CalendarTableViewController

-(void) viewDidLoad {
    
    theAppDel = (SSCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;
    
    NSArray *calendar_types =@[@"Month Calendar",@"Weekly Dances"];
    calendar_switch = [[UISegmentedControl alloc] initWithItems:calendar_types];
    calendar_switch.frame = CGRectMake(0, 0, 100, 30);
    calendar_switch.selectedSegmentIndex = 0;
    [calendar_switch addTarget:self action:@selector(changeCalendarView) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = calendar_switch;
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit ) fromDate:[[NSDate alloc] init]];
    
    
    [components setHour:-[components hour]];
    [components setMinute:-[components minute]];
    [components setSecond:-[components second]];
    _currentDate = [cal dateByAddingComponents:components toDate:[[NSDate alloc] init] options:0];

}

-(void) viewWillAppear:(BOOL)animated {
    
    //put graphic image for loading graphic
    self.navigationController.navigationBarHidden = YES;
    loaderImageView =[[UIImageView alloc] initWithFrame:CGRectMake(0.0f, (self.view.bounds.size.height-568.0f)/2, self.view.frame.size.width, 568.0f)];
    
    UIImage *theImage = [UIImage imageNamed:@"R4Default.png"];
    loaderImageView.image = theImage;
    imageIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    loadingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    loadingLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:22.0];
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.textColor = [UIColor whiteColor];
    loadingLabel.text = @"Getting Week Events";
    [loadingLabel sizeToFit];
    loadingLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, loadingLabel.frame.size.height);
    loadingLabel.center = CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height / 2)+160);
    
    
    [imageIndicator startAnimating];
    imageIndicator.center = CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height / 2)+120);
    
    preloaderView = [[UIView alloc] initWithFrame:self.view.bounds];
    
    
    [preloaderView addSubview:loaderImageView];
    [preloaderView addSubview: imageIndicator];
    [preloaderView addSubview:loadingLabel];
    
    [self.view addSubview:preloaderView];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self performSelector:@selector(startLoading) withObject:self afterDelay:.25];
}

-(void) changeCalendarView{
    [selectedIndexes removeAllObjects];
    [self.theTableView reloadData];
}

-(void) startLoading {
    
    basicCellHeight = 150.0f;
    theImages = [[NSMutableDictionary alloc] init];
    allDays = [[NSMutableArray alloc] init];
    
    //get regular weekly dances
    allWeeklyBannerEvents = [[NSMutableDictionary alloc] init];
    NSArray *allWeeklyEvents = [theAppDel.theBanners getWeeklyBanners];
    for (NSInteger i=0; i<[allWeeklyEvents count];i++ ){
        NSArray *daysOfEvent = [[allWeeklyEvents objectAtIndex:i] objectForKey:@"weekdays"];
        for (NSInteger j=0;j<[daysOfEvent count];j++ ) {
            NSString *dayNameWeekly = [daysOfEvent objectAtIndex:j];
            if (![allDays containsObject:dayNameWeekly] ) {
                NSMutableArray *eventsOnDay = [[NSMutableArray alloc] init];
                [eventsOnDay addObject:[allWeeklyEvents objectAtIndex:i]];
                [allWeeklyBannerEvents setObject:eventsOnDay forKey:dayNameWeekly];
                [allDays addObject:dayNameWeekly];
            } else  {
                NSMutableArray *eventsOnDay = [allWeeklyBannerEvents objectForKey:dayNameWeekly];
                [eventsOnDay addObject:[allWeeklyEvents objectAtIndex:i]];
            }
        }
    }
    NSDictionary *weekdays = @{@"Monday"   :@0,
                               @"Tuesday"  :@1,
                               @"Wednesday":@2,
                               @"Thursday" :@3,
                               @"Friday"   :@4,
                               @"Saturday" :@5,
                               @"Sunday"   :@6};
    NSArray *sortedArray = [[allDays copy] sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber *first = (NSNumber*)[weekdays objectForKey:(NSString*)a];
        NSNumber *second = (NSNumber*)[weekdays objectForKey:(NSString*)b];
        return [first compare: second];
    }];
    allDays = [sortedArray mutableCopy];
    
    //get other frequency dances
    NSArray *otherFrequentEvents = [theAppDel.theBanners getOtherFrequentBanners];
    for (NSInteger i=0;i<[otherFrequentEvents count];i++){
        NSString *day_string = [[otherFrequentEvents objectAtIndex:i] objectForKey:@"date"];
        NSArray *dayData = [day_string componentsSeparatedByString:@" | "];
        NSString *dayName = [dayData objectAtIndex:0];
        if (![allDays containsObject:dayName] ) {
            NSMutableArray *eventsOnDay = [[NSMutableArray alloc] init];
            [eventsOnDay addObject:[otherFrequentEvents objectAtIndex:i]];
            [allWeeklyBannerEvents setObject:eventsOnDay forKey:dayName];
            [allDays addObject:dayName];
        } else  {
            NSMutableArray *eventsOnDay = [allWeeklyBannerEvents objectForKey:dayName];
            [eventsOnDay addObject:[otherFrequentEvents objectAtIndex:i]];
        }
    }
    
    //get specific dates
    NSArray *specificEvents = [theAppDel.theBanners getSpecificDateBanners];
    for (NSInteger i=0;i<[specificEvents count];i++){
        NSString *date_string = [[specificEvents objectAtIndex:i] objectForKey:@"date"];
        NSArray *dateData = [date_string componentsSeparatedByString:@" | "];
        NSString *beginDate = [dateData objectAtIndex:0];
        NSString *endDate = [dateData objectAtIndex:1];
        if ([beginDate rangeOfString:@"specific:"].location != NSNotFound) {
            beginDate = [beginDate stringByReplacingOccurrencesOfString:@"specific:"
                                                 withString:@""];
        } else {
            beginDate = nil;
        }
        if ([endDate rangeOfString:@"specific:"].location != NSNotFound) {
            endDate = [endDate stringByReplacingOccurrencesOfString:@"specific:"
                                                             withString:@""];
        } else {
            endDate = nil;
        }
        
        
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MM/dd/yyyy"];
        NSDate *begin;
        NSDate *end;
        if (beginDate) {
            begin = [dateFormat dateFromString:beginDate];
        }
        if (endDate) {
            end = [dateFormat dateFromString:endDate];
        }
        NSLog(@"%@ - %@",begin,end);
        
        
        NSDate *currDate = begin;
        [dateFormat setDateFormat:@"MM/dd/yyyy"];
        _specificDateEvents = [[NSMutableDictionary alloc] init];
        if ( ![_specificDateEvents objectForKey:currDate] ) {
            NSMutableArray *eventsOnDay = [[NSMutableArray alloc] init];
            [eventsOnDay addObject:[specificEvents objectAtIndex:i]];
            
            NSString *thisDate = [dateFormat stringFromDate:currDate];
            [_specificDateEvents setObject:eventsOnDay forKey:thisDate];
        } else {
            NSMutableArray *eventsOnDay = [_specificDateEvents objectForKey:currDate];
            [eventsOnDay addObject:[specificEvents objectAtIndex:i]];
            
            NSString *thisDate = [dateFormat stringFromDate:currDate];
            [_specificDateEvents setObject:eventsOnDay forKey:thisDate];
        }
        while([currDate timeIntervalSince1970] < [end timeIntervalSince1970]) {
            NSDateComponents *components = [cal components:( NSDayCalendarUnit ) fromDate:currDate];
            [components setDay:1];
            currDate = [cal dateByAddingComponents:components toDate:currDate options:0];
            if ( ![_specificDateEvents objectForKey:currDate] ) {
                NSMutableArray *eventsOnDay = [[NSMutableArray alloc] init];
                [eventsOnDay addObject:[specificEvents objectAtIndex:i]];
                
                NSString *thisDate = [dateFormat stringFromDate:currDate];
                [_specificDateEvents setObject:eventsOnDay forKey:thisDate];
            } else {
                NSMutableArray *eventsOnDay = [_specificDateEvents objectForKey:currDate];
                [eventsOnDay addObject:[specificEvents objectAtIndex:i]];
                
                NSString *thisDate = [dateFormat stringFromDate:currDate];
                [_specificDateEvents setObject:eventsOnDay forKey:thisDate];
            }
        }
    }
    
    
    [self.theTableView reloadData];
    self.navigationController.navigationBarHidden = NO;
    [preloaderView removeFromSuperview];
    
    selectedIndexes = [[NSMutableDictionary alloc] init];
    loadingLabel.text = @"Refreshing Table";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([[calendar_switch titleForSegmentAtIndex:calendar_switch.selectedSegmentIndex] isEqualToString:@"Weekly Dances"]) {
        return [allDays count];
    } else if ([[calendar_switch titleForSegmentAtIndex:calendar_switch.selectedSegmentIndex] isEqualToString:@"Month Calendar"]) {
        NSInteger eventsOnDay = 1;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"EEEE"];
        NSString *thisDay = [formatter stringFromDate:self.currentDate];
        

        
        [formatter setDateFormat:@"MM/dd/yyyy"];
        NSString *thisDate = [formatter stringFromDate:self.currentDate];
        if ([self.specificDateEvents objectForKey:thisDate]) {
            eventsOnDay += [[self.specificDateEvents objectForKey:thisDate] count];
        }
        
        for (NSInteger i=0; i<[[allWeeklyBannerEvents objectForKey:thisDay] count];i++) {
            NSDictionary *thisEvent = [[allWeeklyBannerEvents objectForKey:thisDay] objectAtIndex:i];
            if ([[thisEvent objectForKey:@"is_other_frequent"] isEqualToString:@"yes"]) {
                NSString *date_string = [thisEvent objectForKey:@"date"];
                NSArray *dateData = [date_string componentsSeparatedByString:@" | "];
                NSArray *frequency = [dateData[1] componentsSeparatedByString:@","];
                
                [formatter setDateFormat:@"F"];
                NSString *numOfDayInMonth = [formatter stringFromDate:self.currentDate];
                if ( [frequency containsObject:numOfDayInMonth]) {
                    eventsOnDay += 1;
                }
            } else {
                eventsOnDay += 1;
            }
        }
        return eventsOnDay;
    }
    return 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[calendar_switch titleForSegmentAtIndex:calendar_switch.selectedSegmentIndex] isEqualToString:@"Weekly Dances"]) {
        if ([allDays count] > section ) {
            return [[allWeeklyBannerEvents objectForKey:[allDays objectAtIndex:section]] count];
        }
    } else if ([[calendar_switch titleForSegmentAtIndex:calendar_switch.selectedSegmentIndex] isEqualToString:@"Month Calendar"]) {
        return 1;
    }
    return 0;
}

- (BOOL)cellIsSelected:(NSString *) comboString {
    if ([[selectedIndexes objectForKey:comboString] isEqualToString:@"1"]) {
        return YES;
    } else{
        return NO;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[calendar_switch titleForSegmentAtIndex:calendar_switch.selectedSegmentIndex] isEqualToString:@"Weekly Dances"]) {
        if([self cellIsSelected:[NSString stringWithFormat:@"%d-%d",indexPath.section,indexPath.row]]) {
            return basicCellHeight * 2.0;
        }
    } else if ([[calendar_switch titleForSegmentAtIndex:calendar_switch.selectedSegmentIndex] isEqualToString:@"Month Calendar"]) {
        if (indexPath.section == 0 && indexPath.row == 0 ) {
            return 120.0f;
        }
        if([self cellIsSelected:[NSString stringWithFormat:@"%d-%d",indexPath.section,indexPath.row]]) {
            return basicCellHeight / 2.0;
        } else {
            return basicCellHeight * 2.0;
        }
    }
    return basicCellHeight;
}

-(CGFloat)tableView: (UITableView*) tableView heightForHeaderInSection:(NSInteger)section {
    if ([[calendar_switch titleForSegmentAtIndex:calendar_switch.selectedSegmentIndex] isEqualToString:@"Month Calendar"]) {
        if (section == 0) {
            return 0;
        } else if (section == 1) {
            return 20.0f;
        }
        return 10.0f;
    }
    return 50.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([[calendar_switch titleForSegmentAtIndex:calendar_switch.selectedSegmentIndex] isEqualToString:@"Weekly Dances"]) {
        return [allDays objectAtIndex:section];
    }
    return @"";
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([[calendar_switch titleForSegmentAtIndex:calendar_switch.selectedSegmentIndex] isEqualToString:@"Weekly Dances"]) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
        headerView.backgroundColor = [UIColor clearColor];
        UILabel *tempLabel=[[UILabel alloc]initWithFrame:CGRectMake(15,0,300,44)];
        tempLabel.backgroundColor=[UIColor clearColor];
        tempLabel.shadowOffset = CGSizeMake(0,2);
        tempLabel.textColor = [UIColor whiteColor];
        tempLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:19];
        tempLabel.text=[self tableView:tableView titleForHeaderInSection:section];
        
        [headerView addSubview:tempLabel];
        return headerView;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *thisAddress = [NSString stringWithFormat:@"%d-%d",indexPath.section,indexPath.row];
    if ([self cellIsSelected:thisAddress]) {
        [selectedIndexes setObject:@"0" forKey:thisAddress];
    } else {
        [selectedIndexes setObject:@"1" forKey:thisAddress];
    }
    [self.theTableView deselectRowAtIndexPath:indexPath animated:TRUE];
    
    [self performSelector:@selector(refreshTableCells) withObject:self afterDelay:0.1];
}

-(void) refreshTableCells {
    [self.theTableView beginUpdates];
    [self.theTableView endUpdates];
}

- (UITableViewCell *)prepareCell: (NSDictionary*) thisEvent theCell: (UITableViewCell*) cell {
    //image from banner
    UIImageView *bannerImageView =[[UIImageView alloc] initWithFrame:CGRectMake(-29.0f, 0.0f, 349.0f, 80.0f)];
    if (![theImages valueForKey:[thisEvent objectForKey:@"image_url"]]) {
        NSData *dataFromURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:[thisEvent objectForKey:@"image_url"]]];
        UIImage *theImage = [UIImage imageWithData: dataFromURL];
        bannerImageView.image = theImage;
        [theImages setValue:theImage forKey:[thisEvent objectForKey:@"image_url"]];
    } else {
        bannerImageView.image = [theImages valueForKey:[thisEvent objectForKey:@"image_url"]];
    }
    
    //highlightView objects
    CalendarCellView *highlightView = [[CalendarCellView alloc] initWithFrame:CGRectMake(5.0f, 80.0f, cell.frame.size.width, 70.0f)];
    highlightView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.9f];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(7.0f, 18.0f, 153.0f, 22.0f)];
    title.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:18.0];
    title.textAlignment = NSTextAlignmentLeft;
    title.textColor = [UIColor blackColor];
    title.text = [thisEvent objectForKey:@"post_title"];
    [title sizeToFit];
    
    UILabel *hood = [[UILabel alloc] initWithFrame:CGRectMake(7.0f, 4.0f, 153.0f, 22.0f)];
    hood.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:13.0];
    hood.textAlignment = NSTextAlignmentLeft;
    hood.textColor = [UIColor colorWithRed:235.0/255.0 green:119.0/255.0 blue:24.0/255.0 alpha:1.0];
    hood.shadowColor = [UIColor lightGrayColor];
    hood.shadowOffset = CGSizeMake(0.0f, 0.0f);
    hood.text = @"need_to_update";
    [hood sizeToFit];
    
    UILabel *cats = [[UILabel alloc] initWithFrame:CGRectMake(7.0f, 39.0f, 153.0f, 22.0f)];
    cats.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
    cats.textAlignment = NSTextAlignmentLeft;
    cats.textColor = [UIColor blackColor];
    cats.text = @"need_to_update";
    [cats sizeToFit];
    
    //add labels to highlightView
    [highlightView addSubview:title];
    [highlightView addSubview:hood];
    [highlightView addSubview:cats];
    
    //more Detail Objects
    UILabel *sub_title = [[UILabel alloc] initWithFrame:CGRectMake(6.0f, 81.0f, 309.0f, 22.0f)];
    sub_title.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:16.0];
    sub_title.textAlignment = NSTextAlignmentLeft;
    sub_title.textColor = [UIColor blackColor];
    [sub_title sizeToFit];
    
    //add all the views
    [cell.contentView addSubview:bannerImageView];
    [cell.contentView addSubview:highlightView];
    [cell.contentView addSubview:sub_title];
    
    return cell;
}

-(void) removePreviousCellInfoFromView: (UITableViewCell*) cell {
    for(UIView *view in cell.contentView.subviews){
        if ([view isKindOfClass:[UIView class]]) {
            [view removeFromSuperview];
        }
    }
}


- (void)updateMainTable:(NSDate*) theDate withIndex: (NSInteger)index {
    
    //convert date to string without hours
    _currentDate = theDate;
    [selectedIndexes removeAllObjects];
    [self.theTableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if ([[calendar_switch titleForSegmentAtIndex:calendar_switch.selectedSegmentIndex] isEqualToString:@"Weekly Dances"]) {
        cell  = [tableView dequeueReusableCellWithIdentifier:@"eventCell" forIndexPath:indexPath];
        [self removePreviousCellInfoFromView:cell];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.layer.cornerRadius = 5;
        cell.layer.masksToBounds = YES;
        cell.backgroundColor = [UIColor whiteColor];
        //data for banner
        NSArray *eventsOnDay = [allWeeklyBannerEvents objectForKey:[allDays objectAtIndex:indexPath.section]];
        NSDictionary *thisEvent = [eventsOnDay objectAtIndex:indexPath.row];
        cell = [self prepareCell:thisEvent theCell:cell];
    } else if ([[calendar_switch titleForSegmentAtIndex:calendar_switch.selectedSegmentIndex] isEqualToString:@"Month Calendar"]) {
        if (indexPath.section ==0 && indexPath.row == 0 ) {
            if ( !self.horizontalDateCell) {
                CalendarHorizontalCell *cell  = [[CalendarHorizontalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HorizontalCalendarContainer"];
                cell.delegate = self;
                self.horizontalDateCell = cell;
                return cell;
            } else {
                return self.horizontalDateCell;
            }
        } else {
            cell  = [tableView dequeueReusableCellWithIdentifier:@"eventCell" forIndexPath:indexPath];
            [self removePreviousCellInfoFromView:cell];
            cell.layer.cornerRadius = 5;
            cell.layer.masksToBounds = YES;
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //data for banner
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"EEEE"];
            NSString *thisDay = [formatter stringFromDate:self.currentDate];
            
            NSArray *eventsOnDay;
            
            [formatter setDateFormat:@"MM/dd/yyyy"];
            NSString *thisDate = [formatter stringFromDate:self.currentDate];
            if ([self.specificDateEvents objectForKey:thisDate]) {
                eventsOnDay = [[self.specificDateEvents objectForKey:thisDate]
                               arrayByAddingObjectsFromArray:[allWeeklyBannerEvents objectForKey:thisDay]];
            } else {
                eventsOnDay = [allWeeklyBannerEvents objectForKey:thisDay];
            }
            NSDictionary *thisEvent = [eventsOnDay objectAtIndex:(indexPath.section-1)];
            cell = [self prepareCell:thisEvent theCell:cell];
        }
    }
    return cell;
}

@end

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

