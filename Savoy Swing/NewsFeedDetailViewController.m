//
//  NewsFeedDetailViewController.m
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/24/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "NewsFeedDetailViewController.h"
#import <Social/Social.h>

@interface NewsFeedDetailViewController() <UITableViewDelegate, UITableViewDataSource> {
    NSInteger cellHeight;
    UITapGestureRecognizer *tap;
    SSCAppDelegate *theAppDel;
}

@property (weak, nonatomic) IBOutlet UITableView *theTableView;

@end

@implementation NewsFeedDetailViewController {
    UIColor *bgColor;
}

- (void)viewDidLoad
{
    NSLog(@"Detail News DidLoad");
    [super viewDidLoad];
    theAppDel = [[UIApplication sharedApplication] delegate];
    
    bgColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    self.self.theTableView.backgroundColor = bgColor;
    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;

    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NotificationView" owner:self options:nil];
    self.noti_view = [nib objectAtIndex:0];
    
    self.noti_view.layer.cornerRadius = 5;
    self.noti_view.layer.masksToBounds = YES;
    self.noti_view.alpha = 0;
    [self.view addSubview:self.noti_view];
    self.noti_view.center = self.view.center;
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"Detail News Will Appear");
    cellHeight = 0;
    [self performSelectorInBackground:@selector(startLoading) withObject:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"Detail News Appeared");
    [super viewDidAppear:animated];
    
    if ([self.post_type isEqualToString:@"Facebook"]) {
        [self performSelectorInBackground:@selector(refreshFacebookFeed) withObject:nil];
    }
    
    UITextView *messageLabel = [[UITextView alloc] initWithFrame:CGRectMake(32.0f, 67.0f, 258.0f, 50.0f)];
    messageLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    messageLabel.textAlignment = NSTextAlignmentLeft;
    messageLabel.text = self.message;
    messageLabel.selectable = YES;
    messageLabel.editable = NO;
    messageLabel.scrollEnabled = NO;
    messageLabel.dataDetectorTypes = UIDataDetectorTypeLink;
    [messageLabel sizeToFit];
    cellHeight = 120+messageLabel.frame.size.height;
    if ([self.theFeedData objectForKey:@"picture"]) {
        NSLog(@"loading Facebook News Detail Image");
        self.post_message_image = [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:[self.theFeedData objectForKey:@"picture"]]]];
        if (self.post_message_image.size.width > 270 ) {
            CGFloat multipler = 270/self.post_message_image.size.width;
            cellHeight = cellHeight+(self.post_message_image.size.height*multipler)+20;
        } else {
            cellHeight = cellHeight+self.post_message_image.size.height+20;
        }
    } else if ([[self.theFeedData objectForKey:@"entities"] objectForKey:@"media"] ) {
        for (NSInteger i=0;i< [[[self.theFeedData objectForKey:@"entities"] objectForKey:@"media"] count];i++) {
            NSDictionary *thisMedium = [[[self.theFeedData objectForKey:@"entities"] objectForKey:@"media"] objectAtIndex:i];
            if ([[thisMedium objectForKey:@"type"] isEqualToString:@"photo"]) {
                NSLog(@"loading Twitter News Detail Image");
                NSString *imageURL;
                if ([[thisMedium objectForKey:@"sizes"] objectForKey:@"small"]) {
                    imageURL =[NSString stringWithFormat:@"%@:small",[thisMedium objectForKey:@"media_url_https"]];
                } else {
                    imageURL =[thisMedium objectForKey:@"media_url_https"];
                }
                self.post_message_image = [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]]];
                if (self.post_message_image.size.width > 270 ) {
                    CGFloat multipler = 270/self.post_message_image.size.width;
                    cellHeight = cellHeight+(self.post_message_image.size.height*multipler)+20;
                } else {
                    cellHeight = cellHeight+self.post_message_image.size.height+20;
                }
                
            }
        }
    }
    
    [self.theTableView reloadData];
    self.noti_view.message.text = @"Loading Done";
    [self.noti_view hideNotificationView];
}

- (void) viewDidUnload
{
    [self releaseViewComponents];
    [super viewDidUnload];
}

- (void) dealloc
{
    [self releaseViewComponents];
}

#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) startLoading {
    if (!theAppDel.facebookAccount)
        [theAppDel getFacebookAccount];
    self.noti_view.message.text = @"Loading Info Data";
    [self.noti_view showNotificationView];
}

