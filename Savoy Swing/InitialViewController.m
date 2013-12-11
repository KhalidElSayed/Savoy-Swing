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
    
    _theImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    UIImage *theImage = [UIImage imageNamed:@"R4Default.png"];
    _theImageView.image = theImage;
    [self.view addSubview:_theImageView];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    CGPoint origin = _theImageView.center;
    CGPoint target = CGPointMake(_theImageView.center.x, _theImageView.center.y-150);
    
    CABasicAnimation *bounce = [CABasicAnimation animationWithKeyPath:@"position.y"];
    bounce.fromValue = [NSNumber numberWithInt:origin.y];
    bounce.toValue = [NSNumber numberWithInt:target.y];
    bounce.duration = 1;
    [_theImageView.layer addAnimation:bounce forKey:@"position"];
    
    _theImageView.center = target;

    [self performSelector:@selector(doStuff) withObject:self afterDelay:1.5];
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
    _imageIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    _imageIndicator.center = CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height / 2)-15);
    [_imageIndicator startAnimating];
    
    loadingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    loadingLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:22.0];
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.textColor = [UIColor whiteColor];
    loadingLabel.text = @"Connecting";
    [loadingLabel sizeToFit];
    loadingLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, loadingLabel.frame.size.height);
    loadingLabel.center = CGPointMake(self.view.frame.size.width/2, (self.view.frame.size.height / 2)+15);
    
    [self.view addSubview:_imageIndicator];
    [self.view addSubview: loadingLabel];
    
    if ([theAppDel hasConnectivity]) {
        [self performSelector:@selector(getInternetData) withObject:self afterDelay:1.5];
    } else {
        [_imageIndicator stopAnimating];
        loadingLabel.text = @"Server Unavailable";
    }
}

-(void) getInternetData {
    
    loadingLabel.text = @"Connection Established";
    [theAppDel makeNewFeeds];
    [theAppDel getAbout];
    [theAppDel retrieveDataTimer];
    
    theAppDel.user = @{@"username" : @"awkLindyTurtle",
             @"fullname" : @"Steven Stevenson",
             @"unique_id" : @"1003",
             @"exp_date" : @"4/1/2015",
             @"status"  : @"PAID"};
    
    
    [_imageIndicator stopAnimating];
    [self performSelector:@selector(getFirstViewController) withObject:self afterDelay:2];
}

-(void) getFirstViewController {
    SWRevealViewController *revealController =  (SWRevealViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"revealController"];
    [self presentViewController:revealController animated: YES completion:nil];
}

@end
