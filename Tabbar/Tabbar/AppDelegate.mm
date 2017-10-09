//
//  AppDelegate.m
//  Tabbar
//
//  Created by Jion on 15/4/28.
//  Copyright (c) 2015年 Youjuke. All rights reserved.
//

#import "AppDelegate.h"
#import "TabBarController.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTSubscriberInfo.h>

#import <AVFoundation/AVFoundation.h>

@interface AppDelegate ()<NSStreamDelegate,AVAudioRecorderDelegate>
{
    CTCallCenter *_center;
    UIBackgroundTaskIdentifier bgTask;
    
    NSString *_oldSessionCategory;
    //录音
    AVAudioRecorder *_audioRecorder;
}
@property (strong, nonatomic) UINavigationController *navController;

@property (strong, nonatomic) UIViewController *viewController;

@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, strong) NSMutableString *communicationLog;
@property (nonatomic) BOOL sentPing;
@end

const uint8_t pingString[] = "ping\n";
const uint8_t pongString[] = "pong\n";
@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if ([application applicationState] == UIApplicationStateBackground) {
        NSLog(@"系统自动启动");
    }
    [self loadTelAndSMSMessage];
//    [self didSocktConnect];
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[TabBarController alloc] initWithNibName:@"TabBarController" bundle:nil];
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    self.navController.navigationBar.translucent = NO;
    [self.navController.navigationBar setBarTintColor:[UIColor colorWithRed:78.0/255 green:198.0/255 blue:186.0/255 alpha:1.0]];
    [self.navController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:20]}];
    [self.navController.navigationBar setTintColor:[UIColor whiteColor]];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.window.rootViewController = self.navController;
    
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    return YES;
}

-(void)loadTelAndSMSMessage
{
    //目前只知道可以拿来做两件事情：1. 知道目前你这只 iPhone 用的是哪个电信商的服务；2. 知道现在 iPhone 是不是在打电话。
    //用 CTTelephonyNetworkInfo 与 CTCarrier 这两个 class，就可以取得电信商资讯
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = info.subscriberCellularProvider;
    NSLog(@"carrier:%@", carrier );
//  //返回数据
//  carrier:  CTCarrier (0x140dc0) {
//        Carrier name: [中華電信]
//        Mobile Country Code: [466]
//        Mobile Network Code:[92]
//        ISO Country Code:[tw]
//        Allows VOIP? [YES]
//    }
    
    //当你的 iPhone 漫游到了其他网路的时候，就会执行你这段 block，但光是知道手机现在漫游在哪个电信商的网路里头，大概能做的，就是一些跟电信商关系密切的服务之类，你或许可以决定软体里头有哪些功能，一定 要在某个电信商的网路才能用
    info.subscriberCellularProviderDidUpdateNotifier = ^(CTCarrier *carrier) {NSLog(@"carrier>>>:%@", [carrier description]);};
    
    // 输出手机的数据业务信息
    NSLog(@"Radio Access Technology====%@", info.currentRadioAccessTechnology);
    
    //用 CTCallCenter 与 CTCall 这两个 class，便可以知道目前 iPhone 是否在通话中。CTCallCenter 的用途是用来监控是不是有电话打进来、正在接听、或是已经挂断，而 CTCall 则是将每一则通话事件包装成一个物件
    CTCallCenter *center = [[CTCallCenter alloc] init];
    _center = center;
    center.callEventHandler = ^(CTCall *call) {
        NSSet *curCalls = _center.currentCalls;
        NSLog(@"current calls:%@", curCalls);
        NSLog(@"call:%@", [call description]);
        NSLog(@"set==%@",call.callState);
        //返回数据
        //    current calls:{(
        //                    CTCall (0x17003aec0) {
        //                    callState: [CTCallStateIncoming]//正在连接
        //                        Call ID: [EC04F83D-3369-4E02-AAEF-C60AF669BDC0]
        //                    }
        //
        //                    )}
//                          {(
//                            CTCall (0x1702233c0) {
//                            callState: [CTCallStateConnected]//已经接通
//                            Call ID: [D4A3A261-A84F-4A43-881D-74D93B8B7D52]
//                           }
        
        //    current calls:(null)//断开连接无返回值
        //call:
        //    CTCall (0x143400) {
        //           callState: [CTCallStateIncoming]//正在连接
        //           Call ID: [CE5F9337-1990-4254-8797-1CCEA85B061B]
        //                      }
        //    CTCall (0x1702233c0) {
//                     callState: [CTCallStateConnected]//已经接通
//                     Call ID: [D4A3A261-A84F-4A43-881D-74D93B8B7D52]
//                                    }
        //
        //    CTCall (0x10bac0) {
        //          callState: [CTCallStateDisconnected]//断开连接
        //          Call ID: [CE5F9337-1990-4254-8797-1CCEA85B061B]
        //                     }
        //
        
       
        if (curCalls&&[call.callState isEqualToString:@"CTCallStateIncoming"])
        {
            NSLog(@"正在连接不进行录音");
        }
    //&&[call.callState isEqualToString:@"CTCallStateConnected"]
        if (curCalls) {
            NSLog(@"开始录音");
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:_recordingFilePath])
            {
                [[NSFileManager defaultManager] removeItemAtPath:_recordingFilePath error:nil];
            }
            
            _oldSessionCategory = [[AVAudioSession sharedInstance] category];
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
            [_audioRecorder prepareToRecord];
            [_audioRecorder record];
            
        }
        else if (curCalls == nil)
        {
//            if (_audioRecorder.currentTime<1) {
//                NSLog(@"此次录音无效");
//            
//            }else
            {
                NSLog(@"停止录音");
                [_audioRecorder stop];
                [[AVAudioSession sharedInstance] setCategory:_oldSessionCategory error:nil];

            }
            
        }
    };
    
    // Define the recorder setting
    {
        NSString *fileName = [[NSProcessInfo processInfo] globallyUniqueString];
        _recordingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-audio.m4a",fileName]];
        NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
        
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
        [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
        
        // Initiate and prepare the recorder
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:_recordingFilePath] settings:recordSetting error:nil];
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES;
        
    }

    
}

