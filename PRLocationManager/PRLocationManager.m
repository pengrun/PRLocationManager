//
//  PRCLLocationManager.m
//  PRLocationManager
//
//  Created by huashuda on 2018/9/3.
//  Copyright © 2018年 huashuda. All rights reserved.
//

#import "PRLocationManager.h"
#import <UIKit/UIKit.h>
@interface PRLocationManager () <CLLocationManagerDelegate>

@property (nonatomic, copy) PRLocationSuccess successBlock;
@property (nonatomic, copy) PRLocationFaile errorBlock;

@end

@implementation PRLocationManager
#pragma mark ^^^^^^ 单例 ^^^^^^
+ (PRLocationManager *)shareManager {
    static PRLocationManager *shareObject;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObject = [[PRLocationManager alloc] init];
    });
    return shareObject;
}
#pragma mark ^^^^^^ Init ^^^^^^
- (instancetype)init {
    if ([super init]) {
        self.delegate = self;
        // 设置位置精确度 最佳精确度
        self.desiredAccuracy = kCLLocationAccuracyBest;
        // 设置位置距离精确度
        self.distanceFilter = 10.0;
        // 始终允许访问位置信息
        if ([self respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self requestAlwaysAuthorization];
        }
        // 使用应用程序期间允许访问位置数据
        if ([self respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self requestWhenInUseAuthorization];
        }
    }
    return self;
}
#pragma mark ^^^^^^ Method ^^^^^^
// 判断定位操作是否被允许
- (BOOL)isEnabledLocation {
    if ([CLLocationManager locationServicesEnabled]) {
        return YES;
    }
    return NO;
}
// 定位开始
- (void)locationStart {
    if ([self isEnabledLocation]) {
        NSLog(@"开始定位");
        [self startUpdatingLocation];
    }
}
// 开始定位
- (void)locationStartSuccess:(PRLocationSuccess)success faile:(PRLocationFaile)faile {
    self.successBlock = [success copy];
    self.errorBlock = [faile copy];
    
    [self locationStart];
}
// 定位停止
- (void)locationStop {
    NSLog(@"结束定位");
    [self stopUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate
#pragma mark ^^^^^^ 开始定位 ^^^^^^
// 获取定位信息
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    // locations存储了持续更新的位置坐标值，取最后一个值为最新位置，如果不想让其持续更新位置，则在此方法中获取到一个值之后让locationManager stopUpdatingLocation
    CLLocation *currentLocation = [locations lastObject];
    
    // 纬度：loc.coordinate.latitude
    // 经度：loc.coordinate.longitude
    NSLog(@"纬度=%f，经度=%f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
    
    // 获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    // 根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *array, NSError *error) {
        if (array.count > 0) {
            CLPlacemark *placemark = [array objectAtIndex:0];
            !self.successBlock ?: self.successBlock(currentLocation, placemark);
        } else {
            if (([error code] == kCLErrorDenied)) {
                !self.currentAuthStatus ?: self.currentAuthStatus(NO);
            } else {
                !self.errorBlock ?: self.errorBlock(error);
            }
        }
    }];
    
    // 注意：获取之后就停止更新，避免系统会多次更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可
    [self locationStop];
}
#pragma mark ^^^^^^ 定位失败 ^^^^^^
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    !self.errorBlock ?: self.errorBlock(error);
    [self locationStop];
}
#pragma mark ^^^^^^ 授权改变 ^^^^^^
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse ||
        status == kCLAuthorizationStatusNotDetermined ||
        status == kCLAuthorizationStatusAuthorizedAlways) {
        !self.currentAuthStatus ?: self.currentAuthStatus(YES); // 可以定位
    } else {
        !self.currentAuthStatus ?: self.currentAuthStatus(NO); // 不能定位
    }
}
#pragma mark ^^^^^^ 打开设置 ^^^^^^
+ (void)openLocationService {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{UIApplicationOpenURLOptionUniversalLinksOnly:@""} completionHandler:nil];
        } else{
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}


@end
