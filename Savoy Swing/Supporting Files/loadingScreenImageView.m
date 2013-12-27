//
//  loadingScreenImageView.m
//  Savoy Swing
//
//  Created by Stevenson on 12/26/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "loadingScreenImageView.h"

@implementation loadingScreenImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *theImage = [UIImage imageNamed:@"R4Default.png"];
        self.image = theImage;
        self.imageIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        self.loadingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.loadingLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:22.0];
        self.loadingLabel.textAlignment = NSTextAlignmentCenter;
        self.loadingLabel.textColor = [UIColor whiteColor];
        self.loadingLabel.text = @"Compiling News Data";
        self.loadingLabel.numberOfLines = 0;
        [self.loadingLabel sizeToFit];
        self.loadingLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.loadingLabel.frame.size.height);
        self.loadingLabel.center = CGPointMake(self.frame.size.width / 2, (self.frame.size.height / 2)+160);
        
        [self addSubview:self.imageIndicator];
        self.imageIndicator.center = CGPointMake(self.frame.size.width / 2, (self.frame.size.height / 2)+120);
        [self addSubview:self.loadingLabel];
    }
    return self;
}

-(void) changeLabelText:(NSString*) text {
    self.loadingLabel.text = text;
    [self.loadingLabel sizeThatFits:CGSizeMake(self.frame.size.width, 50)];
    [self.loadingLabel setNeedsDisplay];
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
}

-(void) startAnimating {
    [super startAnimating];
    [self.imageIndicator startAnimating];
}

@end