#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    NSLog(@"录音完成了，开始上传服务器");
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    //    NSLog(@"%@: %@",NSStringFromSelector(_cmd),error);
}

-(void)didSocktConnect
{
    if (!self.inputStream)
    {
        // 1
        CFReadStreamRef readStream;
        CFWriteStreamRef writeStream;
        CFStringRef    host = (__bridge CFStringRef)@"127.0.0.1";
        int port = 10000;
//        CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)(self.txtIP.text), [self.txtPort.text intValue], &readStream, &writeStream);
        CFStreamCreatePairWithSocketToHost(NULL, host, port, &readStream, &writeStream);
       
        // 2
        self.sentPing = NO;
        self.communicationLog = [[NSMutableString alloc] init];
        self.inputStream = (__bridge_transfer NSInputStream *)readStream;
        self.outputStream = (__bridge_transfer NSOutputStream *)writeStream;
        [self.inputStream setProperty:NSStreamNetworkServiceTypeVoIP forKey:NSStreamNetworkServiceType];
        
        // 3
        [self.inputStream setDelegate:self];
        [self.outputStream setDelegate:self];
        [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        // 4
        [self.inputStream open];
        [self.outputStream open];
        
        // 5
        [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{
            if (self.outputStream)
            {
                [self.outputStream write:pingString maxLength:strlen((char*)pingString)];
                [self addEvent:@"Ping sent"];
               
            }
        }];
    }
}
- (void)addEvent:(NSString *)event
{
    [self.communicationLog appendFormat:@"%@\n", event];
    if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive)
    {
//        self.txtReceivedData.text = self.communicationLog;
        NSLog(@"communicationLog==%@",self.communicationLog);
    }
    else
    {
        NSLog(@"App is backgrounded. New event: %@", event);
    }
}
#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventNone:
            // do nothing.
            break;
            
        case NSStreamEventEndEncountered:
            [self addEvent:@"Connection Closed"];
            break;
            
        case NSStreamEventErrorOccurred:
            [self addEvent:[NSString stringWithFormat:@"Had error: %@", aStream.streamError]];
            break;
            
        case NSStreamEventHasBytesAvailable:
            if (aStream == self.inputStream)
            {
                uint8_t buffer[1024];
                NSInteger bytesRead = [self.inputStream read:buffer maxLength:1024];
                NSString *stringRead = [[NSString alloc] initWithBytes:buffer length:bytesRead encoding:NSUTF8StringEncoding];
                stringRead = [stringRead stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                
                [self addEvent:[NSString stringWithFormat:@"Received: %@", stringRead]];
                
                if ([stringRead isEqualToString:@"notify"])
                {
                    UILocalNotification *notification = [[UILocalNotification alloc] init];
                    notification.alertBody = @"New VOIP call";
                    notification.alertAction = @"Answer";
                    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                    
                }
                else if ([stringRead isEqualToString:@"ping"])
                {
                    [self.outputStream write:pongString maxLength:strlen((char*)pongString)];
                }
            }
            break;
            
        case NSStreamEventHasSpaceAvailable:
            if (aStream == self.outputStream && !self.sentPing)
            {
                self.sentPing = YES;
                if (aStream == self.outputStream)
                {
                    [self.outputStream write:pingString maxLength:strlen((char*)pingString)];
                    [self addEvent:@"Ping sent"];
                }
            }
            break;
            
        case NSStreamEventOpenCompleted:
            if (aStream == self.inputStream)
            {
                [self addEvent:@"Connection Opened"];
            }
            break;
            
        default:
            break;
    }
}

