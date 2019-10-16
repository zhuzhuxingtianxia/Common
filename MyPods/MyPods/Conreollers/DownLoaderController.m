//
//  DownLoaderController.m
//  MyPods
//
//  Created by ZZJ on 2019/10/15.
//  Copyright © 2019 Youjuke. All rights reserved.
//

#import "DownLoaderController.h"
#import "ZJDownLoader.h"
#import <MJRefresh.h>
@interface DownLoaderController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic)UITableView *tableView;
@property (strong, nonatomic)NSArray  *soureData;
@property (strong, nonatomic)UIProgressView *progressView;
@property (strong, nonatomic)UILabel *progressLabel;
@property (copy, nonatomic)NSString *downLoadUrl;
@property (strong, nonatomic)NSURLSessionDownloadTask *task;
@end

@implementation DownLoaderController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    
    _downLoadUrl =@"https://raw.githubusercontent.com/zhuzhuxingtianxia/MyPlayer/master/38025-GALA-YOUNGFORYOU%5B68mtv.com%5D.mp4";
//    _downLoadUrl = @"https://www.apple.com/105/media/cn/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-cn-20170912_1280x720h.mp4";
    
    [self buildADownLoader:self.view initY:100];
    self.task = [[ZJDownLoader shared] getTaskWithUrl:_downLoadUrl];
    
    [self buildTable];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downLoadProgress:) name:ZJDownloadProgressNotification object:nil];
}

-(void)dealloc {
    NSLog(@"dealloc 方法");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)downLoadProgress:(NSNotification *)notification {
    NSURLSessionDownloadTask *task = notification.object;
    if (task == self.task) {
        NSProgress *progress = notification.userInfo[@"progress"];
        CGFloat progressValue = 1.0 * progress.completedUnitCount / progress.totalUnitCount;
        NSLog(@"当前的进度 = %f",progressValue);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressView.progress = progressValue;
            self.progressLabel.text = [NSString stringWithFormat:@"进度:%.3f",progressValue];
        });
    }
}

#pragma mark -- ADownLoader
-(void)buildADownLoader:(UIView*)supView initY:(CGFloat)y {
   UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    progressView.frame = CGRectMake(40, y, 300, 5);
    progressView.tag = 100;
    [supView addSubview:progressView];
    progressView.progress = [[ZJDownLoader shared] progressWithUrl:_downLoadUrl];
    _progressView = progressView;
   
    UILabel *progressLabel = [UILabel new];
    progressLabel.tag = 101;
    progressLabel.font = [UIFont systemFontOfSize:15];
    progressLabel.textAlignment = NSTextAlignmentCenter;
    if (progressView.progress > 0) {
        progressLabel.text = [NSString stringWithFormat:@"进度:%.3f",progressView.progress];
    }else{
        progressLabel.text = @"下载进度";
    }
    
   progressLabel.frame = CGRectMake(progressView.mj_x, CGRectGetMaxY(progressView.frame)+10, progressView.mj_w, 20);
    [supView addSubview:progressLabel];
    
    _progressLabel = progressLabel;
    
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    startBtn.frame = CGRectMake(20, CGRectGetMaxY(progressLabel.frame), 100, 40);
    [startBtn setTitle:@"开始/继续下载" forState:UIControlStateNormal];
    [startBtn addTarget:self action:@selector(startDownLoader:) forControlEvents:UIControlEventTouchUpInside];
    [supView addSubview:startBtn];
    
    UIButton *pauseBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    pauseBtn.frame = CGRectMake(CGRectGetMaxX(startBtn.frame)+20, CGRectGetMaxY(progressLabel.frame), 80, 40);
    [pauseBtn setTitle:@"暂停下载" forState:UIControlStateNormal];
    [pauseBtn addTarget:self action:@selector(pauseDownLoader:) forControlEvents:UIControlEventTouchUpInside];
    [supView addSubview:pauseBtn];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelBtn.frame = CGRectMake(CGRectGetMaxX(pauseBtn.frame)+20, CGRectGetMaxY(progressLabel.frame), 80, 40);
    [cancelBtn setTitle:@"取消下载" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelDownLoader:) forControlEvents:UIControlEventTouchUpInside];
    [supView addSubview:cancelBtn];
}


