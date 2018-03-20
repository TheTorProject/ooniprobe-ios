#import "TestResultsTableViewController.h"

@interface TestResultsTableViewController ()

@end

@implementation TestResultsTableViewController
@synthesize results;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.tableFooterView = [UIView new];

    /*
    for (int i = 0; i< 25; i++){
        int lowerBound = 0;
        int upperBound = 31557600;
        int rndValue = lowerBound + arc4random() % (upperBound - lowerBound);
        Result *r = [Result new];
        [r setStartTime:[NSDate dateWithTimeIntervalSinceNow:rndValue]];
        [r setName:@"instant_messaging"];
        [r commit];
    }
     */
  /*
    SRKResultSet* results = [[[[[Person query]
                                where:@"age = 35"]
                               limit:99]
                              orderBy:@"name"]
                             fetch];
   [[[Person query] where:@"department.name = 'Test Department'"] fetch]
*/
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"test_results", nil);
}

-(void)testFilter:(SRKQuery*)newQuery{
    query = newQuery;
    results = [query fetch];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM";
    for (Result *current in results){
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        NSString *key = [df stringFromDate:current.startTime];
        if ([dic objectForKey:key])
            arr = [[dic objectForKey:key] mutableCopy];
        [arr addObject:current];
        [dic setObject:arr forKey:key];
        /*
         build a dictionary like
         17-07
         17-08
         18-01
         */
        //NSLog(@"%@", [df stringFromDate:current.startTime]);
    }
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"" ascending:NO selector:@selector(localizedStandardCompare:)];
    //NSArray *sortedKeys = [[dic allKeys] sortedArrayUsingSelector: @selector(compare:)];
    keys = [[dic allKeys] sortedArrayUsingDescriptors:@[ descriptor ]];
    resultsDic = dic;
    //NSLog(@"STODIC %@", sortedKeys);

    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"ooni_empty_state"];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = NSLocalizedString(@"past_tests_empty", nil);
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"FiraSans-Regular" size:16],
                                 NSForegroundColorAttributeName:[UIColor colorWithRGBHexString:color_gray5 alpha:1.0f]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *month = [keys objectAtIndex:section];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM";
    NSDate *convertedDate = [df dateFromString:month];
    df.dateFormat = @"MMMM yyyy";
    return [df stringFromDate:convertedDate];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor colorWithRGBHexString:color_black alpha:1.0f]];
    [header.textLabel setFont:[UIFont fontWithName:@"FiraSans-Regular" size:14]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [keys count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [(NSArray*)[resultsDic objectForKey:[keys objectAtIndex:section]] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Result *current = [[resultsDic objectForKey:[keys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    TestResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[TestResultTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    [cell setResult:current];
    /*
    UIImageView *testIcon = (UIImageView*)[cell viewWithTag:1];
    UILabel *titleLabel = (UILabel*)[cell viewWithTag:2];
    UILabel *asnLabel = (UILabel*)[cell viewWithTag:3];
    UILabel *timeLabel = (UILabel*)[cell viewWithTag:4];
    [testIcon setImage:[UIImage imageNamed:current.name]];
    titleLabel.text  = NSLocalizedString(current.name, nil);
    
    //TODO what to write when is null? (user disabled sharing asn)
    //TODO these methods can be the GET of relative classes
    NSString *asn = @"";
    NSString *asnName = @"";
    NSString *country = @"";
    if (current.asn) asnName = current.asn;
    if (current.asnName) asnName = current.asnName;
    if (current.country) asnName = current.country;

    NSMutableAttributedString *asnNameAttr = [[NSMutableAttributedString alloc] initWithString:asnName];
    [asnNameAttr addAttribute:NSFontAttributeName
                        value:[UIFont fontWithName:@"FiraSans-SemiBold" size:17]
                        range:NSMakeRange(0, asnNameAttr.length)];
    NSMutableAttributedString *asnText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", [NSString stringWithFormat:@"%@ (%@)", asn, country]]];
    [asnText addAttribute:NSFontAttributeName
                          value:[UIFont fontWithName:@"FiraSans-Regular" size:17]
                          range:NSMakeRange(0, asnText.length)];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] init];
    [attrStr appendAttributedString:asnNameAttr];
    [attrStr appendAttributedString:asnText];
    [asnLabel setAttributedText:attrStr];
    
    //from https://developer.apple.com/library/content/documentation/MacOSX/Conceptual/BPInternational/InternationalizingLocaleData/InternationalizingLocaleData.html
    NSString *localizedDateTime = [NSDateFormatter localizedStringFromDate:current.startTime dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
    timeLabel.text = localizedDateTime;
    */
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Result *current = [[resultsDic objectForKey:[keys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        [current deleteObject];
        [self testFilter:query];
    }
}

/*
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([scrollView.panGestureRecognizer translationInView:scrollView.superview].y > 0)
        [self.view setBackgroundColor:[UIColor colorWithRGBHexString:color_blue5 alpha:1.0f]];
    else
        [self.view setBackgroundColor:[UIColor colorWithRGBHexString:color_white alpha:1.0f]];
}
*/

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y<=0) {
        scrollView.contentOffset = CGPointZero;
    }
}

#pragma mark - Navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"header"]){
        //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ResultsHeaderViewController *vc = (ResultsHeaderViewController * )segue.destinationViewController;
        [vc setDelegate:self];
        //NSString *current = [categories objectAtIndex:indexPath.row];
        //[vc setTestName:@"performance"];
    }
    else if ([[segue identifier] isEqualToString:@"summary"]){
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        TestSummaryTableViewController *vc = (TestSummaryTableViewController * )segue.destinationViewController;
        Result *current = [[resultsDic objectForKey:[keys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        [vc setResult:current];
    }
}

@end