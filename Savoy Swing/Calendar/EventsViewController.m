//
//  EventsViewController.m
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/30/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "EventsViewController.h"

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
    _allEvents = [theAppDel.theBanners getSpecialBanners];
    [self.theTableView reloadData];
    loadingLabel.text = @"Configuring View";
    self.navigationController.navigationBarHidden = NO;
    [preloaderView removeFromSuperview];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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
    UIView *highlightView = [[UIView alloc] initWithFrame:CGRectMake(140.0f, 80.0f, 181.0f, 64.0f)];
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



-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    return 200.0f;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return [_allEvents count];
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventCell" forIndexPath:indexPath];
    NSDictionary *thisEvent = [_allEvents objectAtIndex:indexPath.section];
    cell = [self prepareCell:thisEvent theCell:cell];
    return cell;
}


@end
