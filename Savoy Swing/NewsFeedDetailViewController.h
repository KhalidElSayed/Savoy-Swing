//
//  NewsFeedDetailViewController.h
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/24/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationView.h"
#import "SSCAppDelegate.h"

@interface NewsFeedDetailViewController : UIViewController 

@property NSInteger userLikesPost;
@property BOOL userInData;
@property BOOL unlikeButton;
//@property (nonatomic, strong) UILabel *likeInfo;
@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) NSDictionary *theFeedData;
@property (nonatomic, strong) NSString *post_title;
@property (nonatomic, strong) NSString *date_display;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *image_url;
@property (nonatomic, strong) NSString *post_type;
@property (nonatomic, strong) UIImage *post_message_image;
@property (nonatomic,strong) UIActivityIndicatorView *likeActivity;
@property (weak, nonatomic) NotificationView *noti_view;
@property (nonatomic, strong) NSString *likeUpdateText;

@property (strong, nonatomic) NSArray *likeData;

-(void) hideNotificationView;
@end
