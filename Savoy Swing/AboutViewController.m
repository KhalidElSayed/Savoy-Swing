//
//  AboutViewController.m
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/28/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController () {
    SSCAppDelegate *theAppDel;
}

@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UITextView *aboutText;

@end

@implementation AboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    theAppDel = (SSCAppDelegate *)[[UIApplication sharedApplication] delegate];

    _aboutText.text = theAppDel.aboutText;
    _aboutText.textColor = [UIColor whiteColor];
    _aboutText.layer.cornerRadius = 5;
    _aboutText.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
