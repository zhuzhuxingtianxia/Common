//
//  SeachControler.h
//  T
//
//  Created by Jion on 15/7/7.
//  Copyright (c) 2015年 Youjuke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SeachControler : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (weak, nonatomic) IBOutlet UITableView *table;
- (IBAction)changeTextAction:(id)sender;

@end
