//
//  RouteConstants.h
//  Tuhu
//
//  Created by 丁帅 on 16/9/27.
//  Copyright © 2016年 Tuhu. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#ifndef RouteConstants_h
#define RouteConstants_h

// MARK: 检查条件

/**
 * Router 的 跳转方式
 */
typedef NS_ENUM(NSUInteger, THRouteStyle) {
    THRouteStylePush,
    THRouteStylePresent,
    THRouteStyleTab,
    THRouteStyleSpecial,
};

/**
 * Router 的 跳转检查项
 */
typedef NS_OPTIONS(NSUInteger, THRouteOption) {
    THRouteOptionNone                             = 0,
    THRouteOptionLogin                             = 1 << 0,
    THRouteOptionCarBase                       = 1 << 1,
    THRouteOptionCarFull                          = 1 << 2 | 1 << 1,
    THRouteOptionCarFullWithTID            = 1 << 3 | 1 << 2 | 1 << 1,
    THRouteOptionCarTire                         = 1 << 4 | 1 << 1,
    THRouteOptionCarWheel                     = 1 << 5 | 1 << 1,
    THRouteOptionAll                                  = 0xFF,
};

/**
 * 支持Router的类型要实现此协议
 */
@protocol THRouteSupport <NSObject>
@optional

/**
 * 外部URL跳转时的参数列表映射，格式为 ["URL中的Key" : "属性名"]
 */
+ (nonnull NSDictionary<NSString *, NSString *> *)routeParamMap;

/**
 * 返回实例的方法， 如果不实现，则使用默认的KVC方式创建实例
 */
+ (nonnull UIViewController<THRouteSupport> *)routeViewControllerWithURI:(nonnull NSString *)URI  params:(nullable NSDictionary<NSString *, id>  *)params;

/**
 * 特殊跳转时被调用
 */
+ (void)specialRouteWithURI:(nonnull NSString *)URI  params:(nullable NSDictionary<NSString *, id>  *)param style:(THRouteStyle)style option:(THRouteOption)option;

@end

#endif /* RouteConstants_h */
