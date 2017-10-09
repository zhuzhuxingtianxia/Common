//
//  NetWorkEngine.h
//  ZJMoviePlay
//
//  Created by Jion on 16/7/13.
//  Copyright © 2016年 Youjuke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

// 映客接口
#define HomeData [NSString stringWithFormat:@"http://service.ingkee.com/api/live/gettop?imsi=&uid=17800399&proto=5&idfa=A1205EB8-0C9A-4131-A2A2-27B9A1E06622&lc=0000000000000026&cc=TG0001&imei=&sid=20i0a3GAvc8ykfClKMAen8WNeIBKrUwgdG9whVJ0ljXi1Af8hQci3&cv=IK3.1.00_Iphone&devi=bcb94097c7a3f3314be284c8a5be2aaeae66d6ab&conn=Wifi&ua=iPhone&idfv=DEBAD23B-7C6A-4251-B8AF-A95910B778B7&osversion=ios_9.300000&count=5&multiaddr=1"]


@interface NetWorkEngine : AFHTTPSessionManager

+(void)PostWithURL:(NSString*)url parameters:(NSDictionary*)params response:(void(^)(id json))result error400Code:(void (^)(id failure))error400 failure:(void (^)(id failure))failureCode;

+(void)PostStreamURL:(NSString*)url params:(NSDictionary*)params filePathsAndKey:(NSDictionary*)pathKey response:(void(^)(id json))result error400Code:(void (^)(id failure))error400 errorFailure:(void (^)(id failure))failureCode;

+(void)GetWithURL:(NSString*)url parameters:(NSDictionary*)params response:(void(^)(id json))result error400Code:(void (^)(id failure))failureCode;

@end
