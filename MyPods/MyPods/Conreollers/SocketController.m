//
//  SocketController.m
//  MyPods
//
//  Created by Jion on 2017/8/29.
//  Copyright © 2017年 Youjuke. All rights reserved.
//

#import "SocketController.h"
#import "SocketManager.h"
#import "CoSocketManger.h"
#import "WebSocketManger.h"

@interface SocketController ()<UITextFieldDelegate>

@end

@implementation SocketController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self socketLearn];
}
-(void)socketLearn{
    UITextField *field = [UITextField new];
    field.translatesAutoresizingMaskIntoConstraints = NO;
    field.borderStyle = UITextBorderStyleRoundedRect;
    field.delegate = self;
    field.returnKeyType = UIReturnKeySend;
    field.placeholder = @"输入内容";
    [self.view addSubview:field];
    
    UILabel *textLabe= [[UILabel alloc] init];
    textLabe.translatesAutoresizingMaskIntoConstraints = NO;
    textLabe.layer.masksToBounds = YES;
    textLabe.tag = 214;
    
    [self.view addSubview:textLabe];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[field]-20-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(field)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[textLabe]-20-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(textLabe)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-120-[field(==30)]-20-[textLabe(==30)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(field,textLabe)]];
    
    
    //[[SocketManager share] addObserver:self forKeyPath:@"rev_message" options:NSKeyValueObservingOptionNew context:nil];
    [[WebSocketManger share] connect];
}
#pragma mark --UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    //[[SocketManager share] sendMsg:textField.text];
    //[[CoSocketManger share] sendMsg:textField.text];
    [[WebSocketManger share] sendMsg:textField.text];
    
    [textField endEditing:YES];
    return YES;
}

#pragma mark --Observer
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"rev_message"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CATransition *flipTransition = [CATransition animation];
            flipTransition.duration = 0.5f ;
            flipTransition.timingFunction = UIViewAnimationCurveEaseInOut;
            flipTransition.fillMode = kCAFillModeForwards;
            flipTransition.type = @"push";
            flipTransition.subtype = @"fromTop";
            UILabel *label = [self.view viewWithTag:214];
            label.text = change[@"new"];
            [label.layer addAnimation:flipTransition forKey:@"AnimationKey"];
        });
        
    }
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
