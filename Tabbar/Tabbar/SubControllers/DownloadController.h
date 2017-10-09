//
//  DownloadController.h
//  Tabbar
//
//  Created by Jion on 15/7/22.
//  Copyright (c) 2015年 Youjuke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadController : UIViewController
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

- (IBAction)downloadBtnClicked;
- (IBAction)pauseBtnClicked;
- (IBAction)tanMuAction:(id)sender;
@end
