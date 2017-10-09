//
//  AutolayoutController.m
//  MyPods
//
//  Created by Jion on 2017/8/29.
//  Copyright © 2017年 Youjuke. All rights reserved.
//

#import "AutolayoutController.h"

@interface AutolayoutController ()

@end

@implementation AutolayoutController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //Autolayout系统约束学习
    [self learnAutolayout];
}
-(void)learnAutolayout{
    UILabel *v1 = [[UILabel alloc] initWithFrame:CGRectZero];
    v1.translatesAutoresizingMaskIntoConstraints = NO;
    v1.backgroundColor = [UIColor redColor];
    [self.view addSubview:v1];
    
    UILabel *v2 = [[UILabel alloc] initWithFrame:CGRectZero];
    v2.backgroundColor = [UIColor grayColor];
    v2.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:v2];
    
    UILabel *v3 = [[UILabel alloc] initWithFrame:CGRectZero];
    v3.backgroundColor = [UIColor yellowColor];
    v3.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:v3];
    v1.text = @"这只是一个用来测试";
    v2.text = @"测试的东西而已";
    v3.text = @"这只是东西而已";
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[v1(>=50)][v2(>=50)][v3(>=50)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(v1,v2,v3)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-200-[v1(40)]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(v1)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-200-[v2(40)]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(v2)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-200-[v3(40)]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(v3)]];
    
    /*
     [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[v1]-|"options:0 metrics:nil views:NSDictionaryOfVariableBindings(v1)]];
     [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[v2]-|"options:0 metrics:nil views:NSDictionaryOfVariableBindings(v2)]];
     
     
     [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[v1][v2(==v1)]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(v1,v2)]];
     */
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
