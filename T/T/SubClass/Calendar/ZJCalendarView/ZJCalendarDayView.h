//
//  ZJCalendarDayView.h
//  T
//
//  Created by Jion on 15/11/11.
//  Copyright © 2015年 Youjuke. All rights reserved.
//

#import <UIKit/UIKit.h>
enum {
    DSLCalendarDayViewNotSelected = 0,
    DSLCalendarDayViewWholeSelection,
    DSLCalendarDayViewStartOfSelection,
    DSLCalendarDayViewWithinSelection,
    DSLCalendarDayViewEndOfSelection,
} typedef DSLCalendarDayViewSelectionState;

enum {
    DSLCalendarDayViewStartOfWeek = 0,
    DSLCalendarDayViewMidWeek,
    DSLCalendarDayViewEndOfWeek,
} typedef DSLCalendarDayViewPositionInWeek;

@interface ZJCalendarDayView : UIView

@property (nonatomic, copy) NSDateComponents *day;
@property (nonatomic, assign) DSLCalendarDayViewPositionInWeek positionInWeek;
@property (nonatomic, assign) DSLCalendarDayViewSelectionState selectionState;
@property (nonatomic, assign, getter = isInCurrentMonth) BOOL inCurrentMonth;

@property (nonatomic, strong, readonly) NSDate *dayAsDate;

@end
