//
//  InitialViewController.m
//  Savoy Swing
//
//  Created by Stevenson on 12/6/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "InitialViewController.h"

@interface InitialViewController ()

@end

@implementation InitialViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    theAppDel = (SSCAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    theAppDel.theLoadingScreen = [[loadingScreenImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:theAppDel.theLoadingScreen];
}

-(void) viewDidAppear:(BOOL)animated {
    /*
    [super viewDidAppear:animated];

    CGPoint origin = _theImageView.center;
    CGPoint target = CGPointMake(_theImageView.center.x, _theImageView.center.y-150);
    
    CABasicAnimation *bounce = [CABasicAnimation animationWithKeyPath:@"position.y"];
    bounce.fromValue = [NSNumber numberWithInt:origin.y];
    bounce.toValue = [NSNumber numberWithInt:target.y];
    bounce.duration = 1;
    [_theImageView.layer addAnimation:bounce forKey:@"position"];
    
    _theImageView.center = target;
     */
    [self performSelector:@selector(doStuff) withObject:self afterDelay:1.5];
}

-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotate {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if ((orientation == UIInterfaceOrientationLandscapeLeft ||
         orientation == UIInterfaceOrientationLandscapeRight)) {
        return NO;
    }
    if (orientation==UIInterfaceOrientationPortrait) {
        return YES;
    }
    return NO;
}

-(void) doStuff {
    theAppDel.theLoadingScreen.imageIndicator.hidden = NO;
    [theAppDel.theLoadingScreen.imageIndicator startAnimating];
    [theAppDel.theLoadingScreen changeLabelText:@"Connecting"];
    
    if ([theAppDel hasConnectivity]) {
        [theAppDel.theLoadingScreen changeLabelText:@"Connection Established"];
        [self performSelector:@selector(getInternetData) withObject:self afterDelay:1];
    } else {
        [theAppDel.theLoadingScreen.imageIndicator stopAnimating];
        [theAppDel.theLoadingScreen changeLabelText:@"Server Unavailable"];
        UIButton *retryButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 140, 45)];
        retryButton.backgroundColor = [UIColor colorWithWhite:0 alpha:.2];
        retryButton.center = CGPointMake(self.view.frame.size.width/2,120);
        [retryButton setTitle:@"Retry" forState:UIControlStateNormal];
        [retryButton addTarget:self action:@selector(retryDoStuff) forControlEvents:UIControlEventTouchUpInside];
        retryButton.tag = 201;
        [self.view addSubview:retryButton];
    }
}

-(void) retryDoStuff {
    UIButton *retryButton = (UIButton*)[self.view viewWithTag:201];
    [retryButton removeFromSuperview];
    [self performSelector:@selector(doStuff) withObject:Nil afterDelay:.5];
}

-(void) getInternetData {
    [theAppDel makeNewFeedsWithNews:YES withBanners:YES];
    [theAppDel getAbout];
    [theAppDel retrieveDataTimer];
    [theAppDel loadImages];
    
    [theAppDel.theLoadingScreen.imageIndicator stopAnimating];
    theAppDel.theLoadingScreen.imageIndicator.hidden = YES;
    [theAppDel.theLoadingScreen changeLabelText:@"Loading Home Screen"];
    [self performSelector:@selector(getFirstViewController) withObject:self afterDelay:2];
}

-(void) getFirstViewController {
    SWRevealViewController *revealController =  (SWRevealViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"revealController"];
    [self presentViewController:revealController animated: YES completion:nil];
}

@end
