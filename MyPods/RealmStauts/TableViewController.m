//
//  TableViewController.m
//  MyPods
//
//  Created by Jion on 2017/6/29.
//  Copyright © 2017年 Youjuke. All rights reserved.
//

#import "TableViewController.h"
#import "ViewModel.h"
#import "TableViewCell.h"
#import "ModifyStateController.h"

@interface TableViewController ()
@property(nonatomic,strong)ViewModel  *viewModel;
@property(nonatomic,strong)NSArray  *dataArray;
@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"数据测试";
    [self reloadData];
    
}

-(void)reloadData{
    __weak typeof(self) weakSelf = self;
    self.viewModel = [[ViewModel alloc] initWithCallBlock:^(NSArray *dataArray) {
        weakSelf.dataArray = dataArray;
        [weakSelf.tableView reloadData];
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 13;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 117;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TableModel *model = self.dataArray[indexPath.section];
    TableViewCell *cell = [TableViewCell sharedCellTable:tableView withModel:model];
    
    
    return cell;
}

/*
//跳转方式传参1
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
     //[self performSegueWithIdentifier:@"modifyState" sender:nil];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ModifyStateController *vc = [story instantiateViewControllerWithIdentifier:@"ModifyStateController"];
    vc.model = self.dataArray[indesPath.section];
    vc.block = ^{
    [self.tableView reloadData];
     };
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    //跳转方式传参2
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indesPath = [self.tableView indexPathForCell:sender];
        ModifyStateController *vc = [segue destinationViewController];
        vc.model = self.dataArray[indesPath.section];
        vc.block = ^{
            [self.tableView reloadData];
        };
    }
    
}


@end
