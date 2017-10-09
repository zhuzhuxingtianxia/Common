//
//  BageButtonController.m
//  MyPods
//
//  Created by Jion on 2017/8/30.
//  Copyright © 2017年 Youjuke. All rights reserved.
//

#import "BageButtonController.h"
#import "UpImageDownTextBageButton.h"

@interface BageButtonController ()

@end

@implementation BageButtonController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //自定义控件
    [self upImageDownTextBageButtonTest];
}
-(void)upImageDownTextBageButtonTest{
    UpImageDownTextBageButton *btn = [[UpImageDownTextBageButton alloc] initWithFrame:CGRectMake(30, 150, 60, 60) Title:@"我的订单" ImageName:@"order.png" Badge:@"20"];
    btn.tag = 888;
    btn.actionClick = ^(UIButton *sender){
        NSInteger arcInteger = arc4random()%100;
        UpImageDownTextBageButton *send = (UpImageDownTextBageButton*)sender;
        send.badgeValue = [NSString stringWithFormat:@"%ld",arcInteger];
        NSLog(@"%ld",sender.tag);
        
    };
    [self.view addSubview:btn];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
