//
//  GetInvolvedViewController.h
//  Savoy Swing
//
//  Created by Stevenson on 12/24/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GetInvolvedViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSArray *identifierNames;
    NSArray *cellLinks;
}

@property (strong, nonatomic) IBOutlet UITableView *theTableView;

@end