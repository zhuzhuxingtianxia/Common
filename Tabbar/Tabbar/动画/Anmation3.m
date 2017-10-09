//
//  Anmation3.m
//  Tabbar
//
//  Created by Jion on 15/10/30.
//  Copyright © 2015年 Youjuke. All rights reserved.
//

#import "Anmation3.h"

@interface Anmation3 ()
@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@end

@implementation Anmation3

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
}

- (IBAction)setCulUp:(id)sender {
    //UIViewAnimationTransitionFlipFromLeft, 向左转动
    //UIViewAnimationTransitionFlipFromRight, 向右转动
    //UIViewAnimationTransitionCurlUp, 向上翻动
    //UIViewAnimationTransitionCurlDown, 向下翻动
    
    [UIView beginAnimations:@"animationID" context:nil];
    [UIView setAnimationDuration:2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationRepeatAutoreverses:YES];
     static BOOL isLR = YES;
    if (isLR) {
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.imgView cache:YES];
    }else
    {
       [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.imgView cache:YES];
    }
    
    isLR = !isLR;
    [UIView commitAnimations];
}
- (IBAction)setFlipFeftOrRight:(id)sender {
    
    //开始动画
    [UIView beginAnimations:@"doflip" context:nil];
    //设置时常
    [UIView setAnimationDuration:1];
    //设置动画淡入淡出
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    //设置代理
    [UIView setAnimationDelegate:self];
    //设置翻转方向
    static BOOL isLR = YES;
    
    if (isLR) {
        [UIView setAnimationTransition:
         UIViewAnimationTransitionFlipFromLeft  forView:_imgView cache:YES];
    }else{
        [UIView setAnimationTransition:
         UIViewAnimationTransitionFlipFromRight  forView:_imgView cache:YES];
    }
    isLR = !isLR;
    //动画结束
    [UIView commitAnimations];
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
