//
//  MessageViewController.m
//  Tabbar
//
//  Created by Jion on 15/4/28.
//  Copyright (c) 2015年 Youjuke. All rights reserved.
//

#import "MessageViewController.h"
#import "IQAudioRecorderController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#import "DownloadController.h"
#import <ImageIO/ImageIO.h>
#import "ImageCollectionVC.h"


@interface MessageViewController ()<UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,IQAudioRecorderControllerDelegate>
{
    UIImageView *_imgView;
    
    NSString *audioFilePath;
    UIButton *buttonPlayAudio;
}

@property(nonatomic,strong)UIButton *getMessageCodeButton;
@property(nonatomic,assign)NSInteger currentLeftSeconds;
@end

@implementation MessageViewController
- (id)init
{
    self = [super init];
    if (self) {
        self.tabBarItem.image = [[UIImage imageNamed:@"tab_button_message@2x"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"tab_button_message@2x"];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
     self.tabBarController.navigationItem.title = @"消息";
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 80, 100, 100)];
    _imgView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_imgView];
    UIButton *but = [UIButton buttonWithType:UIButtonTypeSystem];
    [but setTitle:@"获取相册图片" forState:UIControlStateNormal];
    but.frame = CGRectMake(10, 10, 100, 40);
    [but addTarget:self action:@selector(abcd) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:but];
    
    UIButton *but1 = [UIButton buttonWithType:UIButtonTypeSystem];
    [but1 setTitle:@"录音" forState:UIControlStateNormal];
    but1.frame = CGRectMake(10,200, 60, 60);
    [but1 addTarget:self action:@selector(recordAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:but1];
    
    buttonPlayAudio = [UIButton buttonWithType:UIButtonTypeSystem];
    [buttonPlayAudio setTitle:@"播放" forState:UIControlStateNormal];
    buttonPlayAudio.frame = CGRectMake(100,200, 60, 60);
    [buttonPlayAudio addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    buttonPlayAudio.tag = 2;
    buttonPlayAudio.enabled = NO;
    [self.view addSubview:buttonPlayAudio];
    
    UIButton *but3 = [UIButton buttonWithType:UIButtonTypeSystem];
    [but3 setTitle:@"播放电话录音" forState:UIControlStateNormal];
    but3.frame = CGRectMake(200,200, 100, 60);
    [but3 addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    but3.tag = 4;
    
    [self.view addSubview:but3];
    UIButton *but4 = [UIButton buttonWithType:UIButtonTypeSystem];
    [but4 setTitle:@"下载" forState:UIControlStateNormal];
    but4.frame = CGRectMake(10,280, 60, 60);
    [but4 addTarget:self action:@selector(downloadAction:) forControlEvents:UIControlEventTouchUpInside];
    but4.tag = 5;
    
    [self.view addSubview:but4];
    
    //倒计时
    self.getMessageCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.getMessageCodeButton.frame = CGRectMake(150, 10, 60, 40);
    [self.getMessageCodeButton setTitle:NSLocalizedString(@"倒计时", nil) forState:UIControlStateNormal];
    [self.getMessageCodeButton addTarget:self action:@selector(countDown) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.getMessageCodeButton];
    self.currentLeftSeconds = 60;
    [self BubbleStretch];
    [self gifAnimation];
}

#pragma mark--gif图片动画
- (void)gifAnimation
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"test.gif" withExtension:nil];
    CGImageSourceRef csf = CGImageSourceCreateWithURL((__bridge CFTypeRef) url, NULL);
    size_t const count = CGImageSourceGetCount(csf);
    UIImage *frames[count];
    CGImageRef images[count];
    for (size_t i = 0; i<count; ++i) {
        images[i] = CGImageSourceCreateImageAtIndex(csf, i, NULL);
        UIImage *image = [[UIImage alloc] initWithCGImage:images[i]];
        frames[i] = image;
        CFRelease(images[i]);
        
    }
    CGFloat duration = 0.1*count;
    UIImage *const animation = [UIImage animatedImageWithImages:[NSArray arrayWithObjects:frames count:count] duration:duration];
    UIImageView *view2 = [[UIImageView alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - 150, 0, 150, 150)];
    [view2 setImage:animation];
    [self.view addSubview:view2];
    CFRelease(csf);
}

#pragma mark-- 气泡拉伸，实现箭头不变形
- (void)BubbleStretch
{
    UIImage *image = [UIImage imageNamed:@"popover.png"];
    //ios5.0以前
//    image = [image stretchableImageWithLeftCapWidth:10 topCapHeight:20];
    //ios5.0
//    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 20)];
    //ios6.0
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(20, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    
    UIImageView *bubble = [[UIImageView alloc] initWithImage:image];
    
    bubble.frame = CGRectMake(10, 350, 200, 80);
    
    [self.view addSubview:bubble];
}
#pragma mark --GCD实现倒计时
/*
 倒计时
 */
- (void)countDown {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0*NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        if (self.currentLeftSeconds <= 0) {
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.currentLeftSeconds = 60;
                self.getMessageCodeButton.enabled = YES;
                [self.getMessageCodeButton setTitle:NSLocalizedString(@"验证", nil) forState:UIControlStateNormal];
                
            });
        }
        else
        {
            self.currentLeftSeconds--;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.getMessageCodeButton.enabled = NO;
                [self.getMessageCodeButton setTitle:[NSString stringWithFormat:@"%ld%@",(long)self.currentLeftSeconds,NSLocalizedString(@"秒", nil)] forState:UIControlStateDisabled];
            });
        }
    });
    
    dispatch_resume(_timer);
}

