//
//  AboutViewController.m
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/28/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    theAppDel = (SSCAppDelegate *)[[UIApplication sharedApplication] delegate];

    _aboutText.text = theAppDel.aboutText;
    _aboutText.textColor = [UIColor whiteColor];
}


@end
