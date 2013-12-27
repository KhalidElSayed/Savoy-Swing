//
//  SSCRevealViewController.m
//  Savoy Swing
//
//  Created by Stevenson on 12/24/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "MasterNavViewController.h"
#import "RequiredLoginViewController.h"
#import "SSCRevealViewController.h"

@interface SSCRevealViewController ()

@end

@implementation SSCRevealViewController

- (BOOL)shouldAutorotate {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    MasterNavViewController *nav;
    if ([self.frontViewController isKindOfClass:[MasterNavViewController class]] ) {
        nav = (MasterNavViewController*)self.frontViewController;
    }
    if ((orientation == UIInterfaceOrientationLandscapeLeft ||
         orientation == UIInterfaceOrientationLandscapeRight) && (
                                                                  [[nav.topViewController class] isSubclassOfClass:[RequiredLoginViewController class]] ) ) {
        [nav.topViewController.view removeGestureRecognizer:self.panGestureRecognizer];
        return YES;
    }
    if (orientation==UIInterfaceOrientationPortrait) {
        [nav.topViewController.view addGestureRecognizer:self.panGestureRecognizer];
        return YES;
    }
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

@end
