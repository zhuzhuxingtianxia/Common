//
//  TableModel.m
//  MyPods
//
//  Created by Jion on 2017/6/29.
//  Copyright © 2017年 Youjuke. All rights reserved.
//

#import "TableModel.h"

@implementation TableModel

+ (NSDictionary *)replacedKeyFromPropertyName{
    
    return @{@"Id":@"id"};
}
//一般来说,属性为nil的话realm会抛出异常,但是如果实现了这个方法的话,就只有name为nil会抛出异常
+ (NSArray *)requiredProperties {
    return @[@"name"];
}
//设置主键
+(NSString*)primaryKey{
    return @"Id";
}

@end
