//
//  ZJElasticHead.m
//  Tabbar
//
//  Created by Jion on 15/10/27.
//  Copyright © 2015年 Youjuke. All rights reserved.
//

#import "ZJElasticHead.h"

@implementation ZJElasticHead


+(instancetype)shareElasticHead{
    ZJElasticHead *elasticHead = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil].lastObject;
    return elasticHead;
}

- (void)setOffsetY:(CGFloat)offsetY
{
    
    _offsetY = offsetY;
    /*  
     分清图层关系是关键所在，这里面有三个图层，imgView添加在View上,View添加在self上
     */
    //获取imgView的父视图
    UIView *supView = _imgView.superview;
    CGRect frame = supView.frame;
    if (offsetY < 0) {
        //向下拉伸，偏移量发生改变。动态改变imgView的父视图的y坐标
        frame.origin.y = offsetY;
        //根据偏移的距离，改变父视图高度。
        //self的高度不变，父视图高度 = 偏移量 + self高度。supView.superview = self.
        frame.size.height = -offsetY + supView.superview.frame.size.height;
        //重新设置supView的frame.
        supView.frame = frame;
        
        //重新设置imgView的center
        CGPoint center = _imgView.center;
        center.y = supView.frame.size.height/2;
        
        _imgView.center = center;
        //注：出现下拉，img不能铺满，设置img的size.height更大些。
    }
    else{
        if(frame.origin.y != 0)
        {
            frame.origin.y = 0;
            frame.size.height =supView.superview.frame.size.height;
            supView.frame = frame;
        }
        if(offsetY<frame.size.height)
        {
            CGPoint center =  _imgView.center;
            center.y = supView.frame.size.height/2 + 0.5*offsetY;
            _imgView.center = center;
        }

        
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
