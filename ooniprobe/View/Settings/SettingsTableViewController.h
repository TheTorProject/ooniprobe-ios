#import <UIKit/UIKit.h>
#import "SettingsUtility.h"
#import "UIView+Toast.h"
#import "MessageUtility.h"
#import "TestUtility.h"
#import <UserNotifications/UserNotifications.h>
#import "Suite.h"

@interface SettingsTableViewController : UITableViewController <UITextFieldDelegate, UIAlertViewDelegate> {
    NSArray *items;
    UIToolbar *keyboardToolbar;
    NSDateFormatter *timeFormatter;
    UITextField *timeField;
}

@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) AbstractSuite *testSuite;

@end
