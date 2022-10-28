//
//  UploadTaskManager.m
//  MyPods
//
//  Created by ZZJ on 2019/10/28.
//  Copyright © 2019 Youjuke. All rights reserved.
//

#import "UploadTaskManager.h"
#import <objc/runtime.h>

NSString * const UploadTaskProgressNotification = @"UploadTaskProgressNotification";

@interface NSURLSessionUploadTask (_Prive)
@property(nonatomic, copy)NSString *filePath;
@end

@implementation NSURLSessionUploadTask (_Prive)

- (NSString *)filePath {
    return objc_getAssociatedObject(self, @selector(filePath));

}

- (void)setFilePath:(NSString *)filePath {
    objc_setAssociatedObject(self, @selector(filePath), filePath, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

@interface UploadTaskManager ()
@property (nonatomic,strong) AFURLSessionManager *manager;
@property (nonatomic,copy)UploadSuccessBlock success;
@property (nonatomic,copy)UploadFailBlock failure;
/**  下载历史记录 */
@property (nonatomic,strong) NSMutableDictionary *uploadHistoryDictionary;
@property (nonatomic,strong) NSString  *historyFilePath;
@end

@implementation UploadTaskManager
static UploadTaskManager *_install = nil;
+ (UploadTaskManager*)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _install = [[self alloc] init];
    });
    
    return _install;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.zj.UploadTaskManager"];
        //设置最大连接数
        configuration.HTTPMaximumConnectionsPerHost = 1;
        //在蜂窝网络情况下是否继续请求（上传或下载）
        configuration.allowsCellularAccess = YES;
        //设置请求超时为300秒钟
//        configuration.timeoutIntervalForRequest = 300;
        self.manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];

        //设置无效证书访问
        AFSecurityPolicy *security = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        [security setValidatesDomainName:NO];
        security.allowInvalidCertificates = YES;
        
        self.manager.securityPolicy = security;
        
        NSString *path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
        self.historyFilePath=[path stringByAppendingPathComponent:@"fileUploadHistory.plist"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.historyFilePath]) {
            self.uploadHistoryDictionary =[NSMutableDictionary dictionaryWithContentsOfFile:self.historyFilePath];
        }else{
            self.uploadHistoryDictionary =[NSMutableDictionary dictionary];
            //将dictionary中的数据写入plist文件中
            [self.uploadHistoryDictionary writeToFile:self.historyFilePath atomically:YES];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadData:) name:AFNetworkingTaskDidCompleteNotification object:nil];
        
        [self observerNetworkChanged];
        
    }
    
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -- Notification
/*************下载模块的关键的代码 包括强退闪退都会有***********/
- (void)uploadData:(NSNotification *)notification{
    
    if ([notification.object isKindOfClass:[NSURLSessionUploadTask class]]) {
        NSURLSessionUploadTask *task = notification.object;
        
        //[task.currentRequest.URL absoluteString];
        NSString *urlHost = task.filePath;
        NSError *error  = [notification.userInfo objectForKey:AFNetworkingTaskDidCompleteErrorKey] ;
        if (error) {
            if (error.code == -1001) {
                NSLog(@"下载出错,看一下网络是否正常");
            }
            NSData *resumeData = [error.userInfo objectForKey:@"NSURLSessionUploadTaskResumeData"];
            if (resumeData && resumeData.length>0) {
                NSDictionary *resumeDict = [self taskDataInfo:(NSHTTPURLResponse *)task.response resumeData:resumeData];
                
                [self saveHistoryWithKey:urlHost uploadTaskInfo:resumeDict];
            }
            
            //这个是因为 用户比如强退程序之后 ,再次进来的时候 存进去这个继续的data  需要用户去刷新列表
            
        }else{
            
            if ([self.uploadHistoryDictionary valueForKey:urlHost]) {
                [self.uploadHistoryDictionary removeObjectForKey:urlHost];
                [self saveUploadHistoryDirectory];
            }
        }
    }
    
}

