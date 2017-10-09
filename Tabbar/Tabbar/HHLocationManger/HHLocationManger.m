//
//  HHLocationManger.m
//  BMHaoLeDi
//
//  Created by sam.l on 14-11-24.
//  Copyright (c) 2014年 bluemob. All rights reserved.
//

#import "HHLocationManger.h"
//#import <MapKit/MapKit.h>

@implementation HHLocationManger
+ (HHLocationManger *)shareLocation;
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init {
    self = [super init];
    if (self) {

    }
    return self;
}


- (void)getLocationCoordinate:(LocationBlock) locaiontBlock
{
    self.locationBlock = [locaiontBlock copy];
    [self getUserLocation];
    
}
- (void)getAddress:(AddressBlock)addressBlock
{
    self.addressBlock = [addressBlock copy];
    [self getUserLocation];
}
- (void)getCityBlock:(CityBlock)cityBlock
{
    self.cityBlock = [cityBlock copy];
    [self getUserLocation];
}

- (void)getDictBlock:(DictBlock)dictBlock
{
    self.dictBlock = [dictBlock copy];
    [self getUserLocation];
}

- (void)getUserLocation
{
    //判断位置服务是否可用
    if (![CLLocationManager locationServicesEnabled]) {
        return;
    }
//    [UIApplication sharedApplication].idleTimerDisabled = TRUE;
    //创建一个CLLocationManager对象
    if (nil == _locationManager)
    {
        _locationManager = [[CLLocationManager alloc] init];
    }

     //NSLocationWhenInUseDescription

    //设置代理
    _locationManager.delegate = self;
    
    //desired 要求  想得到的    Accuracy 精确度
    //定位的水平精确度
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    
    //distance距离 Filter过滤器
    //触发定位事件的最小距离， 单位是米
    _locationManager.distanceFilter = 1;
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [_locationManager requestWhenInUseAuthorization];
    }
    if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
    {
        [_locationManager requestAlwaysAuthorization];
    }
//    if (IOS8_OR_LATER) {
//        [_locationManager requestAlwaysAuthorization];        //NSLocationAlwaysUsageDescription
//        [_locationManager requestWhenInUseAuthorization];
//    }
    //开始定位服务_locationManager
    [_locationManager startUpdatingLocation];
    
}

#pragma mark CLLocationManagerDelegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = [locations lastObject];
    
//    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 2000, 2000);
    //[mapView setRegion:viewRegion animated:YES];
//    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
//    [self.mapView setRegion:adjustedRegion animated:YES];
    CLGeocoder *clGeoCoder = [[CLGeocoder alloc] init];
    __block NSString *lastAddress ;
    __block NSString *cityStr;
    CLGeocodeCompletionHandler handle = ^(NSArray *placemarks,NSError *error)
    {
        for (CLPlacemark * placeMark in placemarks)
        {
            NSDictionary *addressDic=placeMark.addressDictionary;
            
            NSString *state=[addressDic objectForKey:@"State"];
            NSString *city=[addressDic objectForKey:@"City"];
            NSString *subLocality=[addressDic objectForKey:@"SubLocality"];
            NSString *street=[addressDic objectForKey:@"Street"];
            
//            self.lastCity = city;
            lastAddress=[NSString stringWithFormat:@"%@%@%@%@",state,city,subLocality,street];
            cityStr = city;
//            [standard setObject:self.lastCity forKey:MMLastCity];
//            [standard setObject:self.lastAddress forKey:MMLastAddress];
            
//            [self stopLocation];
            if (_dictBlock)
            {
                _dictBlock(addressDic);
                _dictBlock = nil;
            }

             [_locationManager stopUpdatingLocation];
        }
        
//        if (_cityBlock) {
//            _cityBlock(_lastCity);
//            _cityBlock = nil;
//        }
//        
        if (_locationBlock) {
            _locationBlock(newLocation.coordinate);
            _locationBlock = nil;
        }
        
        if (_addressBlock) {
            _addressBlock(lastAddress);
            _addressBlock = nil;
        }
        if (_cityBlock) {
            
            if ([cityStr hasSuffix:@"市"]||[cityStr hasSuffix:@"省"]||[cityStr hasSuffix:@"区"]) {
                cityStr = [cityStr substringWithRange:NSMakeRange(0, cityStr.length -1)];
            }
            _cityBlock(cityStr);
            _cityBlock = nil;
        }
           };
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [clGeoCoder reverseGeocodeLocation:newLocation completionHandler:handle];

    
//    [_locationManager stopUpdatingLocation];
    
//    self.latitude = newLocation.coordinate.latitude;// [NSString stringWithFormat:@"%.6f",newLocation.coordinate.latitude];
//    
//    self.longitude = newLocation.coordinate.longitude;// [NSString stringWithFormat:@"%.6f",newLocation.coordinate.longitude];
//    
//    NSLog(@"Lat: %@  Lng: %@",  self.latitude, self.longitude);
}

@end
