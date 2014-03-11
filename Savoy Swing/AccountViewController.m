//
//  AccountTableViewController.m
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/18/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "AccountViewController.h"

@interface AccountViewController() <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *accountSection;
@property (nonatomic, strong) NSArray *profileSection;
@property (nonatomic, weak) IBOutlet UITableView *theTableView;

-(IBAction)dismissKeyboard:(id)sender;

@end

@implementation AccountViewController


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.accountSection =@[@"username",@"status",@"exp_date",@"email"];
    self.profileSection = @[@"name",@"add1",@"add2",@"city",@"state",@"zip",@"phone"];
}

-(void)viewDidAppear:(BOOL)animated  {
    [super viewDidAppear:animated];
    [self.theTableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;
    
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
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
    NSString *data = @"";
    if ( indexPath.section == 0 ){
        cell = [self.theTableView dequeueReusableCellWithIdentifier:[self.accountSection objectAtIndex:indexPath.row] forIndexPath:indexPath];
        data = [theAppDel.user objectForKey:[self.accountSection objectAtIndex:indexPath.row]];
    } else if (indexPath.section == 1 ){
        cell = [self.theTableView dequeueReusableCellWithIdentifier:[self.profileSection objectAtIndex:indexPath.row] forIndexPath:indexPath];
        data = [theAppDel.user objectForKey:[self.profileSection objectAtIndex:indexPath.row]];
    }
    UILabel *readOnlyData = (UILabel*)[cell viewWithTag:101];
    readOnlyData.text = data;

    
    return cell;
}

@end
