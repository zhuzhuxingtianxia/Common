//
//  ModifyStateController.h
//  MyPods
//
//  Created by Jion on 2017/6/30.
//  Copyright © 2017年 Youjuke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableModel.h"
@interface ModifyStateController : UIViewController
@property(nonatomic,strong)TableModel  *model;
@property(nonatomic,strong)void(^block)();
@end
