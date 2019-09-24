#import "SettingsTableViewController.h"

@interface SettingsTableViewController ()
@end

@implementation SettingsTableViewController
@synthesize category, testSuite;

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(registeredForNotifications)
                                                 name:@"registeredForNotifications"
                                               object:nil];

    if (category != nil)
        self.title = [LocalizationUtility getNameForSetting:category];
    else if (testSuite != nil)
        self.title = [LocalizationUtility getNameForTest:testSuite.name];
    self.navigationController.navigationBar.topItem.title = @"";
    timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH:mm"];
    keyboardToolbar = [[UIToolbar alloc] init];
    [keyboardToolbar sizeToFit];
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                      target:self.view action:@selector(endEditing:)];
    keyboardToolbar.items = @[flexBarButton, doneBarButton];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reloadSettings];
}

-(void)reloadSettings {
    if (category != nil)
        items = [SettingsUtility getSettingsForCategory:category];
    else if (testSuite != nil)
        items = [SettingsUtility getSettingsForTest:testSuite.name :YES];
    //hide rows smooth
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    });
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (testSuite != nil){
        [testSuite.testList removeAllObjects];
        [testSuite getTestList];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"settingsChanged" object:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [items count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (category != nil && [category isEqualToString:@"sharing"])
        return NSLocalizedString(@"Settings.Sharing.Footer", nil);
    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    NSString *current = [items objectAtIndex:indexPath.row];
    if ([[SettingsUtility getTypeForSetting:current] isEqualToString:@"bool"]){
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.textLabel.text = [LocalizationUtility getNameForSetting:current];
        cell.textLabel.textColor = [UIColor colorWithRGBHexString:color_gray9 alpha:1.0f];
        UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
        [switchview addTarget:self action:@selector(setSwitch:) forControlEvents:UIControlEventValueChanged];
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:current] boolValue]) switchview.on = YES;
        else switchview.on = NO;
        cell.accessoryView = switchview;
    }
    else if ([[SettingsUtility getTypeForSetting:current] isEqualToString:@"segue"]){
        if ([current isEqualToString:@"website_categories"]){
            cell = [tableView dequeueReusableCellWithIdentifier:@"CellSub" forIndexPath:indexPath];
            NSString *subtitle = NSLocalizedFormatString(@"Settings.Websites.Categories.Description", [NSString stringWithFormat:@"%ld", [SettingsUtility getNumberCategoriesEnabled]]);
            [cell.detailTextLabel setText:subtitle];
        }
        else
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.textLabel.text = [LocalizationUtility getNameForSetting:current];
        cell.textLabel.textColor = [UIColor colorWithRGBHexString:color_gray9 alpha:1.0f];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if ([[SettingsUtility getTypeForSetting:current] isEqualToString:@"int"] || [[SettingsUtility getTypeForSetting:current] isEqualToString:@"date"]){
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.textLabel.text = [LocalizationUtility getNameForSetting:current];
        cell.textLabel.textColor = [UIColor colorWithRGBHexString:color_gray9 alpha:1.0f];
        UITextField *textField = [self createTextField:[SettingsUtility getTypeForSetting:current]];
        if ([[SettingsUtility getTypeForSetting:current] isEqualToString:@"int"]){
            NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:current];
            NSDecimalNumber *someNumber = [NSDecimalNumber decimalNumberWithString:[value stringValue]];
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            textField.text = [formatter stringFromNumber:someNumber];
        }
        else if ([[SettingsUtility getTypeForSetting:current] isEqualToString:@"date"]){
            NSDate *time = [[NSUserDefaults standardUserDefaults] objectForKey:current];
            textField.text = [timeFormatter stringFromDate:time];
            timeField = textField;
        }
        cell.accessoryView = textField;
    }
    else if ([[SettingsUtility getTypeForSetting:current] isEqualToString:@"string"]){
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.textLabel.text = [LocalizationUtility getNameForSetting:current];
        cell.textLabel.textColor = [UIColor colorWithRGBHexString:color_gray9 alpha:1.0f];
        NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:current];
        UITextField *textField = [self createTextField:@"string"];
        textField.text = value;
        cell.accessoryView = textField;
    }
    return cell;
}

- (UITextField*)createTextField:(NSString*)type{
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
    textField.delegate = self;
    textField.backgroundColor = [UIColor colorWithRGBHexString:color_white alpha:1.0f];
    textField.font = [UIFont fontWithName:@"FiraSans-Regular" size:15.0f];
    textField.textColor = [UIColor colorWithRGBHexString:color_gray9 alpha:1.0f];
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.borderStyle = UITextBorderStyleRoundedRect;
    if ([type isEqualToString:@"int"])
        textField.keyboardType = UIKeyboardTypeNumberPad;
    else if ([type isEqualToString:@"date"]){
        UIDatePicker *datePicker = [[UIDatePicker alloc] init];
        [datePicker setDatePickerMode:UIDatePickerModeTime];
        [datePicker setLocale:[NSLocale currentLocale]];
        NSDate *time = [[NSUserDefaults standardUserDefaults] objectForKey:@"test_reminder_time"];
        [datePicker setDate:time];
        [datePicker addTarget:self action:@selector(timeChanged:) forControlEvents:UIControlEventValueChanged];
        textField.inputView = datePicker;
    }
    else
        textField.keyboardType = UIKeyboardTypeDefault;
    textField.inputAccessoryView = keyboardToolbar;
    return textField;
}

