//
//  SSCViewController.h
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/25/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeView: UIView  <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView  *news_teaser;

@end


@interface HomeViewController : UIViewController


@property (strong, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) IBOutlet HomeView *Home_info_view;

@end

