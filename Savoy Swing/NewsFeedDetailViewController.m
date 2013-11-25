//
//  NewsFeedDetailViewController.m
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/24/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "NewsFeedDetailViewController.h"

@implementation NewsFeedDetailViewController

@synthesize postTableView;

@synthesize post_title;
@synthesize date_display;
@synthesize message;
@synthesize image_url;

- (void)viewDidLoad
{
    [super viewDidLoad];
    postTableView.delegate = self;
    postTableView.dataSource = self;
}

-(void)viewWillAppear:(BOOL)animated {
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 67.0f, 269.0f, 50.0f)];
    messageLabel.font = [UIFont fontWithName:@"HevelticaNeue-Regular" size:14.0];
    messageLabel.textAlignment = NSTextAlignmentLeft;
    messageLabel.textColor = [UIColor blackColor];
    messageLabel.text = message;
    messageLabel.numberOfLines = 0;
    [messageLabel sizeToFit];
    cellHeight = 120+messageLabel.frame.size.height;
    
    
    [postTableView reloadData];
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
    self.navigationController.navigationBar.hidden = NO;
    
    postTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
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
        nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.text = post_title;
        
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.0f, 32.0f, 211.0f, 19.0f)];
        dateLabel.font = [UIFont fontWithName:@"HevelticaNeue-Regular" size:14.0];
        dateLabel.textAlignment = NSTextAlignmentLeft;
        dateLabel.textColor = [UIColor lightGrayColor];
        dateLabel.text = date_display;
        
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(32.0f, 67.0f, 268.0f, 50.0f)];
        messageLabel.font = [UIFont fontWithName:@"HevelticaNeue-Regular" size:12.0];
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
        botShare.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5f];
        
        UIView *botSeparator = [[UIView alloc] initWithFrame:CGRectMake(20.0f, yPostForMenu+40.0f, cell.frame.size.width-40, 5.0f)];
        botSeparator.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        UIView *cellBackground = [[UIView alloc] initWithFrame:CGRectMake(20.0f, 0.0f, 280.0f, cellHeight)];
        cellBackground.backgroundColor = [UIColor whiteColor];
        
        [cell addSubview:cellBackground];
        [cell addSubview:botShare];
        [cell addSubview:botSeparator];
        [cell addSubview:user_image];
        [cell addSubview:user_image];
        [cell addSubview:nameLabel];
        [cell addSubview:dateLabel];
        [cell addSubview:messageLabel];
    } else {
        CellIdentifier = @"Cell";
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.backgroundColor = [UIColor clearColor];
        
        UIView *cellBackground = [[UIView alloc] initWithFrame:CGRectMake(20.0f, 00.0f, 280.0f, cell.frame.size.height)];
        cellBackground.backgroundColor = [UIColor whiteColor];
        
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
