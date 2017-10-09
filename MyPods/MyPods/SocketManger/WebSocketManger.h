//
//  WebSocketManger.h
//  MyPods
//
//  Created by Jion on 2017/3/16.
//  Copyright © 2017年 Youjuke. All rights reserved.
//http://www.cocoachina.com/ios/20170110/18544.html

#import <Foundation/Foundation.h>
typedef enum : NSUInteger {
    disConnectByUser ,
    disConnectByServer,
} DisConnectType;

@interface WebSocketManger : NSObject
+ (instancetype)share;

- (void)connect;
- (void)disConnect;

- (void)sendMsg:(NSString *)msg;

- (void)ping;

@end
