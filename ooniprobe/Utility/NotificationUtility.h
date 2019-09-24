#import <Foundation/Foundation.h>
#import "MessageUtility.h"

@interface NotificationUtility : NSObject


+ (void)showLocalNotification:(NSDate*)fireDate withText:(NSString*)text;
+ (void)scheduleLocalNotification:(NSDate*)fireDate withText:(NSString*)text;

@end
