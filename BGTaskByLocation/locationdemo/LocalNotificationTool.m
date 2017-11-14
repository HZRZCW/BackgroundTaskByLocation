//
//  LocalNotificationTool.m
//  mpc_ios
//
//  Created by nanMenHaiShao on 2017/10/24.
//  Copyright © 2017年 litong. All rights reserved.
//

#import "LocalNotificationTool.h"
#import <UserNotifications/UserNotifications.h>

@interface LocalNotificationTool ()<UNUserNotificationCenterDelegate>

@end

@implementation LocalNotificationTool

singleton_implementation(LocalNotificationTool);

/**
 *  生成32位UUID
 */
- (NSString *)getUUIDString{
    
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    //去除UUID ”-“
    NSString *UUID = [[uuid lowercaseString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    return UUID;
}

/**
 创建本地通知

 @param title 通知标题
 @param subtitle 副标题
 @param identifier 区分不同通知的id
 */
- (void)createLocateNoticatificationWithTitle:(NSString *)title Subtitle:(NSString *)subtitle{
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        //获取当前的通知设置，UNNotificationSettings 是只读对象，不能直接修改，只能通过以下方法获取
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            [self registerNotification:1 WithAlertTitle:title Subtitle:subtitle];
        }];
}

//iOS10使用 UNNotification 本地通知
- (void)registerNotification:(NSInteger )alerTime WithAlertTitle:(NSString *)title Subtitle:(NSString *)subtitle{

        // 使用 UNUserNotificationCenter 来管理通知
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound)
                              completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                  // Enable or disable features based on authorization.
                              }];
        //需创建一个包含待通知内容的 UNMutableNotificationContent 对象，注意不是 UNNotificationContent ,此对象为不可变对象。
        UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
        content.title = [NSString localizedUserNotificationStringForKey:title arguments:nil];
        content.body = [NSString localizedUserNotificationStringForKey:subtitle  arguments:nil];
        content.sound = [UNNotificationSound soundNamed:@"recognizeFlagSound.wav"];
        // 在 alertTime 后推送本地推送
        UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:alerTime repeats:NO];
        NSString *identifier = [NSString stringWithFormat:@"%@",[self getUUIDString]];
        UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:identifier
                                                                              content:content trigger:trigger];
        //添加推送成功后的处理！
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            
        }];
  
}

#pragma mark - UNUserNotificationCenterDelegate
// 在展示通知前进行处理，即有机会在展示通知前再修改通知内容。
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    //1. 处理通知

        //2. 处理完成后条用 completionHandler ，用于指示在前台显示通知的形式
        completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
    
}

@end
