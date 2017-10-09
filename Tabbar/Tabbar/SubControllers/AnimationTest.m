//
//  AnimationTest.m
//  Tabbar
//
//  Created by Jion on 15/10/27.
//  Copyright © 2015年 Youjuke. All rights reserved.
//

#import "AnimationTest.h"
#import "ZJElasticHead.h"
#import "Animation1.h"
#import "Animation2.h"
#import "Anmation3.h"

#import "GenieTestViewController.h"
#import "ZJCarrousel.h"
#import "ZJInvertedImage.h"

@interface AnimationTest ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong)ZJElasticHead *elasticHead;
@property (nonatomic,strong)NSArray   *animationTitles;
@end

@implementation AnimationTest

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _animationTitles = @[@"绘画练习",@"核心动画",@"基础动画",@"他人动画",@"旋转木马",@"倒影"];
    //添加头部视图
    self.elasticHead = [ZJElasticHead shareElasticHead];
    self.tableView.tableHeaderView = _elasticHead;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark 设置头部视图的拉伸效果
//滑动的时候调用
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    self.elasticHead.offsetY = scrollView.contentOffset.y;
}
//减速调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
// CAAnimation
//    CAAnimationGroup
//    CAPropertyAnimation
//    CABasicAnimation
//    CASpringAnimation
//    CATransaction
//  CGAffineTransform
//    CATransform3D
//    CAKeyframeAnimation
//    CATransition
    
}
//结束拖动的时候调用
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (decelerate == NO) {
        
    }
}
//将要拖动的时候调用
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{

}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    return _animationTitles.count;
}


 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
     if (!cell) {
         cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
     }
 
   
     cell.textLabel.text = _animationTitles[indexPath.row];
    return cell;
 }

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *av;
    switch (indexPath.row) {
        case 0:
          av = [[Animation1 alloc] init];
            break;
        case 1:
              av = [[Animation2 alloc] init];
            break;
        case 2:
            av = [[Anmation3 alloc] init];
            break;
        case 3:
            av = [[GenieTestViewController alloc] init];
            break;
        case 4:
            av = [[ZJCarrousel alloc] init];
            break;
        case 5:
            av = [[ZJInvertedImage alloc] init];
            break;
        default:
            break;
    }
    
    av.title = _animationTitles[indexPath.row];
    [self.navigationController pushViewController:av animated:YES];
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
