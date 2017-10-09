//
//  ZJLocationManger.m
//  BuldingMall
//
//  Created by Jion on 2017/6/23.
//  Copyright © 2017年 Youjuke. All rights reserved.
//

#import "ZJLocationManger.h"

@interface ZJLocationManger ()<CLLocationManagerDelegate,UIAlertViewDelegate>
@property (nonatomic, strong) void (^locationBlock)(CLLocationCoordinate2D locationCorrrdinate);
@property (nonatomic, strong) void (^addressBlock)(NSString *address);
@property (nonatomic, strong) void (^cityBlock)(NSString *city);
@property (nonatomic, strong) void (^dictBlock)(NSDictionary *dict);

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation ZJLocationManger

+ (ZJLocationManger *)shareLocation;
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationSettingInfo:) name:@"LocationAuthorizationStatus" object:nil];
    }
    return self;
}

-(void)dealloc{
    [_locationManager stopUpdatingLocation];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LocationAuthorizationStatus" object:nil];
}

-(void)getLocationCoordinate:(void (^)(CLLocationCoordinate2D))locaiontBlock{
    self.locationBlock = [locaiontBlock copy];
    [self getUserLocation];
}

-(void)getAddress:(void (^)(NSString *))addressBlock{
    self.addressBlock = [addressBlock copy];
    [self getUserLocation];
}

-(void)getCityBlock:(void (^)(NSString *))cityBlock{
    self.cityBlock = [cityBlock copy];
    [self getUserLocation];
}

-(void)getDictBlock:(void (^)(NSDictionary *))dictBlock{
    self.dictBlock = [dictBlock copy];
    [self getUserLocation];
}

- (void)getUserLocation{

    if (![CLLocationManager locationServicesEnabled]) {
        //定位不可用
        [self errorAuthorization];
        return;
    }
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        //用户拒绝使用定位服务
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您还没有开启位置信息" delegate:self cancelButtonTitle:@"暂不开启" otherButtonTitles:@"开启", nil];
        [alert show];
        return;
    }
    
    //[UIApplication sharedApplication].idleTimerDisabled = TRUE;
    //创建一个CLLocationManager对象
    if (nil == _locationManager)
    {
        _locationManager = [[CLLocationManager alloc] init];
    }
    
    //设置代理
    _locationManager.delegate = self;
    
    //定位的水平精确度
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    
    //distance距离 Filter过滤器
    //触发定位事件的最小距离， 单位是米
    _locationManager.distanceFilter = 1;
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        
        [_locationManager requestWhenInUseAuthorization];
        
    }else if([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]){
        
        [_locationManager requestAlwaysAuthorization];
        
    }
    
    //开始定位服务_locationManager
    [_locationManager startUpdatingLocation];
    
}
#pragma mark --UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
        
    }else{
        [self errorAuthorization];
    }
}

-(void)locationSettingInfo:(NSNotification*)aNotification{
    if ([aNotification.object integerValue] == 2) {
        [self errorAuthorization];
    }else{
        [self getUserLocation];
    }
}

-(void)errorAuthorization{
    if (_dictBlock){
        _dictBlock(nil);
    }
    
    if (_locationBlock) {
        CLLocation *location;
        _locationBlock(location.coordinate);
    }
    if (_addressBlock) {
        _addressBlock(nil);
    }
    if (_cityBlock) {
        
        _cityBlock(nil);
      
    }

}

#pragma mark CLLocationManagerDelegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = [locations lastObject];
    
    CLLocationCoordinate2D beforeLocation = [ZJLocationTransform transformFromWGSToGCJ:newLocation.coordinate];
    //转化为百度坐标
    CLLocationCoordinate2D afterLocation = [ZJLocationTransform transformFromGCJToBaidu:beforeLocation];
    if (_locationBlock) {
        _locationBlock(afterLocation);
        _locationBlock = nil;
        
        return;
    }
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
            
            lastAddress=[NSString stringWithFormat:@"%@%@%@%@",state,city,subLocality,street];
            cityStr = city;
            
            if (_dictBlock)
            {
                _dictBlock(addressDic);
                _dictBlock = nil;
            }
            
            [_locationManager stopUpdatingLocation];
        }
        
        if (_locationBlock) {
            _locationBlock(afterLocation);
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
    
    
}


