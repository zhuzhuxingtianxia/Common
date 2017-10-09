//
//  DownloadController.m
//  Tabbar
//
//  Created by Jion on 15/7/22.
//  Copyright (c) 2015年 Youjuke. All rights reserved.
//

#import "DownloadController.h"
#import "LCDownloadManager.h"
#import "AFNetworking.h"

#define VIDEO_URL @"http://mw5.dwstatic.com/1/3/1528/133489-99-1436409822.mp4"

@interface DownloadController ()
@property (nonatomic, strong) AFHTTPRequestOperation *operation;
@property (nonatomic, strong) AFHTTPRequestOperation *operation1;

@end

@implementation DownloadController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor grayColor];
    self.progressView.progress = 0;
    
}

#pragma mark--Action
- (IBAction)downloadBtnClicked
{
    self.operation = [LCDownloadManager downloadFileWithURLString:VIDEO_URL cachePath:@"demo1.mp4" progressBlock:^(CGFloat progress, CGFloat totalMBRead, CGFloat totalMBExpectedToRead) {
        
        NSLog(@"1--%f %f %f", progress, totalMBRead, totalMBExpectedToRead);
        self.progressView.progress = progress;
        
    } successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"1--Download finish");
        
    } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (error.code == -999) NSLog(@"1--Maybe you pause download.");
        
        NSLog(@"1--%@", error);
    }];
    
   self.operation1 = [LCDownloadManager downloadFileWithURLString:@"http://mw2.dwstatic.com/2/8/1528/133366-99-1436362095.mp4" cachePath:@"demo2.mp4" progressBlock:^(CGFloat progress, CGFloat totalMBRead, CGFloat totalMBExpectedToRead) {
        
        NSLog(@"2--%f %f %f", progress, totalMBRead, totalMBExpectedToRead);
        
    } successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"2--Download finish");
        
    } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (error.code == -999) NSLog(@"2--Maybe you pause download.");
        
        NSLog(@"2--%@", error);
    }];

}
- (IBAction)pauseBtnClicked
{
   [LCDownloadManager pauseWithOperation:self.operation];
    [LCDownloadManager pauseWithOperation:self.operation1];
}

- (IBAction)tanMuAction:(id)sender {
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
