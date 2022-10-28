//
//  UploadTaskManager.h
//  MyPods
//
//  Created by ZZJ on 2019/10/28.
//  Copyright © 2019 Youjuke. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFNetworking.h"

NS_ASSUME_NONNULL_BEGIN

//推荐：使用通知接收加载进度，新建界面可同步刷新UI，使用回调则不能实现该效果。
FOUNDATION_EXPORT NSString * const UploadTaskProgressNotification;

typedef void (^UploadSuccessBlock)(id res,NSURLResponse *response );
typedef void (^UploadFailBlock)(NSError*  error ,NSInteger statusCode);
typedef void (^UploadProgress)(CGFloat  progress);

@interface UploadTaskManager : NSObject

@property (nonatomic,readonly) AFURLSessionManager *manager;

+ (UploadTaskManager*)shared;

/*
 根据路径上传文件，并将结果回调
 */

- (NSURLSessionUploadTask *)uploadWithUrl:(NSString*)url
                                 filePath:(NSString*)filePath
                                 progress:(UploadProgress)progress
                                  success:(UploadSuccessBlock)success
                                  failure:(UploadFailBlock)failure;

/*
 根据URL获取task
 */
-(NSURLSessionUploadTask*)getTaskWithPath:(NSString*)path;
/*
 获取上次的上传进度
 */
-(CGFloat)progressWithPath:(NSString*)path;

/*
 暂停某个任务
 */

-(void)stopUploadTaskByPath:(NSString*)path;

/*
 暂停所有任务
 */
- (void)stopAllUploadTasks;

/*
 取消某个任务
 */
-(void)cancelUploadTaskByPath:(NSString*)path;
/*
 取消所有任务
 */
- (void)cancelAllUploadTasks;


@end

NS_ASSUME_NONNULL_END
