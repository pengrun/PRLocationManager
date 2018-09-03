//
//  PRCLLocationManager.h
//  PRLocationManager
//
//  Created by huashuda on 2018/9/3.
//  Copyright © 2018年 huashuda. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>
typedef void (^PRLocationCurrentAuthStatus)(BOOL isEnableLocation);
typedef void (^PRLocationSuccess)(CLLocation *location, CLPlacemark *placemark);
typedef void (^PRLocationFaile)(NSError *error);

@interface PRLocationManager : CLLocationManager
@property (nonatomic, copy) PRLocationCurrentAuthStatus currentAuthStatus;
/**
 单例

 @return 单例
 */
+ (PRLocationManager *)shareManager;
/**
 判断能否定位

 @return YES 可以定位 NO 不能定位
 */
- (BOOL)isEnabledLocation;
/**
 停止定位，开始后要手动停止
 */
- (void)locationStop;
/**
 回调结果

 @param success 成功回调
 @param faile 失败回调
 */
- (void)locationStartSuccess:(PRLocationSuccess)success faile:(PRLocationFaile)faile;

/**
 打开设置
 */
+ (void)openLocationService;
@end
