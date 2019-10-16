//
//  ViewController.m
//  MyPods
//
//  Created by Jion on 15/9/16.
//  Copyright (c) 2015年 Youjuke. All rights reserved.
//

#import "ViewController.h"

#define ScreenHeight    ([[UIScreen mainScreen] bounds].size.height)
#define ScreenWidth     ([[UIScreen mainScreen] bounds].size.width)
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong)NSArray *array;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.array = @[@"AutolayoutController",
                   @"MasonryController",
                   @"JSPacthController",
                   @"LockViewController",
                   @"SocketController",
                   @"BageButtonController",
                   @"DownLoaderController"];
}

#pragma mark -- UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.array.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.array[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%ld",(long)indexPath.row);
    NSString *classStr = self.array[indexPath.row];
    
    UIViewController *vc = [[NSClassFromString(classStr) alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
