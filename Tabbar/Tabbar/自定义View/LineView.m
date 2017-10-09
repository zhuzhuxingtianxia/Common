//
//  LineView.m
//  Tabbar
//
//  Created by Jion on 15/10/28.
//  Copyright © 2015年 Youjuke. All rights reserved.
//
#define r1  (arc4random_uniform(256)/255.0)
#define g1  (arc4random_uniform(256)/255.0)
#define b1  (arc4random_uniform(256)/255.0)
#define arcColor [UIColor colorWithRed:r1 green:g1  blue:b1  alpha:0.8]
#define alColor(x) [UIColor colorWithRed:r1 green:g1  blue:b1  alpha:x]

#import "LineView.h"

@implementation LineView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    switch ((arc4random()%4)) {
        case 0:
             [self draw1:rect];
            break;
        case 1:
             [self draw2:rect];
            break;

        case 2:
             [self draw3:rect];
            break;

        case 3:
             [self draw4:rect];
            break;

            
        default:
            break;
    }
    
   
}

/*
  画圆
 */
- (void)draw1:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [arcColor set];
    CGContextFillRect(context, rect);
    
    CGContextAddEllipseInRect(context, rect);
    [arcColor set];
    CGContextFillPath(context);
}

/*
 边框圆
 */
- (void)draw2:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetRGBStrokeColor(context, r1, g1, b1, 1.0);
    CGContextSetLineWidth(context, 10);
    //参数说明：一获取上下文，二三圆心坐标，四半径，五六开始/结束的角度，七绘制方向（1顺时针0逆时针）
    CGContextAddArc(context, rect.size.width/2, rect.size.height/2, rect.size.height/2 - 10, 0, 2*M_PI, 0);
    
    CGContextDrawPath(context, kCGPathStroke);
}
/*
 画折线
 */
- (void)draw3:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [arcColor set];
    CGContextFillRect(context, rect);
    
    CGContextSetLineWidth(context, 2);
    [arcColor set];
    NSUInteger random = arc4random()%10+10;
    CGPoint points[random+1];
    for (NSUInteger i=0; i<random+1; i++) {
        points[i] = CGPointMake(i*(rect.size.width/random), arc4random()%100 + 50);
        
    }
    CGContextAddLines(context, points, random+1);
    CGContextDrawPath(context, kCGPathStroke);
    
    //边框圆
    CGContextSetLineWidth(context, 4);
     [alColor(0.3) set];
    CGContextAddArc(context, rect.size.width/2, rect.size.height/2, rect.size.width/2 - 2, 0, 2*M_PI, 1);
    CGContextDrawPath(context, kCGPathStroke);
}

/*
 曲线,采用贝塞尔曲线算法。
 Bezier曲线，中间两对参数为控制点,曲线并不经过控制点。
 与抛物线不同，抛物线是将点用平滑的曲线连接起来，点在线上。
 */
- (void)draw4:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor redColor] set];
    CGContextSetLineWidth(context, 4.0);
    
    CGContextSetStrokeColorWithColor(context, [arcColor CGColor]);
    //起始点
    CGContextMoveToPoint(context, 0, rect.size.height/2);
    //设置Bezier曲线，添加控制点。
    //两个控制点定义了曲线的几何形状。如果两个控制点都在起点和终点的下 面，则则曲线向上供。如果第二个控制点相比第一个控制点更接近起点，则曲线会构成一个循环.
    CGContextAddCurveToPoint(context, rect.size.width/3, 10, rect.size.width*2/3, 2*rect.size.height, rect.size.width, 10);
    
    CGContextStrokePath(context);
}

@end
