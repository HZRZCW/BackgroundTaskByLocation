//
//  ViewController.m
//  locationdemo
//
//  Created by yebaojia on 16/2/23.
//  Copyright © 2016年 mjia. All rights reserved.
//

#import "ViewController.h"
#import "GCD.h"
#import "AppDelegate.h"
#import "LocalNotificationTool.h"
#import "DispatchTimer.h"

@interface ViewController ()

//@property(strong,nonatomic) GCDTimer *timer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //运行GCDTimer
    [self runGCDTimer];
}

- (void)runGCDTimer{
//    //初始化定时器
//    self.timer = [[GCDTimer alloc] initInQueue:[GCDQueue mainQueue]];
//    //指定时间间隔以及要执行的事件；
//    [self.timer event:^{
//        //在这里写入需要重复执行的代码；
//        [[LocalNotificationTool sharedLocalNotificationTool] createLocateNoticatificationWithTitle:@"常驻后台" Subtitle:@"测试而已"];
//
//    } timeIntervalWithSecs:1800.0f];
//    //运行
//    [self.timer start];
    
    [DispatchTimer scheduleDispatchTimerWithName:@"test" timeInterval:1800 queue:nil repeats:YES action:^{
        //在这里写入需要重复执行的代码；
        [[LocalNotificationTool sharedLocalNotificationTool] createLocateNoticatificationWithTitle:@"常驻后台" Subtitle:@"测试而已"];
    }];
}


@end
