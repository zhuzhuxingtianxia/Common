//
//  ViewModel.h
//  MyPods
//
//  Created by Jion on 2017/6/29.
//  Copyright © 2017年 Youjuke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJExtension.h"

@interface ViewModel : NSObject

-(instancetype)initWithCallBlock:(void (^)(NSArray *dataArray))dataBlock;

@end
