//
//  AccountTableViewController.h
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/18/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *accountSection;
@property (nonatomic, strong) NSArray *profileSection;

-(IBAction)dismissKeyboard:(id)sender;

@end
