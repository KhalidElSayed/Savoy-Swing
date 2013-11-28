//
//  SSCViewController.h
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/25/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCAppDelegate.h"

@interface HomeView: UIView  <UITableViewDelegate, UITableViewDataSource> {
    SSCAppDelegate *theAppDel;
}

@property (nonatomic, strong) IBOutlet UITableView  *news_teaser;
@property (strong, nonatomic) IBOutlet UIButton *moreEducation;
@property (strong, nonatomic) IBOutlet UIButton *moreCommunity;

@end


@interface HomeViewController : UIViewController {
    SSCAppDelegate *theAppDel;
}

@property (strong, nonatomic) IBOutlet UIButton *fullSite;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) IBOutlet HomeView *Home_info_view;
@property (strong, nonatomic) NSTimer *singleNewsTimer;

@end

