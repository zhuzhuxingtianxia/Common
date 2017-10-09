//
//  TableViewController.m
//  T
//
//  Created by Jion on 15/5/5.
//  Copyright (c) 2015年 Youjuke. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController ()

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /*------------------------第一种排序----------------------------*/
    NSComparator cmptr = ^(id obj1, id obj2){
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    
    NSArray *sortArray = [[NSArray alloc] initWithObjects:@"1",@"3",@"4",@"7",@"8",@"2",@"6",@"5",@"13",@"15",@"12",@"20",@"28",@"26",nil];
    //排序前
    NSMutableString *outputBefore = [[NSMutableString alloc] init];
    for(NSString *str in sortArray){
        [outputBefore appendFormat:@"%@,",str];
         }
         NSLog(@"排序前:%@",outputBefore);
    //第一种排序
    NSArray *array = [sortArray sortedArrayUsingComparator:cmptr];

    NSMutableString *outputAfter = [[NSMutableString alloc] init];
    for(NSString *str in array){
        [outputAfter appendFormat:@"%@,",str];
         }
         NSLog(@"排序后:%@",outputAfter);
   
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return 10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cc"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cc"];
    }
    cell.textLabel.text = @"xxxxxxxx";
    // Configure the cell...
    
    return cell;
}

@end