@end

//===============

static const double a = 6378245.0;
static const double ee = 0.00669342162296594323;
static const double pi = M_PI;
static const double xPi = M_PI  * 3000.0 / 180.0;

@implementation ZJLocationTransform

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    if (self = [super init]) {
        self.coordinate = coordinate;
    }
    return self;
}

- (id)transformFromGPSToGD {
    CLLocationCoordinate2D coor = [ZJLocationTransform transformFromWGSToGCJ:CLLocationCoordinate2DMake(self.coordinate.latitude, self.coordinate.longitude)];
    return [[ZJLocationTransform alloc] initWithCoordinate:coor];
}

- (id)transformFromGDToBD {
    CLLocationCoordinate2D coor = [ZJLocationTransform transformFromGCJToBaidu:CLLocationCoordinate2DMake(self.coordinate.latitude, self.coordinate.longitude)];
    return [[ZJLocationTransform alloc] initWithCoordinate:coor];
}

- (id)transformFromBDToGD {
    CLLocationCoordinate2D coor = [ZJLocationTransform transformFromBaiduToGCJ:CLLocationCoordinate2DMake(self.coordinate.latitude, self.coordinate.longitude)];
    return [[ZJLocationTransform alloc] initWithCoordinate:coor];
}

- (id)transformFromGDToGPS {
    CLLocationCoordinate2D coor = [ZJLocationTransform transformFromGCJToWGS:CLLocationCoordinate2DMake(self.coordinate.latitude, self.coordinate.longitude)];
    return [[ZJLocationTransform alloc] initWithCoordinate:coor];
}

- (id)transformFromBDToGPS {
    //先把百度转化为高德
    CLLocationCoordinate2D start_coor = [ZJLocationTransform transformFromBaiduToGCJ:CLLocationCoordinate2DMake(self.coordinate.latitude, self.coordinate.longitude)];
    CLLocationCoordinate2D end_coor = [ZJLocationTransform transformFromGCJToWGS:CLLocationCoordinate2DMake(start_coor.latitude, start_coor.longitude)];
    return [[ZJLocationTransform alloc] initWithCoordinate:end_coor];
}

+ (CLLocationCoordinate2D)transformFromWGSToGCJ:(CLLocationCoordinate2D)wgsLoc {
    CLLocationCoordinate2D adjustLoc;
    if([self isLocationOutOfChina:wgsLoc]) {
        adjustLoc = wgsLoc;
    }
    else {
        double adjustLat = [self transformLatWithX:wgsLoc.longitude - 105.0 withY:wgsLoc.latitude - 35.0];
        double adjustLon = [self transformLonWithX:wgsLoc.longitude - 105.0 withY:wgsLoc.latitude - 35.0];
        long double radLat = wgsLoc.latitude / 180.0 * pi;
        long double magic = sin(radLat);
        magic = 1 - ee * magic * magic;
        long double sqrtMagic = sqrt(magic);
        adjustLat = (adjustLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi);
        adjustLon = (adjustLon * 180.0) / (a / sqrtMagic * cos(radLat) * pi);
        adjustLoc.latitude = wgsLoc.latitude + adjustLat;
        adjustLoc.longitude = wgsLoc.longitude + adjustLon;
    }
    return adjustLoc;
}

+ (double)transformLatWithX:(double)x withY:(double)y {
    double lat = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));
    
    lat += (20.0 * sin(6.0 * x * pi) + 20.0 *sin(2.0 * x * pi)) * 2.0 / 3.0;
    lat += (20.0 * sin(y * pi) + 40.0 * sin(y / 3.0 * pi)) * 2.0 / 3.0;
    lat += (160.0 * sin(y / 12.0 * pi) + 320 * sin(y * pi / 30.0)) * 2.0 / 3.0;
    return lat;
}

+ (double)transformLonWithX:(double)x withY:(double)y {
    double lon = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
    lon += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    lon += (20.0 * sin(x * pi) + 40.0 * sin(x / 3.0 * pi)) * 2.0 / 3.0;
    lon += (150.0 * sin(x / 12.0 * pi) + 300.0 * sin(x / 30.0 * pi)) * 2.0 / 3.0;
    return lon;
}

