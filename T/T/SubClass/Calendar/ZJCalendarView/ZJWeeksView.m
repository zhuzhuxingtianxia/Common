//
//  ZJWeeksView.m
//  T
//
//  Created by Jion on 15/11/11.
//  Copyright © 2015年 Youjuke. All rights reserved.
//

#import "ZJWeeksView.h"
@interface ZJWeeksView()
@property (nonatomic,strong)NSMutableArray<UILabel *> *weeks;
@end

@implementation ZJWeeksView


+ (id)view:(CGRect)rect {
    static UIView *view;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        view = [[self alloc] initWithFrame:rect];
        
    });
    return view;
}
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        // Initialise properties
     NSArray *weekNames = @[@"周日",@"周一",@"周二",@"周三",@"周四",@"周五",@"周六"];
        CGFloat W = frame.size.width/weekNames.count;
        CGFloat H = frame.size.height;
        for (int i=0;i<weekNames.count;i++) {
            CGFloat x = i*W;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, W, H)];
            
            label.text = weekNames[i];
            label.textAlignment = NSTextAlignmentCenter;
            label.layer.borderWidth=1;
            label.layer.borderColor = [[UIColor grayColor]CGColor];
            label.font = [UIFont boldSystemFontOfSize:16];
            if (i != 0 && i != weekNames.count-1) {
                label.textColor = [UIColor blackColor];
            }
            else
            {
               label.textColor = [UIColor redColor];
            }
            
            [self addSubview:label];
           
        }

    }
    
    return self;
}

@end
