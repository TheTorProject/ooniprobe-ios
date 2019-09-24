#import "Suite.h"
#import "NotificationUtility.h"

@implementation AbstractSuite

-(id) init {
    self = [super init];
    if (self) {
        self.backgroundTask = UIBackgroundTaskInvalid;
        self.testList = [[NSMutableArray alloc] init];
    }
    return self;
}

-(id)initSuite:(NSString*)testSuite{
    if ([testSuite isEqualToString:@"websites"])
        self = [[WebsitesSuite alloc] init];
    else if ([testSuite isEqualToString:@"performance"])
        self = [[PerformanceSuite alloc] init];
    else if ([testSuite isEqualToString:@"middle_boxes"])
        self = [[MiddleBoxesSuite alloc] init];
    else if ([testSuite isEqualToString:@"instant_messaging"])
        self = [[InstantMessagingSuite alloc] init];
    return self;
}

-(void)runTestSuite {
    [self newResult];
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }];
    for (AbstractTest *current in [self getTestList]){
        [current setDelegate:self];
        [current setResult:self.result];
        [current runTest];
    }
}

-(void)testEnded:(AbstractTest*)test{
    [self.testList removeObject:test];
    [self.result save];
    self.measurementIdx++;
    //if last test
    if ([self.testList count] == 0){
        [self.result setIs_done:YES];
        [self.result save];
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        if (state == UIApplicationStateBackground || state == UIApplicationStateInactive){
            if ([SettingsUtility getSettingWithName:@"notifications_enabled"] && [SettingsUtility getSettingWithName:@"notifications_completion"])
                [NotificationUtility showLocalNotification:[NSDate date]
                                                  withText:[NSString stringWithFormat:@"%@ %@",
                                                            [LocalizationUtility getNameForTest:self.result.test_group_name], NSLocalizedString(@"Notification.FinishedRunning", nil)]];
        }
        //Resetting class values
        self.result = nil;
        self.measurementIdx = 0;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"networkTestEnded" object:nil];
    }
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
    self.backgroundTask = UIBackgroundTaskInvalid;
}

-(NSArray*)getTestList {
    return self.testList;
}

-(void)newResult {
    //For rerun measurement result is set by the view controller
    if (self.result == nil){
        self.result = [Result new];
        [self.result setTest_group_name:self.name];
        //The Result object needs to be saved to have an Id, needed for log
        [self.result save];
    }
}

-(int)getRuntime{
    int runtime = 0;
    for (AbstractTest *current in [self getTestList]){
        runtime+=[current getRuntime];
    }
    return runtime;
}

@end
