//
//  YJTUploadManager.m
//  MyPods
//
//  Created by ZZJ on 2019/10/28.
//  Copyright © 2019 Youjuke. All rights reserved.
//

#import "YJTUploadManager.h"
#import "AFNetworking.h"

#define kSuperUploadBlockSize (1024 * 1024)
#define kRet_success_data_key @"success"

@implementation YJTUploadManager

static YJTUploadManager *_install = nil;
+ (YJTUploadManager*)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _install = [[self alloc] init];
    });
    
    return _install;
}

static NSString* UploadUrl() {
    return @"上传接口";
}

#pragma mark- first upload 断点
// 上传初始化
- (void)uploadFilePath:(NSString *)filePath withModel:(YJTDocUploadModel *)model {
    // 判断文件是否存在
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSLog(@"文件路径不存在：%@", filePath);
        // 查找并删除对应的缓存
        return;
    }
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    // 计算片数
    NSInteger count = data.length / (kSuperUploadBlockSize);
    NSInteger blockCount = data.length % (kSuperUploadBlockSize) == 0 ? count : count + 1;

    // 给model赋值
    model.filePath = filePath;
    model.totalCount = blockCount;
    model.totalSize = data.length;
    model.uploadedCount = 0;
    model.isRunning = YES;

    // 上传所需参数
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    parameters[@"sequenceNo"] = @0;
    parameters[@"blockSize"] = @(kSuperUploadBlockSize);
    parameters[@"totFileSize"] = @(data.length);
    parameters[@"suffix"] = model.filePath.pathExtension;
    parameters[@"token"] = @"";
    NSString *requestUrl = UploadUrl();

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSURLSessionDataTask *dataTask  = [manager POST:requestUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:[NSData data] name:@"block" fileName:model.filePath.lastPathComponent mimeType:@"application/octet-stream"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dataDict = responseObject[kRet_success_data_key];
        model.upToken = dataDict[@"upToken"];

        NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:model.filePath];
        if (handle == nil) {  return; }
        [self continueUploadWithModel:model];
        [self addUploadModel:model];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error.localizedDescription);
    }];

    model.dataTask = dataTask;

}

#pragma mark- continue upload
- (void)continueUploadWithModel:(YJTDocUploadModel *)model {
    if (!model.isRunning) {
        return;
    }
    __block NSInteger i = model.uploadedCount;

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"blockSize"] = @(kSuperUploadBlockSize);
    parameters[@"totFileSize"] = @(model.totalSize);
    parameters[@"suffix"] = model.filePath.pathExtension;
    parameters[@"token"] = @"";
    parameters[@"upToken"] = model.upToken;
    parameters[@"crc"] = @"";
    parameters[@"sequenceNo"] = @(i + 1);

    NSString *requestUrl = UploadUrl();
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSURLSessionDataTask *dataTask  = [manager POST:requestUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:model.filePath];
        [handle seekToFileOffset:kSuperUploadBlockSize * i];
        NSData *blockData = [handle readDataOfLength:kSuperUploadBlockSize];
        [formData appendPartWithFileData:blockData name:@"block" fileName:model.filePath.lastPathComponent mimeType:@"application/octet-stream"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        i ++;
        model.uploadedCount = i;
        NSDictionary *dataDict = responseObject[kRet_success_data_key];
        NSString *fileUrl = dataDict[@"fileUrl"];
        if ([fileUrl isKindOfClass:[NSString class]]) {
            [model.parameters setValue:fileUrl forKey:@"url"];
            // 最后所有片段上传完毕，服务器返回文件url，执行后续操作
            [self saveRequest:model];
        }else {
            if (i < model.totalCount) {
                [self continueUploadWithModel:model];
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // 上传失败重试
        [self continueUploadWithModel:model];
    }];
    
    model.dataTask = dataTask;
}

-(void)addUploadModel:(YJTDocUploadModel*)model {
    
}

-(void)saveRequest:(YJTDocUploadModel*)model {
    
}

-(void)refreshCaches {
    
}

#pragma mark- write cache file
- (NSString *)writeToCacheVideo:(NSData *)data appendNameString:(NSString *)name {

    NSString *cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *createPath =  [cachesDirectory stringByAppendingPathComponent:@"video"];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    [fileManager createDirectoryAtPath:createPath withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *path = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/video/%.0f%@",[NSDate date].timeIntervalSince1970,name]];
    [data writeToFile:path atomically:NO];

    return path;
}


@end


@implementation YJTDocUploadModel

// 上传完毕后更新模型相关数据
- (void)setUploadedCount:(NSInteger)uploadedCount {

    _uploadedCount = uploadedCount;

    self.uploadPercent = (CGFloat)uploadedCount / self.totalCount;
    self.progressLableText = [NSString stringWithFormat:@"%.2fMB/%.2fMB",self.totalSize * self.uploadPercent /1024.0/1024.0,self.totalSize/1024.0/1024.0];
    if (self.progressBlock) {
        self.progressBlock(self.uploadPercent,self.progressLableText);
    }
    // 刷新本地缓存
    [[YJTUploadManager shared] refreshCaches];

}

@end
