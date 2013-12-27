//
//  InitialViewController.h
//  Savoy Swing
//
//  Created by Stevenson on 12/6/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCAppDelegate.h"
#import "SSCRevealViewController.h"

@interface InitialViewController : UIViewController {
    SSCAppDelegate *theAppDel;
}

@property (strong, nonatomic) UIImageView *theImageView;

@end
