//
//  ViewController.m
//  T
//
//  Created by Jion on 15/5/5.
//  Copyright (c) 2015年 Youjuke. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <sqlite3.h>
#import "QRCodeGenerator.h"
#import "RootViewController.h"
#import "BBFlashCtntLabel.h"
#import "LSPaoMaView.h"

#define ScreenHigh   [[UIScreen mainScreen] bounds].size.height
#define ScreenWidth   [[UIScreen mainScreen] bounds].size.width
@interface ViewController ()<UIScrollViewDelegate,AVCaptureMetadataOutputObjectsDelegate,UIActionSheetDelegate>
{
    UIImageView *imgView;
    UIScrollView *_samllScrollView;
    NSString     *isURL;
    
    UILocalNotification *localNotification;
}
@property ( strong , nonatomic ) AVCaptureDevice * device;

@property ( strong , nonatomic ) AVCaptureDeviceInput * input;

@property ( strong , nonatomic ) AVCaptureMetadataOutput * output;

@property ( strong , nonatomic ) AVCaptureSession * session;

@property ( strong , nonatomic ) AVCaptureVideoPreviewLayer * preview;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSDictionary *mutableDic1 = @{@"num":@"1",@"key":@"2",@"name":@"中国"};
    NSEnumerator *enumerator=[mutableDic1 keyEnumerator];
    id key;
    while(key=[enumerator nextObject]){
        id object=[mutableDic1 objectForKey:key];
        NSLog(@"object:%@",object);
        
    }
    //// 获取Documents目录路径
   NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    // 获取沙盒主目录路径
    NSString *homeDir = NSHomeDirectory();
    
    [self paoMaDeng];
    //循环跑马灯
    NSString* text = @"两块钱,你买不了吃亏,两块钱,你买不了上当,真正的物有所值,拿啥啥便宜,买啥啥不贵,都两块,买啥都两块,全场卖两块,随便挑,随便选,都两块！";
    
    LSPaoMaView* paomav = [[LSPaoMaView alloc] initWithFrame:CGRectMake(10, 64, self.view.bounds.size.width-20, 44) title:text];
    paomav.backgroundColor=[UIColor clearColor];
    [self.view addSubview:paomav];
    //通话记录
    [self readCallLogs];
    
}

- (void)readCallLogs
{
    NSMutableArray*   _dataArray = [[NSMutableArray alloc] init];
    
    [_dataArray removeAllObjects];
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *callHisoryDatabasePath = @"/var/wireless/Library/CallHistory/call_history.db";
    BOOL callHistoryFileExist = FALSE;
    callHistoryFileExist = [fileManager fileExistsAtPath:callHisoryDatabasePath];
    
    if(callHistoryFileExist)
    {
        if ([fileManager isReadableFileAtPath:callHisoryDatabasePath])
        {
            sqlite3 *database;
            if(sqlite3_open([callHisoryDatabasePath UTF8String], &database) == SQLITE_OK)
            {
                sqlite3_stmt *compiledStatement;
                NSString *sqlStatement = @"SELECT * FROM call;";
                
                int errorCode = sqlite3_prepare_v2(database, [sqlStatement UTF8String], -1,  &compiledStatement, NULL);
                if( errorCode == SQLITE_OK)
                {
                    int count = 1;
                    
                    while(sqlite3_step(compiledStatement) == SQLITE_ROW)
                    {
                        // Read the data from the result row
                        NSMutableDictionary *callHistoryItem = [[NSMutableDictionary alloc] init];
                        int numberOfColumns = sqlite3_column_count(compiledStatement);
                        NSString *data;
                        NSString *columnName;
                        
                        for (int i = 0; i < numberOfColumns; i++)
                        {
                            columnName = [[NSString alloc] initWithUTF8String:
                                          (char *)sqlite3_column_name(compiledStatement, i)];
                            
                            data = [[NSString alloc] initWithUTF8String:
                                    (char *)sqlite3_column_text(compiledStatement, i)];
                            
                            [callHistoryItem setObject:data forKey:columnName];
                            
                        
                        }
                        
                        [_dataArray addObject:callHistoryItem];
                        
                    }
                    
                    count++;
                }
                else
                {
                    NSLog(@"Failed to retrieve table");
                    NSLog(@"Error Code: %d", errorCode);
                }
                sqlite3_finalize(compiledStatement);
            }
        }
    }
    NSLog(@"%@",_dataArray);
}

//需要真机测试
- (void)setupCamera
{
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
//     [ _output setRectOfInterest : CGRectMake (( 124 )/ ScreenHigh ,(( ScreenWidth - 220 )/ 2 )/ ScreenWidth , 220 / ScreenHigh , 220 / ScreenWidth )];
//    [_output setRectOfInterest:CGRectMake(0.5, 0, 0.5, 1)];
 
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    // 条码类型 AVMetadataObjectTypeQRCode
    _output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];//@[AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeUPCECode,AVMetadataObjectTypeCode39Code,AVMetadataObjectTypeCode39Mod43Code,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode93Code,AVMetadataObjectTypePDF417Code,AVMetadataObjectTypeQRCode,AVMetadataObjectTypeAztecCode,AVMetadataObjectTypeInterleaved2of5Code,AVMetadataObjectTypeITF14Code,AVMetadataObjectTypeDataMatrixCode] ;
    
    // Preview
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.bounds =CGRectMake(0,0,200,150);
    _preview.position = CGPointMake(CGRectGetMaxX(_zbrImage.frame)+5 + _preview.bounds.size.width*0.5, _zbrImage.frame.origin.y+ _preview.bounds.size.height*0.5);
    
