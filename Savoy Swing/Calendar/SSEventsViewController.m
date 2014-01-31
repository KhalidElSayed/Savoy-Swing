//
//  EventsViewController.m
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/30/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "SSEventsViewController.h"
#import "CalendarTableViewCell.h"

@interface SSEventsViewController () <UITableViewDelegate, UITableViewDataSource> {
    SSCAppDelegate *theAppDel;
    
}

@property (strong, nonatomic) IBOutlet UITableView *theTableView;
@property (strong)  NSTimer *loadingScreenText;
@property (strong, nonatomic) NSArray *allEvents;

-(void) startLoading;

@end

@implementation SSEventsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    theAppDel = (SSCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;
    

}

-(void) viewWillAppear:(BOOL)animated {
    //put graphic image for loading graphic
    self.navigationController.navigationBarHidden = YES;
    theAppDel.theLoadingScreen = [[loadingScreenImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:theAppDel.theLoadingScreen];
}

-(void) viewDidAppear:(BOOL)animated {
    
    [self performSelector:@selector(startLoading) withObject:self afterDelay:0.5];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) startLoading {
    if ([theAppDel.theBanners.allEventImages count] == 0) {
        //load Images
        [theAppDel.theBanners loadImagesToMemory];
    }
    _allEvents = [theAppDel.theBanners getSpecificDateBanners];
    [self.theTableView reloadData];
    [theAppDel.theLoadingScreen changeLabelText:@"Configuring View"];
    self.navigationController.navigationBarHidden = NO;
    [theAppDel.theLoadingScreen.imageIndicator stopAnimating];
    [theAppDel.theLoadingScreen removeFromSuperview];
}

-(void) removePreviousCellInfoFromView: (UITableViewCell*) cell {
    for(UIView *view in cell.contentView.subviews){
        if ([view isKindOfClass:[UIView class]]) {
            [view removeFromSuperview];
        }
    }
}

#pragma mark UITableViewDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    NSDictionary *thisEvent = [_allEvents objectAtIndex:indexPath.section];
    UILabel *main_text = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 60.0f, 280.0f, 22.0f)];
    main_text.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
    main_text.textAlignment = NSTextAlignmentLeft;
    main_text.textColor = [UIColor blackColor];
    main_text.numberOfLines = 0;
    main_text.text = [thisEvent objectForKey:@"post_text"];
    [main_text sizeToFit];
    return 160+main_text.frame.size.height;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return [_allEvents count];
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CalendarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventCell" forIndexPath:indexPath];
    [self removePreviousCellInfoFromView:cell];
    NSDictionary *thisEvent = [_allEvents objectAtIndex:indexPath.section];
    
    float height = cell.frame.size.width/283.5f*60.0f;
    UIImageView *bannerImageView =[[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, cell.frame.size.width, height)];
    bannerImageView.image = [theAppDel.theBanners.allEventImages objectForKey:[thisEvent objectForKey:@"post_id"]];
    [cell.contentView addSubview:bannerImageView];
    
    [cell prepareCell:thisEvent onDate:nil];
    cell.layer.cornerRadius = 5;
    cell.layer.masksToBounds = YES;
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}


@end
