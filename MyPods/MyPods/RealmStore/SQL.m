//
//  SQL.m
//  MyPods
//
//  Created by Jion on 16/1/27.
//  Copyright © 2016年 Youjuke. All rights reserved.
//

#import "SQL.h"
#import "UserModel.h"
#import "UserListController.h"
#import "MJExtension.h"

@interface SQL ()
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation SQL

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"持久化";
    // Do any additional setup after loading the view.
    NSString *documentpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSLog(@"数据库路径：%@ ",documentpath);
    
    //用于重置数据库
    //[[NSFileManager defaultManager] removeItemAtURL:[RLMRealmConfiguration defaultConfiguration].fileURL error:nil];
    
    self.nameField.text = @"qqq";
    self.nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.passwordField.text = @"123456";
    self.passwordField.clearButtonMode = UITextFieldViewModeAlways;
}
- (IBAction)longinAction:(id)sender {
    if (self.nameField.text.length<=0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入内容" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    if (self.passwordField.text.length<=0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入密码" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    
    // 使用断言字符串查询
    RLMResults *userNames = [UserModel objectsWhere:[NSString stringWithFormat:@"name = '%@'",self.nameField.text]];
    if (userNames.count==0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"用户不存在" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;

    }
    // 使用 NSPredicate 查询
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"password = %@",self.passwordField.text];
    RLMResults *userPasswords = [UserModel objectsWithPredicate:pred];
    if (userPasswords.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"密码错误" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    
    if (userNames.count>0 && userPasswords.count>0) {
        //登录后需要把该账户放在数组的第一个位置
        UserModel *userModel = [userNames firstObject];
        if (userModel) {
            
            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm transactionWithBlock:^{
                
            }];
        }
        
        UserListController *userList = [[UserListController alloc] init];
        [self.navigationController pushViewController:userList animated:YES];
        
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