- (void)say {
    
    /*
     主要依赖AVSpeechSynthesizer，AVSpeechUtterance,AVSpeechSynthesisVoice,要使用这些类必须先加入
     
     AVFoundation框架
     */
    //语音合成器
   AVSpeechSynthesizer * synthesizer = [[AVSpeechSynthesizer alloc] init];
    
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:@"123456"];
    NSLog(@"%@",[AVSpeechSynthesisVoice speechVoices]);
    //设置语言类别
    AVSpeechSynthesisVoice *voice= [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-TW"];
    utterance.voice = voice;
    //设置语速快慢
    utterance.rate *= 0.2;
    
    //音调调节
    utterance.pitchMultiplier = 1.5;
    //音量大小
    utterance.volume = 1.0;
    //开始语音延迟
    utterance.preUtteranceDelay = 0;
    //结束语音延迟
    utterance.postUtteranceDelay = 0.3;
    [synthesizer speakUtterance:utterance];
}


#pragma mark--下载界面
- (void)downloadAction:(UIButton*)sender
{
    DownloadController *down = [[DownloadController alloc] init];
    [self.navigationController pushViewController:down animated:YES];
}

- (void)recordAction
{
    IQAudioRecorderController *controller = [[IQAudioRecorderController alloc] init];
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}
- (void)playAction:(UIButton*)sender
{
    switch (sender.tag) {
        case 2:{
            
            MPMoviePlayerViewController *controller = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:audioFilePath]];
            [self presentMoviePlayerViewControllerAnimated:controller];
        }
            
            break;
        case 4:{
            AppDelegate *app = [UIApplication sharedApplication].delegate;
            NSString *path = app.recordingFilePath;
            NSLog(@"path =%@",path);
            
            NSFileManager* manager = [NSFileManager defaultManager];
            long long fileSize =0;
            if ([manager fileExistsAtPath:path]){
                //获取文件大小  filesize 返回为kB
              fileSize = [[manager attributesOfItemAtPath:path error:nil] fileSize]/1024.0;
            }
            if (fileSize<1.0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"目前没有电话录音" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
                return;
            }

            MPMoviePlayerViewController *controller = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:path]];
            [self presentMoviePlayerViewControllerAnimated:controller];
        }
            
            break;
        default:
            break;
    }
    
}

- (void)saveImage:(UIImage *)image {
    NSLog(@"保存");
//   NSString *tempPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/salesImageSmall.jpg"];
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:@"salesImageSmall.jpg"];
    UIImage *img=[[UIImage alloc]initWithContentsOfFile:fullPathToFile];
    [_imgView setImage:img];
}

- (void)abcd
{
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"选择图片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相册",@"拍照",@"多选", nil];
    as.tag = 111;
    [as showInView:self.view];
    as.delegate = self;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (actionSheet.tag==111) {
        
        if (buttonIndex == 2){
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            ImageCollectionVC *imageCollection = [[ImageCollectionVC alloc] initWithCollectionViewLayout:layout];
            imageCollection.title = @"图片多选";
            [self.navigationController pushViewController:imageCollection animated:YES];
        }
       else if (buttonIndex == 1) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
               
                [self pickImageWithType:UIImagePickerControllerSourceTypeCamera];
            }
            else
            {
                NSLog(@"不支持相机");
            }
        }else if(buttonIndex == 0){
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                [self pickImageWithType:UIImagePickerControllerSourceTypePhotoLibrary];
            }
            else
            {
                NSLog(@"不支持相册");
            }
        }
    }
}
-(void)pickImageWithType:(UIImagePickerControllerSourceType)type
{
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.sourceType = type;
    picker.allowsEditing = YES;
    
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark --UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image= [info objectForKey:UIImagePickerControllerEditedImage];
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        //        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }
   UIImage *theImage = [self imageWithImageSimple:image scaledToSize:CGSizeMake(120.0, 120.0)];
    UIImage *midImage = [self imageWithImageSimple:image scaledToSize:CGSizeMake(210.0, 210.0)];
    UIImage *bigImage = [self imageWithImageSimple:image scaledToSize:CGSizeMake(440.0, 440.0)];
    
    [self saveImage:theImage WithName:@"salesImageSmall.jpg"];
    [self saveImage:midImage WithName:@"salesImageMid.jpg"];
    [self saveImage:bigImage WithName:@"salesImageBig.jpg"];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    [self saveImage:nil];
}
#pragma mark 保存图片到document
- (void)saveImage:(UIImage *)tempImage WithName:(NSString *)imageName
{
    NSData* imageData = UIImagePNGRepresentation(tempImage);
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    // Now we get the full path to the file
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:imageName];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if(![manager fileExistsAtPath:fullPathToFile])
    {
    //创建文件夹 [manager createDirectoryAtPath:<#(NSString *)#> withIntermediateDirectories:<#(BOOL)#> attributes:<#(NSDictionary *)#> error:<#(NSError *__autoreleasing *)#>]
        [manager createFileAtPath:fullPathToFile contents:nil attributes:nil];
    }

    // and then we write it out
    [imageData writeToFile:fullPathToFile atomically:NO];
}
//压缩图片
- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark--IQAudioRecorderControllerDelegate
-(void)audioRecorderController:(IQAudioRecorderController *)controller didFinishWithAudioAtPath:(NSString *)filePath
{
    //点击完成的时候调用
    audioFilePath = filePath;
    buttonPlayAudio.enabled = YES;
}

-(void)audioRecorderControllerDidCancel:(IQAudioRecorderController *)controller
{
    //点击取消的时候调用
    buttonPlayAudio.enabled = NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
