//
//  ZJCarrousel.m
//  Tabbar
//
//  Created by Jion on 15/11/4.
//  Copyright © 2015年 Youjuke. All rights reserved.
//

#import "ZJCarrousel.h"
#import "iCarousel.h"


@interface ZJCarrousel ()<iCarouselDelegate, iCarouselDataSource>
{
    BOOL Flag;
    iCarousel *_carousel;
}

@end

@implementation ZJCarrousel

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor blackColor];
    
    UIBarButtonItem *rightItem=[[UIBarButtonItem alloc] initWithTitle:@"切换" style:UIBarButtonItemStylePlain target:self action:@selector(qiehuan)];
    self.navigationItem.rightBarButtonItem=rightItem;
    
    _carousel=[[iCarousel alloc] initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, 300)];
    _carousel.type=iCarouselTypeCylinder;
    _carousel.delegate=self;
    _carousel.dataSource=self;
    
    [self.view addSubview:_carousel];

}

#pragma mark--Action
-(void)qiehuan{
    Flag = !Flag;
    if (Flag) {
        _carousel.type=iCarouselTypeCoverFlow;
    }else {
         _carousel.type=iCarouselTypeCylinder;
       
    }
    
}

#pragma mark iCarouselDataSource
//有多少项
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    return 11;
}
//最大有多少个可以显示
- (NSUInteger)numberOfVisibleItemsInCarousel:(iCarousel *)carousel{
    return 21;
}
//每一个的内容
- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index{
    
    UIImageView *imgv=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 210, 300)];
    imgv.image=[UIImage imageNamed:[NSString stringWithFormat:@"%lu.jpg", (unsigned long)index]];
    
    return imgv;
}

#pragma mark -
#pragma mark iCarouselDelegate
-(CGFloat)carouselItemWidth:(iCarousel *)carousel{
    return 230;
}
- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index{
    NSLog(@"---->%ld", (long)index);
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
