//
//  GetInvolvedViewController.m
//  Savoy Swing
//
//  Created by Stevenson on 12/24/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "GetInvolvedViewController.h"

@interface GetInvolvedViewController () <UITableViewDataSource, UITableViewDelegate> {
    NSArray *identifierNames;
    NSArray *cellLinks;
}

@property (weak, nonatomic) IBOutlet UITableView *theTableView;

@end

@implementation GetInvolvedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;
    identifierNames = @[@"CommunityInvolvement",@"EducationInvolvement",@"SavoyMondaysInvolvement",@"DonateInvolvement"];
    cellLinks = @[@"https://www.savoyswing.org",
                  @"https://www.savoyswing.org",
                  @"https://www.savoyswing.org",
                  @"https://www.savoyswing.org"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark UITableViewDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *theURL = [cellLinks objectAtIndex:indexPath.section];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:theURL]];
    [self.theTableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark UITableViewDataSource
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.theTableView dequeueReusableCellWithIdentifier:[identifierNames objectAtIndex:indexPath.section]];
    
    return cell;
}

@end
