//
//  DetailController.m
//  MyPods
//
//  Created by Jion on 2017/6/27.
//  Copyright © 2017年 Youjuke. All rights reserved.
//

#import "DetailController.h"
#import "UserModel.h"

@interface DetailController ()<UIAlertViewDelegate>

@property(nonatomic,strong)UserModel  *userModel;

@end

@implementation DetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.tableFooterView = [UIView new];
    RLMResults *userNames = [UserModel objectsWhere:[NSString stringWithFormat:@"name = '%@'",self.title]];
    self.userModel = [userNames firstObject];
    
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addDog)];
    
}

- (void)addDog
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"设置名字" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
    
}

#pragma mark -- 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        UITextField *field = [alertView textFieldAtIndex:0];
        NSInteger integer = arc4random()%3 + 1;
        switch (integer) {
            case 1:
            {
                [[RLMRealm defaultRealm] transactionWithBlock:^{
                    //设置添加1
                  Dog *adog = [Dog createInDefaultRealmWithValue:@[field.text?field.text:@"无名",@3]];
                    [self.userModel.dogs addObject:adog];
                    
                }];
            }
                break;
            case 2:
            {
                [[RLMRealm defaultRealm] transactionWithBlock:^{
                    //设置添加2
                   Dog *adog = [Dog createInDefaultRealmWithValue:@{@"name":field.text?field.text:@"无名",@"age":@2}];
                    [self.userModel.dogs addObject:adog];
                    
                }];
            }
                break;
            case 3:
            {
                //设置添加3
                RLMRealm *realm = RLMRealm.defaultRealm;
                [realm beginWriteTransaction];
                Dog *adog = [Dog createInRealm:realm withValue:@{@"name":field.text?field.text:@"无名",@"age":@1}];
                [self.userModel.dogs addObject:adog];
                [realm commitWriteTransaction];
            }
                break;
                
            default:
                break;
        }
        
        
        
        [self.tableView beginUpdates];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];

    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.userModel.dogs.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"reuseIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    Dog *dogModel = [self.userModel.dogs objectAtIndex:indexPath.row];
    
    cell.textLabel.text = dogModel.name;
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"年龄：%ld",dogModel.age];
    
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



//iOS8 需要实现这个代理方法才能滑动删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        
        
    }
}
//自定义滑动按钮
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除"handler:^(UITableViewRowAction *action,NSIndexPath *indexPath) {
        RLMRealm *realm = RLMRealm.defaultRealm;
        [realm beginWriteTransaction];
        [realm deleteObject:self.userModel.dogs[indexPath.row]];
        [realm commitWriteTransaction];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }];
    return  @[deleteRowAction];
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