-(void)refreshFacebookFeed {
    self.theFeedData = [theAppDel.theFeed refreshFacebookFeedAndReturnPostForID:[self.theFeedData objectForKey:@"id"]];
    self.likeData = [[self.theFeedData valueForKey:@"likes"] valueForKey:@"data"];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.userLikesPost = 0;
        if (self.likeData) {
            self.userInData = NO;
            for (NSInteger i=0;i<[_likeData count]; i++) {
                if ([theAppDel.facebookUserID isEqualToString:[[self.likeData objectAtIndex:i] objectForKey:@"id"]]) {
                    self.userInData = YES;
                    self.userLikesPost = 1;
                }
            }
        }
        [self refreshLikeInfo];
        [self.self.theTableView reloadData];
        [self.self.theTableView beginUpdates];
        [self.self.theTableView endUpdates];
    });
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.post_title = @"";
    self.date_display = @"";
    self.message = @"";
    self.image_url = @"";
    self.post_message_image = nil;
    _likeData = nil;
    self.likeButton = nil;
    self.theFeedData = nil;
    self.userLikesPost = -1;
    self.likeUpdateText = nil;
    self.unlikeButton = NO;
    self.navigationController.navigationBar.hidden = NO;
    
    self.theTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    cellHeight = 0;
    [self.theTableView beginUpdates];
    [self.theTableView endUpdates];
}

-(void) sharePost {
    // need to use custom composeviewcontroller to have Facebook "via" info different.
    // for web browser difference: https://www.facebook.com/dialog/feed?app_id=1422669574628832&redirect_uri=https://www.savoyswing.org
    
    NSString *shareMessage = @"Check this out! Found this with the Savoy Swing Club app!\n\n";
    NSString *linkToMessage = @"";
    if ([self.post_type isEqualToString:@"Facebook"]) {
        linkToMessage = [NSString stringWithFormat:@"https://www.facebook.com/%@",[self.theFeedData objectForKey:@"id"]];
    } else if ([self.post_type isEqualToString:@"Wordpress"]) {
        linkToMessage = @"https://www.savoyswing.org";
    } else if ([self.post_type isEqualToString:@"Twitter"]) {
        linkToMessage = [NSString stringWithFormat:@"https://twitter.com/%@/status/%@/",
                         [[self.theFeedData objectForKey:@"user"] objectForKey:@"screen_name"],
                         [self.theFeedData objectForKey:@"id"]];
    }
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *composer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [composer setInitialText:[NSString stringWithFormat:@" \n\n%@",shareMessage]];
        if (self.post_message_image) {
            [composer addImage:self.post_message_image];
        }
        if (![linkToMessage isEqualToString:@""]) {
            [composer addURL:[NSURL URLWithString:linkToMessage]];
        }
        [self presentViewController:composer animated:YES completion:nil];

    } else {
        NSArray *itemsToShare = @[shareMessage,];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
        activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll]; //or whichever you don't need
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}

-(void) hideNotificationView {
    NSLog(@"HidingNotiView");
    [self.noti_view hideNotificationView];
}

-(void) refreshLikeInfo {
    
    if (self.userLikesPost == 1 ) {
        NSInteger likeDataCount = [_likeData count];
        if ( likeDataCount > 1) {
            if (self.userInData)
                likeDataCount--;
            NSString *likeText = [[NSString alloc] initWithFormat:@"%d others like this",likeDataCount];
            self.likeUpdateText = [NSString stringWithFormat:@"You and %@",likeText];
        } else {
            self.likeUpdateText = [NSString stringWithFormat:@"You like this"];
        }
        self.unlikeButton = YES;
    } else  {
        NSInteger likeDataCount = [_likeData count];
        if ( likeDataCount > 0) {
            if (likeDataCount > 1 || !self.userInData) {
                if (self.userInData)
                    likeDataCount--;
                NSString *likeText = [[NSString alloc] initWithFormat:@"%d others like this",likeDataCount];
                self.likeUpdateText = likeText;
            } else {
                self.likeUpdateText = @"";
            }
        } else {
            self.likeUpdateText = @"";
        }
        self.unlikeButton = NO;
    }
}

-(NSString*) getLikeButtonText {
    if ( self.unlikeButton ) {
        return @"Unlike";
    } else {
        return @"Like";
    }
}

-(NSString*) getLikeInfoText {
    return self.likeUpdateText;
}

