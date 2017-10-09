//
//  UserModel.m
//  MyPods
//
//  Created by Jion on 2017/6/23.
//  Copyright © 2017年 Youjuke. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

-(instancetype)init{
    self = [super init];
    if (self) {
        _Id = [[NSUUID UUID] UUIDString];
    }
    
    return self;
}

-(instancetype)initWithValue:(id)value{
    self = [super initWithValue:value];
    if (self) {
        _Id = [[NSUUID UUID] UUIDString];
    }
    return self;
}

//设置主键
+ (NSString *)primaryKey {
    return @"Id";
}

//设置忽略属性
+ (NSArray *)ignoredProperties {
    return @[@"tmpID"];
}

/*
// 主键
+ (NSString *)primaryKey {
    return @"ID";
}
//设置属性默认值
+ (NSDictionary *)defaultPropertyValues{
    return @{@"carName":@"测试" };
}
//设置忽略属性,即不存到realm数据库中
+ (NSArray *)ignoredProperties {
    return @[@"ID"];
}
//一般来说,属性为nil的话realm会抛出异常,但是如果实现了这个方法的话,就只有name为nil会抛出异常,也就是说现在cover属性可以为空了
+ (NSArray *)requiredProperties {
    return @[@"name"];
}
//设置索引,可以加快检索的速度
+ (NSArray *)indexedProperties {
    return @[@"ID"];
}
 
 */

@end

//==================
@implementation Dog
+ (NSDictionary *)linkingObjectsProperties
{
    // Define "owners" as the inverse relationship to Person.dogs
    return @{ @"owners": [RLMPropertyDescriptor descriptorWithClass:UserModel.class propertyName:@"dogs"] };
}
@end


