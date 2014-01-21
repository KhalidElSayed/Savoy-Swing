//
// DemoTableHeaderView.m
//
// @author Shiki
//

#import "NewsFeedHeaderView.h"

@interface NewsFeedHeaderView()

@end

@implementation NewsFeedHeaderView

@synthesize title;
@synthesize activityIndicator;

- (void) awakeFromNib
{
  self.backgroundColor = [UIColor clearColor];
  [super awakeFromNib];
}

@end
