//
//  CoSocketManger.h
//  MyPods
//
//  Created by Jion on 2017/3/16.
//  Copyright © 2017年 Youjuke. All rights reserved.
//http://www.cocoachina.com/ios/20170110/18544.html

#import <Foundation/Foundation.h>

@interface CoSocketManger : NSObject
+ (instancetype)share;

- (BOOL)connect;
- (void)disConnect;

- (void)sendMsg:(NSString *)msg;
- (void)pullTheMsg;

@end
