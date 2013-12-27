//
//  MembershipViewController.h
//  Savoy Swing
//
//  Created by Steven Stevenson on 12/1/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequiredLoginViewController.h"

@interface MembershipViewController : RequiredLoginViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *logout_button;
@property (strong, nonatomic) NSArray *sectionNames;
@property (strong, nonatomic) NSArray *contentForRow;
@property (strong, nonatomic) IBOutlet UITableView *theTableView;


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface MembershipInfoTableCell : UITableViewCell


@end