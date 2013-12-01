//
//  EventsViewController.h
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/30/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCAppDelegate.h"

@interface EventsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    SSCAppDelegate *theAppDel;
    NSMutableDictionary *theImages;
    
    //preloading image
    UIView *preloaderView;
    UIImageView *loaderImageView;
    UILabel *loadingLabel;
    UIActivityIndicatorView *imageIndicator;
}

@property (strong, nonatomic) IBOutlet UITableView *theTableView;
@property (strong)  NSTimer *loadingScreenText;
@property (strong, nonatomic) NSArray *allEvents;

-(void) startLoading;

@end
