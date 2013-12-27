//
//  AccountViewController.h
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/18/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequiredLoginViewController.h"

@interface AccountViewController : RequiredLoginViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *accountSection;
@property (nonatomic, strong) NSArray *profileSection;
@property (nonatomic, strong) IBOutlet UITableView *theTableView;

-(IBAction)dismissKeyboard:(id)sender;

@end
