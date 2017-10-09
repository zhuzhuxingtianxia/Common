//
//  ZJInvertedImage.m
//  Tabbar
//
//  Created by Jion on 15/11/4.
//  Copyright © 2015年 Youjuke. All rights reserved.
//

#import "ZJInvertedImage.h"
#import "AFOpenFlowView.h"

@interface ZJInvertedImage ()<AFOpenFlowViewDelegate>

@end

@implementation ZJInvertedImage

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor blackColor];
    //用处：展示一些电影的海报、书籍等
    AFOpenFlowView *openfloor=[[AFOpenFlowView alloc]initWithFrame:CGRectMake(0, 20, 320,450)];
    openfloor.viewDelegate=self;
    
    openfloor.backgroundColor=[UIColor clearColor];
    
    //setNumberOfImages参数要和for的次数对应着
    [openfloor setNumberOfImages:11];
    for (int i=0; i<11; i++) {
        
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg",i]];
        
        //设置对应索引的图片，对图片是有要求的
        [openfloor setImage:image forIndex:i];
        
    }
    
    [self.view addSubview:openfloor];
}

- (void)openFlowView:(AFOpenFlowView *)openFlowView selectionDidChange:(int)index{
    NSLog(@"---->%d",index);
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
