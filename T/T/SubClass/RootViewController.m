
//
//  RootViewController.m
//  NewProject
//
//  Created by 学鸿 张 on 13-11-29.
//  Copyright (c) 2013年 Steven. All rights reserved.
//

#import "RootViewController.h"
const CGFloat lineW = 1.0;

@interface RootViewController ()<UIAlertViewDelegate>
@property (nonatomic, strong)UIImageView *bgImageView;
@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];


    [self loadCustomNav];
    
    
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        
        return;
    }
   

//	UIButton * scanButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [scanButton setTitle:@"取消" forState:UIControlStateNormal];
//    scanButton.frame = CGRectMake((ScreenWidth-120)/2, 420, 120, 40);
//    [scanButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:scanButton];
    
//    UILabel * labIntroudction= [[UILabel alloc] initWithFrame:CGRectMake((ScreenWidth-290)/2, 40, 290, 50)];
//    labIntroudction.backgroundColor = [UIColor clearColor];
//    labIntroudction.numberOfLines=2;
//    labIntroudction.textColor=[UIColor whiteColor];
//    labIntroudction.text=@"将二维码图像置于矩形方框内，离手机摄像头10CM左右，系统会自动识别。";
//    [self.view addSubview:labIntroudction];
    
//    //边框
//    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake((ScreenWidth-300)/2, 100, 300, 300)];
//    imageView.image = [UIImage imageNamed:@"pick_bg"];
//    [self.view addSubview:imageView];
    
    
    CGFloat height = [UIScreen mainScreen].bounds.size.height - 64.f;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    upOrdown = NO;
    num =0;
//    _line = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth -220)/2, 110, 220, 2)];
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(.15*width,.15*height +64,0.7*width,lineW)];
    [_line setCenter:self.view.center];
//    [_line setCenterX:self.view.center.x];
//    _line.image = [UIImage imageNamed:@"line.png"];
    _line.backgroundColor = [UIColor greenColor];
    [self.view addSubview:_line];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
    
   
    
    
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, width,height)];
    [self.view addSubview:bgView];
    UIImage *image = [self drawImage:CGSizeMake(width, height) centerFrame:CGRectMake(.15*width,.15*height,0.7*width,0.7*width)];
    bgView.image = image;
    self.bgImageView = bgView;

}
- (void)loadCustomNav
{
    UIView *navBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    navBgView.backgroundColor =  [UIColor blueColor];
    [self.view addSubview:navBgView];
    
    UILabel *tittleLable = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2.f - 100, 20, 200, 44)];
    tittleLable.text = @"扫描二维码";
    tittleLable.textAlignment =  1;
    tittleLable.textColor = [UIColor whiteColor];
    tittleLable.font = [UIFont systemFontOfSize:18.f];
    [navBgView addSubview:tittleLable];
    
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeSystem];
    float cancelWidth = 50;
    float cancelHeight = 44;
    cancel.frame = CGRectMake(self.view.frame.size.width  - cancelWidth, 20, cancelWidth, cancelHeight);
    [cancel addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [cancel setTitle:@"取消" forState:UIControlStateNormal];
    [cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [navBgView addSubview:cancel];
    
}

- (UIImage *)drawImage:(CGSize)imageSize centerFrame:(CGRect)frame
{
   
    
    UIGraphicsBeginImageContext(imageSize);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(ctx, 0,0,0,0.5);
    
    CGRect drawRect =CGRectMake(0, 0, imageSize.width,imageSize.height);
    
    CGContextFillRect(ctx, drawRect);   //draw the transparent layer
    
    drawRect = frame;
    CGContextClearRect(ctx, drawRect);//clear the center rect  of the layer
    
    [[UIColor whiteColor] set];
    
    UIRectFill(CGRectMake(frame.origin.x , frame.origin.y,frame.size.width, .5f));
    UIRectFill(CGRectMake(frame.origin.x, frame.origin.y ,.5f, frame.size.width));
    UIRectFill(CGRectMake(frame.origin.x, frame.origin.y -.5f + frame.size.height,frame.size.width,.5f));
    UIRectFill(CGRectMake(frame.origin.x -.5f + frame.size.width, frame.origin.y,.5f, frame.size.height));
    
    
    [[UIColor blueColor] set];
    CGFloat height = 20.f;
    CGFloat width = 2.f;
    UIRectFill(CGRectMake(frame.origin.x, frame.origin.y,height, width));
    UIRectFill(CGRectMake(frame.origin.x, frame.origin.y,width, height));
    UIRectFill(CGRectMake(frame.origin.x, frame.origin.y + frame.size.height - height,width, height));
    UIRectFill(CGRectMake(frame.origin.x, frame.origin.y + frame.size.height - width,height, width));
    
    UIRectFill(CGRectMake(frame.origin.x + frame.size.width - height, frame.origin.y,height, width));
    UIRectFill(CGRectMake(frame.origin.x + frame.size.width - width, frame.origin.y,width, height));
    UIRectFill(CGRectMake(frame.origin.x + frame.size.width - width , frame.origin.y + frame.size.height - height,width, height));
    UIRectFill(CGRectMake(frame.origin.x + frame.size.width - height, frame.origin.y + frame.size.height - width,height, width));
    
    
    UIImage* returnimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return returnimage;
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)animation1
{
    
    CGFloat height = [UIScreen mainScreen].bounds.size.height - 64.f;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    if (upOrdown == NO) {
        num ++;
//        _line.frame = CGRectMake((ScreenWidth-220)/2, 110+2*num, 220, 2);
        _line.frame =  CGRectMake(.15*width , .15*height +64  + 2*num, 0.7*width, lineW);
        if (2*num >= 0.7*width ) {
            upOrdown = YES;
        }
    }
    else {
        num --;
//        _line.frame = CGRectMake((ScreenWidth -220)/2, 110+2*num, 220, 2);
        _line.frame = CGRectMake(.15*width , .15*height + 64 + 2*num, 0.7*width, lineW);
        if (_line.frame.origin.y <= .15*height + 64 ) {
            upOrdown = NO;
        }
    }

}
-(void)backAction
{
    
    [self dismissViewControllerAnimated:YES completion:^{
        [timer invalidate];
    }];
}
-(void)viewWillAppear:(BOOL)animated
{
    NSString *mediaType = AVMediaTypeVideo;
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        
        NSLog(@"相机权限受限");
        
        return;
        
    }
    
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView * alert =[[UIAlertView alloc]initWithTitle:@"提示" message:@"当前相机功能不可用，无法扫描二维码！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
       // return;
    }
    
        [self setupCamera];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    
    [_session stopRunning];
}