#pragma mark -- 并发加载
-(void)buildTable {
    
    CGSize size = [[UIScreen mainScreen] bounds].size;
    self.tableView.frame = CGRectMake(0, 200, size.width, size.height - 200);
    
    [self.view addSubview:self.tableView];
    
    self.soureData = @[@"https://raw.githubusercontent.com/zhuzhuxingtianxia/MyPlayer/master/38025-GALA-YOUNGFORYOU%5B68mtv.com%5D.mp4",
                       @"https://www.apple.com/105/media/cn/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-cn-20170912_1280x720h.mp4",
                       @"https://images.apple.com/media/cn/macbook-pro/2016/b4a9efaa_6fe5_4075_a9d0_8e4592d6146c/films/design/macbook-pro-design-tft-cn-20161026_1536x640h.mp4",
                       @"https://www.apple.com/105/media/cn/ipad-pro/how-to/2017/a0f629be_c30b_4333_942f_13a221fc44f3/films/dock/ipad-pro-dock-cn-20160907_1280x720h.mp4",
                       @"https://www.apple.com/105/media/cn/ipad/2018/08716702_0a2f_4b2c_9fdd_e08394ae72f1/films/use-two-apps/ipad-use-two-apps-tpl-cn-20180404_1280x720h.mp4"];
    
    [self.tableView reloadData];
}

#pragma mark -- UITableViewDelegate
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.soureData.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownLoaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[DownLoaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    NSString *urlStr = self.soureData[indexPath.row];
    cell.downLoadUrl = urlStr;
    
    return cell;
}

#pragma mark -- action
-(void)startDownLoader:(UIButton*)btn {
   self.task = [[ZJDownLoader shared] donwLoadWithUrl:_downLoadUrl progress:^(CGFloat progress) {
       
    } targetPath:[self getFileUrl] success:^(NSURL *fileUrlPath, NSURLResponse *response) {
        NSLog(@"下载成功 下载的文档路径是 %@, ",fileUrlPath);
    } failure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"下载失败,%ld",statusCode);
    }];
    
}
-(void)pauseDownLoader:(UIButton*)btn {
    
    [[ZJDownLoader shared] stopDownLoadTaskByUrl:_downLoadUrl];
}

-(void)cancelDownLoader:(UIButton*)btn {
    UIView *supView = btn.superview;
    __weak UIProgressView *progressView = [self getProgressView:supView];
    __weak UILabel *progressLabel = [self getProgressLabel:supView];
    
    [[ZJDownLoader shared] cancelDownLoadTaskByUrl:_downLoadUrl];
    
    progressView.progress = [[ZJDownLoader shared] progressWithUrl:_downLoadUrl];
    if (progressView.progress > 0) {
        progressLabel.text = [NSString stringWithFormat:@"进度:%.3f",progressView.progress];
    }else{
        progressLabel.text = @"下载进度";
    }
}

#pragma mark -- getter
-(NSURL*)getFileUrl {
    NSString *localPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    // 要检查的文件目录
    NSString *filePath = [localPath stringByAppendingPathComponent:@"iphonex.mp4"];
   NSURL *fileUrl = [NSURL fileURLWithPath:filePath isDirectory:NO];
    return fileUrl;
}

-(UIProgressView*)getProgressView:(UIView*)supView {
    UIView *progress = [supView viewWithTag:100];
    UIProgressView *progressView;
    if ([progress isKindOfClass:[UIProgressView class]]) {
        progressView = (UIProgressView*)progress;
    }
    return progressView;
}

-(UILabel*)getProgressLabel:(UIView*)supView {
    UIView *label = [supView viewWithTag:101];
    UILabel *progressLabel;
    if ([label isKindOfClass:[UILabel class]]) {
        progressLabel = (UILabel*)label;
    }
    return progressLabel;
}

-(UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 80;
    }
    return _tableView;
}

@end

@interface DownLoaderCell ()
@property (strong, nonatomic)UIProgressView *progressView;
@property (strong, nonatomic)UILabel *progressLabel;
@property (strong, nonatomic)NSURLSessionDownloadTask *task;
@end

@implementation DownLoaderCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self buildADownLoader:self.contentView initY:5];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downLoadProgress:) name:ZJDownloadProgressNotification object:nil];
    }
    return self;
}
-(void)dealloc {
    NSLog(@"dealloc 方法");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)downLoadProgress:(NSNotification *)notification {
    NSURLSessionDownloadTask *task = notification.object;
    if (task == self.task) {
        NSProgress *progress = notification.userInfo[@"progress"];
        CGFloat progressValue = 1.0 * progress.completedUnitCount / progress.totalUnitCount;
        NSLog(@"当前的进度 = %f",progressValue);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressView.progress = progressValue;
            self.progressLabel.text = [NSString stringWithFormat:@"进度:%.3f",progressValue];
        });
    }
    
    
}

