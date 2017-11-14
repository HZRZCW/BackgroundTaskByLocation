//
//  BGLogation.m
//  locationdemo
//
//  Created by yebaojia on 16/2/24.
//  Copyright © 2016年 mjia. All rights reserved.
//

#import "BGLogation.h"
#import "BGTask.h"
#import "LocalNotificationTool.h"

@interface BGLogation()
{
    BOOL isCollect;
}
@property (strong , nonatomic) BGTask *bgTask; //后台任务
@property (strong , nonatomic) NSTimer *restarTimer; //重新开启后台任务定时器
@property (nonatomic,strong) CLLocationManager *locationManager;

@end
@implementation BGLogation

#pragma mark - customGeoFenceManager初始化
- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        //    locationManager.distanceFilter = kCLDistanceFilterNone; // 不移动也可以后台刷新回调
        _locationManager.distanceFilter = 1000;
        if ([[UIDevice currentDevice].systemVersion floatValue]>= 8.0) {
            [_locationManager requestAlwaysAuthorization];
        }
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
            _locationManager.allowsBackgroundLocationUpdates = YES;  //允许后台定位
        }
        _locationManager.pausesLocationUpdatesAutomatically = NO; // 不允许系统暂停
    }
    return _locationManager;
}

+ (instancetype)sharedManager
{
    static BGLogation *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BGLogation alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if ( self )
    {
        isCollect = NO;
        _bgTask = [BGTask shareBGTask];
        //监听进入后台通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}
- (void)dealloc {
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
    self.locationManager = nil;
}

- (void)start{
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter  = 1000;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    if ([[UIDevice currentDevice].systemVersion floatValue]>= 8.0) {
        [self.locationManager requestAlwaysAuthorization];
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
        self.locationManager.allowsBackgroundLocationUpdates = YES;  //允许后台定位
    }
    self.locationManager.pausesLocationUpdatesAutomatically = NO; // 不允许系统暂停
    [self.locationManager startUpdatingLocation];
}

//后台监听方法
-(void)applicationEnterBackground
{
    NSLog(@"come in background");
    [self start];
    [_bgTask beginNewBackgroundTask];
}

//重启定位服
-(void)restartLocation
{
    NSLog(@"重新启动定位");
    [self start];
    [self.bgTask beginNewBackgroundTask];
//    [[LocalNotificationTool sharedLocalNotificationTool] createLocateNoticatificationWithTitle:@"重新启动定位" Subtitle:@"测试而已"];
}
//开启服务
- (void)startLocation {
    NSLog(@"开启定位");
    if ([CLLocationManager locationServicesEnabled] == NO) {
        NSLog(@"locationServicesEnabled false");
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [servicesDisabledAlert show];
    } else {
        CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
        if(authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted){
            NSLog(@"authorizationStatus failed");
        } else {
            NSLog(@"authorizationStatus authorized");
            [self start];
        }
    }
}

//停止后台定位
-(void)stopLocation
{
    NSLog(@"停止定位");
    isCollect = NO;
    [self.locationManager stopUpdatingLocation];
//    [[LocalNotificationTool sharedLocalNotificationTool] createLocateNoticatificationWithTitle:@"停止定位" Subtitle:@"测试而已"];
}
#pragma mark --delegate
//定位回调里执行重启定位和关闭定位
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    NSLog(@"定位收集");
    CLLocation *location = locations.lastObject;
    NSTimeInterval locationAge = [location.timestamp timeIntervalSinceNow];
    if (fabs(locationAge) > 2.0)
    {
        NSLog(@"不是最新的定位结果：%@, 与当前时间差：%f 秒",location,locationAge);
        return ;
    }
    if (location.horizontalAccuracy < 0)
    {
        NSLog(@"此次定位结果不可用：%@",location);
        return;
    }
    //如果正在10秒定时收集的时间，不需要执行延时开启和关闭定位
    if (isCollect) {
        return;
    }
    [self performSelector:@selector(restartLocation) withObject:nil afterDelay:160];
    [self performSelector:@selector(stopLocation) withObject:nil afterDelay:10];
    isCollect = YES;//标记正在定位
}

- (void)locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error
{
    // NSLog(@"locationManager error:%@",error);
    
    switch([error code])
    {
        case kCLErrorNetwork: // general, network-related error
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络错误" message:@"请检查网络连接" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        case kCLErrorDenied:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请开启后台服务" message:@"应用不可以定位，需要在在设置/通用/后台应用刷新开启" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        default:
        {
            
        }
        break;
    }
}

@end
