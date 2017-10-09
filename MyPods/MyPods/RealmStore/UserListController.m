//
//  UserListController.m
//  MyPods
//
//  Created by Jion on 2017/6/23.
//  Copyright © 2017年 Youjuke. All rights reserved.
//

#import "UserListController.h"
#import "UserModel.h"

@interface UserListController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)RLMResults  *dataArray;
@property (nonatomic, strong) RLMNotificationToken *notification;

@end

@implementation UserListController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
    
    //查询全部用户信息
    self.dataArray = [UserModel allObjects];
    
    __weak typeof(self) weakSelf = self;
    
    /*
    //通知方式1
    self.notification = [RLMRealm.defaultRealm addNotificationBlock:^(NSString *note, RLMRealm *realm) {
        [weakSelf.tableView reloadData];
    }];
    */
    //通知方式2
    self.notification = [self.dataArray addNotificationBlock:^(RLMResults *data, RLMCollectionChange *changes, NSError *error) {
        if (error) {
            NSLog(@"Failed to open Realm on background worker: %@", error);
            return;
        }
        
        UITableView *tv = weakSelf.tableView;
        // Initial run of the query will pass nil for the change information
        if (!changes) {
            [tv reloadData];
            return;
        }
        
        // changes is non-nil, so we just need to update the tableview
        [tv beginUpdates];
        [tv deleteRowsAtIndexPaths:[changes deletionsInSection:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tv insertRowsAtIndexPaths:[changes insertionsInSection:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tv reloadRowsAtIndexPaths:[changes modificationsInSection:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tv endUpdates];
    }];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"reuseIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.textColor = [UIColor redColor];
    }else{
        cell.textLabel.textColor = [UIColor blackColor];
    }
    UserModel *model = [self.dataArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = model.name;
    
    cell.detailTextLabel.text = model.password;
    
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
    if (indexPath.row==0) {
        UITableViewRowAction *modifyPassAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"修改密码"handler:^(UITableViewRowAction *action,NSIndexPath *indexPath) {
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
           id vc = [story instantiateViewControllerWithIdentifier:@"ChangePasswordController"];
             UserModel *model = [self.dataArray objectAtIndex:indexPath.row];
            [vc setTitle:model.name];
            
            [self.navigationController pushViewController:vc animated:YES];
            
        }];
        modifyPassAction.backgroundColor = [UIColor blueColor];
        return  @[modifyPassAction];
    }else{
        
        UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除"handler:^(UITableViewRowAction *action,NSIndexPath *indexPath) {
            
            /*
            //删除1 有动画效果
             UserModel *model = [self.dataArray objectAtIndex:indexPath.row];
            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm beginWriteTransaction];
            // 删除单条记录
            [realm deleteObject:model];
            
            [realm commitWriteTransaction];
            
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            */
            
            //删除2 需要与RLM通知配合
            RLMRealm *realm = RLMRealm.defaultRealm;
            [realm beginWriteTransaction];
            [realm deleteObject:self.dataArray[indexPath.row]];
            [realm commitWriteTransaction];
            
        }];
        return  @[deleteRowAction];
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UserModel *model = [self.dataArray objectAtIndex:indexPath.row];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"不使用通知" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       
        id vc = [[NSClassFromString(@"DetailController") alloc] init];
        [vc setTitle:model.name];
        
        [self.navigationController pushViewController:vc animated:YES];
        
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"realm通知" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        id vc = [[NSClassFromString(@"Detail2Controller") alloc] init];
        [vc setTitle:model.name];
        
        [self.navigationController pushViewController:vc animated:YES];
        
    }]];
    
    [self presentViewController:alert animated:YES completion:^{
        
    }];
    
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
