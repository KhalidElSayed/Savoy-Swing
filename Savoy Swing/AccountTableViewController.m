//
//  AccountTableViewController.m
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/18/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "AccountTableViewController.h"

@implementation AccountTableViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.accountSection =@[@"username",@"status",@"exp_date"];
    self.profileSection = @[@"name",@"add1",@"add2",@"city",@"state",@"zip",@"phone",@"email"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( section == 0 ) {
        return [self.accountSection count];
    } else if ( section == 1) {
        return [self.profileSection count];
    }
    return 0;
}

-(IBAction)dismissKeyboard:(id)sender {
    [sender becomeFirstResponder];
    [sender resignFirstResponder];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ( section == 0 ) {
        return @"Account Settings";
    } else if ( section == 1) {
        return @"Profile Settings";
    }
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if ( indexPath.section == 0 ){
        cell = [tableView dequeueReusableCellWithIdentifier:[self.accountSection objectAtIndex:indexPath.row] forIndexPath:indexPath];
    } else if (indexPath.section == 1 ){
        cell = [tableView dequeueReusableCellWithIdentifier:[self.profileSection objectAtIndex:indexPath.row] forIndexPath:indexPath];
    }

    
    return cell;
}

@end
