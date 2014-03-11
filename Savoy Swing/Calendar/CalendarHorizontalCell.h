//
//  CalendarHorizontalCell.h
//  Savoy Swing
//
//  Created by Stevenson on 12/14/13.
//  Copyright (c) 2013 Steven Stevenson. All rights reserved.
//

#import "HorizontalTableViewCell.h"

#pragma mark - HorizontalCellDelegate Protocol
@protocol HorizontalCellDelegate <NSObject>
- (void)updateMainTable:(NSMutableArray*) theDates withIndex: (NSInteger)index;
@end


@interface CalendarHorizontalCell : HorizontalTableViewCell

@property (nonatomic, weak) id<HorizontalCellDelegate> delegate;

-(void) prepCalendarCells;
@end