-(void) likePost {
    [self.likeButton removeFromSuperview];
    self.likeButton = nil;
    [self.likeActivity startAnimating];
    self.likeActivity.hidden = NO;
    NSString *objID = [self.theFeedData objectForKey:@"id"];
    NSArray *objIDSplit = [objID componentsSeparatedByString:@"_"];
    objID = [objIDSplit objectAtIndex:1];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/likes", objID]];
    if (self.userLikesPost == 1 ) {
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodDELETE URL:url parameters:nil];
        request.account = theAppDel.facebookAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *err) {
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                [self.likeActivity stopAnimating];
                self.likeActivity.hidden = YES;
            });
            
            if (err) {
                NSLog(@"error: %@",[err localizedDescription]);
            } else {
                NSError *jsonError;
                id responseJson = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                NSLog(@"response: %@",responseJson);
                if (jsonError) {
                    NSLog(@"error: %@",[jsonError localizedDescription]);
                } else if ([responseJson intValue] == 1) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        self.userLikesPost = 0;
                        
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unlike Success"
                                                                            message:@"You have Unliked this Post!"
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"Dismiss"
                                                                  otherButtonTitles:nil];
                        [alertView show];
                        [self refreshLikeInfo];
                        [self.self.theTableView reloadData];
                        [self.self.theTableView beginUpdates];
                        [self.self.theTableView endUpdates];
                    });
                }
            }
        }];
    } else if (self.userLikesPost == 0) {
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodPOST URL:url parameters:nil];
        request.account = theAppDel.facebookAccount;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *err) {

            dispatch_sync(dispatch_get_main_queue(), ^{
                
                [self.likeActivity stopAnimating];
                self.likeActivity.hidden = YES;
            });
            
            if (err) {
                NSLog(@"error: %@",[err localizedDescription]);
                self.noti_view.message.text = @"Like Error";
            } else {
                NSError *jsonError;
                id responseJson = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                NSLog(@"response: %@",responseJson);
                if (jsonError) {
                    NSLog(@"error: %@",[jsonError localizedDescription]);
                } else if ([responseJson intValue] == 1) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        self.userLikesPost = 1;
                        
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Like Success"
                                                                            message:@"You have Successfully Liked this Post!"
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"Dismiss"
                                                                  otherButtonTitles:nil];
                        [alertView show];
                        [self refreshLikeInfo];
                        [self.self.theTableView reloadData];
                        [self.self.theTableView beginUpdates];
                        [self.self.theTableView endUpdates];
                    });
                }
            }
        }];

    }
}

-(void) sendTweet {
    SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    NSString *theString  =[NSString stringWithFormat:@"RT%@ %@",self.post_title,self.message];
    if ([theString length] > 140) {
        theString = [theString substringToIndex:140];
    }
    if (self.post_message_image) {
        [tweetSheet addImage:self.post_message_image];
    }
    [tweetSheet setInitialText:theString];
    [self presentViewController:tweetSheet animated:YES completion:nil];
}


- (void) releaseViewComponents
{
    self.post_title = nil;
    self.date_display = nil;
    self.message = nil;
    self.image_url = nil;
    self.theTableView = nil;
    _likeData = nil;
    cellHeight = 0;
}

#pragma mark UITableViewDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (cellHeight != 0 ) {
        if (indexPath.section == 0 && indexPath.row == 0 ) {
            return cellHeight;
        } else if (indexPath.section == 0 && indexPath.row == 1 &&
                   ((self.likeData && [self.likeData count] > 1) ||
                    self.userLikesPost == 1)) {
                       return 55;
                   }
    }
    return 0;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *) tableView {
    return 1;
}

