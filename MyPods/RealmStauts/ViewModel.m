//
//  ViewModel.m
//  MyPods
//
//  Created by Jion on 2017/6/29.
//  Copyright © 2017年 Youjuke. All rights reserved.
//

#import "ViewModel.h"
#import "MBProgressHUD.h"
#import "TableModel.h"

@interface ViewModel()
@property(nonatomic,strong)MBProgressHUD *hud;
@property(nonatomic,strong)void (^dataBlock)(NSArray *dataArray);
@end
@implementation ViewModel

-(instancetype)initWithCallBlock:(void (^)(NSArray *dataArray))dataBlock{
    self = [super init];
    if (self) {
        self.dataBlock = dataBlock;
        [self loadDataServer];
    }
    return self;
};

-(void)loadDataServer{
    
    [self.hud show:YES];
    
    RLMResults *resulrs = [TableModel allObjects];
    if (resulrs.count>0) {
        NSLog(@"%@",resulrs);
        self.dataBlock((NSArray*)resulrs);
    }
    
   NSString *path = [[NSBundle mainBundle] pathForResource:@"DataSoure" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:path];
    
   id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([json isKindOfClass:[NSDictionary class]]) {
            if ([json[@"status"] integerValue] == 200) {
                [self.hud hide:YES];
                
                NSArray *array = json[@"data"];
                
                NSArray *modelArray = [TableModel objectArrayWithKeyValuesArray:array];
                
                self.dataBlock(modelArray);
                
                RLMRealm *realm = [RLMRealm defaultRealm];
                [realm transactionWithBlock:^{
                    /*
                    //防止数据重复先清空数据库,
                    [realm deleteAllObjects];
                     [realm addObjects:modelArray];
                     */
                    //另一种方式是设置主键
                    [realm addOrUpdateObjectsFromArray:modelArray];
                    
                }];
                
                
                //异步添加到数据库
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_async(queue, ^{
                    
                    
                });
                
            }else{
                self.dataBlock(nil);
            }
            
        }else{
            @throw @"解析有误";
        }
        
    });
}

-(MBProgressHUD*)hud{
    if (!_hud) {
        UIWindow *keyWin = [[UIApplication sharedApplication] keyWindow];
        _hud = [[MBProgressHUD alloc ] initWithWindow:keyWin];
        _hud.mode = MBProgressHUDModeIndeterminate;
        _hud.removeFromSuperViewOnHide = YES;
        [keyWin addSubview:_hud];
    }
    return _hud;
}

@end
