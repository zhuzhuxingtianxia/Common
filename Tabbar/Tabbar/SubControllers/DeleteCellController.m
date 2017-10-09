//
//  DeleteCellController.m
//  Tabbar
//
//  Created by Jion on 15/5/8.
//  Copyright (c) 2015年 Youjuke. All rights reserved.
//

#import "DeleteCellController.h"

@interface DeleteCellController ()<UIAlertViewDelegate>

{
    NSMutableArray  *_dataList;
}
@end

@implementation DeleteCellController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *arr1 = [NSMutableArray arrayWithObjects:@"000000000000",@"11111111",@"2222222",@"3333333",@"44444444", nil];
    NSMutableArray *arr2 =[NSMutableArray arrayWithObjects:@"5555555",@"66666666",@"77777777",@"88888888888",@"999999999", nil];
    _dataList = [NSMutableArray arrayWithObjects:arr1,arr2, nil];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"选择动画删除还是排序" delegate:self cancelButtonTitle:nil otherButtonTitles:@"删除",@"排序", nil];
    [alert show];
    
}
#pragma mark--UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            
        }
            break;
        case 1:
        {
           [self.tableView setEditing:!self.tableView.isEditing animated:true]; 
        }
            break;
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataList.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return [[_dataList objectAtIndex:section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     UITableViewCell * customCell = [tableView dequeueReusableCellWithIdentifier:@"cc"];
    if (!customCell) {
        customCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cc"];
        
    }
    
    customCell.textLabel.text = [_dataList[indexPath.section] objectAtIndex:indexPath.row];
    return customCell;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSLog(@"ooo%ld,%ld",(long)fromIndexPath.row,(long)toIndexPath.row);
    NSMutableArray *arr1 = _dataList[fromIndexPath.section];
    NSMutableArray *arr2 = [_dataList lastObject];
    NSString *obj = [arr1 objectAtIndex:fromIndexPath.row];
    [arr1 removeObject:obj];
    if (arr1.count==0) {
        [_dataList removeObject:arr1];
         [tableView reloadData];
    }
    [arr2 insertObject:obj atIndex:arr2.count];
    [tableView reloadData];

}
//排序
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"111");
//    NSString *str =[_dataList objectAtIndex:indexPath.row];
    [_dataList[indexPath.section] removeObject:_dataList[indexPath.section][indexPath.row]];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    
//    [_dataList insertObject:str atIndex:_dataList.count-1];
//    [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [_dataList[indexPath.section] removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


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

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
