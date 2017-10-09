//
//  ModifyStateController.m
//  MyPods
//
//  Created by Jion on 2017/6/30.
//  Copyright © 2017年 Youjuke. All rights reserved.
//

#import "ModifyStateController.h"

@interface ModifyStateController ()

@end

@implementation ModifyStateController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.model.name;
}
- (IBAction)changeState:(UIButton*)sender {
    NSInteger index = sender.tag;
    NSString  *state = @"0";
    switch (index) {
        case 0:
            case 1:
            case 5:
            case 8:
        {
            //审核中1
           state = @"1";
        }
            break;
        case 2:
        {
            //未通过2
          state = @"2";
        }
            break;
        case 3:
            case 4:
            case 6:
        {
            //已通过3
            state = @"3";
        }
            break;
        case 7:
        {
            //已打款4
           state = @"7";
        }
            break;
        case 9:
        {
            //待跟进5
           state = @"9";
        }
            break;
        case 11:
        {
            //无效6
           state = @"11";
        }
            break;
            
        default:
            break;
    }
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    self.model.reviewed_status = state;
    [realm commitWriteTransaction];
    
    self.block();
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    NSLog(@"已经释放");
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