//    _preview . frame = self . view . layer . bounds ;
    [self.view.layer insertSublayer:self.preview atIndex:0];
    
    
    
    // Start
    [_session startRunning];
}
#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    NSString *stringValue;
    
    if ([metadataObjects count] >0)
    {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
        isURL = stringValue;
    }
    
    [_session stopRunning];
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"结果：%@",stringValue] delegate:self cancelButtonTitle:nil otherButtonTitles:@"知道了",@"重新扫描", nil];
    [alert show];
    //生成二维码
//     _zbrImage.image = [QRCodeGenerator qrImageForString:stringValue imageSize:_zbrImage.bounds.size.width];
    _zbrImage.image = [self QRCodeGeneratorImageWithString:stringValue];
    _zbrImage.userInteractionEnabled = YES;
    UIImageView *iocon = [[UIImageView alloc] init];
    iocon.backgroundColor = [UIColor clearColor];
    iocon.bounds = CGRectMake(0, 0, 40, 40);
    CGFloat w = _zbrImage.bounds.size.width;
    CGFloat h = _zbrImage.bounds.size.height;
    iocon.center = CGPointMake(w/2, h/2);
    [iocon setImage:[UIImage imageNamed:@"img.jpg"]];
    [_zbrImage addSubview:iocon];
    

    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGestreHandle:)];
    longGesture.minimumPressDuration = 1.0;
    [_zbrImage addGestureRecognizer:longGesture];
}

//系统生成二维码
- (UIImage*)QRCodeGeneratorImageWithString:(NSString*)string
{
    //1.创建滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    //2.恢复默认
    [filter setDefaults];
    //3.给滤镜添加数据
    //将数据转换成NSData类型
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    //通过KVC设置滤镜的二维码输入信息
    [filter setValue:data forKey:@"inputMessage"];
    //纠错级别
    [filter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
     //4.获取输出的二维码图片（CIImage类型）
    CIImage *outImage = filter.outputImage;
    //将CIImage类型的图片装换成UIImage类型的图片
//    UIImage *image = [UIImage imageWithCIImage:outImage];
   UIImage *image = [self createNonInterpolatedUIImageFormCIImage:outImage withSize:300];
    //改变背景色
    UIImage *reslustImage = [self imageBlackToTransparent:image withRed:0 andGreen:0 andBlue:0];
    return reslustImage;
}
#pragma mark - InterpolatedUIImage
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // create a bitmap image that we'll draw into a bitmap context at the desired size;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // Create an image with the contents of our bitmap
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    // Cleanup
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

#pragma mark - imageToTransparent
void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}
- (UIImage*)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue{
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    // create context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
//    // traverse pixe
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900){
            // change color
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }else{
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    // context to image
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    // release
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}


- (void)longGestreHandle:(UILongPressGestureRecognizer*)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
         NSLog(@"长安手势");
        if ([isURL rangeOfString:@"http://"].location != NSNotFound) {
            UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"识别二维码", nil];
            sheet.tag = 190;
            [sheet showInView:self.view];
        }
        
    }
   
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
        if(buttonIndex == 0)
        {
            [self dismissViewControllerAnimated:YES completion:^
             {
                 //             [timer invalidate];
             }];
            
        }
        else
        {
            [_session startRunning];
        }

}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    NSLog(@"缩放比例:%f",scale);
    
}

//用户使用捏合手势时调用
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
   
    
    return imgView;
}
//缩放中
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    NSLog(@"12");
    imgView.center = scrollView.center;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
//     [self performSegueWithIdentifier:@"1" sender:self];
     [segue destinationViewController];
     NSLog(@"2222");
 }


- (UILabel*)label
{
    UILabel *label = [[UILabel alloc] init];
    return label;
}
#pragma mark--跑马灯

