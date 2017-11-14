//
//  LocalNotificationTool.h
//  mpc_ios
//
//  Created by nanMenHaiShao on 2017/10/24.
//  Copyright © 2017年 litong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"

@interface LocalNotificationTool : NSObject

singleton_interface(LocalNotificationTool);

- (void)createLocateNoticatificationWithTitle:(NSString *)title Subtitle:(NSString *)subtitle;

@end
