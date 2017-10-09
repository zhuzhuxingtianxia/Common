//
//  RegisterController.m
//  MyPods
//
//  Created by Jion on 2017/6/23.
//  Copyright © 2017年 Youjuke. All rights reserved.
//

#import "RegisterController.h"
#import "UserModel.h"

@interface RegisterController ()
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *password;

@end

@implementation RegisterController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)registerAction:(id)sender {
    if (self.nameField.text.length<=0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入内容" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    if (self.password.text.length<=0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入密码" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    
    // 使用 NSPredicate 查询
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"password = %@",self.password.text];
    RLMResults *userNames = [UserModel objectsWithPredicate:pred];
    if (userNames.count > 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"该用户已存在" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    
    UserModel *user = [[UserModel alloc] init];
    user.name = self.nameField.text;
    user.password = self.password.text;
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [realm addObject:user];
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }];

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
