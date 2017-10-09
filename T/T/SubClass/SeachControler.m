//
//  SeachControler.m
//  T
//
//  Created by Jion on 15/7/7.
//  Copyright (c) 2015年 Youjuke. All rights reserved.
//

#import "SeachControler.h"
#import "NSString+Levenshtein.h"

@interface SeachControler ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *_dataArray;
    NSArray  *customArray;
}
@property (strong) NSOperationQueue *autoCompleteQueue;
@property(nonatomic,strong)NSOperation  *operation;

@property(nonatomic,strong)UITableView *tableAction;
@end

@implementation SeachControler

- (void)viewDidLoad {
    [super viewDidLoad];
    self.table.delegate = self;
    self.table.dataSource = self;
    self.table.hidden = YES;
    // Do any additional setup after loading the view from its nib.
    [self setAutoCompleteQueue:[[NSOperationQueue alloc] init]];
    self.autoCompleteQueue.name = [NSString stringWithFormat:@"Autocomplete Queue %i", arc4random()];
    
    [self buildActionTable];
}

//==========================
-(void)buildActionTable{
    customArray = @[@"跳转设置",@"跳转WIFI",@"定位服务",@"跳转移动网络",@"跳转通知",@"相机和相册",@"跳转通用",@"跳转隐私"];
    
    [self.view addSubview:self.tableAction];

}
-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_tableAction(150)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableAction)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-84-[_tableAction]-20-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableAction)]];

}

