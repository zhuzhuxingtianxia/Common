//
//  AppDelegate.m
//  MyPods
//
//  Created by Jion on 15/9/16.
//  Copyright (c) 2015年 Youjuke. All rights reserved.
//

#import "AppDelegate.h"
#import "JSPatchCode.h"
#import "JPEngine.h"
#import "ZJDownLoader.h"

#ifdef DEBUG  // 调试状态
// 打开LOG功能
#define ZJLog(...) NSLog(__VA_ARGS__)
#else // 发布状态
// 关闭LOG功能
#define ZJLog(...)
#endif
@interface AppDelegate ()

@end

@implementation AppDelegate

- (NSInteger)xNeedWithCount:(NSInteger)n
{
    NSInteger sum = 0;
    NSUInteger number = 1,temp;
    for (int i = 0; i < n; i++) {
        if (i < 2) {
            sum = number;
        }else{
            temp = sum;
            sum += number;
            number = temp;
        }
    }
    return sum;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self testDemo];
    NSString *sp = [[NSBundle mainBundle] localizedStringForKey:@"BTFinish" value:@"中国" table:nil];
    NSLog(@"sp = %@",sp);
    NSLog(@"===%ld",[self xNeedWithCount:8]);
    ZJLog(@"测试");
    //[self jsPatchLoading];
   // [JSPatchCode syncUpdate];
    //UIKeyboardDidHideNotification
    
    [ZJDownLoader shared];
    return YES;
}

-(void)jsPatchLoading{
    [JPEngine startEngine];
    /*
    //直接使用js描述
    NSString *script = @"\
    var alertView = require('UIAlertView').alloc().init();\
    alertView.setTitle('Alert');\
    alertView.setMessage('这是一个测试弹框');\
    alertView.addButtonWithTitle('ok');\
    alertView.show();\
    ";
     */
    
    //使用本地单个js文件
//    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"demo" ofType:@"js"];
//    NSString *script = [NSString stringWithContentsOfFile:sourcePath encoding:NSUTF8StringEncoding error:nil];
//     [JPEngine evaluateScript:script];
    //使用本地多个js文件，注意路径
    NSString *sourcePaths = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"main.js"];
    [JPEngine evaluateScriptWithPath:sourcePaths];
    
    /*
    // 从网络拉回js脚本执行
   NSURLSessionDataTask *dataTask= [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"https://raw.githubusercontent.com/hotJSPatch/jsv/master/demo.js"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *script = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [JPEngine evaluateScript:script];
    }];
    [dataTask resume];
    */
}

- (void)testDemo
{
    NSLog(@"res1:%@ \n",[self intToBinary:15]);
    NSLog(@"res2:%@ \n",[self intToBinary1:15]);
    
     NSLog(@"res3:%@ \n",[self binaryStringWithInteger:15]);
    NSLog(@"res4:%@ \n",[self paddedBinaryString:15]);
    NSLog(@"res5:%@ \n",[self delimitedBinaryString:15]);
}
//将整数作为NSString转换为二进制数
- (NSString *)intToBinary:(int)intValue{
    int byteBlock = 8,            // 8 bits per byte
    totalBits = (sizeof(int)) * byteBlock, // Total bits
    binaryDigit = totalBits; // Which digit are we processing
    // C array - storage plus one for null
    char ndigit[totalBits + 1];
    while (binaryDigit-- > 0)
    {
        // Set digit in array based on rightmost bit
        ndigit[binaryDigit] = (intValue & 1) ? '1' : '0';
        // Shift incoming value one to right
        intValue >>= 1;
    }
    // Append null
    ndigit[totalBits] = 0;
    // Return the binary string
    return [NSString stringWithUTF8String:ndigit];
    
}

//用NSString转换整数为二进制字串
- (NSString *)intToBinary1:(int)intValue
{
    int byteBlock = 8,    // 每个字节8位
    totalBits = sizeof(int) * byteBlock, // 总位数（不写死，可以适应变化）
    binaryDigit = 1;  // 当前掩（masked）位
    NSMutableString *binaryStr = [[NSMutableString alloc] init];   // 二进制字串
    do
    {
        // 检出下一位，然后向左移位，附加 0 或 1
        [binaryStr insertString:((intValue & binaryDigit) ? @"1" : @"0" ) atIndex:0];
        // 若还有待处理的位（目的是为避免在最后加上分界符），且正处于字节边界，则加入分界符|
        if (--totalBits && !(totalBits % byteBlock))
            [binaryStr insertString:@"|" atIndex:0];
        // 移到下一位
        binaryDigit <<= 1;
    } while (totalBits);
    // 返回二进制字串
    return binaryStr;
}
//用NSString转换整数为二进制字符串
- (NSString *)binaryStringWithInteger:(NSInteger)value
{
    NSMutableString *string = [NSMutableString string];
    while (value)
    {
        [string insertString:(value & 1)? @"1": @"0" atIndex:0];
        value /= 2;
    }
    return string;
}
- (NSString *)paddedBinaryString:(NSInteger)value{
    NSMutableString *string = [NSMutableString string];
//    NSInteger value = [self integerValue];
    for (NSInteger i = 0; i < sizeof(value) * 8; i++)
    {
        [string insertString:(value & 1)? @"1": @"0" atIndex:0];
        value /= 2;
    }
    return string;
}

- (NSString *)delimitedBinaryString:(NSInteger)value{
    NSMutableString *string = [NSMutableString string];
//    NSInteger value = [self integerValue];
    for (NSInteger i = 0; i < sizeof(value) * 8; i++)
    {
        if (i && i % 8 == 0) [string insertString:@"|" atIndex:0];
        [string insertString:(value & 1)? @"1": @"0" atIndex:0];
        value /= 2;
    }
    return string;
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
