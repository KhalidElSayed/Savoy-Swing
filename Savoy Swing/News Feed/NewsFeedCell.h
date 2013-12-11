//
//  NewsFeedCell.h
//  Savoy Swing
//
//  Created by Stevenson on 12/10/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCAppDelegate.h"

@interface NewsFeedCell : UITableViewCell {
    SSCAppDelegate *theAppDel;
}

@property (strong,nonatomic) UIView *cell_back;

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier height: (float) height;
@end