#pragma mark UITableViewDataSource
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier;
    UITableViewCell *cell;
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        UIImageView *user_image = [[UIImageView alloc] initWithFrame:CGRectMake(32.0f, 12.0f, 40.f, 40.f)];
        UIImage * toImage = [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:self.image_url]]];
        user_image.image = toImage;
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.0f, 14.0f, 211.0f, 19.0f)];
        nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.text = self.post_title;
        
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.0f, 30.0f, 211.0f, 19.0f)];
        dateLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:10.0];
        dateLabel.textAlignment = NSTextAlignmentLeft;
        dateLabel.textColor = [UIColor lightGrayColor];
        dateLabel.text = self.date_display;
        
        
        UITextView *messageLabel = [[UITextView alloc] initWithFrame:CGRectMake(32.0f, 67.0f, 258.0f, 50.0f)];
        messageLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
        messageLabel.textAlignment = NSTextAlignmentLeft;
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.text = self.message;
        messageLabel.selectable = YES;
        messageLabel.editable = NO;
        messageLabel.scrollEnabled = NO;
        messageLabel.dataDetectorTypes = UIDataDetectorTypeLink;
        [messageLabel sizeToFit];
        
        UIImageView *theImageView;
        if (self.post_message_image) {
            CGFloat height = self.post_message_image.size.height;
            CGFloat width = self.post_message_image.size.width;
            if (width > 270) {
                CGFloat multipler = 270/width;
                height = height*multipler;
                width = width*multipler;
            }
            theImageView = [[UIImageView alloc] initWithFrame:CGRectMake(25,67+messageLabel.frame.size.height+10,width,height)];
            theImageView.image = self.post_message_image;
            theImageView.backgroundColor = [UIColor redColor];
        }
        
        CellIdentifier = @"main_post_cell";
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        
        float yPostForMenu = cellHeight-45.0f;
        UIView *botShare = [[UIView alloc] initWithFrame:CGRectMake(20.0f, yPostForMenu, cell.frame.size.width-40, 40.0f)];
        botShare.backgroundColor = [UIColor groupTableViewBackgroundColor] ;
        botShare.layer.cornerRadius = 5;
        botShare.layer.masksToBounds = YES;
        
        if ([self.post_type isEqualToString:@"Facebook"] && theAppDel.facebookAccount) {
            self.likeButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 280.0f/2.0f, 40.0f)];
            [self.likeButton setTitle:[self getLikeButtonText] forState:UIControlStateNormal];
            [self.likeButton setTintColor:[UIColor lightGrayColor]];
            [self.likeButton setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
            [self.likeButton addTarget:self action:@selector(likePost) forControlEvents:UIControlEventTouchUpInside];
            [self.likeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
            [botShare addSubview:self.likeButton];
            
            self.likeActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            self.likeActivity.hidden = YES;
            [botShare addSubview:self.likeActivity];
            self.likeActivity.center = self.likeButton.center;
            
            UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(280.0f/2.0f, 0.0f, 280.0f/2.0f, 40.0f)];
            [shareButton setTitle:@"Share" forState:UIControlStateNormal];
            [shareButton setTintColor:[UIColor lightGrayColor]];
            [shareButton setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
            [shareButton addTarget:self action:@selector(sharePost) forControlEvents:UIControlEventTouchUpInside];
            [shareButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
            [botShare addSubview:shareButton];
        } else if ([self.post_type isEqualToString:@"Twitter"]) {
            UIButton *tweetButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 280.0f/2.0f, 40.0f)];
            [tweetButton setTitle:@"ReTweet" forState:UIControlStateNormal];
            [tweetButton setTintColor:[UIColor lightGrayColor]];
            [tweetButton setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
            [tweetButton addTarget:self action:@selector(sendTweet) forControlEvents:UIControlEventTouchUpInside];
            [tweetButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
            [botShare addSubview:tweetButton];
            
            UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(280.0f/2.0f, 0.0f, 280.0f/2.0f, 40.0f)];
            [shareButton setTitle:@"Share" forState:UIControlStateNormal];
            [shareButton setTintColor:[UIColor lightGrayColor]];
            [shareButton setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
            [shareButton addTarget:self action:@selector(sharePost) forControlEvents:UIControlEventTouchUpInside];
            [shareButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
            [botShare addSubview:shareButton];
        } else {
            UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 280.0f, 40.0f)];
            [shareButton setTitle:@"Share" forState:UIControlStateNormal];
            [shareButton setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
            [shareButton addTarget:self action:@selector(sharePost) forControlEvents:UIControlEventTouchUpInside];
            [shareButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
            [botShare addSubview:shareButton];
        }
        
        
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
        [cell addSubview:nameLabel];
        [cell addSubview:dateLabel];
        [cell addSubview:messageLabel];
        if (self.post_message_image) {
            [cell addSubview:theImageView];
        }
    } else if (indexPath.section == 0 && indexPath.row == 1){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.backgroundColor = [UIColor clearColor];
        
        NSString *likeText = @"i hate your stinking guts, you are scum between my toes, you make me vommit. Love Alfalfa! ";
        if ( self.likeUpdateText ) {
            likeText = self.likeUpdateText;
        } else {
            likeText = [self getLikeInfoText];
        }
        
        UILabel *likeInfo = [[UILabel alloc] initWithFrame:CGRectMake(32.0f, 11.0f, 268.0f, 21.0f)];
        likeInfo.font = [UIFont fontWithName:@"HevelticaNeue-Regular" size:10.0];
        likeInfo.textAlignment = NSTextAlignmentLeft;
        likeInfo.textColor = [UIColor blackColor];
        likeInfo.text = likeText;
        likeInfo.numberOfLines = 1;
        [likeInfo sizeToFit];
        
        UIView *cellBackground = [[UIView alloc] initWithFrame:CGRectMake(20.0f, 0.0f, 280.0f, cell.frame.size.height)];
        cellBackground.backgroundColor = [UIColor whiteColor];
        cellBackground.layer.cornerRadius = 5;
        cellBackground.layer.masksToBounds = YES;
        
        [cell addSubview:cellBackground];
        [cell addSubview:likeInfo];
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



@end