- (void)setupCamera
{
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
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
    _output.metadataObjectTypes =[NSArray arrayWithObjects:AVMetadataObjectTypeQRCode,AVMetadataObjectTypeCode39Code,AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeCode39Mod43Code,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode93Code,nil];
    
    
    
    

    CGFloat height = [UIScreen mainScreen].bounds.size.height - 64.f;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    CGRect cropRect = CGRectMake(.15*width,.15*height,0.7*width,0.7*width
                                 );
    CGFloat p1 = height/width;
    CGFloat p2 = 1920./1080.; //使用了1080p的图像输出
    if (p1 < p2) {
        CGFloat fixHeight = self.view.bounds.size.width * 1920. / 1080.;
        CGFloat fixPadding = (fixHeight - height)/2;
        _output.rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                                            cropRect.origin.x/width,
                                            cropRect.size.height/fixHeight,
                                            cropRect.size.width/width);
    } else {
        CGFloat fixWidth = self.view.bounds.size.height * 1080. / 1920.;
        CGFloat fixPadding = (fixWidth - width)/2;
        _output.rectOfInterest = CGRectMake(cropRect.origin.y/height,
                                            (cropRect.origin.x + fixPadding)/fixWidth,
                                            cropRect.size.height/height,
                                            cropRect.size.width/fixWidth);
    }
    
    
    
    // Preview
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
//    _preview.frame =CGRectMake((ScreenWidth-280)/2,110,280,280);
    _preview.frame =CGRectMake(0,64,width,height);
    [self.view.layer insertSublayer:self.preview atIndex:0];
    

    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.7 * width + .15 * height + 64.f + 20.f, width, 44.f)];
    contentLabel.textAlignment = NSTextAlignmentCenter;
    contentLabel.textColor = [UIColor grayColor];
    contentLabel.font = [UIFont systemFontOfSize:12.f];
    contentLabel.text = @"将二维码/条形码放入框内，即可自动扫描";
    [self.view addSubview:contentLabel];
    
    
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
        
        /*
         *
         */
      
        [[NSNotificationCenter defaultCenter]postNotificationName:@"qcode" object:stringValue];
        
        
        
        [self dismissViewControllerAnimated:YES completion:^
         {
             [timer invalidate];
             [[NSNotificationCenter defaultCenter]postNotificationName:@"qcode" object:stringValue];
//             NSString *regex = @"http+:[^\\s]*";
//             NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
//
//             NSString * str =@"^(UID:)[0-9,a-z,A-Z]+$";
//             NSPredicate *predicateSSid = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",str];
//             
//             if ([predicate evaluateWithObject:stringValue]) {
//                 [[UIApplication sharedApplication]openURL:[NSURL URLWithString:stringValue]];
//                  NSLog(@"http:_________%@",stringValue);
//                 
//             }
//            if ([predicateSSid evaluateWithObject:stringValue]){
//                 NSLog(@"UID:____________%@",stringValue);
//                
//             }
//             else{
//             
//              NSLog(@"other:____________%@",stringValue);
//             }
         }];
    }
    
    [_session stopRunning];
    [timer invalidate];
    

}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
