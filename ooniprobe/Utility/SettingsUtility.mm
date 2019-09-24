#import "SettingsUtility.h"
#import "TestUtility.h"

@implementation SettingsUtility

+ (NSArray*)getSettingsCategories{
    return @[@"notifications", @"automated_testing", @"sharing", @"advanced", @"send_email", @"about_ooni"];
}

+ (NSArray*)getSettingsForCategory:(NSString*)categoryName{
    if ([categoryName isEqualToString:@"notifications"]) {
        if ([self getSettingWithName:@"notifications_enabled"])
            //TODO NEWS reenable @"notifications_news"
            return @[@"notifications_enabled", @"notifications_completion"];
        else
            return @[@"notifications_enabled"];
    }
    else if ([categoryName isEqualToString:@"automated_testing"]) {
        if ([self getSettingWithName:@"test_reminder"])
            return @[@"test_reminder", @"test_reminder_time"];
        else
            return @[@"test_reminder"];
    }
    else if ([categoryName isEqualToString:@"sharing"]) {
        //TODO GPS @"include_gps"
        return @[@"upload_results", @"upload_results_manually", @"include_asn", @"include_cc", @"include_ip"];
    }
    else if ([categoryName isEqualToString:@"advanced"]) {
        //TODO DOMAIN FRONTING @"use_domain_fronting"
        return @[@"send_crash", @"debug_logs"];
    }
    else
        return nil;
}

+ (NSString*)getTypeForSetting:(NSString*)setting{
    if ([setting isEqualToString:@"website_categories"])
        return @"segue";
    else if ([setting isEqualToString:@"monthly_mobile_allowance"] || [setting isEqualToString:@"monthly_wifi_allowance"] || [setting isEqualToString:@"max_runtime"])
        return @"int";
    if ([setting isEqualToString:@"test_reminder_time"])
        return @"date";
    return @"bool";
}

+ (NSArray*)getAutomaticTestsEnabled{
    return [[NSUserDefaults standardUserDefaults] arrayForKey:@"automatic_tests"];
}

+ (NSString*)getVerbosity {
    if ([self getSettingWithName:@"debug_logs"])
        return @"DEBUG2";
    return @"INFO";
}

+ (NSArray*)addRemoveAutomaticTest:(NSString*)testName{
    NSMutableArray *automaticTests = [[self getAutomaticTestsEnabled] mutableCopy];
    if ([automaticTests containsObject:testName])
        [automaticTests removeObject:testName];
    else
        [automaticTests addObject:testName];
    [[NSUserDefaults standardUserDefaults] setObject:automaticTests forKey:@"automatic_tests"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return automaticTests;
}

+ (NSArray*)getSitesCategories{
    return @[@"ANON",
             @"COMT",
             @"CTRL",
             @"CULTR",
             @"ALDR",
             @"COMM",
             @"ECON",
             @"ENV",
             @"FILE",
             @"GMB",
             @"GAME",
             @"GOVT",
             @"HACK",
             @"HATE",
             @"HOST",
             @"HUMR",
             @"IGO",
             @"LGBT",
             @"MMED",
             @"MISC",
             @"NEWS",
             @"DATE",
             @"POLR",
             @"PORN",
             @"PROV",
             @"PUBH",
             @"REL",
             @"SRCH",
             @"XED",
             @"GRP",
             @"MILX"];
}

+ (NSArray*)getSitesCategoriesDisabled {
    return [[NSUserDefaults standardUserDefaults] arrayForKey:@"categories_disabled"];
}

+ (long)getNumberCategoriesEnabled{
    return [[self getSitesCategories] count] - [[self getSitesCategoriesDisabled] count];
}

+ (NSArray*)addRemoveSitesCategory:(NSString*)categoryName {
    NSMutableArray *categories_disabled = [[self getSitesCategoriesDisabled] mutableCopy];
    if ([categories_disabled containsObject:categoryName])
        [categories_disabled removeObject:categoryName];
    else
        [categories_disabled addObject:categoryName];
    [[NSUserDefaults standardUserDefaults] setObject:categories_disabled forKey:@"categories_disabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return categories_disabled;
}

+ (NSArray*)getSettingsForTest:(NSString*)testName :(BOOL)includeAll{
    NSMutableArray *settings = [[NSMutableArray alloc] init];
    if ([testName isEqualToString:@"websites"]) {
        if (includeAll) [settings addObject:@"website_categories"];
        if (includeAll) [settings addObject:@"max_runtime"];
    }
    else if ([testName isEqualToString:@"instant_messaging"]) {
        [settings addObject:@"test_whatsapp"];
        if (includeAll && [self getSettingWithName:@"test_whatsapp"])
            [settings addObject:@"test_whatsapp_extensive"];
        [settings addObject:@"test_telegram"];
        [settings addObject:@"test_facebook_messenger"];
    }
    else if ([testName isEqualToString:@"middle_boxes"]) {
        [settings addObject:@"run_http_invalid_request_line"];
        [settings addObject:@"run_http_header_field_manipulation"];
    }
    else if ([testName isEqualToString:@"performance"]) {
        [settings addObject:@"run_ndt"];
        [settings addObject:@"run_dash"];
    }
    return settings;
}

+ (BOOL)getSettingWithName:(NSString*)settingName{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:settingName] boolValue];
}

+ (NSString*)get_push_token{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"push_token"]){
        return [[NSUserDefaults standardUserDefaults] objectForKey:@"push_token"];
    }
    return @"";
}

+ (void)set_push_token:(NSString*)push_token{
    [[NSUserDefaults standardUserDefaults] setObject:push_token forKey:@"push_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
