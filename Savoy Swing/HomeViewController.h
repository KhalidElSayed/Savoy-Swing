//
//  SSCViewController.h
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/25/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCAppDelegate.h"
#import "NewsFeedDetailViewController.h"

@interface HomeView: UIView 

@property (nonatomic, strong) IBOutlet UITableView  *news_teaser;
@property (strong, nonatomic) IBOutlet UIButton *moreEducation;
@property (strong, nonatomic) IBOutlet UIButton *moreCommunity;

@end


@interface HomeViewController : UIViewController 

@end

