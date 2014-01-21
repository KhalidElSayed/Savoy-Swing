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

@interface CalendarTableViewController() <UITableViewDelegate, UITableViewDataSource, HorizontalCellDelegate> {
    SSCAppDelegate *theAppDel;
    
    //IBOutlet UITableView *the_tableView;
	NSMutableDictionary *selectedIndexes;
    NSInteger basicCellHeight;
    
    NSMutableDictionary *allWeeklyBannerEvents;
    NSMutableArray *allDays;
    
    //calendar switch
    UISegmentedControl *calendar_switch;
}

//preloading image
@property (strong, nonatomic) IBOutlet UITableView *theTableView;

//calendar date cell
@property (nonatomic, retain) CalendarHorizontalCell *horizontalDateCell;

//monthly calendar data
@property (strong,nonatomic) NSMutableArray *currentDateCells;
@property (strong,nonatomic) NSDate *currentDate;
@property (strong,nonatomic) NSMutableDictionary *specificDateEvents;

//load indicator
@property (strong, nonatomic) NSMutableDictionary *cellIndicators;

-(void) startLoading;

@end

@implementation CalendarTableViewController

-(void) viewDidLoad {
    
    theAppDel = (SSCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;
    
    NSArray *calendar_types =@[@"Month Calendar",@"Weekly Dances"];
    calendar_switch = [[UISegmentedControl alloc] initWithItems:calendar_types];
    calendar_switch.frame = CGRectMake(0, 0, 100, 30);
    calendar_switch.selectedSegmentIndex = 0;
    calendar_switch.tintColor = [UIColor whiteColor];
    [calendar_switch addTarget:self action:@selector(changeCalendarView) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = calendar_switch;
    
    _currentDate = [[NSDate alloc] init];

}

-(void) viewWillAppear:(BOOL)animated {
    
    //put graphic image for loading graphic
    self.navigationController.navigationBarHidden = YES;
    theAppDel.theLoadingScreen = [[loadingScreenImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:theAppDel.theLoadingScreen];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self performSelector:@selector(startLoading) withObject:self afterDelay:.25];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) changeCalendarView{
    [selectedIndexes removeAllObjects];
    [self.theTableView reloadData];
}

-(void) addWeeklyDances {
    allWeeklyBannerEvents = [[NSMutableDictionary alloc] init];
    NSArray *allWeeklyEvents = [theAppDel.theBanners getWeeklyBanners];
    for (NSInteger i=0; i<[allWeeklyEvents count];i++ ){
        NSArray *daysOfEvent = [[allWeeklyEvents objectAtIndex:i] objectForKey:@"weekdays"];
        for (NSInteger j=0;j<[daysOfEvent count];j++ ) {
            NSString *dayNameWeekly = [daysOfEvent objectAtIndex:j];
            if ([dayNameWeekly rangeOfString:@" : "].location != NSNotFound) {
                NSArray *dayHour =[dayNameWeekly componentsSeparatedByString:@" : "];
                dayNameWeekly = dayHour[0];
            }
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
}

-(void) startLoading {
    basicCellHeight = 125.0f;
    allDays = [[NSMutableArray alloc] init];
    selectedIndexes = [[NSMutableDictionary alloc] init];
    
    if ([theAppDel.theBanners.allEventImages count] == 0) {
        //load Images
        [theAppDel.theBanners loadImagesToMemory];
    }
    
    //get regular weekly dances
    [self addWeeklyDances];
    
    //get other frequency dances
    NSArray *otherFrequentEvents = [theAppDel.theBanners getOtherFrequentBanners];
    for (NSInteger i=0;i<[otherFrequentEvents count];i++){
        NSString *day_string = [[otherFrequentEvents objectAtIndex:i] objectForKey:@"date"];
        NSArray *dayData = [day_string componentsSeparatedByString:@" | "];
        NSString *dayName = [dayData objectAtIndex:0];
        if ([dayName rangeOfString:@" : "].location != NSNotFound) {
            NSArray *dayHour =[dayName componentsSeparatedByString:@" : "];
            dayName = dayHour[0];
        }
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
    _specificDateEvents = [[NSMutableDictionary alloc] init];
    NSArray *specificEvents = [theAppDel.theBanners getSpecificDateBanners];
    for (NSInteger i=0;i<[specificEvents count];i++){
        NSString *date_string = [[specificEvents objectAtIndex:i] objectForKey:@"date"];
        NSArray *dateData = [date_string componentsSeparatedByString:@" | "];
        NSString *beginDate = [dateData objectAtIndex:0];
        NSString *endDate = [dateData objectAtIndex:1];
        if ([beginDate rangeOfString:@"specific:"].location != NSNotFound) {
            beginDate = [beginDate stringByReplacingOccurrencesOfString:@"specific:"
                                                 withString:@""];
        }
        if ([endDate rangeOfString:@"specific:"].location != NSNotFound) {
            endDate = [endDate stringByReplacingOccurrencesOfString:@"specific:"
                                                             withString:@""];
        }
        
        
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MM/dd/yyyy"];
        NSDate *begin;
        NSDate *end;
        if (beginDate) {
            begin = [dateFormat dateFromString:beginDate];
        } else {
            begin = [[NSDate alloc] init];
        }
        if (endDate) {
            end = [dateFormat dateFromString:endDate];
        } else {
            end = begin;
        }
        
        NSDate *currDate = begin;
        [dateFormat setDateFormat:@"MM/dd/yyyy"];
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
    [theAppDel.theLoadingScreen changeLabelText:@"Refreshing Table"];
    [theAppDel.theLoadingScreen.imageIndicator stopAnimating];
    [theAppDel.theLoadingScreen removeFromSuperview];
    
}

- (BOOL)cellIsSelected:(NSString *) comboString {
    if ([[selectedIndexes objectForKey:comboString] isEqualToString:@"1"]) {
        return YES;
    } else{
        return NO;
    }
}

-(CGFloat) heightOfEvent: (NSDictionary*) thisEvent {
    float ongoingHeight = 0.0;
    
    ongoingHeight += 4.0f;
    UILabel *hood = [[UILabel alloc] initWithFrame:CGRectMake(7.0f, ongoingHeight, self.theTableView.frame.size.width-14, 22.0f)];
    hood.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0];
    hood.textAlignment = NSTextAlignmentLeft;
    hood.textColor = [UIColor colorWithRed:235.0/255.0 green:119.0/255.0 blue:24.0/255.0 alpha:1.0];
    hood.numberOfLines = 0;
    hood.shadowColor = [UIColor lightGrayColor];
    hood.shadowOffset = CGSizeMake(0.0f, 0.0f);
    hood.text = [thisEvent objectForKey:@"date"];
    [hood sizeToFit];
    ongoingHeight += hood.frame.size.height;
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(7.0f, ongoingHeight, self.theTableView.frame.size.width-14, 50.0f)];
    title.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:18.0];
    title.textAlignment = NSTextAlignmentLeft;
    title.textColor = [UIColor blackColor];
    title.numberOfLines = 2;
    [title sizeToFit];
    ongoingHeight += title.frame.size.height;
    
    UILabel *cats = [[UILabel alloc] initWithFrame:CGRectMake(7.0f, ongoingHeight, self.theTableView.frame.size.width, 22.0f)];
    cats.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:12.0];
    cats.textAlignment = NSTextAlignmentLeft;
    cats.textColor = [UIColor blackColor];
    cats.numberOfLines = 0;
    cats.text = [thisEvent objectForKey:@"post_sub"];
    [cats sizeToFit];
    ongoingHeight += cats.frame.size.height;
    
    
    ongoingHeight += 14;
    UILabel *main_text = [[UILabel alloc] initWithFrame:CGRectMake(7.0f, ongoingHeight, self.theTableView.frame.size.width-14.0f, 22.0f)];
    main_text.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
    main_text.textAlignment = NSTextAlignmentLeft;
    main_text.textColor = [UIColor blackColor];
    main_text.numberOfLines = 0;
    main_text.text = [thisEvent objectForKey:@"post_text"];
    [main_text sizeToFit];
    ongoingHeight += main_text.frame.size.height;
    
    return 150+ongoingHeight;
}


-(void) refreshTableCells {
    [self.theTableView beginUpdates];
    [self.theTableView endUpdates];
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



-(void) getInfoForCell: (NSArray*) data {
    
    [[data objectAtIndex:0] prepareCell:[data objectAtIndex:1] onDate:self.currentDate];
    UIActivityIndicatorView *thisIndicator = [_cellIndicators objectForKey:[NSString stringWithFormat:@"%@",[data objectAtIndex:1]]];
    [thisIndicator removeFromSuperview];
    [_cellIndicators removeObjectForKey:[data objectAtIndex:1]];
}


#pragma mark UITableViewDataSource
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
        return eventsOnDay+1;
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


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([[calendar_switch titleForSegmentAtIndex:calendar_switch.selectedSegmentIndex] isEqualToString:@"Weekly Dances"]) {
        return [NSString stringWithFormat:@"%@s",[allDays objectAtIndex:section]];
    }
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CalendarTableViewCell *cell;
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
        
        float height = cell.frame.size.width/283.5f*60.0f;
        UIImageView *bannerImageView =[[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, cell.frame.size.width, height)];
        bannerImageView.image = [theAppDel.theBanners.allEventImages objectForKey:[thisEvent objectForKey:@"post_id"]];
        [cell.contentView addSubview:bannerImageView];
        
        [cell prepareCell:thisEvent onDate:[allDays objectAtIndex:indexPath.section]];
    } else if ([[calendar_switch titleForSegmentAtIndex:calendar_switch.selectedSegmentIndex] isEqualToString:@"Month Calendar"]) {
        if (indexPath.section ==0 && indexPath.row == 0 ) {
            _cellIndicators = [[NSMutableDictionary alloc] init];
            if ( !self.horizontalDateCell) {
                CalendarHorizontalCell *cell  = [[CalendarHorizontalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HorizontalCalendarContainer"];
                cell.delegate = self;
                self.horizontalDateCell = cell;
                return cell;
            } else {
                return self.horizontalDateCell;
            }
        } else {            //data for banner
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
            if ( [self numberOfSectionsInTableView:self.theTableView] == indexPath.section+1 ) {
                UITableViewCell *infoCell = [tableView dequeueReusableCellWithIdentifier:@"TapBannerMoreInfo" forIndexPath:indexPath];
                infoCell.backgroundColor = [UIColor colorWithWhite:1 alpha:.05];
                infoCell.selectionStyle = UITableViewCellSelectionStyleNone;
                if (![infoCell viewWithTag:1002]) {
                    UILabel *info = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 00.0f, infoCell.frame.size.width, 22)];
                    info.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:18.0];
                    info.textAlignment = NSTextAlignmentCenter;
                    info.textColor = [UIColor whiteColor];
                    info.text = @"Tap Banner For More Info";
                    info.tag = 1002;
                    [infoCell addSubview:info];
                    info.center = CGPointMake(infoCell.frame.size.width/2, (62.5)/2);
                }
                return infoCell;
            } else {
                cell  = [tableView dequeueReusableCellWithIdentifier:@"eventCell" forIndexPath:indexPath];
                [self removePreviousCellInfoFromView:cell];
                cell.layer.cornerRadius = 5;
                cell.layer.masksToBounds = YES;
                cell.backgroundColor = [UIColor whiteColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                NSDictionary *thisEvent = [eventsOnDay objectAtIndex:(indexPath.section-1)];
                
                float height = cell.frame.size.width/283.5f*60.0f;
                UIImageView *bannerImageView =[[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, cell.frame.size.width, height)];
                bannerImageView.image = [theAppDel.theBanners.allEventImages objectForKey:[thisEvent objectForKey:@"post_id"]];
                [cell.contentView addSubview:bannerImageView];
                UIActivityIndicatorView *thisCellIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                thisCellIndicator.color = [UIColor colorWithRed:235.0/255.0 green:119.0/255.0 blue:24.0/255.0 alpha:1.0];
                thisCellIndicator.center = CGPointMake(cell.frame.size.width / 2, (height/ 2));
                [thisCellIndicator startAnimating];
                [cell addSubview:thisCellIndicator];
                [_cellIndicators setObject:thisCellIndicator forKey:[NSString stringWithFormat:@"%@",thisEvent]];
                [self performSelector:@selector(getInfoForCell:) withObject:@[cell,thisEvent] afterDelay:.1];
            }
        }
    }
    return cell;
}

#pragma mark UITableViewDataDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *thisEvent;
    if ([[calendar_switch titleForSegmentAtIndex:calendar_switch.selectedSegmentIndex] isEqualToString:@"Weekly Dances"]) {
        if([self cellIsSelected:[NSString stringWithFormat:@"%d-%d",indexPath.section,indexPath.row]]) {
            NSArray *eventsOnDay = [allWeeklyBannerEvents objectForKey:[allDays objectAtIndex:indexPath.section]];
            thisEvent = [eventsOnDay objectAtIndex:indexPath.row];
            return [self heightOfEvent:thisEvent];
        }
    } else if ([[calendar_switch titleForSegmentAtIndex:calendar_switch.selectedSegmentIndex] isEqualToString:@"Month Calendar"]) {
        if (indexPath.section == 0 && indexPath.row == 0 ) {
            return 120.0f;
        } else if(![self cellIsSelected:[NSString stringWithFormat:@"%d-%d",indexPath.section,indexPath.row]]) {
            return basicCellHeight / 2.0;
        }
        
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
        if ([self numberOfSectionsInTableView:self.theTableView] == indexPath.section+1) {
            return basicCellHeight / 2.0;
        }
        thisEvent = [eventsOnDay objectAtIndex:(indexPath.section-1)];
        return [self heightOfEvent:thisEvent];
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
    if ([self cellIsSelected:thisAddress] ) {
        [selectedIndexes setObject:@"0" forKey:thisAddress];
    } else {
        [selectedIndexes setObject:@"1" forKey:thisAddress];
    }
    [self.theTableView deselectRowAtIndexPath:indexPath animated:TRUE];
    
    [self performSelector:@selector(refreshTableCells) withObject:self afterDelay:0.1];
}

@end

#pragma mark CalendarCell of UITableViewCell
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CalendarCellView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setBackgroundColor:(UIColor *)backgroundColor {
    CGFloat alpha = CGColorGetAlpha(backgroundColor.CGColor);
    if (alpha != 0) {
        [super setBackgroundColor:backgroundColor];
    }
}

@end

