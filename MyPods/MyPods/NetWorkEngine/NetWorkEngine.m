//
//  NetWorkEngine.m
//  ZJMoviePlay
//
//  Created by Jion on 16/7/13.
//  Copyright © 2016年 Youjuke. All rights reserved.
//

#import "NetWorkEngine.h"

#ifdef DEBUG

#define VerificationNSAppTransportSecurity  NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];\
NSDictionary *tmep = [NSDictionary dictionaryWithContentsOfFile:path];\
if (tmep && !tmep[@"NSAppTransportSecurity"]) {\
    NSLog(@"============warning LINE %d Method %s ==============Info.plist  not set AppTransportSecurity , and addKey \n NSAppTransportSecurity :\n {\n NSAllowsArbitraryLoads : YES \n}", __LINE__, __func__);\
    return ;\
}\

#if 0
#define baseUrl   @"https://api.youjuke.com"
#else
#define baseUrl  @"https://preapi.51youjuke.com"
#endif

#else
#define baseUrl  @"https://api.youjuke.com"

#endif

@implementation NetWorkEngine
static NetWorkEngine *instance = nil;

+ (instancetype)shareIntance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //验证是否允许Http请求
        VerificationNSAppTransportSecurity;
        
        instance = [[NetWorkEngine alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
        // 设置超时时间,默认60s
        instance.requestSerializer.timeoutInterval = 15.f;
        instance.responseSerializer.acceptableContentTypes =[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/xml", @"text/plain", nil];
        //设置无效证书访问
        AFSecurityPolicy *security = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        [security setValidatesDomainName:NO];
        security.allowInvalidCertificates = YES;
        
        instance.securityPolicy = security;
        
    });
    return instance;
}

+ (NetWorkEngine *)shareNetWorkEngine{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //验证是否允许Http请求
        VerificationNSAppTransportSecurity;
        
        instance = [NetWorkEngine manager];
        // 设置超时时间
        instance.requestSerializer.timeoutInterval = 15.f;
        instance.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/xml", @"text/plain", nil];
        //设置无效证书访问
        AFSecurityPolicy *security = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        [security setValidatesDomainName:NO];
        security.allowInvalidCertificates = YES;
        
        instance.securityPolicy = security;
        
    });
    return instance;
}

