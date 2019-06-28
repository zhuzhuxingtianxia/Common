//
//  SettingViewController.m
//  Tabbar
//
//  Created by Jion on 15/4/28.
//  Copyright (c) 2015年 Youjuke. All rights reserved.
//

#import "SettingViewController.h"
#import "THWaterView.h"
#import <HealthKit/HealthKit.h>

@interface SettingViewController ()

@property(nonatomic,strong)THWaterView *waterView;
@property(nonatomic,strong)UILabel  *healthLabel;
@property (nonatomic, strong) HKHealthStore *healthStore;
@end

@implementation SettingViewController
- (id)init
{
    self = [super init];
    if (self) {
        self.tabBarItem.image = [[UIImage imageNamed:@"tab_button_settings"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"tab_button_settings"];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.navigationItem.title = @"设置";
    
    /*
     加载健康数据
     在这之前需要设置targets->capabilities ->healthKit设置为ON。
     此时会有一个.entitlements的文件
     */
    [self reloadHealthData];
   
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.tableHeaderView = self.waterView;
    [self.view addSubview:self.healthLabel];
}

- (void)reloadHealthData{
     //查看healthKit在设备上是否可用，ipad不支持HealthKit
    if(![HKHealthStore isHealthDataAvailable])
    {
        NSLog(@"设备不支持healthKit");
        _healthLabel.text = @"设备不支持healthKit";
        return;
    }
  
    //创建healthStore实例对象
    self.healthStore = [[HKHealthStore alloc] init];
    //设置需要获取的权限这里仅设置了步数
    HKObjectType *stepCount = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    NSSet *healthSet = [NSSet setWithObjects:stepCount, nil];
    //从健康应用中获取权限
    [self.healthStore requestAuthorizationToShareTypes:nil readTypes:healthSet completion:^(BOOL success, NSError * _Nullable error) {
        if (success)
        {
            NSLog(@"获取步数权限成功");
            //获取步数后我们调用获取步数的方法
            [self readStepCount];
        }
        else
        {
            NSLog(@"获取步数权限失败");
            dispatch_async(dispatch_get_main_queue(), ^{
                _healthLabel.text = @"获取步数失败";
            });
            
        }
    }];
}
- (void)readStepCount
{
    //查询采样信息
    HKSampleType *sampleType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    //NSSortDescriptors用来告诉healthStore怎么样将结果排序。
    NSSortDescriptor *start = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    NSSortDescriptor *end = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    /*查询的基类是HKQuery，这是一个抽象类，能够实现每一种查询目标，这里我们需要查询的步数是一个
     HKSample类所以对应的查询类就是HKSampleQuery。
     下面的limit参数传1表示查询最近一条数据,查询多条数据只要设置limit的参数值就可以了
     */
    HKSampleQuery *sampleQuery = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:nil limit:1 sortDescriptors:@[start,end] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        //打印查询结果
        NSLog(@"resultCount = %ld result = %@",results.count,results);
        //把结果装换成字符串类型
        HKQuantitySample *result = results[0];
        HKQuantity *quantity = result.quantity;
        NSString *stepStr = (NSString *)quantity;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            //查询是在多线程中进行的，如果要对UI进行刷新，要回到主线程中
            NSLog(@"最新步数：%@",stepStr);
            _healthLabel.text = [NSString stringWithFormat:@"最新步数：%@",stepStr];
        }];
        
    }];
    //执行查询
    [self.healthStore executeQuery:sampleQuery];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UILabel*)healthLabel{
    if (!_healthLabel) {
        _healthLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, self.view.bounds.size.width, 30)];
        _healthLabel.textColor = [UIColor orangeColor];
        _healthLabel.font = [UIFont boldSystemFontOfSize:18];
        _healthLabel.textAlignment = NSTextAlignmentCenter;
        _healthLabel.text = @"最新步数：---";
    }
   
    return _healthLabel;
}
-(THWaterView*)waterView{
    if (!_waterView) {
        _waterView = [[THWaterView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, 100)];
        
        //_waterView.layer.cornerRadius = _waterView.frame.size.height/2.f ;
        //_waterView.clipsToBounds = YES;
        _waterView.currentLinePointY = 50;
        
    }
    return _waterView;
}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return 10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    cell.textLabel.text = @"测试用";
    // Configure the cell...
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


@end
