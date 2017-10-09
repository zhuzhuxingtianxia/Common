//
//  ChangePasswordController.m
//  MyPods
//
//  Created by Jion on 2017/6/27.
//  Copyright © 2017年 Youjuke. All rights reserved.
//

#import "ChangePasswordController.h"
#import "UserModel.h"

@interface ChangePasswordController ()
@property (weak, nonatomic) IBOutlet UITextField *oldPassword;
@property (weak, nonatomic) IBOutlet UITextField *password;

@end

@implementation ChangePasswordController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
}
- (IBAction)commitAction:(id)sender {
    RLMResults *userNames = [UserModel objectsWhere:[NSString stringWithFormat:@"name = '%@'",self.title]];
    UserModel *model = [userNames firstObject];
    
    if (self.oldPassword.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入原密码" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    if (self.password.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入新密码" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    
    if (self.oldPassword.text != model.password) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"原密码输入错误" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    
    //修改密码
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    model.password = self.password.text;
    [realm commitWriteTransaction];
    
    [self.navigationController popViewControllerAnimated:YES];
    
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
