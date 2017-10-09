//
//  VersionCheck.h
//  ZJP
//
//  Created by Jion on 15/9/9.
//  Copyright (c) 2015年 Youjuke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VersionCheck : UIView

/*
 在appdelegeate里调用
 第一个参数传入window
 第二个参数传入应用的ID号
 */
+ (void)updateVisonWithWindow:(UIWindow*)window AppId:(NSString*)appId;

@end
