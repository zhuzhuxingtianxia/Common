//
//  ZJDownLoader.m
//  MyPods
//
//  Created by ZZJ on 2019/10/14.
//  Copyright © 2019 Youjuke. All rights reserved.
//

#import "ZJDownLoader.h"

NSString * const ZJDownloadProgressNotification = @"ZJDownloadProgressNotification";

@interface ZJDownLoader ()
@property (nonatomic,strong) AFURLSessionManager *manager;
@property (nonatomic,copy)DownLoadSuccessBlock success;
@property (nonatomic,copy)DownLoadFailBlock failure;
/**  下载历史记录 */
@property (nonatomic,strong) NSMutableDictionary *downLoadHistoryDictionary;
@property (nonatomic,strong) NSString  *historyFilePath;
@end

@implementation ZJDownLoader

static ZJDownLoader *_install = nil;
+ (ZJDownLoader*)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _install = [[self alloc] init];
    });
    
    return _install;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.zj.downLoader"];
        //设置最大连接数
        configuration.HTTPMaximumConnectionsPerHost = 8;
        //在蜂窝网络情况下是否继续请求（上传或下载）
//        configuration.allowsCellularAccess = YES;
        //设置请求超时为10秒钟
        configuration.timeoutIntervalForRequest = 10;
        self.manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];

        //设置无效证书访问
        AFSecurityPolicy *security = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        [security setValidatesDomainName:NO];
        security.allowInvalidCertificates = YES;
        
        self.manager.securityPolicy = security;
        
        NSString *path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
        self.historyFilePath=[path stringByAppendingPathComponent:@"fileDownLoadHistory.plist"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.historyFilePath]) {
            self.downLoadHistoryDictionary =[NSMutableDictionary dictionaryWithContentsOfFile:self.historyFilePath];
        }else{
            self.downLoadHistoryDictionary =[NSMutableDictionary dictionary];
            //将dictionary中的数据写入plist文件中
            [self.downLoadHistoryDictionary writeToFile:self.historyFilePath atomically:YES];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downLoadData:) name:AFNetworkingTaskDidCompleteNotification object:nil];
        
        [self observerNetworkChanged];
        
    }
    
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -- Notification
/*************下载模块的关键的代码 包括强退闪退都会有***********/
- (void)downLoadData:(NSNotification *)notification{
    
    if ([notification.object isKindOfClass:[NSURLSessionDownloadTask class]]) {
        NSURLSessionDownloadTask *task = notification.object;
        NSString *urlHost = [task.currentRequest.URL absoluteString];
        NSError *error  = [notification.userInfo objectForKey:AFNetworkingTaskDidCompleteErrorKey] ;
        if (error) {
            if (error.code == -1001) {
                NSLog(@"下载出错,看一下网络是否正常");
            }
            NSData *resumeData = [error.userInfo objectForKey:@"NSURLSessionDownloadTaskResumeData"];
            if (resumeData && resumeData.length>0) {
                NSDictionary *resumeDict = [self taskDataInfo:(NSHTTPURLResponse *)task.response resumeData:resumeData];
                
                [self saveHistoryWithKey:urlHost downloadTaskInfo:resumeDict];
            }
            
            //这个是因为 用户比如强退程序之后 ,再次进来的时候 存进去这个继续的data  需要用户去刷新列表
            
        }else{
            
            if ([self.downLoadHistoryDictionary valueForKey:urlHost]) {
                [self.downLoadHistoryDictionary removeObjectForKey:urlHost];
                [self saveDownLoadHistoryDirectory];
            }
        }
    }
    
}

-(void)observerNetworkChanged{
 AFNetworkReachabilityManager *reachabilityManager =   [AFNetworkReachabilityManager sharedManager];
    
    [reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"网络状态%ld",status);
        if (self.manager.downloadTasks.count > 0) {
            if (status == AFNetworkReachabilityStatusReachableViaWWAN) {
                
            }else if (status == AFNetworkReachabilityStatusNotReachable){
                
            }else if (status == AFNetworkReachabilityStatusUnknown){
                
            }else{
                [self WWANAlert];
            }
        }
        
    }];
    
    [reachabilityManager startMonitoring];
}

