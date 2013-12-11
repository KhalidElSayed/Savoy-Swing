//
//  InitialViewController.h
//  Savoy Swing
//
//  Created by Stevenson on 12/6/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCAppDelegate.h"
#import "SWRevealViewController.h"

@interface InitialViewController : UIViewController {
    SSCAppDelegate *theAppDel;
    UILabel *loadingLabel;
}

@property (strong, nonatomic) UIImageView *theImageView;
@property (strong, nonatomic) UIActivityIndicatorView *imageIndicator;

@end