-(void)observerNetworkChanged{
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    
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
-(CGFloat)progressWithPath:(NSString*)url {
    NSURLSessionUploadTask *objTask = [self getTaskWithPath:url];
    if (objTask) {
        NSProgress *progressObj = [self.manager uploadProgressForTask:objTask];
        if (progressObj) {
           return 1.0 * progressObj.completedUnitCount / progressObj.totalUnitCount;
        }
        return 0;
    }else {
        NSDictionary *uploadHistory = [self.uploadHistoryDictionary objectForKey:url];
        
        NSInteger uploadHistoryDataLength = [[uploadHistory valueForKey:@"data"] integerValue];
        int64_t totalCount = [[uploadHistory valueForKey:@"totalCount"] longLongValue];
        int64_t completedCount = [[uploadHistory valueForKey:@"completedCount"] longLongValue];
        if (uploadHistoryDataLength>0 && completedCount > 0 &&totalCount > 0) {
            if(totalCount > completedCount) {
                return 1.0 * completedCount / totalCount;
            }else {
                return 1.0;
            }
            
        }
        return 0;
    }
}

- (NSURLSessionUploadTask *)uploadWithUrl:(NSString*)url
                                 filePath:(NSString*)filePath
                                 progress:(UploadProgress)progress
                                  success:(UploadSuccessBlock)success
                                  failure:(UploadFailBlock)failure {
    
    
    // 判断文件是否存在
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSLog(@"文件路径不存在：%@", filePath);
        // 查找并删除对应的缓存
        return nil;
    }
    
    NSURLSessionUploadTask *objTask = [self getTaskWithPath:url];
    if (objTask) {
        return objTask;
    }
    
    self.success = success;
    self.failure = failure;
    
   __block NSURLSessionUploadTask  *downloadTask = nil;
    NSDictionary *uploadHistory = [self.uploadHistoryDictionary objectForKey:url];
    NSInteger uploadHistoryLength = [[uploadHistory valueForKey:@"data"] integerValue];
    
    if (uploadHistoryLength > 0) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
        [handle seekToFileOffset:uploadHistoryLength];
        // 获取剩余的数据
        NSData *fileData = [handle readDataToEndOfFile];
        
        downloadTask = [self.manager uploadTaskWithRequest:request fromData:fileData progress:^(NSProgress * _Nonnull uploadProgress) {
            if (progress) {
                progress(1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
            }
            // 进度通知
            [[NSNotificationCenter defaultCenter] postNotificationName:UploadTaskProgressNotification object:downloadTask userInfo:@{@"progress":uploadProgress}];
        } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            [self completionHandler:response resObject:responseObject err:error];
        }];
        
    }else {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        
        downloadTask = [self.manager uploadTaskWithRequest:request fromFile:[NSURL fileURLWithPath:filePath] progress:^(NSProgress * _Nonnull uploadProgress) {
            if (progress) {
                progress(1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
            }
            // 进度通知
            [[NSNotificationCenter defaultCenter] postNotificationName:UploadTaskProgressNotification object:downloadTask userInfo:@{@"progress":uploadProgress}];
        } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            [self completionHandler:response resObject:responseObject err:error];
        }];
        
    }
    [downloadTask resume];
    downloadTask.filePath = filePath;
    
    return downloadTask;
}

-(void)completionHandler:(NSURLResponse *)response resObject:(id)res err:(NSError *)error {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    if ([httpResponse statusCode] == 404) {
        
    }
    if (error) {
        if (self.failure) {
            self.failure(error,[httpResponse statusCode]);
        }
        //将下载失败存储起来  提交到了appDelegate 的网络监管类里面
    }else{
        if (self.success) {
            self.success(res,response);
        }
        //将下载成功存储起来  提交到了appDelegate 的网络监管类里面
    }
}

/*
 根据filePath获取task
 */