#pragma mark -- public
-(CGFloat)progressWithUrl:(NSString*)url {
    NSURLSessionDownloadTask *objTask = [self getTaskWithUrl:url];
    if (objTask) {
        NSProgress *progressObj = [self.manager downloadProgressForTask:objTask];
        if (progressObj) {
           return 1.0 * progressObj.completedUnitCount / progressObj.totalUnitCount;
        }
        return 0;
    }else {
        NSDictionary *downLoadHistory = [self.downLoadHistoryDictionary objectForKey:url];
        
        NSData *downLoadHistoryData = [downLoadHistory valueForKey:@"data"];
        int64_t totalCount = [[downLoadHistory valueForKey:@"totalCount"] longLongValue];
        int64_t completedCount = [[downLoadHistory valueForKey:@"completedCount"] longLongValue];
        if (downLoadHistoryData.length>0 && completedCount > 0 &&totalCount > completedCount) {
            return 1.0 * completedCount / totalCount;
        }
        return 0;
    }
}

- (NSURLSessionDownloadTask *)donwLoadWithUrl:(NSString*)url progress:(DowningProgress)progress targetPath:(NSURL*)targetPath success:(DownLoadSuccessBlock)success failure:(DownLoadFailBlock)failure {
    
    NSURLSessionDownloadTask *objTask = [self getTaskWithUrl:url];
    if (objTask) {
        return objTask;
    }
    
    self.success = success;
    self.failure = failure;
    
   __block NSURLSessionDownloadTask  *downloadTask = nil;
    NSDictionary *downLoadHistory = [self.downLoadHistoryDictionary objectForKey:url];
    NSData *downLoadHistoryData = [downLoadHistory valueForKey:@"data"];
    
    if (downLoadHistoryData && downLoadHistoryData.length > 0) {
        downloadTask = [self.manager downloadTaskWithResumeData:downLoadHistoryData progress:^(NSProgress * _Nonnull downloadProgress) {
            if (progress) {
                progress(1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
            }
            // 进度通知
            [[NSNotificationCenter defaultCenter] postNotificationName:ZJDownloadProgressNotification object:downloadTask userInfo:@{@"progress":downloadProgress}];
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull filePath, NSURLResponse * _Nonnull response) {
            return targetPath;
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            [self completionHandler:response filePath:filePath err:error];
        }];
    }else {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        downloadTask = [self.manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            if (progress) {
                progress(1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
            }
            // 进度通知
            [[NSNotificationCenter defaultCenter] postNotificationName:ZJDownloadProgressNotification object:downloadTask userInfo:@{@"progress":downloadProgress}];
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull filePath, NSURLResponse * _Nonnull response) {
            return targetPath;
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            [self completionHandler:response filePath:filePath err:error];
        }];
    }
    [downloadTask resume];
    
    return downloadTask;
}

-(void)completionHandler:(NSURLResponse *)response filePath:(NSURL *)filePath err:(NSError *)error {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    if ([httpResponse statusCode] == 404) {
        [[NSFileManager defaultManager] removeItemAtURL:filePath error:nil];
    }
    if (error) {
        if (self.failure) {
            self.failure(error,[httpResponse statusCode]);
        }
        //将下载失败存储起来  提交到了appDelegate 的网络监管类里面
    }else{
        if (self.success) {
            self.success(filePath,response);
        }
        //将下载成功存储起来  提交到了appDelegate 的网络监管类里面
    }
}

/*
 根据URL获取task
 */
-(NSURLSessionDownloadTask*)getTaskWithUrl:(NSString*)url {
    for (NSURLSessionDownloadTask *objTask in self.manager.downloadTasks) {
        if ([objTask.currentRequest.URL.absoluteString isEqualToString:url]) {
            
            return objTask;
        }
    }
    return nil;
}

-(void)resumeAllDownLoadTasks {
    if ([[self.manager downloadTasks] count]  == 0) {
        return;
    }
    for (NSURLSessionDownloadTask *task in  [self.manager downloadTasks]) {
        if (task.state == NSURLSessionTaskStateSuspended) {
            [task resume];
        }
    }
}

/*
 暂停某个任务
 */
-(void)stopDownLoadTaskByUrl:(NSString*)url {
    NSURLSessionDownloadTask *task = [self getTaskWithUrl:url];
    if (task) {
        [self stopDownLoadTask:task];
    }
}
-(void)stopDownLoadTask:(NSURLSessionDownloadTask*)task {
    if ([[self.manager downloadTasks] count]  == 0) {
        return;
    }
    
    if (task.state == NSURLSessionTaskStateRunning) {
        [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            
        }];
    }
    NSProgress *progress = [self.manager downloadProgressForTask:task];
    NSLog(@"在这里可以获取到progress：%@",progress);
}

