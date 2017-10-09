//
//  ZJCalendarDayView.m
//  T
//
//  Created by Jion on 15/11/11.
//  Copyright © 2015年 Youjuke. All rights reserved.
//

#import "ZJCalendarDayView.h"

@implementation ZJCalendarDayView
{
    __strong NSCalendar *_calendar;
    __strong NSDate *_dayAsDate;
    __strong NSDateComponents *_day;
    __strong NSString *_labelText;
}


- (id)initWithFrame:(CGRect)frame 
{
   self = [super initWithFrame:frame];
    if (self!=nil) {
       _labelText = @"11";
        [self loadCell];
    }
    return self;
}

- (void)loadCell
{
     _positionInWeek = DSLCalendarDayViewMidWeek;
    UIFont *textFont = [UIFont boldSystemFontOfSize:17.0];
    CGSize textSize = [_labelText sizeWithAttributes:@{NSFontAttributeName:textFont}];
    
    CGRect textRect = CGRectMake(ceilf(CGRectGetMidX(self.bounds) - (textSize.width / 2.0)), ceilf(CGRectGetMidY(self.bounds) - (textSize.height / 2.0)), textSize.width, textSize.height);
    [_labelText drawInRect:textRect withAttributes:@{NSFontAttributeName:textFont}];
}

- (id)label{
    UILabel *label = [[UILabel alloc] init];
    label.bounds = CGRectMake(0, 0, self.frame.size.width, 30);
    
    
    return label;
}
@end
