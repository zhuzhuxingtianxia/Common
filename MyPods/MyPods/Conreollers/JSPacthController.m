//
//  JSPacthController.m
//  MyPods
//
//  Created by Jion on 2017/8/29.
//  Copyright © 2017年 Youjuke. All rights reserved.
//

#import "JSPacthController.h"
#import "JSPatchCode.h"
@interface JSPacthController ()

@end

@implementation JSPacthController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //学习脚本下发
    [self showJSPacth];
}
-(void)showJSPacth{
    [self bulidView];
}
-(void)bulidView{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.bounds = CGRectMake(0, 0, 80, 40);
    btn.center = self.view.center;
    [btn setTitle:@"下发js脚本" forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(jsScriptRun:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}
-(void)jsScriptRun:(id)sender{
    
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