-(void)timeChanged:(UIDatePicker*)sender{
    [[NSUserDefaults standardUserDefaults] setObject:sender.date forKey:@"test_reminder_time"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [timeField setText:[timeFormatter stringFromDate:sender.date]];
    [self showNotification:datePicker.date];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    UITableViewCell *cell = (UITableViewCell *)textField.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSString *current = [items objectAtIndex:indexPath.row];
    if ([current isEqualToString:@"max_runtime"]){
        if ([textField.text integerValue] < 10){
            NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
            f.numberStyle = NSNumberFormatterDecimalStyle;
            [[NSUserDefaults standardUserDefaults] setObject:[f numberFromString:@"10"] forKey:@"max_runtime"];
            [self.tableView reloadData];
            [self.view makeToast:NSLocalizedString(@"Settings.Error.TestDurationTooLow", nil)];
        }
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    UITableViewCell *cell = (UITableViewCell *)textField.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSString *current = [items objectAtIndex:indexPath.row];
    NSString * str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([[SettingsUtility getTypeForSetting:current] isEqualToString:@"int"]){
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        [[NSUserDefaults standardUserDefaults] setObject:[f numberFromString:str] forKey:current];
    }
    else
        [[NSUserDefaults standardUserDefaults] setObject:str forKey:current];
    return YES;
}

-(IBAction)setSwitch:(UISwitch *)mySwitch{
    UITableViewCell *cell = (UITableViewCell *)mySwitch.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSString *current = [items objectAtIndex:indexPath.row];
    //TODO ORCHESTRA handle automated_testing_enabled
    if ([current isEqualToString:@"notifications_enabled"] && mySwitch.on){
        [self handleNotificationChanges];
        [mySwitch setOn:FALSE];
    }
    //TODO if test reminder ask notification
    else if ([current isEqualToString:@"include_cc"] && !mySwitch.on){
        UIAlertAction* okButton = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Modal.OK", nil)
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       [[NSUserDefaults standardUserDefaults] setBool:NO forKey:current];
                                       [[NSUserDefaults standardUserDefaults] synchronize];
                                       [self reloadSettings];
                                   }];
        UIAlertAction* cancelButton = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"Modal.Cancel", nil)
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction * action) {
                                           [mySwitch setOn:TRUE];
                                       }];
        [MessageUtility alertWithTitle:NSLocalizedString(@"Settings.Sharing.IncludeCountryCode", nil)
                            message:NSLocalizedString(@"Settings.Sharing.IncludeCountryCode.PopUp", nil)
                              okButton:okButton
                          cancelButton:cancelButton
                                inView:self];
        return;
    }
    
    if (!mySwitch.on && ![self canSetSwitch]){
        [mySwitch setOn:TRUE];
        [MessageUtility alertWithTitle:nil
                               message:NSLocalizedString(@"Modal.EnableAtLeastOneTest", nil)
                                inView:self];
        return;
    }
    
    if (mySwitch.on)
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:current];
    else
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:current];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    //TODO NEWS when enable remote news notification send something to backend
    [self reloadSettings];
}

- (void)handleNotificationChanges{
    [[UNUserNotificationCenter currentNotificationCenter]getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        switch (settings.authorizationStatus) {
            case UNAuthorizationStatusNotDetermined:{
                //First launch
                [MessageUtility notificationAlertinView:self];
                break;
            }
            case UNAuthorizationStatusDenied:{
                //Notification permission denied or disabled
                UIAlertAction* okButton = [UIAlertAction
                                           actionWithTitle:NSLocalizedString(@"Modal.Error.NotificationNotEnabled.GoToSettings", nil)
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                                               [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                           }];
                [MessageUtility alertWithTitle:NSLocalizedString(@"Modal.Error", nil)
                                       message:NSLocalizedString(@"Modal.Error.NotificationNotEnabled", nil)
                                      okButton:okButton
                                        inView:self];
                break;
            }
            case UNAuthorizationStatusAuthorized:{
                [self registeredForNotifications];
                break;
            }
            default:
                break;
        }
    }];
}
- (void)registeredForNotifications {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"notifications_enabled"];
    [self reloadSettings];
}

-(BOOL)canSetSwitch{
    if (testSuite != nil){
        NSArray *items = [SettingsUtility getSettingsForTest:testSuite.name :NO];
        NSUInteger numberOfTests = [items count];
        if ([testSuite.name isEqualToString:@"performance"] || [testSuite.name isEqualToString:@"middle_boxes"] || [testSuite.name isEqualToString:@"instant_messaging"]){
            for (NSString *current in items){
                if (![[[NSUserDefaults standardUserDefaults] objectForKey:current] boolValue])
                    numberOfTests--;
            }
            if (numberOfTests < 2)
                return NO;
            return YES;
        }
        return YES;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *current = [items objectAtIndex:indexPath.row];
    if ([[SettingsUtility getTypeForSetting:current] isEqualToString:@"segue"]){
        [self performSegueWithIdentifier:current sender:self];
    }
    [self.view endEditing:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)showNotification:(NSDate*)fireDate
{
    [self cancelScheduledNotifications];
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = fireDate;
    localNotification.alertBody = NSLocalizedString(@"Notification.RunTestReminder", nil);
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.repeatInterval = NSCalendarUnitDay;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

-(void)cancelScheduledNotifications{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

@end
