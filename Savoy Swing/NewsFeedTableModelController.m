//
//  NewsFeedTableModelController.m
//  Savoy Swing
//
//  Created by Stevenson on 1/21/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "NewsFeedTableModelController.h"

@implementation NewsFeedTableModelController

-(void) startLoading {
    if (!theAppDel.facebookAccount)
        [theAppDel getFacebookAccount];
    
    loadingFromMemory = NO;
    _detectData = [NSTimer scheduledTimerWithTimeInterval:100.0 target:self selector:@selector(newNewsPostDetected) userInfo:nil repeats:YES];
    self.finalizedTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(finalizeFeed) userInfo:nil repeats:YES];
}


-(void) finalizeFeed {
    if ([theAppDel.theFeed allDone]) {
        [self.finalizedTimer invalidate];
        _refreshImage = [NSTimer scheduledTimerWithTimeInterval:12.0 target:self selector:@selector(switchImageView) userInfo:nil repeats:YES];
        
        [self.tableView reloadData];
        [self setHeaderView:self.headerView];
        [self loadImages];
        [UIView animateWithDuration:0.25
                              delay:.5
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             loaderImageView.alpha = 0;
                         }completion:^(BOOL finished){
                             self.navigationController.navigationBarHidden = NO;
                             [theAppDel.theLoadingScreen removeFromSuperview];
                         }];
    }
}

-(void)loadImages {
    //setup image
    if (self.imageArr == nil ) {
        self.imageArr = theAppDel.imageArr;
        
        if ( [self.imageArr count] != 0 ) {
            NSInteger indexArr = 0;
            self.home_background.image = [self.imageArr objectAtIndex:indexArr];
            indexArr++;
            NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
            
            if (standardUserDefaults) {
                [standardUserDefaults setObject:[NSNumber numberWithInt:(int)indexArr] forKey:@"indexArr"];
                [standardUserDefaults synchronize];
            }
        }
        CATransition *transition = [CATransition animation];
        transition.duration = 0.66f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        transition.delegate = self;
        [self.home_background.layer addAnimation:transition forKey:nil];
    }
}

-(void)loadImagesFromWeb {
    //setup image
    if (self.imageArr == nil ) {
        self.imageArr = [[NSMutableArray alloc]  init];
        // GET information (update to POST if possible)
        NSString *strURL = [NSString stringWithFormat:@"http://www.savoyswing.org/wp-content/plugins/ssc_iphone_app/lib/processMobileApp.php?appSend&sliders"];
        NSData *dataURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
        NSString *strResult = [[NSString alloc] initWithData:dataURL encoding:NSUTF8StringEncoding];
        NSData *theData = [strResult dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        NSArray *imageStrArr = [NSJSONSerialization JSONObjectWithData:theData options:kNilOptions error:&e];
        for (int i=1; i < [imageStrArr count]; i++ ){
            if ( [strResult length] == 0 ) {
                break;
            } else {
                UIImage *thisImage = [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:[imageStrArr objectAtIndex:i]]]];
                [self.imageArr addObject:thisImage];
            }
        }
    }
}

-(void)switchImageView
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *index = nil;
    
    if (standardUserDefaults)
        index = [standardUserDefaults objectForKey:@"indexArr"];
    
    NSInteger indexArr = [index intValue];
    
    UIImage * toImage = [self.imageArr objectAtIndex:indexArr];
    [UIView transitionWithView:self.view
                      duration:0.33f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.home_background.image = toImage;
                    } completion:NULL];
    indexArr++;
    if ( indexArr == [self.imageArr count]) {
        indexArr = 0;
    }
    [standardUserDefaults setObject:[NSNumber numberWithInt:(int)indexArr] forKey:@"indexArr"];
    [standardUserDefaults synchronize];
}


@end
