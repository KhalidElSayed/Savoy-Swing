//
//  NewsFeedDetailViewController.m
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/24/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "NewsFeedDetailViewController.h"

@implementation NewsFeedDetailViewController {
    UIColor *bgColor;
}

@synthesize postTableView;

@synthesize post_title;
@synthesize date_display;
@synthesize message;
@synthesize image_url;
@synthesize post_type;

- (void)viewDidLoad
{
    [super viewDidLoad];
    bgColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
    self.postTableView.backgroundColor = bgColor;
    postTableView.delegate = self;
    postTableView.dataSource = self;
}

-(void)viewWillAppear:(BOOL)animated {
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(32.0f, 67.0f, 258.0f, 50.0f)];
    messageLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    messageLabel.textAlignment = NSTextAlignmentLeft;
    messageLabel.textColor = [UIColor blackColor];
    messageLabel.text = message;
    messageLabel.numberOfLines = 0;
    [messageLabel sizeToFit];
    cellHeight = 120+messageLabel.frame.size.height;
    
    
    [postTableView reloadData];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidLoad];

}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.post_title = @"";
    self.date_display = @"";
    self.message = @"";
    self.image_url = @"";
    _likeData = nil;
    self.navigationController.navigationBar.hidden = NO;
    
    postTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
}

-(void) sharePost {
    NSArray *itemsToShare = @[message];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll]; //or whichever you don't need
    [self presentViewController:activityVC animated:YES completion:nil];
}

-(void) likePost {
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = 1;
    if (_likeData) {
        numRows++;
    }
    return numRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0 ) {
        return cellHeight;
    }
    return 50.0f;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger) numberOfSectionsInTableView:(UITableView *) tableView {
    return 1;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier;
    UITableViewCell *cell;
    if (indexPath.section == 0 && indexPath.row == 0) {
        UIImageView *user_image = [[UIImageView alloc] initWithFrame:CGRectMake(32.0f, 12.0f, 40.f, 40.f)];
        UIImage * toImage = [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:image_url]]];
        user_image.image = toImage;
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.0f, 14.0f, 211.0f, 19.0f)];
        nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.text = post_title;
        
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.0f, 30.0f, 211.0f, 19.0f)];
        dateLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:10.0];
        dateLabel.textAlignment = NSTextAlignmentLeft;
        dateLabel.textColor = [UIColor lightGrayColor];
        dateLabel.text = date_display;
        
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(32.0f, 67.0f, 258.0f, 50.0f)];
        messageLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
        messageLabel.textAlignment = NSTextAlignmentLeft;
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.text = message;
        messageLabel.numberOfLines = 0;
        [messageLabel sizeToFit];
        
        CellIdentifier = @"main_post_cell";
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        
        float yPostForMenu = cellHeight-45.0f;
        UIView *botShare = [[UIView alloc] initWithFrame:CGRectMake(20.0f, yPostForMenu, cell.frame.size.width-40, 40.0f)];
        botShare.backgroundColor = [UIColor groupTableViewBackgroundColor] ;
        botShare.layer.cornerRadius = 5;
        botShare.layer.masksToBounds = YES;
        
        if ([post_type isEqualToString:@"Facebook"]) {
            UIButton *likeButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 280.0f/2.0f, 40.0f)];
            [likeButton setTitle:@"Like" forState:UIControlStateNormal];
            [likeButton setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
            [likeButton addTarget:self action:@selector(likePost) forControlEvents:UIControlEventTouchUpInside];
            [likeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
            [botShare addSubview:likeButton];
        } else if ([post_type isEqualToString:@"Facebook"]) {
            UIButton *likeButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 280.0f/2.0f, 40.0f)];
            [likeButton setTitle:@"ReTweet" forState:UIControlStateNormal];
            [likeButton setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
            [likeButton addTarget:self action:@selector(likePost) forControlEvents:UIControlEventTouchUpInside];
            [likeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
            [botShare addSubview:likeButton];
        }
        UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 280.0f, 40.0f)];
        [shareButton setTitle:@"Share" forState:UIControlStateNormal];
        [shareButton setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        [shareButton addTarget:self action:@selector(sharePost) forControlEvents:UIControlEventTouchUpInside];
        [shareButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [botShare addSubview:shareButton];
        
        
        float yPostForMenuTop = cellHeight-45.0f;
        UIView *botShareTop = [[UIView alloc] initWithFrame:CGRectMake(20.0f, yPostForMenuTop, cell.frame.size.width-40, 5.0f)];
        botShareTop.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        
        UIView *botSeparator = [[UIView alloc] initWithFrame:CGRectMake(20.0f, yPostForMenu+40.0f, cell.frame.size.width-40, 5.0f)];
        botSeparator.backgroundColor = bgColor;
        
        UIView *cellBackground = [[UIView alloc] initWithFrame:CGRectMake(20.0f, 0.0f, 280.0f, cellHeight-5)];
        cellBackground.backgroundColor = [UIColor whiteColor];
        cellBackground.layer.cornerRadius = 5;
        botShare.layer.masksToBounds = YES;
        
        [cell addSubview:cellBackground];
        [cell addSubview:botShare];
        [cell addSubview:botShareTop];
        [cell addSubview:botSeparator];
        [cell addSubview:user_image];
        [cell addSubview:user_image];
        [cell addSubview:nameLabel];
        [cell addSubview:dateLabel];
        [cell addSubview:messageLabel];
    } else if (indexPath.section == 0 && indexPath.row == 1 && _likeData){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.backgroundColor = [UIColor clearColor];
        
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(32.0f, 11.0f, 268.0f, 21.0f)];
        messageLabel.font = [UIFont fontWithName:@"HevelticaNeue-Regular" size:10.0];
        messageLabel.textAlignment = NSTextAlignmentLeft;
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.text = _likeData;
        messageLabel.numberOfLines = 0;
        [messageLabel sizeToFit];
        
        UIView *cellBackground = [[UIView alloc] initWithFrame:CGRectMake(20.0f, 0.0f, 280.0f, cell.frame.size.height)];
        cellBackground.backgroundColor = [UIColor whiteColor];
        cellBackground.layer.cornerRadius = 5;
        cellBackground.layer.masksToBounds = YES;
        
        [cell addSubview:cellBackground];
        [cell addSubview:messageLabel];
    } else {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.backgroundColor = [UIColor clearColor];
        
        UIView *cellBackground = [[UIView alloc] initWithFrame:CGRectMake(20.0f, 0.0f, 280.0f, cell.frame.size.height)];
        cellBackground.backgroundColor = [UIColor whiteColor];
        cellBackground.layer.cornerRadius = 5;
        cellBackground.layer.masksToBounds = YES;
        
        [cell addSubview:cellBackground];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) releaseViewComponents
{
    post_title = nil;
    date_display = nil;
    message = nil;
    image_url = nil;
    postTableView = nil;
    _likeData = nil;
    cellHeight = 0;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) dealloc
{
    [self releaseViewComponents];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) viewDidUnload
{
    [self releaseViewComponents];
    [super viewDidUnload];
}


@end
