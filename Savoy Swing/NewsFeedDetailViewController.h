//
//  NewsFeedDetailViewController.h
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/24/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsFeedDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    NSInteger cellHeight;
}

@property (nonatomic, strong) NSString *post_title;
@property (nonatomic, strong) NSString *date_display;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *image_url;

@property (strong, nonatomic) IBOutlet UITableView *postTableView;
@property (strong, nonatomic) UILabel *title_label;
@property (strong, nonatomic) UILabel *date_label;
@property (strong, nonatomic) UILabel *message_label;


@end
