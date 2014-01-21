//
//  InitialViewController.m
//  Savoy Swing
//
//  Created by Stevenson on 12/6/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "InitialViewController.h"

@interface InitialViewController () {
    SSCAppDelegate *theAppDel;
}
@property (strong, nonatomic) UIImageView *theImageView;

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

    [super viewDidAppear:animated];
    [self performSelector:@selector(doStuff) withObject:self afterDelay:0.5];
}

-(void) viewDidDisappear:(BOOL)animated {
    [theAppDel.theLoadingScreen removeFromSuperview];
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if ((orientation == UIInterfaceOrientationLandscapeLeft ||
         orientation == UIInterfaceOrientationLandscapeRight)) {
        return NO;
    }
    if (orientation==UIInterfaceOrientationPortrait || orientation==UIInterfaceOrientationPortraitUpsideDown) {
        return YES;
    }
    return NO;
}


#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
    [self performSelectorInBackground:@selector(loadGeneral) withObject:nil];
    
    [theAppDel makeNewFeedsWithNews:YES withBanners:YES];
    [self performSelectorInBackground:@selector(loadInitial) withObject:nil];

    [theAppDel.theLoadingScreen.imageIndicator stopAnimating];
    theAppDel.theLoadingScreen.imageIndicator.hidden = YES;
    [theAppDel.theLoadingScreen changeLabelText:@"Loading Home Screen"];
    [self performSelector:@selector(getFirstViewController) withObject:self afterDelay:2];
}

-(void) loadInitial {
    if ([theAppDel.theBanners.allEventImages count] == 0) {
        //load Images
        [theAppDel.theBanners loadImagesToMemory];
    }
}

-(void) loadGeneral {
    [theAppDel getAbout];
    [theAppDel loadImages];
}

-(void) getFirstViewController {
    SWRevealViewController *revealController =  (SWRevealViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"revealController"];
    [self presentViewController:revealController animated: YES completion:nil];
}

@end
