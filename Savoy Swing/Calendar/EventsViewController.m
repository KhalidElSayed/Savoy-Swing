//
//  EventsViewController.m
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/30/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "EventsViewController.h"
#import "CalendarTableViewCell.h"

@interface EventsViewController ()

@end

@implementation EventsViewController

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
    loaderImageView =[[UIImageView alloc] initWithFrame:CGRectMake(0.0f, (self.view.bounds.size.height-568.0f)/2, self.view.frame.size.width, 568.0f)];
    
    UIImage *theImage = [UIImage imageNamed:@"R4Default.png"];
    loaderImageView.image = theImage;
    imageIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    loadingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    loadingLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:22.0];
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.textColor = [UIColor whiteColor];
    loadingLabel.text = @"Getting Special Events";
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

-(void) viewDidAppear:(BOOL)animated {
    [self performSelector:@selector(startLoading) withObject:self afterDelay:.25];
}


-(void) startLoading {
    theImages = [[NSMutableDictionary alloc] init];
    _allEvents = [theAppDel.theBanners getSpecificDateBanners];
    [self.theTableView reloadData];
    loadingLabel.text = @"Configuring View";
    self.navigationController.navigationBarHidden = NO;
    [preloaderView removeFromSuperview];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void) removePreviousCellInfoFromView: (UITableViewCell*) cell {
    for(UIView *view in cell.contentView.subviews){
        if ([view isKindOfClass:[UIView class]]) {
            [view removeFromSuperview];
        }
    }
}



-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    NSDictionary *thisEvent = [_allEvents objectAtIndex:indexPath.section];
    UILabel *main_text = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 60.0f, 280.0f, 22.0f)];
    main_text.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
    main_text.textAlignment = NSTextAlignmentLeft;
    main_text.textColor = [UIColor blackColor];
    main_text.numberOfLines = 0;
    main_text.text = [thisEvent objectForKey:@"post_text"];
    [main_text sizeToFit];
    return 150+main_text.frame.size.height;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return [_allEvents count];
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CalendarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventCell" forIndexPath:indexPath];
    NSDictionary *thisEvent = [_allEvents objectAtIndex:indexPath.section];
    
    float height = cell.frame.size.width/283.5f*60.0f;
    UIImageView *bannerImageView =[[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, cell.frame.size.width, height)];
    if (![theImages valueForKey:[thisEvent objectForKey:@"image_url"]]) {
        NSData *dataFromURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:[thisEvent objectForKey:@"image_url"]]];
        UIImage *theImage = [UIImage imageWithData: dataFromURL];
        bannerImageView.image = theImage;
        [theImages setValue:theImage forKey:[thisEvent objectForKey:@"image_url"]];
    } else {
        bannerImageView.image = [theImages valueForKey:[thisEvent objectForKey:@"image_url"]];
    }
    [cell.contentView addSubview:bannerImageView];
    
    cell = [cell prepareCell:thisEvent theCell:cell];
    cell.layer.cornerRadius = 5;
    cell.layer.masksToBounds = YES;
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}


@end