- (void)backgroundHandler
{
    NSLog(@"11");
    UIApplication *app = [UIApplication sharedApplication];
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"22");
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //在这里写你要在后运行行的代码
    [self loadTelAndSMSMessage];
        while (1) {
            static int i=0;
            i++;
            sleep(1);
            NSLog(@"%d",i);
        }
        
       
    });
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    //当程序被推送到后台的时候调用。所以要设置后台继续运行，则在这个函数里面设置即可
    NSLog(@"后台运行");

    BOOL backgroundAccepted = [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{ [self backgroundHandler]; }];
    
    if (backgroundAccepted)
        
    {
        
        NSLog(@"backgrounding accepted 每十分钟执行一次");
        
    }
    
    [self backgroundHandler];
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    //当程序从后台将要重新回到前台时候调用
   
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    //当应用程序入活动状态执行，这个刚好跟applicationWillResignActive方法相反
    NSLog(@"进入激活状态时条用");
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    //当程序将要退出是被调用，通常是用来保存数据和一些退出前的清理工作。这个需要要设置UIApplicationExitsOnSuspend的键值
    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    //iPhone设备只有有限的内存，如果为应用程序分配了太多内存操作系统会终止应用程序的运行，在终止前会执行这个方法，通常可以在这里进行内存清理工作防止程序被终止
}
- (void)applicationWillResignActive:(UIApplication *)application {
    
    //当应用程序将要入非活动状态执行，在此期间，应用程序不接收消息或事件，比如来电话了
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationSignificantTimeChange:(UIApplication *)application
{
    //当系统时间发生改变时执行
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
//    当程序载入后执行
    NSLog(@"应用程序启动完毕--------");
}

- (void)application:(UIApplication*)application willChangeStatusBarFrame:(CGRect)newStatusBarFrame
{
    //当StatusBar框将要变化时执行
}
- (void)application:(UIApplication*)application willChangeStatusBarOrientation:
(UIInterfaceOrientation)newStatusBarOrientation
           duration:(NSTimeInterval)duration
{
    //当StatusBar框方向将要变化时执行
}

- (void)application:(UIApplication*)application didChangeStatusBarOrientation:(UIInterfaceOrientation)oldStatusBarOrientation
{
    //当StatusBar框方向变化完成后执行
}
- (void)application:(UIApplication*)application didChangeSetStatusBarFrame:(CGRect)oldStatusBarFrame
{
    //当StatusBar框变化完成后执行
}
- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)url
{
    //当通过url执行
    return NO;
}

@end