-(NSURLSessionUploadTask*)getTaskWithPath:(NSString*)filePath {
    for (NSURLSessionUploadTask *objTask in self.manager.uploadTasks) {
        if([objTask.filePath isEqualToString:filePath]) {
            return objTask;
        }
    }
    return nil;
}

/*
 根据URL获取task
 */
-(NSURLSessionUploadTask*)getTaskWithUrl:(NSString*)url {
    for (NSURLSessionUploadTask *objTask in self.manager.uploadTasks) {
        if ([objTask.currentRequest.URL.absoluteString isEqualToString:url]) {
            return objTask;
        }
    }
    return nil;
}

-(void)resumeAllDownLoadTasks {
    if ([[self.manager uploadTasks] count]  == 0) {
        return;
    }
    for (NSURLSessionUploadTask *task in  [self.manager uploadTasks]) {
        if (task.state == NSURLSessionTaskStateSuspended) {
            [task resume];
        }
    }
}


// 取消某个任务
-(void)stopUploadTaskByPath:(NSString*)url {
    NSURLSessionUploadTask *task = [self getTaskWithPath:url];
    if (task) {
        [self stopUploadTask:task];
    }
}
-(void)stopUploadTask:(NSURLSessionUploadTask*)task {
    if ([[self.manager uploadTasks] count]  == 0) {
        return;
    }
    
    if (task.state == NSURLSessionTaskStateRunning) {
        
        [task cancel];
    }
    NSProgress *progress = [self.manager downloadProgressForTask:task];
    NSLog(@"在这里可以获取到progress：%@",progress);
}

/*
 暂停所有任务
 */
- (void)stopAllUploadTasks {
    //停止所有的上传
    if ([[self.manager uploadTasks] count]  == 0) {
        return;
    }
    for (NSURLSessionUploadTask *task in  [self.manager uploadTasks]) {
        if (task.state == NSURLSessionTaskStateRunning) {
            [task cancel];
        }
    }
}

/*
 取消某个任务,删除未完成的临时文件
 */
-(void)cancelUploadTaskByPath:(NSString*)url {
    if (!url || url.length == 0) {
        return;
    }
    
    NSURLSessionUploadTask *task = [self getTaskWithPath:url];
    
    if (task) {
        [self cancelUploadTask:task];
    }else{
        [self.uploadHistoryDictionary removeObjectForKey:url];
        [self saveUploadHistoryDirectory];
    }
    
}
-(void)cancelUploadTask:(NSURLSessionUploadTask*)task {
    if (task) {
        //task.currentRequest.URL.absoluteString;
        NSString *key = task.filePath;
        [task cancel];
        if (key) {
            [self.uploadHistoryDictionary removeObjectForKey:key];
            [self saveUploadHistoryDirectory];
        }
        
    }
}

/*
 取消所有任务,删除未完成的临时文件
 */
- (void)cancelAllUploadTasks {
    if ([[self.manager uploadTasks] count]  > 0) {
        for (NSURLSessionUploadTask *task in  [self.manager uploadTasks]) {
            [self cancelUploadTask:task];
        }
    }else {
        [self.uploadHistoryDictionary removeAllObjects];
        [self saveUploadHistoryDirectory];
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
    [self stopAllUploadTasks];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"当前为蜂窝网络状态，是否继续？" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"继续" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self resumeAllDownLoadTasks];
    }]];
    
    [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alert animated:YES completion:nil];
}


#pragma mark -- file
- (void)saveHistoryWithKey:(NSString *)key uploadTaskInfo:(NSDictionary *)data{
    if (!data) {
        data = @{};
    }
    [self.uploadHistoryDictionary setObject:data forKey:key];
    
    [self.uploadHistoryDictionary writeToFile:self.historyFilePath atomically:NO];
}
- (void)saveUploadHistoryDirectory{
    [self.uploadHistoryDictionary writeToFile:self.historyFilePath atomically:YES];
}


@end
