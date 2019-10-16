//
//  ZJDownLoader.h
//  MyPods
//
//  Created by ZZJ on 2019/10/14.
//  Copyright © 2019 Youjuke. All rights reserved.
// 好的demo：https://github.com/HeroWqb/HWDownloadDemo
//文章参考：https://www.jianshu.com/p/83fd0fcdf898
// 下载器
/*
 断点续传需满足：
 1.自第一次请求资源依赖，资源没有变化
 2.该任务必须是GET请求
 3.使用断点续传，服务器返回文件的部分数据时,服务器响应码必须是 206,不可以是200或者其他状态码,否则客户端会从头下载
 4.服务器在响应中提供ETAG或Last-Modified。标记最后一次资源修改的时间
 5.服务器支持字节范围请求，即服务器响应头包含：Accept-Ranges:bytes;
 6.系统尚未删除临时文件以响应磁盘空间压力，即存在本地缓存文件
 */

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

FOUNDATION_EXPORT NSString * const ZJDownloadProgressNotification;

typedef void (^DownLoadSuccessBlock)(NSURL *fileUrlPath ,NSURLResponse *response );
typedef void (^DownLoadFailBlock)(NSError*  error ,NSInteger statusCode);
typedef void (^DowningProgress)(CGFloat  progress);

@interface ZJDownLoader : NSObject

@property (nonatomic,readonly) AFURLSessionManager *manager;

+ (ZJDownLoader*)shared;

/*
 根据下载URL，下载到指定文件夹下，并将结果回调
 */

- (NSURLSessionDownloadTask *)donwLoadWithUrl:(NSString*)url progress:(DowningProgress)progress targetPath:(NSURL*)targetPath success:(DownLoadSuccessBlock)success failure:(DownLoadFailBlock)failure;

/*
 根据URL获取task
 */
-(NSURLSessionDownloadTask*)getTaskWithUrl:(NSString*)url;
/*
 获取上次的下载进度
 */
-(CGFloat)progressWithUrl:(NSString*)url;

/*
 暂停某个任务
 */

-(void)stopDownLoadTaskByUrl:(NSString*)url;

/*
 暂停所有任务
 */
- (void)stopAllDownLoadTasks;

/*
 取消某个任务,删除未完成的临时文件
 */
-(void)cancelDownLoadTaskByUrl:(NSString*)url;
/*
 取消所有任务,删除未完成的临时文件
 */
- (void)cancelAllDownLoadTasks;

@end

