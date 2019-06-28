//
//  ContactViewController.m
//  Tabbar
//
//  Created by Jion on 15/4/28.
//  Copyright (c) 2015年 Youjuke. All rights reserved.
//

//获取SIM卡信息

#import "ContactViewController.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#import "DeleteCellController.h"
#import "AnimationTest.h"
#import "ZJHeadInfo.h"
@interface ContactViewController ()
{
        
        //声明变量
    CTTelephonyNetworkInfo *networkInfo;
    
}
@property (nonatomic,strong)ZJHeadInfo *headView;
@end

@implementation ContactViewController
- (id)init
{
    self = [super init];
    if (self) {
        self.tabBarItem.image = [[UIImage imageNamed:@"tab_button_friends"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"tab_button_friends"];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.navigationItem.title = @"联系人";
    [self.tableView reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
   
    //设置SIM卡
    [self simCardChanged];
    //设置头部控件
    [self loadTableHeadView];
}
- (void)loadTableHeadView{
    self.headView = [ZJHeadInfo shareHeadInfo];
    self.tableView.tableHeaderView = _headView;
    __weak ContactViewController* wself = self;
    [_headView setHandleRefreshEvent:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [wself.headView stopRefresh];
        });
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//获取网络供应商
- (void)simCardChanged {
    self.navigationItem.prompt = @"CTTelephonyNetworkInfo";
    
    self.navigationItem.title = @"CTCarrier";
    //初始化
    networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    //当sim卡更换时弹出此窗口
    
    networkInfo.subscriberCellularProviderDidUpdateNotifier = ^(CTCarrier *carrier){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Sim card changed" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
        
    };
 
}

#pragma mark- scroll delegate
//滑动的时候调用
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    self.headView.offsetY = scrollView.contentOffset.y;
}
//减速调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    _headView.touching = NO;
}
//结束拖动的时候调用
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (decelerate == NO) {
        _headView.touching = NO;
    }
}
//将要拖动的时候调用
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    _headView.touching = YES;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return 5;
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //获取sim卡信息
    CTCarrier *carrier = networkInfo.subscriberCellularProvider;
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *deleteline = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, 1.0)];
        deleteline.backgroundColor = [UIColor grayColor];
        deleteline.hidden = NO;
        [cell.contentView addSubview:deleteline];
    }
   
    switch (indexPath.row) {
        case 0://动画
            
            cell.textLabel.text = @"动画，绘图";
            
            break;
        case 1://供应商名称（中国联通 中国移动）
            
            cell.textLabel.text = @"carrierName";
            
            cell.detailTextLabel.text = carrier.carrierName;
            
            break;
            
        case 2://所在国家编号
            
            cell.textLabel.text = @"mobileCountryCode";
            
            cell.detailTextLabel.text = carrier.mobileCountryCode;
            
            break;
            
        case 3://供应商网络编号
            
            cell.textLabel.text = @"mobileNetworkCode";
            
            cell.detailTextLabel.text = carrier.mobileNetworkCode;
            
            break;
            
        case 4:
            
            cell.textLabel.text = @"isoCountryCode";
            
            cell.detailTextLabel.text = carrier.isoCountryCode;
            
            break;
            
        case 5://是否允许voip
            
            cell.textLabel.text = @"allowsVOIP";
            
            cell.detailTextLabel.text = carrier.allowsVOIP?@"YES":@"NO";
            
            break;
            
            
        default:
            
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIViewController *controller;
    if (indexPath.row == 0) {
        controller = [[AnimationTest alloc] init];
        controller.title = cell.textLabel.text;

    }else{
        controller = [[DeleteCellController alloc] init];
        controller.title = @"点击删除cell";
    }
    
    [self.navigationController pushViewController:controller animated:YES];
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