- (void)paoMaDeng{
    for (int i = 0; i < 5; i++) {
        CGRect rect = CGRectMake(150, 30+64 + i * 42, 180, 40);
        BBFlashCtntLabel *lbl = [[BBFlashCtntLabel alloc] initWithFrame:rect];
        lbl.backgroundColor = [UIColor lightGrayColor];
        lbl.leastInnerGap = 50.f;
        if (i % 3 == 0) {
            lbl.repeatCount = 5;
            lbl.speed = BBFlashCtntSpeedSlow;
        } else if (i % 3 == 1) {
            lbl.speed = BBFlashCtntSpeedMild;
        } else {
            lbl.speed = BBFlashCtntSpeedFast;
        }
        NSString *str = @"测试文字。来来；‘了哈哈😄^_^abcdefg123456👿";
        
        if (i %2 == 0) {
            lbl.text = str;
            lbl.font = [UIFont systemFontOfSize:20];
            lbl.textColor = [UIColor whiteColor];
        } else {
            NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:str];
            [att addAttribute:NSFontAttributeName
                        value:[UIFont systemFontOfSize:25]
                        range:NSMakeRange(0, 5)];
            [att addAttribute:NSFontAttributeName
                        value:[UIFont systemFontOfSize:17]
                        range:NSMakeRange(15, 5)];
            [att addAttribute:NSBackgroundColorAttributeName
                        value:[UIColor cyanColor]
                        range:NSMakeRange(0, 15)];
            [att addAttribute:NSForegroundColorAttributeName
                        value:[UIColor redColor]
                        range:NSMakeRange(8, 7)];
            lbl.attributedText = att;
        }
        /*
        //少量文字的时候不显示了？
        if (i == 0) {
            lbl.textColor = [UIColor greenColor];
            lbl.text = @"少量文字";
        }
         */
        
        [self.view addSubview:lbl];
    }
    

}

#pragma mark--Action
- (IBAction)showImage:(id)sender {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-100)];
    //    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 1000);
    //    scrollView.alwaysBounceHorizontal = YES;
    scrollView.alwaysBounceVertical = YES;
    scrollView.delegate = self;
    scrollView.bounces = NO;
    scrollView.bouncesZoom = NO;
    scrollView.minimumZoomScale = 0.5;
    scrollView.maximumZoomScale = 3.0;
    scrollView.userInteractionEnabled = YES;
    scrollView.backgroundColor = [UIColor redColor];
    //    scrollView.showsHorizontalScrollIndicator = YES;
    //    scrollView.pagingEnabled = YES;
    [self.view addSubview:scrollView];
    
    imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 375, 600)];
    imgView.image = [UIImage imageNamed:@"img.jpg"];
    
    scrollView.contentSize = imgView.image.size;
    [scrollView addSubview:imgView];

}

- (IBAction)removeImage:(id)sender {
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            [view removeFromSuperview];
        }
    }
}

- (IBAction)QRCodeAction:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"我的二维码" otherButtonTitles:@"老贾的二维码", nil];
        [sheet showInView:self.view];
        
        
       
    }else
    {
        UIAlertView  *aler = [[UIAlertView alloc] initWithTitle:nil message:@"请在真机上运行" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [aler show];
    }
    
}

//本地通知
- (IBAction)localNotification:(UIButton*)sender {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    if (!localNotification) {
        localNotification = [[UILocalNotification alloc] init];
    }
    //设置默认8：25的通知
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    NSInteger hourTime = [_hour.text integerValue]==0?8:[_hour.text integerValue];
    dateComponents.hour = hourTime;
    NSInteger mimuteTime = [_minute.text integerValue]==0?25:[_minute.text integerValue];
    dateComponents.minute = mimuteTime;
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
    
    //设置本地通知的触发时间（如果要立即触发，无需设置），这里设置为10妙后
    localNotification.fireDate = date;//[NSDate dateWithTimeIntervalSinceNow:10];
    //设置本地通知的时区
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    // 设置重复的间隔
    localNotification.repeatInterval = kCFCalendarUnitDay;
    
    //设置通知的内容
    localNotification.alertBody = @"上班时间到了";
    //设置通知动作按钮的标题
    localNotification.alertAction = @"查看";
    //设置提醒的声音，可以自己添加声音文件，这里设置为默认提示声
//    localNotification.soundName = UILocalNotificationDefaultSoundName;
    //添加自定义声音文件时需要勾选add to target.否则不起作用
    localNotification.soundName = @"sound.caf";
    //设置通知的相关信息，这个很重要，可以添加一些标记性内容，方便以后区分和获取通知的信息
    NSDictionary *infoDic = [NSDictionary dictionaryWithObjectsAndKeys:@"affair.schedule",@"id",@"你有新消息",@"content", nil];
    localNotification.userInfo = infoDic;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
    // ios8后，需要添加这个注册，才能得到授权
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        // 通知重复提示的单位，可以是天、周、月
//        notification.repeatInterval = NSCalendarUnitDay;
    }
//    else {
        // 通知重复提示的单位，可以是天、周、月
//        notification.repeatInterval = NSDayCalendarUnit;
//    }
    
#else
#endif
    //在规定的日期触发通知
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    //显示在icon上的红色圈中的数子
    NSInteger coun = [[[UIApplication sharedApplication] scheduledLocalNotifications] count];
   coun = coun==0?1:coun;
    localNotification.applicationIconBadgeNumber = coun;
    
    //立即触发一个通知
//    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
  
}

#pragma mark----ActinSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 190) {
        if (buttonIndex != 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:isURL]];
        }
        
    }
    else
    {
        if (buttonIndex == 0) {
            [self setupCamera];
        }else if(buttonIndex == 1){
            [self pushRootVC];
        }
    }
    
}
- (void)pushRootVC {
    RootViewController *rootVC = [[RootViewController alloc] init];
    
    [self.navigationController pushViewController:rootVC animated:YES];
}

#pragma mark--去除第一响应
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
