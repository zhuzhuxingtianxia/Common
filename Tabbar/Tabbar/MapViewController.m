//
//  MapViewController.m
//  Tabbar
//
//  Created by Jion on 15/5/11.
//  Copyright (c) 2015年 Youjuke. All rights reserved.
//

/*
在Info.plist中加入两个缺省没有的字段

NSLocationAlwaysUsageDescription

NSLocationWhenInUseUsageDescription
*/

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "HHLocationManger.h"

@interface MapViewController ()<MKMapViewDelegate,UISearchBarDelegate>
{
    UIBarButtonItem *_rightItem;
    UILabel *addressLabel;
    UISearchBar *_searchBar;
    BOOL _isHide;
}
@property(nonatomic,strong)MKMapView *mapView;
@property(nonatomic,strong)HHLocationManger *locationManger;
@end

@implementation MapViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.tabBarItem.image = [[UIImage imageNamed:@"tab_button_message@2x"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"tab_button_message@2x"];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.navigationItem.title = @"地图";
    _rightItem = [[UIBarButtonItem alloc] initWithTitle:@"搜索" style:UIBarButtonItemStylePlain target:self action:@selector(searchBar)];
    self.tabBarController.navigationItem.rightBarButtonItem = _rightItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    // Do any additional setup after loading the view.
    self.locationManger = [HHLocationManger shareLocation];
    [self loadMapView];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    _searchBar.delegate = self;
    _searchBar.backgroundColor = [UIColor whiteColor];
    _searchBar.hidden = YES;
    _searchBar.showsCancelButton = YES;
    [self.view addSubview:_searchBar];
}
//添加搜索
- (void)searchBar
{
    NSLog(@"添加搜索");
   
    if (!_isHide) {
        _isHide = YES;
        _rightItem.title = @"隐藏";
        _searchBar.hidden = NO;
        addressLabel.hidden = YES;
    }
    else{
        _isHide = NO;
        _rightItem.title = @"搜索";
        _searchBar.hidden = YES;
        addressLabel.hidden = NO;
    }
    
}

//加载地图
- (void)loadMapView
{
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height-40-64-50)];
    self.mapView.mapType = MKMapTypeStandard;
   //允许跟踪显示用户位置信息
    [self.mapView setShowsUserLocation:YES];
    //设置用户跟踪模式
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    
    self.mapView.delegate = self;
    [self.view addSubview: self.mapView];
//    [self.locationManger getLocationCoordinate:^(CLLocationCoordinate2D locationCorrrdinate) {
//    
//        //设置跨度两种方式 1）
//       MKCoordinateRegion Region = MKCoordinateRegionMakeWithDistance(locationCorrrdinate, 1000, 1000);
//        [self.mapView setRegion:Region];
//        //设置跨度两种方式 2）
////        [self.mapView setRegion:MKCoordinateRegionMake(locationCorrrdinate, MKCoordinateSpanMake(0.01, 0.01)) animated:NO];
//        //和上面的一句代码有什么区别吗？
////        [self setCenterCoordinate:locationCorrrdinate zoomLevel:15 animated:YES];
//        
//    }];
    
    [self.locationManger getDictBlock:^(NSDictionary *dict) {
        addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        NSString *state=[dict objectForKey:@"State"];
        NSString *subLocality=[dict objectForKey:@"SubLocality"];
         NSString *street=[dict objectForKey:@"Street"];
        NSString *address = [NSString stringWithFormat:@"%@%@%@",state,subLocality,street];
        addressLabel.text = address;
        NSLog(@"%@",address);
        addressLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:addressLabel];
    }];
    
}
#pragma mark--UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"搜索");
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"取消");
    [_searchBar resignFirstResponder];
}

#pragma mark--MKMapViewDelegate
- (MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    return nil;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation

{
    
    _mapView.centerCoordinate = userLocation.location.coordinate;
    MKCoordinateRegion Region = MKCoordinateRegionMakeWithDistance(_mapView.centerCoordinate, 1000, 1000);
    [self.mapView setRegion:Region];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Public methods
- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated
{
    // clamp large numbers to 28
    zoomLevel = MIN(zoomLevel, 28);
    
    // use the zoom level to compute the region
    MKCoordinateSpan span = [self coordinateSpanWithMapView:self.mapView centerCoordinate:centerCoordinate andZoomLevel:zoomLevel];
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, span);
    
    // set the region like normal
    [self.mapView setRegion:region animated:animated];
}

- (MKCoordinateSpan)coordinateSpanWithMapView:(MKMapView *)mapView
                             centerCoordinate:(CLLocationCoordinate2D)centerCoordinate
                                 andZoomLevel:(NSUInteger)zoomLevel
{
    // convert center coordiate to pixel space
    double centerPixelX = [self longitudeToPixelSpaceX:centerCoordinate.longitude];
    double centerPixelY = [self latitudeToPixelSpaceY:centerCoordinate.latitude];
    
    // determine the scale value from the zoom level
    NSInteger zoomExponent = 20 - zoomLevel;
    double zoomScale = pow(2, zoomExponent);
    
    // scale the map's size in pixel space
    CGSize mapSizeInPixels = mapView.bounds.size;
    double scaledMapWidth = mapSizeInPixels.width * zoomScale;
    double scaledMapHeight = mapSizeInPixels.height * zoomScale;
    
    // figure out the position of the top-left pixel
    double topLeftPixelX = centerPixelX - (scaledMapWidth / 2);
    double topLeftPixelY = centerPixelY - (scaledMapHeight / 2);
    
    // find delta between left and right longitudes
    CLLocationDegrees minLng = [self pixelSpaceXToLongitude:topLeftPixelX];
    CLLocationDegrees maxLng = [self pixelSpaceXToLongitude:topLeftPixelX + scaledMapWidth];
    CLLocationDegrees longitudeDelta = maxLng - minLng;
    
    // find delta between top and bottom latitudes
    CLLocationDegrees minLat = [self pixelSpaceYToLatitude:topLeftPixelY];
    CLLocationDegrees maxLat = [self pixelSpaceYToLatitude:topLeftPixelY + scaledMapHeight];
    CLLocationDegrees latitudeDelta = -1 * (maxLat - minLat);
    
    // create and return the lat/lng span
    MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
    return span;
}

#define MERCATOR_OFFSET 268435456
#define MERCATOR_RADIUS 85445659.44705395
- (double)longitudeToPixelSpaceX:(double)longitude
{
    return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / 180.0);
}

- (double)latitudeToPixelSpaceY:(double)latitude
{
    return round(MERCATOR_OFFSET - MERCATOR_RADIUS * logf((1 + sinf(latitude * M_PI / 180.0)) / (1 - sinf(latitude * M_PI / 180.0))) / 2.0);
}

- (double)pixelSpaceXToLongitude:(double)pixelX
{
    return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / M_PI;
}

- (double)pixelSpaceYToLatitude:(double)pixelY
{
    return (M_PI / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / M_PI;
}


@end
