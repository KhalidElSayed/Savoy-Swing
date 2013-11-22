//
//  CalendarTableViewController.m
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/18/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "CalendarTableViewController.h"
#import "CalendarCellView.h"
#import  "BannerEvent.h"

@implementation CalendarTableViewController

@synthesize mondays;
@synthesize tuesdays;
@synthesize basicCellHeight;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    theCells = [[NSMutableDictionary alloc] init];
    days = [[NSMutableArray alloc] init];
    banner_events_weekly = [[NSMutableDictionary alloc] init];
    self.basicCellHeight = 74;
    
    for (int i=0; i<11;i++ ){
        BannerEvent *thisEvent = [[BannerEvent alloc] initWithID:i];
        NSMutableArray *eventsOnDay;
        if ( [days containsObject:thisEvent.day] ) {
            eventsOnDay = [[NSMutableArray alloc] initWithArray:[banner_events_weekly objectForKey:thisEvent.day]];
            [eventsOnDay addObject:thisEvent];
            [banner_events_weekly setObject:eventsOnDay forKey:thisEvent.day];
        } else {
            [days addObject:thisEvent.day];
            eventsOnDay = [[NSMutableArray alloc] initWithObjects:thisEvent, nil];
            [banner_events_weekly setObject:eventsOnDay forKey:thisEvent.day];
        }
    }
    
    [self.tableView reloadData];
    for (int i=0; i<[self numberOfSectionsInTableView:self.tableView]; i++){
        for (int j=0; j<[self.tableView numberOfRowsInSection:i]; j++ ) {
            NSIndexPath *thisPath = [NSIndexPath indexPathForRow:j inSection:i];
            UITableViewCell *theCell = [self tableView:self.tableView cellForRowAtIndexPath:thisPath];
            [theCells setObject:theCell forKey:thisPath];
            NSLog(@"New Cell Created!");
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    self.tableView.separatorColor = [UIColor colorWithWhite:0.15f alpha:0.4f];
    
    selectedIndexes = [[NSMutableDictionary alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 7;
}

- (BOOL)cellIsSelected:(NSIndexPath *)indexPath {
	// Return whether the cell at the specified index path is selected or not
	NSNumber *selectedIndex = [selectedIndexes objectForKey:indexPath];
	return selectedIndex == nil ? FALSE : [selectedIndex boolValue];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // If our cell is selected, return double height
    if([self cellIsSelected:indexPath]) {
        return self.basicCellHeight * 2.0;
        //move extra view down
    }
    //move extra view back up
    // Cell isn't selected so return single height
    return self.basicCellHeight;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([[banner_events_weekly objectForKey:[days objectAtIndex:section]] isKindOfClass:[NSMutableArray class]] ) {
        return [[banner_events_weekly objectForKey:[days objectAtIndex:section] ] count];
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [days objectAtIndex:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	// Deselect cell
	[tableView deselectRowAtIndexPath:indexPath animated:TRUE];
	
	// Toggle 'selected' state
	BOOL isSelected = ![self cellIsSelected:indexPath];
	
	// Store cell 'selected' state keyed on indexPath
	NSNumber *selectedIndex = [NSNumber numberWithBool:isSelected];
	[selectedIndexes setObject:selectedIndex forKey:indexPath];
    
	// This is where magic happens...
	[demoTableView beginUpdates];
	[demoTableView endUpdates];
}

- (UITableViewCell *)prepareCell: (BannerEvent*) thisBanner theCell: (UITableViewCell*) cell {
    //image from banner
    UIImageView *bannerImageView =[[UIImageView alloc] initWithFrame:CGRectMake(-29.0f, 0.0f, 349.0f, 80.0f)];
    NSData *dataFromURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:thisBanner.image]];
    UIImage *theImage = [UIImage imageWithData: dataFromURL];
    bannerImageView.image = theImage;
    
    //highlightView objects
    CalendarCellView *highlightView = [[CalendarCellView alloc] initWithFrame:CGRectMake(161.0f, 11.0f, 160.0f, 64.0f)];
    highlightView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.9f];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(7.0f, 18.0f, 153.0f, 22.0f)];
    title.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:18.0];
    title.textAlignment = NSTextAlignmentLeft;
    title.textColor = [UIColor blackColor];
    title.text = thisBanner.title;
    [title sizeToFit];
    
    UILabel *hood = [[UILabel alloc] initWithFrame:CGRectMake(7.0f, 4.0f, 153.0f, 22.0f)];
    hood.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:13.0];
    hood.textAlignment = NSTextAlignmentLeft;
    hood.textColor = [UIColor colorWithRed:235.0/255.0 green:119.0/255.0 blue:24.0/255.0 alpha:1.0];
    hood.shadowColor = [UIColor lightGrayColor];
    hood.shadowOffset = CGSizeMake(0.0f, 0.0f);
    hood.text = thisBanner.neighborhood;
    [hood sizeToFit];
    
    UILabel *cats = [[UILabel alloc] initWithFrame:CGRectMake(7.0f, 39.0f, 153.0f, 22.0f)];
    cats.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
    cats.textAlignment = NSTextAlignmentLeft;
    cats.textColor = [UIColor blackColor];
    cats.text = thisBanner.categories;
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
    sub_title.text = thisBanner.sub_title;
    [sub_title sizeToFit];
    
    
    //add all the views
    [cell.contentView addSubview:bannerImageView];
    [cell.contentView addSubview:highlightView];
    [cell.contentView addSubview:sub_title];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    if (![theCells objectForKey:indexPath]) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"bannerCell" forIndexPath:indexPath];
        //cell.backgroundColor = [UIColor blackColor];
        
        //data for banner
        BannerEvent *thisBanner = [[banner_events_weekly objectForKey:[days objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        
        //draw cell
        cell = [self prepareCell:thisBanner theCell:cell];
    } else {
        cell = [theCells objectForKey:indexPath];
    }
    
    
    return cell;
}

@end
