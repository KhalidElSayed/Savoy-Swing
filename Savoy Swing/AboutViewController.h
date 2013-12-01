//
//  AboutViewController.h
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/28/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCAppDelegate.h"

@interface AboutViewController : UIViewController {
    SSCAppDelegate *theAppDel;
}

@property (strong, nonatomic) IBOutlet UIView *shadowView;
@property (strong, nonatomic) IBOutlet UITextView *aboutText;

@end