-(UITableView*)tableAction{
    if (!_tableAction) {
        _tableAction = [[UITableView alloc] init];
        _tableAction.tag = 400;
        _tableAction.delegate = self;
        _tableAction.dataSource = self;
        _tableAction.translatesAutoresizingMaskIntoConstraints = NO;
        _tableAction.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    return _tableAction;
}
//==========================

- (IBAction)changeTextAction:(id)sender {
    UITextField *field = (UITextField*)sender;
    
    [self.autoCompleteQueue cancelAllOperations];
    NSArray *suggestions = [self getArray];
    _operation = [[NSOperation alloc] init];
   NSArray *newA = [self autocompleteSuggestionsForString:field.text withPossibleStrings:suggestions];
    _dataArray = newA;
    [self.autoCompleteQueue addOperation:_operation];
    [self showTableView];
    NSLog(@"new =%@",newA);
}


#pragma mark --TableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 400) {
        return customArray.count;
    }else{
        return _dataArray.count;
    }
    
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    if (tableView.tag == 400) {
        cell.textLabel.text = customArray[indexPath.row];
    }else{
        cell.textLabel.text = _dataArray[indexPath.row];
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 400) {
#define iOS10 ([[UIDevice currentDevice].systemVersion doubleValue] >= 10.0)
        
        NSArray *prefs = @[UIApplicationOpenSettingsURLString,
                           @"App-Prefs:root=WIFI",
                           @"App-Prefs:root=LOCATION_SERVICES",
                           @"App-Prefs:root=MOBILE_DATA_SETTINGS_ID",
                           @"App-Prefs:root=NOTIFICATIONS_ID",
                           @"App-Prefs:root=Photos",
                           @"App-Prefs:root=General",
                           @"App-Prefs:root=Privacy"];
        NSString * urlString = prefs[indexPath.row];
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]]) {
            if (iOS10) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            }
        }
        
    }else{
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *autoCompleteString = selectedCell.textLabel.text;
        self.textField.text = autoCompleteString;
        [self hideTableView];
    }
    
}
- (void)showTableView
{
    _table.hidden = NO;
   [_table reloadData];
}
- (void)hideTableView
{
    _table.hidden = YES;
    [self finishedSearching];
}
- (void) finishedSearching
{
    [self.textField resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)autocompleteSuggestionsForString:(NSString *)inputString withPossibleStrings:(NSArray *)possibleTerms
{
    if([inputString isEqualToString:@""]){
        return [NSArray array];
    }
    
    if(self.operation.isCancelled){
        return [NSArray array];
    }
    
    NSMutableArray *editDistances = [NSMutableArray arrayWithCapacity:possibleTerms.count];
    
    
    float editDistanceOfCurrentString;
    NSDictionary *stringsWithEditDistances;
    NSUInteger maximumRange;
    for(NSString *currentString in possibleTerms) {
        
        if(self.operation.isCancelled){
            return [NSArray array];
        }
        
        maximumRange = (inputString.length < currentString.length) ? inputString.length : currentString.length;
        editDistanceOfCurrentString = [inputString asciiLevenshteinDistanceWithString:[currentString substringWithRange:NSMakeRange(0, maximumRange)]];
        
        stringsWithEditDistances = @{@"string" : currentString ,
                                     @"editDistance" : [NSNumber numberWithFloat:editDistanceOfCurrentString]};
        [editDistances addObject:stringsWithEditDistances];
    }
    
    if(self.operation.isCancelled){
        return [NSArray array];
    }
    
    [editDistances sortUsingComparator:^(NSDictionary *string1Dictionary,
                                         NSDictionary *string2Dictionary){
        
        return [string1Dictionary[@"editDistance"] compare:string2Dictionary[@"editDistance"]];
    }];
    
    
    NSString *suggestedString;
    NSMutableArray *prioritySuggestions = [NSMutableArray array];
    NSMutableArray *otherSuggestions = [NSMutableArray array];
    for(NSDictionary *stringsWithEditDistances in editDistances){
        
        if(self.operation.isCancelled){
            return [NSArray array];
        }
        
        suggestedString = stringsWithEditDistances[@"string"];
        NSRange occurrenceOfInputString = [[suggestedString lowercaseString]
                                           rangeOfString:[inputString lowercaseString]];
        
        if (occurrenceOfInputString.length != 0 && occurrenceOfInputString.location == 0) {
            [prioritySuggestions addObject:suggestedString];
        } else{
            [otherSuggestions addObject:suggestedString];
        }
    }
    
    NSMutableArray *results = [NSMutableArray array];
    [results addObjectsFromArray:prioritySuggestions];
    [results addObjectsFromArray:otherSuggestions];
    
    
    return [NSArray arrayWithArray:results];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
- (NSArray*)getArray
{
    NSArray *countries =
    @[@"啊们", @"报纸",@"吃饭",@"当权",@"放开",@"我爱我家",@"总数",@"爱人",@"爱情",
      @"我们",@"Abkhazia",@"Antarctica",@"Antigua & Barbuda",@"Argentina",@"Armenia",@"Aruba",@"Azerbaijan",@"British Antarctic Territory",
      @"British Virgin Islands", @"Brunei",
      @"Bulgaria",@"Burkina Faso",@"Burundi",@"Chile",@"China",@"Christmas Island",
      @"Cocos Keeling Islands",@"Colombia",@"Commonwealth",@"Comoros",@"Democratic Republic of the Congo",@"Denmark",@"Djibouti",@"Dominica",@"Dominican Republic",
      @"East Timor",@"Ethiopia",@"European Union",@"Falkland Islands",@"Faroes",@"Fiji",
      @"Finland",@"France",@"Gabon",@"Guam",@"Guatemala",@"Guernsey",
      @"Guinea Bissau",@"Guinea",@"Guyana",@"Haiti",
      @"Honduras",@"Hong Kong",@"Hungary",
      @"Iceland",@"Israel",@"Italy",@"Jamaica",
      @"Japan",@"Jersey",@"Jordan",@"Kazakhstan",@"Kenya",@"Kiribati",
      @"Kosovo",@"Kuwait",@"Kyrgyzstan",
      @"Laos",@"Latvia",@"Lebanon",@"Lesotho",@"Liberia",@"Libya",
      @"Liechtenstein",@"Lithuania",@"Luxembourg",@"Macau",
      @"Macedonia",@"Micronesia",@"Moldova",@"Monaco",@"Mongolia",
      @"Montenegro",@"Montserrat",@"Morocco",@"Mozambique",@"Myanmar",
      @"Nagorno Karabakh",@"Namibia",@"NATO",@"Niue",@"Norfolk Island",
      @"North Korea",@"Northern Cyprus",@"Northern Mariana Islands",
      @"Norway",@"Olympics",@"Oman",@"Pakistan",
      @"Palau",@"Poland",@"Portugal",
      @"Puerto Rico",@"Qatar",@"Red Cross",
      @"Republic of the Congo",@"Romania",@"Russia",
      @"Rwanda",@"Saint Barthelemy",@"Saint Helena",@"Slovenia",
      @"Solomon Islands",@"Somalia",@"Somaliland",@"South Africa",@"Thailand",@"Togo",
      @"Tonga",@"Trinidad & Tobago",@"Tunisia",
      @"Turkey",@"Turkmenistan",
      @"Turks & Caicos Islands",
      @"Tuvalu",@"Uganda",@"Ukraine",@"United Arab Emirates",@"United Kingdom",
      @"United Nations",@"United States",@"Uruguay",@"US Virgin Islands",
      @"Uzbekistan",@"Vanuatu",@"Vatican City",@"Venezuela",@"Vietnam",
      @"Wales",@"Western Sahara",@"Yemen",@"Zambia",@"Zimbabwe",
      
      ];
    return countries;
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


@end
