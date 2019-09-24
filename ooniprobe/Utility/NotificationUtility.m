//
//  NotificationUtility.m
//  ooniprobe
//
//  Created by Lorenzo Primiterra on 24/09/2019.
//  Copyright © 2019 OONI. All rights reserved.
//

#import "NotificationUtility.h"

@implementation NotificationUtility

+ (UILocalNotification*)prepareNotification:(NSDate*)fireDate withText:(NSString*)text{
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = fireDate;
    localNotification.alertBody = text;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.repeatInterval = NSCalendarUnitDay;
    [localNotification setApplicationIconBadgeNumber:[[UIApplication sharedApplication] applicationIconBadgeNumber] + 1];
    return localNotification;
}


+ (void)showLocalNotification:(NSDate*)fireDate withText:(NSString*)text
{
    UILocalNotification* localNotification = [self prepareNotification:fireDate withText:text];
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}

+ (void)scheduleLocalNotification:(NSDate*)fireDate withText:(NSString*)text{
    [self cancelScheduledNotifications];
    UILocalNotification* localNotification = [self prepareNotification:fireDate withText:text];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}


+ (void)cancelScheduledNotifications{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

@end
