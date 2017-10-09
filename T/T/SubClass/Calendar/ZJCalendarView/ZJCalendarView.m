//
//  ZJCalendarView.m
//  T
//
//  Created by Jion on 15/11/9.
//  Copyright © 2015年 Youjuke. All rights reserved.
//

#import "ZJCalendarView.h"
#import "ZJWeeksView.h"
#import "ZJCalendarMonthView.h"
//尺寸
#define zScreenHeight [[UIScreen mainScreen] bounds].size.height

#define zScreenWidth [[UIScreen mainScreen] bounds].size.width

@interface ZJCalendarView()
{
    CGFloat _dayViewHeight;
    NSDateComponents *_visibleMonth;
}
@property (nonatomic, strong) NSMutableDictionary *monthViews;
@property (nonatomic, strong) UIView *monthContainerView;
@property (nonatomic, strong) UIView *monthContainerViewContentView;
@end

@implementation ZJCalendarView

// Designated initialisers
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self commonInit];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit{
    _dayViewHeight = 44;
    _visibleMonth = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitCalendar fromDate:[NSDate date]];
    

    ZJWeeksView *weeksView = [ZJWeeksView view:CGRectMake(0, 0, self.frame.size.width, 40)];
    [self addSubview:weeksView];
  /*--------------------------------------------*/
    // Month views are contained in a content view inside a container view - like a scroll view, but not a scroll view so we can have proper control over animations.意思是把月份视图放在一个容器里，像scrollview但又不是，方便我们控制。
    CGRect frame = self.bounds;
    frame.origin.x = 0;
    frame.origin.y = CGRectGetMaxY(weeksView.frame);
    frame.size.height -= frame.origin.y;
    self.monthContainerView = [[UIView alloc] initWithFrame:frame];
    self.monthContainerView.clipsToBounds = YES;
    [self addSubview:self.monthContainerView];
    
    self.monthContainerViewContentView = [[UIView alloc] initWithFrame:self.monthContainerView.bounds];
    [self.monthContainerView addSubview:self.monthContainerViewContentView];
    
    self.monthViews = [[NSMutableDictionary alloc] init];
    
    [self positionViewsForMonth:_visibleMonth fromMonth:_visibleMonth animated:NO];
}

#pragma mark-- 对月份组件做滑动处理
- (void)positionViewsForMonth:(NSDateComponents*)month fromMonth:(NSDateComponents*)fromMonth animated:(BOOL)animated {
    fromMonth = [fromMonth copy];
    month = [month copy];
    
    CGFloat nextVerticalPosition = 0;
    CGFloat startingVerticalPostion = 0;
    CGFloat restingVerticalPosition = 0;
    CGFloat restingHeight = 0;
    
    //日期比较
    NSComparisonResult monthComparisonResult = [month.date compare:fromMonth.date];
    //设置动画时间
    NSTimeInterval animationDuration = (monthComparisonResult == NSOrderedSame || !animated) ? 0.0 : 0.5;
    NSMutableArray *activeMonthViews = [[NSMutableArray alloc] init];
    
    //Create and position the month views for the target month and those around it
    for (NSInteger montOffset = -2; montOffset <= 2; montOffset ++) {
        NSDateComponents *offsetMonth = [month copy];
        offsetMonth.month = offsetMonth.month + montOffset;
        offsetMonth = [offsetMonth.calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitCalendar fromDate: offsetMonth.date];
        
        //检查本月是不是与上个月折叠
        if (![self monthStartsOnFirstDayOfWeek:offsetMonth]) {
            nextVerticalPosition -= _dayViewHeight;
        }
        
        //创建并设置当前月的位置
        ZJCalendarMonthView *monthView = [self cachedOrCreatedMonthViewForMonth:offsetMonth];
        [activeMonthViews addObject:monthView];
        //把月份视图放在父视图之上
        [monthView.superview bringSubviewToFront:monthView];
        
        //重置frame还没有懂？？
        CGRect frame = monthView.frame;
        frame.origin.y = nextVerticalPosition;
        nextVerticalPosition += frame.size.height;
        monthView.frame = frame;
        
        //检查是否动画偏移
        if (montOffset == 0) {
            //中间月，以中间月为基准滑动
            restingVerticalPosition = monthView.frame.origin.y;
            restingHeight += monthView.bounds.size.height;
        }
        else if (montOffset == 1 && monthComparisonResult == NSOrderedAscending)
        {
          //获取后一个月的视图位置
            startingVerticalPostion = monthView.frame.origin.y;
            
            if ([self monthStartsOnFirstDayOfWeek:offsetMonth]) {
                startingVerticalPostion -= _dayViewHeight;
                
            }
        }
        else if (montOffset == -1 && monthComparisonResult == NSOrderedDescending)
        {
            //获取前一个月的视图位置
            startingVerticalPostion = monthView.frame.origin.y;
            
            if ([self monthStartsOnFirstDayOfWeek:offsetMonth]) {
                
                startingVerticalPostion -= _dayViewHeight;
            }
        }
        
        //检查月份的开始是不是周天的开始
        if (montOffset == 0 && [self monthStartsOnFirstDayOfWeek:offsetMonth]) {
            //如果当前月的开始是一周的开始，前一个月视图增加一个高度
            restingVerticalPosition -= _dayViewHeight;
            restingHeight  += _dayViewHeight;
        }
        else if (montOffset == 1 && [self monthStartsOnFirstDayOfWeek:offsetMonth]){
            
            restingHeight += _dayViewHeight;
        }
        
    }
    
    //设置父视图frame
    CGRect frame = self.monthContainerViewContentView.frame;
    frame.size.height = CGRectGetMaxY([[activeMonthViews lastObject] frame]);
    self.monthContainerViewContentView.frame = frame;
    
    //移除之前不再需要的月份
    NSArray *monthViewKeyes = self.monthViews.allKeys;
    for (NSString *key in monthViewKeyes) {
        UIView *monthView = [self.monthViews objectForKey:key];
        if (![activeMonthViews containsObject:monthView]) {
            [monthView removeFromSuperview];
            [self.monthViews removeObjectForKey:key];
        }
    }
    //展示视图
    if (monthComparisonResult != NSOrderedSame) {
        CGRect frame = self.monthContainerViewContentView.frame;
        frame.origin.y = -startingVerticalPostion;
        self.monthContainerViewContentView.frame = frame;
    }
    

}

//判断本周的第一天是否为本月第一天
- (BOOL)monthStartsOnFirstDayOfWeek:(NSDateComponents*)month
{
    month = [month.calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitCalendar fromDate:month.date];
    //weekday = 1~7,fistWeekday = 1
    return (month.weekday - month.calendar.firstWeekday == 0);
}

//创建月份视图
- (ZJCalendarMonthView*)cachedOrCreatedMonthViewForMonth:(NSDateComponents*)month
{
    month = [month.calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitCalendar fromDate:month.date];
    ZJCalendarMonthView *monthView = [[ZJCalendarMonthView alloc] init];
    monthView.frame = self.monthContainerViewContentView.frame;
    monthView.backgroundColor = [self randColor];
     [self.monthContainerViewContentView addSubview:monthView];
    return monthView;
}

//随机色
- (UIColor*)randColor
{
    CGFloat r = arc4random_uniform(256);
    CGFloat g = arc4random_uniform(256);
    CGFloat b = arc4random_uniform(256);
    
    //    return WNXColor(r, g, b);分类中不要用宏，便于分类的复用性
    return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1];
}

@end
