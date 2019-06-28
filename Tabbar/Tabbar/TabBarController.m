//
//  TabBarController.m
//  Tabbar
//
//  Created by Jion on 15/4/28.
//  Copyright (c) 2015年 Youjuke. All rights reserved.
//

#import "TabBarController.h"
#import "MessageViewController.h"
#import "ContactViewController.h"
#import "SettingViewController.h"
#import "MapViewController.h"

@interface TabBarController ()<UITabBarControllerDelegate>
{
    UIBarButtonItem *rightButton;
}
@property (strong, nonatomic) UIView *viewMenu;

@end

@implementation TabBarController

- (void)viewWillAppear:(BOOL)animated
{
    [self.selectedViewController viewWillAppear:animated];
//    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addChildViewController:[[MessageViewController alloc] init]];
    [self addChildViewController:[[ContactViewController alloc] init]];
    [self addChildViewController:[[SettingViewController alloc] init]];
    [self addChildViewController:[[MapViewController alloc] init]];
    
    [self.tabBar setTranslucent:NO];
    [self.tabBar setBarTintColor:[UIColor grayColor]];
    [self.tabBar setSelectedImageTintColor:[UIColor whiteColor]];
    [self.tabBar setSelectionIndicatorImage:[UIImage imageNamed:@"tab_button_select_back"]];
    self.delegate = self;
    
    rightButton = [[UIBarButtonItem alloc]
                   initWithImage:[UIImage imageNamed:@"nav_button_add"]
                   style:UIBarButtonItemStylePlain
                   target:self
                   action:@selector(showAddMenu:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    //创建弹出菜单
    [self createMenuView];
}

- (void)showAddMenu:(id)sender
{
    CGRect frame = _viewMenu.frame;
    if(_viewMenu.hidden)
    {
        _viewMenu.hidden = NO;
        
        CGAffineTransform transform = CGAffineTransformMakeTranslation(frame.size.width / 2, -frame.size.height / 2);
        transform = CGAffineTransformScale(transform, 0.01, 0.01);
        _viewMenu.transform = transform;
        
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             CGAffineTransform transform = CGAffineTransformMakeTranslation(-frame.size.width / 20, frame.size.height / 20);
                             transform = CGAffineTransformScale(transform, 1.0, 1.0);
                             _viewMenu.transform = transform;
                         }
                         completion:^(BOOL finished){
                             if (finished){
                                 [UIView animateWithDuration:0.05 delay:0 options:UIViewAnimationOptionCurveLinear
                                                  animations:^{
                                                      _viewMenu.transform = CGAffineTransformIdentity;
                                                  }
                                                  completion:^(BOOL finished){
                                                      if (finished){
                                                          
                                                      }
                                                  }
                                  ];
                             }
                         }
         ];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        button.tag = 10000;
        button.backgroundColor = [UIColor blackColor];
        button.alpha = 0.6;
        [button addTarget:self action:@selector(showAddMenu:) forControlEvents:UIControlEventTouchUpInside];
        [self.view insertSubview:button belowSubview:_viewMenu];
    }
    else
    {
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             CGAffineTransform transform = CGAffineTransformMakeTranslation(frame.size.width / 2, -frame.size.height / 2);
                             transform = CGAffineTransformScale(transform, 0.01, 0.01);
                             _viewMenu.transform = transform;
                         }
                         completion:^(BOOL finished){
                             if (finished){
                                 _viewMenu.transform = CGAffineTransformIdentity;
                                 _viewMenu.hidden = YES;
                             }
                         }
         ];
        
        [(UIButton*)[self.view viewWithTag:10000] removeFromSuperview];
    }
}

- (void)createMenuView
{
    _viewMenu = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-126, 5, 116, 93)];
    
    UIButton *button0 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 116, 50)];
    [button0 setBackgroundImage:[UIImage imageNamed:@"nav_menu_button_0"] forState:UIControlStateNormal];
    [button0 setBackgroundImage:[UIImage imageNamed:@"nav_menu_button_0_down"] forState:UIControlStateHighlighted];
    [button0 setImage:[UIImage imageNamed:@"nav_menu_icon_0"] forState:UIControlStateNormal];
    [button0 setImageEdgeInsets:UIEdgeInsetsMake(7, 0, 0, 0)];
    [button0.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [button0.titleLabel setTextColor:[UIColor whiteColor]];
    [button0 setTitle:@"添加好友" forState:UIControlStateNormal];
    [button0 setTitleEdgeInsets:UIEdgeInsetsMake(10, 8, 0, 0)];
    [button0 setAdjustsImageWhenHighlighted:NO];
    
//    [button0 addTarget:self action:@selector(addFriendsClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 51, 116, 42)];
    [button1 setBackgroundImage:[UIImage imageNamed:@"nav_menu_button_1"] forState:UIControlStateNormal];
    [button1 setBackgroundImage:[UIImage imageNamed:@"nav_menu_button_1_down"] forState:UIControlStateHighlighted];
    [button1 setImage:[UIImage imageNamed:@"nav_menu_icon_1"] forState:UIControlStateNormal];
    [button1 setImageEdgeInsets:UIEdgeInsetsMake(0, -3, 0, 0)];
    [button1.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [button1.titleLabel setTextColor:[UIColor whiteColor]];
    [button1 setTitle:@"发起群聊" forState:UIControlStateNormal];
    [button1 setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
    [button1 setAdjustsImageWhenHighlighted:NO];
    
//    [button1 addTarget:self action:@selector(startGroupClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [_viewMenu addSubview:button0];
    [_viewMenu addSubview:button1];
    
    [self.view addSubview:_viewMenu];
    
    _viewMenu.hidden = YES;
}

#pragma mark--UITabBarDelegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if([viewController isKindOfClass:[MessageViewController class]])
        self.navigationItem.rightBarButtonItem = rightButton;
    else if ([viewController isKindOfClass:[MapViewController class]])
    {
//        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"搜索" style:UIBarButtonItemStylePlain target:self action:@selector(searchBar)];
//        self.navigationItem.rightBarButtonItem = rightItem;
    }
    else
        self.navigationItem.rightBarButtonItem = nil;

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