+(void)PostWithURL:(NSString*)url parameters:(NSDictionary*)params response:(void(^)(id json))result error400Code:(void (^)(id failure))error400 failure:(void (^)(id failure))failureCode{
    if (!url) {
        return;
    }
    url = [url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSMutableDictionary *inDictionary = [NSMutableDictionary dictionary];
    [inDictionary setValue:url forKey:@"function_name"];
    [inDictionary setValue:params forKey:@"params"];
    
    NSString *paramStr = [NetWorkEngine getJsonStringByDictionary:inDictionary encoding:NSUTF8StringEncoding];
    NSDictionary *lastParam = @{@"json_msg":paramStr};
    
    NetWorkEngine *request;
    if ([url hasPrefix:@"http"]) {
        request = [NetWorkEngine shareNetWorkEngine];
    }else{
        request = [NetWorkEngine shareIntance];
    }
    [request cancelDataRequest];
    
    NSString *path = @"materialMall/management_interface";
    
    [request POST:path parameters:lastParam progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
      NSString *body = [[NSString alloc] initWithData:task.currentRequest.HTTPBody encoding:NSUTF8StringEncoding];
        NSLog(@"url = %@,body = %@",task.currentRequest,body);
        if ([responseObject[@"status"] integerValue] == 200) {
            result(responseObject[@"data"]);
        }else{
            NSURLRequest *curetRequest = task.currentRequest;
            error400(responseObject[@"message"]);
            NSLog(@"%@\n%@",curetRequest.URL,responseObject[@"message"]);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failureCode(error);
        NSLog(@"error ====================\n ======== %@",error);
    }];
    
}

+(void)PostStreamURL:(NSString*)url params:(NSDictionary*)params filePathsAndKey:(NSDictionary*)pathKey response:(void(^)(id json))result error400Code:(void (^)(id failure))error400 errorFailure:(void (^)(id failure))failureCode{
    if (!url) {
        return;
    }
    url = [url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSMutableDictionary *inDictionary = [NSMutableDictionary dictionary];
    [inDictionary setValue:url forKey:@"function_name"];
    [inDictionary setValue:params forKey:@"params"];
    
    NSString *paramStr = [NetWorkEngine getJsonStringByDictionary:inDictionary encoding:NSUTF8StringEncoding];
    NSDictionary *lastParam = @{@"json_msg":paramStr};
    
    NetWorkEngine *request;
    if ([url hasPrefix:@"http"]) {
        request = [NetWorkEngine shareNetWorkEngine];
    }else{
        request = [NetWorkEngine shareIntance];
    }
    [request cancelDataRequest];
    
    NSString *path = @"materialMall/management_interface";
    
    [request POST:path parameters:lastParam constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if (pathKey.allKeys.count == 1) {
            //使用多线程会出错
            if ([pathKey.allValues.firstObject isKindOfClass:[NSArray class]]) {
                NSArray *filePaths = pathKey.allValues.firstObject;
                for (NSString *filePath in filePaths) {
                    NSError *error = nil;
                    [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:pathKey.allKeys.firstObject error:&error];
                    if (error) {
                        NSLog(@"上传文件出错error == %@",error);
                    }
                    
                }
                
            }else{
                //单张上传
                NSError *error;
                [formData appendPartWithFileURL:[NSURL fileURLWithPath:pathKey.allValues.firstObject] name:pathKey.allKeys.firstObject error:&error];
                if (error) {
                    NSLog(@"上传文件出错error == %@",error);
                }
                
            }
            
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"status"] integerValue] == 200) {
            result(responseObject[@"data"]);
        }else{
            NSURLRequest *curetRequest = task.currentRequest;
            error400(responseObject[@"message"]);
            NSLog(@"%@\n%@",curetRequest.URL,responseObject[@"message"]);
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failureCode(error);
    }];
    
}


+(void)GetWithURL:(NSString*)url parameters:(NSDictionary*)params response:(void(^)(id json))result error400Code:(void (^)(id failure))failureCode{
    if (!url) {
        return;
    }
    url = [url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NetWorkEngine *request;
    if ([url hasPrefix:@"http"]) {
        request = [NetWorkEngine shareNetWorkEngine];
    }else{
        request = [NetWorkEngine shareIntance];
    }
    
    [request cancelDataRequest];
    
    [request GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        result(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error ====================\n ======== %@",error);
    }];
    
    
}

//模拟请求
+(void)simulation_postWithURL:(NSString *)url params:(NSDictionary*)params response:(void(^)(id json))result error400Code:(void (^)(id failure))failureCode{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSString *path = [[NSBundle mainBundle] pathForResource:url ofType:nil];
        if (!path) {
            NSLog(@"没有找到模拟文件");
            result(nil);
            return ;
        }
        NSData *data = [NSData dataWithContentsOfFile:path];
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if (data && json==nil) {
            NSLog(@"Json格式错误");
            result(nil);
            return;
        }
        result(json);
        
    });
    
}


// 取消请求数据的方法
- (void)cancelDataRequest
{
    [instance.operationQueue cancelAllOperations];
}


+(NSString *)getJsonStringByDictionary:(NSDictionary *)dictionary encoding:(NSStringEncoding)encoding{
    if(!dictionary)return nil;
    if(!encoding)return nil;
    NSData *JSONData = [self getJSONDataFromObject:dictionary];
    return [[NSString alloc] initWithData:JSONData encoding:encoding];
}

+(NSData *)getJSONDataFromObject:(id)obj{
    if(!obj)return nil;
    
    if([NSJSONSerialization isValidJSONObject:obj]){
        
        NSError *error = nil;
        
        return [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:&error];
        
        
    }
    
    return nil;
}


@end
