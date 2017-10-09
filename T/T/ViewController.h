//
//  ViewController.h
//  T
//
//  Created by Jion on 15/5/5.
//  Copyright (c) 2015年 Youjuke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *zbrImage;
@property (weak, nonatomic) IBOutlet UITextField *hour;
@property (weak, nonatomic) IBOutlet UITextField *minute;

- (IBAction)showImage:(id)sender;

- (IBAction)removeImage:(id)sender;
- (IBAction)QRCodeAction:(id)sender;

@end