-(void)buildADownLoader:(UIView*)supView initY:(CGFloat)y {
    UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    progressView.frame = CGRectMake(40, y, 300, 5);
    progressView.tag = 100;
    [supView addSubview:progressView];
    
    _progressView = progressView;
    
    UILabel *progressLabel = [UILabel new];
    progressLabel.tag = 101;
    progressLabel.font = [UIFont systemFontOfSize:15];
    progressLabel.textAlignment = NSTextAlignmentCenter;
    if (progressView.progress > 0) {
        progressLabel.text = [NSString stringWithFormat:@"并发进度:%.3f",progressView.progress];
    }else{
        progressLabel.text = @"并发下载进度";
    }
    
    progressLabel.frame = CGRectMake(progressView.mj_x, CGRectGetMaxY(progressView.frame)+10, progressView.mj_w, 20);
    [supView addSubview:progressLabel];
    
    _progressLabel = progressLabel;
    
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    startBtn.frame = CGRectMake(20, CGRectGetMaxY(progressLabel.frame), 100, 40);
    [startBtn setTitle:@"开始/继续下载" forState:UIControlStateNormal];
    [startBtn addTarget:self action:@selector(startDownLoader:) forControlEvents:UIControlEventTouchUpInside];
    [supView addSubview:startBtn];
    
    UIButton *pauseBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    pauseBtn.frame = CGRectMake(CGRectGetMaxX(startBtn.frame)+20, CGRectGetMaxY(progressLabel.frame), 80, 40);
    [pauseBtn setTitle:@"暂停下载" forState:UIControlStateNormal];
    [pauseBtn addTarget:self action:@selector(pauseDownLoader:) forControlEvents:UIControlEventTouchUpInside];
    [supView addSubview:pauseBtn];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelBtn.frame = CGRectMake(CGRectGetMaxX(pauseBtn.frame)+20, CGRectGetMaxY(progressLabel.frame), 80, 40);
    [cancelBtn setTitle:@"取消下载" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelDownLoader:) forControlEvents:UIControlEventTouchUpInside];
    [supView addSubview:cancelBtn];
}

-(void)setDownLoadUrl:(NSString *)downLoadUrl {
    _downLoadUrl = downLoadUrl;
    //判断是否存在
    self.task = [[ZJDownLoader shared] getTaskWithUrl:_downLoadUrl];
    
    _progressView.progress = [[ZJDownLoader shared] progressWithUrl:_downLoadUrl];
    
    if (_progressView.progress > 0) {
        _progressLabel.text = [NSString stringWithFormat:@"并发进度:%.3f",_progressView.progress];
    }else{
        _progressLabel.text = @"并发下载进度";
    }
}

#pragma mark -- action
-(void)startDownLoader:(UIButton*)btn {
    self.task = [[ZJDownLoader shared] donwLoadWithUrl:_downLoadUrl progress:^(CGFloat progress) {
        
    } targetPath:[self getFileUrl:[NSString stringWithFormat:@"%@",[_downLoadUrl componentsSeparatedByString:@"/"].lastObject]] success:^(NSURL *fileUrlPath, NSURLResponse *response) {
        NSLog(@"下载成功 下载的文档路径是 %@, ",fileUrlPath);
    } failure:^(NSError *error, NSInteger statusCode) {
        NSLog(@"下载失败,%ld",statusCode);
    }];
    
}
-(void)pauseDownLoader:(UIButton*)btn {
    
    [[ZJDownLoader shared] stopDownLoadTaskByUrl:_downLoadUrl];
}

-(void)cancelDownLoader:(UIButton*)btn {
    UIView *supView = btn.superview;
    __weak UIProgressView *progressView = [self getProgressView:supView];
    __weak UILabel *progressLabel = [self getProgressLabel:supView];
    
    [[ZJDownLoader shared] cancelDownLoadTaskByUrl:_downLoadUrl];
    
    progressView.progress = [[ZJDownLoader shared] progressWithUrl:_downLoadUrl];
    if (progressView.progress > 0) {
        progressLabel.text = [NSString stringWithFormat:@"进度:%.3f",progressView.progress];
    }else{
        progressLabel.text = @"下载进度";
    }
}


#pragma mark -- getter
-(NSURL*)getFileUrl:(NSString*)fileNmae {
    if (!fileNmae || fileNmae.length == 0) {
        return nil;
    }
    NSString *localPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    // 要检查的文件目录
    NSString *filePath;
    if ([fileNmae containsString:@".mp4"]) {
        filePath = [localPath stringByAppendingPathComponent:fileNmae];
    }else{
        filePath = [localPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",fileNmae]];
    }
    
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath isDirectory:NO];
    return fileUrl;
}

-(UIProgressView*)getProgressView:(UIView*)supView {
    UIView *progress = [supView viewWithTag:100];
    UIProgressView *progressView;
    if ([progress isKindOfClass:[UIProgressView class]]) {
        progressView = (UIProgressView*)progress;
    }
    return progressView;
}

-(UILabel*)getProgressLabel:(UIView*)supView {
    UIView *label = [supView viewWithTag:101];
    UILabel *progressLabel;
    if ([label isKindOfClass:[UILabel class]]) {
        progressLabel = (UILabel*)label;
    }
    return progressLabel;
}


@end
