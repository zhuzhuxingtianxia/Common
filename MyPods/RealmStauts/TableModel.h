//
//  TableModel.h
//  MyPods
//
//  Created by Jion on 2017/6/29.
//  Copyright © 2017年 Youjuke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm.h>

@interface TableModel : RLMObject

@property NSString *Id;//订单ID
@property NSString *name;//业主姓名
@property NSString *sign_time;//签约时间
@property NSString *address;//地址
@property NSString *reviewed_status;//审核状态
//以下是收款记录
@property NSString *pay_type;//支付类型  0.签约奖励 1.托管奖励定金 2.托管奖励尾款

@end
