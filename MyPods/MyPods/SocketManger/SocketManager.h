//
//  SocketManager.h
//  MyPods
//
//  Created by Jion on 2017/3/15.
//  Copyright © 2017年 Youjuke. All rights reserved.
//http://www.cocoachina.com/ios/20170110/18544.html 

#import <Foundation/Foundation.h>

@interface SocketManager : NSObject
@property(nonatomic,copy)NSString *rev_message;
+ (instancetype)share;
- (void)connect;
- (void)disConnect;
- (void)sendMsg:(NSString *)msg;

@end
