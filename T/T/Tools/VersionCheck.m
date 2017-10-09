//
//  VersionCheck.m
//  ZJP
//
//  Created by Jion on 15/9/9.
//  Copyright (c) 2015年 Youjuke. All rights reserved.
//

#import "VersionCheck.h"
//系统版本
#define zSystemVersion [[[UIDevice currentDevice] systemVersion] floatValue]
#define APP_URL   @"https://itunes.apple.com/lookup?id=%@"  //1021153605

@interface VersionCheck ()<UIAlertViewDelegate>
@property(nonatomic,copy)NSString *downLoadUrl;

@end
@implementation VersionCheck

+ (void)updateVisonWithWindow:(UIWindow*)window AppId:(NSString*)appId
{
    
    VersionCheck *check = [[VersionCheck alloc] init];
#if __IPHONE_9_0 <= __IPHONE_OS_VERSION_MAX_ALLOWED
    [window.rootViewController.view addSubview:check];
#else
    [window addSubview:check];
#endif
    [check compareVison:appId andWindow:window];
}

#pragma mark--版本检测
- (void)compareVison:(NSString *)appId andWindow:(UIWindow*)window
{
    // 关键是自动取版本信息：
    NSString *shortVersion =[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSLog(@"version:%@",shortVersion);
    NSString *longBuildVersion =[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
//    NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    NSString *URL = [NSString stringWithFormat:APP_URL,appId];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:URL]];
    [request setHTTPMethod:@"GET"];
    
 #if __IPHONE_9_0 <= __IPHONE_OS_VERSION_MAX_ALLOWED
    NSURLSession *session = [NSURLSession sharedSession];
   NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error==%@",error);
            
        }else{
            NSLog(@"itunes SDK9.0 request Success");
            NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            
            NSArray *infoArray = [dict objectForKey:@"results"];
            if ([infoArray count]) {
                NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
                NSString *latestVersion = [releaseInfo objectForKey:@"version"];
                _downLoadUrl = [releaseInfo objectForKey:@"trackViewUrl"];
                int latest = [self versionToInt:latestVersion];
                int current = [self versionToInt:longBuildVersion];
                
                if (latest > current)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // 更新UI
                        [self alertUpdateWindow:window];
                    });
                    
                }
            }
            
        }

    }];
    // 使用resume方法启动任务
    [dataTask resume];
#else
    //创建一个队列（默认添加到该队列中的任务异步执行）
    //    NSOperationQueue *queue=[[NSOperationQueue alloc]init];
    //获取一个主队列
    NSOperationQueue *queue=[NSOperationQueue mainQueue];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"connectionError==%@",connectionError);
            
        }else{
            NSLog(@"itunes request Success");
            NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            
            NSArray *infoArray = [dict objectForKey:@"results"];
            if ([infoArray count]) {
                NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
                NSString *latestVersion = [releaseInfo objectForKey:@"version"];
                _downLoadUrl = [releaseInfo objectForKey:@"trackViewUrl"];
                int latest = [self versionToInt:latestVersion];
                int current = [self versionToInt:longBuildVersion];
                
                if (latest > current)
                {
                    
                    [self alertUpdateWindow:window];
                }
            }
            
        }
        
    }];
#endif
    
}

#if __IPHONE_9_0 <= __IPHONE_OS_VERSION_MAX_ALLOWED

- (void)alertUpdateWindow:(UIWindow*)window
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"有新的版本更新" preferredStyle:UIAlertControllerStyleAlert];
    
    [window.rootViewController  presentViewController:alert animated:YES completion:nil];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"以后再说" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"马上更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
         NSURL *url = [NSURL URLWithString:_downLoadUrl];
         [[UIApplication sharedApplication] openURL:url];
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:defaultAction];
}
#else
-(void)alertUpdateWindow:(UIWindow*)window
{
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                 message:@"有新的版本更新"
                                                delegate:self       //委托给Self，才会执行上面的调用
                                       cancelButtonTitle:@"以后再说"
                                       otherButtonTitles:@"马上更新",nil];
    [av show];
    
}
#pragma mark--alertView代理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [alertView cancelButtonIndex])
    {
        NSURL *url = [NSURL URLWithString:_downLoadUrl];
        [[UIApplication sharedApplication] openURL:url];
    }
}

#endif

#pragma mark -- 日期比较
+(BOOL)compareDate{
    NSString *key = @"VisonCheckDate";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
    NSDate *currentDate = [dateFormatter dateFromString:dateStr];
    
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: currentDate];
    NSDate *localeDate = [currentDate dateByAddingTimeInterval: interval];
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *oldDate = [userDefaults objectForKey:key];
    if (!oldDate) {
        [userDefaults setObject:localeDate forKey:key];
    }
    
    if ([oldDate compare:localeDate] == NSOrderedAscending) {
        
        [userDefaults setObject:localeDate forKey:key];
        return YES;
    }
    
    return NO;
}

/**猪猪添加 若去除符号“.”后长度大与3（10.2.0或1.10.0），该方法需重写*/
- (int)versionToInt:(NSString*)str
{
    str = [str stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (str.length<3) {
        str = [NSString stringWithFormat:@"%@0",str];
        int temp =[self versionToInt:str];
        str = [NSString stringWithFormat:@"%d",temp];
    }
    
    return [str intValue];
    
}

@end
