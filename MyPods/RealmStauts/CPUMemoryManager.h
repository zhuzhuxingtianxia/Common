//
//  CPUMemoryManager.h
//  MyPods
//
//  Created by Jion on 2017/6/30.
//  Copyright © 2017年 Youjuke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPUMemoryManager : NSObject
+(instancetype)sharedCPUMemoryManager;

//获得 App 的 CPU 占用率的方法
- (float)cpu_usage;
//下面是 GT 中获得 App 的 CPU 占用率的方法
- (float)getCpuUsage;
//获取当前 App Memory 的使用情况
- (NSUInteger)getResidentMemory;

//获取内网ip地址
+ (NSString *)getIPAddress;
//获取公网ip
+(NSString*)getPublicIPAddress;
@end
