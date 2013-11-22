//
//  NewsFeedSettingsViewController.m
//  Savoy Swing
//
//  Created by Steven Stevenson on 11/19/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "NewsFeedSettingsViewController.h"

@interface NewsFeedSettingsViewController ()

@end

@implementation NewsFeedSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _facebookSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(251.0f, 6.0f, 51.0f, 31.0f)];
    _facebookSwitch.on = _theAppDel.newsFeedFacebookActive;

    _twitterSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(251.0f, 6.0f, 51.0f, 31.0f)];
    _twitterSwitch.on = _theAppDel.newsFeedTwitterActive;
}

-(void) viewWillDisappear:(BOOL)animated {
    if (_facebookSwitch.on != _theAppDel.newsFeedFacebookActive ){
        _theAppDel.newsFeedFacebookActive = _facebookSwitch.on;
        _theAppDel.newsFeedCells = nil;
    }
    if (_twitterSwitch.on != _theAppDel.newsFeedTwitterActive ){
        _theAppDel.newsFeedCells = nil;
        _theAppDel.newsFeedTwitterActive = _twitterSwitch.on;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    NSString *CellIdentifier = @"Cell";
    if (indexPath.section == 0 && indexPath.row == 0 ) {
        CellIdentifier = @"tsc";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        [_twitterSwitch addTarget:self action:nil forControlEvents:UIControlEventValueChanged];
        [cell addSubview:_twitterSwitch];
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        CellIdentifier = @"fsc";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        [_facebookSwitch addTarget:self action:nil forControlEvents:UIControlEventValueChanged];
        [cell addSubview:_facebookSwitch];
    }
    return cell;
}


@end
