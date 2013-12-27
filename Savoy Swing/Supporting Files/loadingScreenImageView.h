//
//  loadingScreenImageView.h
//  Savoy Swing
//
//  Created by Stevenson on 12/26/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface loadingScreenImageView : UIImageView

@property (strong,nonatomic) UILabel *loadingLabel;
@property (strong,nonatomic) UIActivityIndicatorView *imageIndicator;

-(void) changeLabelText:(NSString*) text;
@end
