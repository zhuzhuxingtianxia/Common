//
//  ZJLocationManger.h
//  BuldingMall
//
//  Created by Jion on 2017/6/23.
//  Copyright © 2017年 Youjuke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
@interface ZJLocationManger : NSObject

+ (ZJLocationManger *)shareLocation;

- (void)getLocationCoordinate:(void (^)(CLLocationCoordinate2D locationCorrrdinate)) locaiontBlock ;

- (void)getAddress:(void (^)(NSString *address))addressBlock ;
- (void)getCityBlock:(void (^)(NSString *city))cityBlock;
- (void)getDictBlock:(void (^)(NSDictionary *dict))dictBlock;


@end

@interface ZJLocationTransform : NSObject
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

+ (CLLocationCoordinate2D)transformFromWGSToGCJ:(CLLocationCoordinate2D)wgsLoc;
+ (CLLocationCoordinate2D)transformFromGCJToBaidu:(CLLocationCoordinate2D)p;
/*
 坐标系：
 WGS-84：是国际标准，GPS坐标（Google Earth使用、或者GPS模块）
 GCJ-02：中国坐标偏移标准，Google Map、高德、腾讯使用
 BD-09 ：百度坐标偏移标准，Baidu Map使用
 */

#pragma mark - 从GPS坐标转化到高德坐标
- (id)transformFromGPSToGD;

#pragma mark - 从高德坐标转化到百度坐标
- (id)transformFromGDToBD;

#pragma mark - 从百度坐标到高德坐标
- (id)transformFromBDToGD;

#pragma mark - 从高德坐标到GPS坐标
- (id)transformFromGDToGPS;

#pragma mark - 从百度坐标到GPS坐标
- (id)transformFromBDToGPS;

@end