+ (CLLocationCoordinate2D)transformFromGCJToBaidu:(CLLocationCoordinate2D)p {
    long double z = sqrt(p.longitude * p.longitude + p.latitude * p.latitude) + 0.00002 * sqrt(p.latitude * pi);
    long double theta = atan2(p.latitude, p.longitude) + 0.000003 * cos(p.longitude * pi);
    CLLocationCoordinate2D geoPoint;
    //猪猪修正0.0002
    geoPoint.latitude  = (z * sin(theta) + 0.006 +0.0003);
    geoPoint.longitude = (z * cos(theta) + 0.0065 -0.0002);
    return geoPoint;
}

+ (CLLocationCoordinate2D)transformFromBaiduToGCJ:(CLLocationCoordinate2D)p {
    double x = p.longitude - 0.0065, y = p.latitude - 0.006;
    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * xPi);
    double theta = atan2(y, x) - 0.000003 * cos(x * xPi);
    CLLocationCoordinate2D geoPoint;
    geoPoint.latitude  = z * sin(theta);
    geoPoint.longitude = z * cos(theta);
    return geoPoint;
}

+ (CLLocationCoordinate2D)transformFromGCJToWGS:(CLLocationCoordinate2D)p {
    double threshold = 0.00001;
    
    // The boundary
    double minLat = p.latitude - 0.5;
    double maxLat = p.latitude + 0.5;
    double minLng = p.longitude - 0.5;
    double maxLng = p.longitude + 0.5;
    
    double delta = 1;
    int maxIteration = 30;
    // Binary search
    while(true) {
        CLLocationCoordinate2D leftBottom  = [[self class] transformFromWGSToGCJ:(CLLocationCoordinate2D){.latitude = minLat,.longitude = minLng}];
        CLLocationCoordinate2D rightBottom = [[self class] transformFromWGSToGCJ:(CLLocationCoordinate2D){.latitude = minLat,.longitude = maxLng}];
        CLLocationCoordinate2D leftUp      = [[self class] transformFromWGSToGCJ:(CLLocationCoordinate2D){.latitude = maxLat,.longitude = minLng}];
        CLLocationCoordinate2D midPoint    = [[self class] transformFromWGSToGCJ:(CLLocationCoordinate2D){.latitude = ((minLat + maxLat) / 2),.longitude = ((minLng + maxLng) / 2)}];
        delta = fabs(midPoint.latitude - p.latitude) + fabs(midPoint.longitude - p.longitude);
        
        if(maxIteration-- <= 0 || delta <= threshold) {
            return (CLLocationCoordinate2D){.latitude = ((minLat + maxLat) / 2),.longitude = ((minLng + maxLng) / 2)};
        }
        
        if(isContains(p, leftBottom, midPoint)) {
            maxLat = (minLat + maxLat) / 2;
            maxLng = (minLng + maxLng) / 2;
        } else if(isContains(p, rightBottom, midPoint)) {
            maxLat = (minLat + maxLat) / 2;
            minLng = (minLng + maxLng) / 2;
        } else if(isContains(p, leftUp, midPoint)) {
            minLat = (minLat + maxLat) / 2;
            maxLng = (minLng + maxLng) / 2;
        } else {
            minLat = (minLat + maxLat) / 2;
            minLng = (minLng + maxLng) / 2;
        }
    }
    
}

#pragma mark - 判断某个点point是否在p1和p2之间
static bool isContains(CLLocationCoordinate2D point, CLLocationCoordinate2D p1, CLLocationCoordinate2D p2) {
    return (point.latitude >= MIN(p1.latitude, p2.latitude) && point.latitude <= MAX(p1.latitude, p2.latitude)) && (point.longitude >= MIN(p1.longitude,p2.longitude) && point.longitude <= MAX(p1.longitude, p2.longitude));
}

#pragma mark - 判断是不是在中国
+ (BOOL)isLocationOutOfChina:(CLLocationCoordinate2D)location {
    if (location.longitude < 72.004 || location.longitude > 137.8347 || location.latitude < 0.8293 || location.latitude > 55.8271)
        return YES;
    return NO;
}

@end
