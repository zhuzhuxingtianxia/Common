//
//  HHLocationManger.h
//  BMHaoLeDi
//
//  Created by sam.l on 14-11-24.typedef void (^LocationBlock)(CLLocationCoordinate2D locationCorrrdinate);
//  Copyright (c) 2014年 bluemob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#define  HHLastLongitude @"MMLastLongitude"
#define  HHLastLatitude  @"MMLastLatitude"
@interface HHLocationManger : NSObject<CLLocationManagerDelegate>

typedef void (^LocationBlock)(CLLocationCoordinate2D locationCorrrdinate);
typedef void (^AddressBlock)(NSString *address);
typedef void (^CityBlock)(NSString *city);
typedef void (^DictBlock)(NSDictionary *dict);
@property (nonatomic, strong) LocationBlock locationBlock;
@property (nonatomic, strong) AddressBlock addressBlock;
@property (nonatomic, strong) CityBlock cityBlock;
@property (nonatomic, strong) DictBlock dictBlock;

@property (nonatomic, strong) CLLocationManager *locationManager;

//@property(nonatomic,assign)float latitude;
//@property(nonatomic,assign)float longitude;
+ (HHLocationManger *)shareLocation;

- (void)getUserLocation;
- (void)getLocationCoordinate:(LocationBlock) locaiontBlock ;
- (void)getAddress:(AddressBlock)addressBlock ;
- (void)getCityBlock:(CityBlock)cityBlock;
- (void)getDictBlock:(DictBlock)dictBlock;
@end