/*
 暂停所有任务
 */
- (void)stopAllDownLoadTasks {
    //停止所有的下载
    if ([[self.manager downloadTasks] count]  == 0) {
        return;
    }
    for (NSURLSessionDownloadTask *task in  [self.manager downloadTasks]) {
        if (task.state == NSURLSessionTaskStateRunning) {
            [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                
            }];
        }
    }
}

/*
 取消某个任务,删除未完成的临时文件
 */
-(void)cancelDownLoadTaskByUrl:(NSString*)url {
    if (!url || url.length == 0) {
        return;
    }
    
    NSURLSessionDownloadTask *task = [self getTaskWithUrl:url];
    
    if (task) {
        [self cancelDownLoadTask:task];
    }else{
        [self.downLoadHistoryDictionary removeObjectForKey:url];
        [self saveDownLoadHistoryDirectory];
    }
    
}
-(void)cancelDownLoadTask:(NSURLSessionDownloadTask*)task {
    if (task) {
        NSString *key = task.currentRequest.URL.absoluteString;
        [task cancel];
        if (key) {
            [self.downLoadHistoryDictionary removeObjectForKey:key];
            [self saveDownLoadHistoryDirectory];
        }
        
    }
}

/*
 取消所有任务,删除未完成的临时文件
 */
- (void)cancelAllDownLoadTasks {
    if ([[self.manager downloadTasks] count]  > 0) {
        for (NSURLSessionDownloadTask *task in  [self.manager downloadTasks]) {
            [self cancelDownLoadTask:task];
        }
    }else {
        [self.downLoadHistoryDictionary removeAllObjects];
        [self saveDownLoadHistoryDirectory];
    }
}

#pragma mark -- private

-(NSDictionary*)taskDataInfo:(NSHTTPURLResponse*)response resumeData:(NSData*)resumeData{
    NSDictionary *headerFields = [response allHeaderFields];
    NSString *contentLength = headerFields[@"Content-Length"];
    if (!contentLength) {
        contentLength = headerFields[@"content-length"];
    }
    
    NSString *contentRange = headerFields[@"content-range"];
    NSRange range = [contentRange rangeOfString:@"/"];
    if (range.location != NSNotFound) {
        
        contentLength = [contentRange substringFromIndex:range.location+range.length];
    }
    
    NSString *completedCount = @"0";
    NSRange rangeCom = [contentRange rangeOfString:@"-"];
    if (rangeCom.location != NSNotFound) {
        NSArray *separateArray = [contentRange componentsSeparatedByString:@"-"];
        if (separateArray.count>1) {
            NSString *fistPart = separateArray.firstObject;
            if ([fistPart rangeOfString:@" "].location != NSNotFound) {
                separateArray = [fistPart componentsSeparatedByString:@" "];
                if (separateArray.count > 1) {
                    completedCount = separateArray.lastObject;
                }
            }
        }
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
    if (resumeData) {
        [dict setValue:resumeData forKey:@"data"];
    }else{
        [dict setValue:@"" forKey:@"data"];
    }
    
    [dict setValue:contentLength forKey:@"totalCount"];
    [dict setValue:completedCount forKey:@"completedCount"];
    
    return dict;
}

-(void)WWANAlert {
    [self stopAllDownLoadTasks];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"当前为蜂窝网络状态，是否继续下载？" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"继续" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self resumeAllDownLoadTasks];
    }]];
    
    [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alert animated:YES completion:nil];
}


#pragma mark -- file
- (void)saveHistoryWithKey:(NSString *)key downloadTaskInfo:(NSDictionary *)data{
    if (!data) {
        data = @{};
    }
    [self.downLoadHistoryDictionary setObject:data forKey:key];
    
    [self.downLoadHistoryDictionary writeToFile:self.historyFilePath atomically:NO];
}
- (void)saveDownLoadHistoryDirectory{
    [self.downLoadHistoryDictionary writeToFile:self.historyFilePath atomically:YES];
}

@end
