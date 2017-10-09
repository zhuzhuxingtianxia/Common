//
//  AppDelegate.m
//  T
//
//  Created by Jion on 15/5/5.
//  Copyright (c) 2015年 Youjuke. All rights reserved.
//

#import "AppDelegate.h"
#import "TableViewController.h"
#import "UIDevice+ZJDeviceModel.h"
@interface AppDelegate ()
@property(nonatomic,strong)TableViewController *viewController;
@property(nonatomic,strong)UINavigationController *navController;
@end

@implementation AppDelegate

//启动后的淡出效果
- (void)bootProgram
{
        [self.window makeKeyAndVisible];
    
        CGFloat  mScreenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat  mScreenHeight = [UIScreen mainScreen].bounds.size.height;
        UIImageView *splashView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 64, mScreenWidth, mScreenHeight-64*2)];
        splashView.contentMode = UIViewContentModeScaleAspectFit;
        //将图片添加到UIImageView对象中
        splashView.image=[UIImage imageNamed:@"img.jpg"];
        [self.window addSubview:splashView];
        [self.window bringSubviewToFront:splashView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //设置动画效果
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration:1.0];
        [UIView setAnimationDelegate:self];
        splashView.alpha=0.0;
        splashView.frame=CGRectMake(-mScreenWidth/2, -mScreenHeight/2, 2*mScreenWidth, (2*mScreenHeight-64*2));
        
        [UIView commitAnimations];
    });
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    /*
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.viewController = [[TableViewController alloc] initWithNibName:nil bundle:nil];
    
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    self.navController.navigationBar.translucent = NO;
//    [self.navController.navigationBar setBarTintColor:Common_Color_Def_Nav];
    [self.navController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:20]}];
    [self.navController.navigationBar setTintColor:[UIColor whiteColor]];
    //[[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.window.rootViewController = self.navController;
    
//     Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
*/
    NSLog(@"1111");
    NSString *model = [[UIDevice currentDevice] deviceModel];
    
    [self bootProgram];
    return YES;
}

//点击通知栏执行这个方法
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"收到本地通知");
    /*
     a、应用程序在后台的时候，本地通知会给设备送达一个和远程通知一样的提醒，提醒的样式由用户在手机设置中设置
     
     b、应用程序正在运行中，则设备不会收到提醒，但是会走应用程序delegate中的这个方法。
         如果你想实现程序在后台时候的那种提醒效果，可以在添加相关代码
     */
     application.applicationIconBadgeNumber = 0;
    if ([[notification.userInfo objectForKey:@"id"] isEqualToString:@"affair.schedule"]) {
        //判断应用程序当前的运行状态，如果是激活状态，则进行提醒，否则不提醒
        if (application.applicationState == UIApplicationStateActive) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"test" message:notification.alertBody delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:notification.alertAction, nil];
            [alert show];
        }
    }
    
    // 在不需要再推送时，可以取消推送
    [self cancelLocalNotificationWithKey:@"id"];
}

// 取消某个本地推送通知
- (void)cancelLocalNotificationWithKey:(NSString *)key {
    // 获取所有本地通知数组
    NSArray *localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
    
    for (UILocalNotification *notification in localNotifications) {
        NSDictionary *userInfo = notification.userInfo;
        if (userInfo) {
            // 根据设置通知参数时指定的key来获取通知参数
            NSString *info = userInfo[key];
            
            // 如果找到需要取消的通知，则取消
            if (info != nil) {
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
                break;
            }
        }
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [application setApplicationIconBadgeNumber:0];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //点击应用图标时清除角标
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
