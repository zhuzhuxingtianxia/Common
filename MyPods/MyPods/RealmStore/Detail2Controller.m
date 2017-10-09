//
//  Detail2Controller.m
//  MyPods
//
//  Created by Jion on 2017/6/28.
//  Copyright © 2017年 Youjuke. All rights reserved.
//

#import "Detail2Controller.h"
#import "UserModel.h"

@interface Detail2Controller ()
@property (nonatomic, strong) RLMNotificationToken *notification;
@property(nonatomic,strong)UserModel  *userModel;
@end

@implementation Detail2Controller

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.tableFooterView = [UIView new];
    RLMResults *userNames = [UserModel objectsWhere:[NSString stringWithFormat:@"name = '%@'",self.title]];
    self.userModel = [userNames firstObject];
    
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"添加狗狗" style:UIBarButtonItemStylePlain target:self action:@selector(addDog)];
    
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addDog)];
    
     //发生改变的通知
     __weak typeof(self) weakSelf = self;
    self.notification = [self.userModel.dogs addNotificationBlock:^(RLMArray * _Nullable array, RLMCollectionChange * _Nullable changes, NSError * _Nullable error) {
        if (error) {
            return ;
        }
        
        if (!changes) {
            [weakSelf.tableView reloadData];
            return;
        }
        
        
        [weakSelf.tableView beginUpdates];
        if (changes.deletions.count > 0) {
            [weakSelf.tableView deleteRowsAtIndexPaths:[changes deletionsInSection:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        if (changes.insertions.count>0) {
            [weakSelf.tableView insertRowsAtIndexPaths:[changes insertionsInSection:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        [weakSelf.tableView reloadRowsAtIndexPaths:[changes modificationsInSection:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [weakSelf.tableView endUpdates];

        
    }];
    
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
         __weak typeof(self) weakSelf = self;
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        Dog *aDog = [Dog createInRealm:realm withValue:@{@"name": field.text?field.text:@"无名",@"age": @5}];
        [weakSelf.userModel.dogs addObject:aDog];
        [realm commitWriteTransaction];
        
         //在后台添加 则需要通知配合
         dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
         // Import many items in a background thread
         dispatch_async(queue, ^{
         // Get new realm and table since we are in a new thread
          //userModel在主线程，在这里添加dog对象造成线程不同步
         
         });
        
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
    __weak typeof(self) weakSelf = self;
    
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除"handler:^(UITableViewRowAction *action,NSIndexPath *indexPath) {
        RLMRealm *realm = RLMRealm.defaultRealm;
        [realm beginWriteTransaction];
        [realm deleteObject:weakSelf.userModel.dogs[indexPath.row]];
        [realm commitWriteTransaction];
        
    }];
    UITableViewRowAction *changeRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"修改名字"handler:^(UITableViewRowAction *action,NSIndexPath *indexPath) {
        
        Dog *dog = weakSelf.userModel.dogs[indexPath.row];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"为%@设置新名字",dog.name] message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf.tableView beginUpdates];
            
            [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            [weakSelf.tableView endUpdates];
            
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UITextField *field = alert.textFields.firstObject;
            if (field.text.length == 0) {
                [action setEnabled:NO];
                return ;
            }
            RLMRealm *realm = RLMRealm.defaultRealm;
            [realm transactionWithBlock:^{
              dog.name = field.text;
            }];
            
        }]];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            //在此可给textField设置相关属性
        }];
        
        [self presentViewController:alert animated:YES completion:^{
            
        }];
        
        
    }];
    changeRowAction.backgroundColor = [UIColor brownColor];
    return  @[deleteRowAction,changeRowAction];
}

-(void)dealloc{
    
    NSLog(@"已释放当前视图");
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
