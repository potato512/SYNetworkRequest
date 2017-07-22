//
//  ViewController.m
//  DemoSYNetworkRequest
//
//  Created by zhangshaoyu on 2017/7/22.
//  Copyright © 2017年 zhangshaoyu. All rights reserved.
//

#import "ViewController.h"
#import "SYNetworkRequest.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *array;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"网络请求";
    
    self.array = @[@"network status", @"GET", @"POST", @"UPLOAD", @"DOWNLOAD"];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.tableFooterView = [UIView new];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    tableView.delegate = self;
    tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    cell.textLabel.text = self.array[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (0 == indexPath.row)
    {
        // network status
        
        BOOL isStatus = [SYNetworkRequest isReachable];
        NSLog(@"网络状态 - %@", (isStatus ? @"有网" : @"无网"));
        BOOL isWIFI = [SYNetworkRequest isWIFI];
        BOOL isWWAN = [SYNetworkRequest isWWAN];
        NSLog(@"网络类型 - %@", (isWIFI ? @"wifi" : (isWWAN ? @"wwan" : @"unknow")));
    }
    else if (1 == indexPath.row)
    {
        // GET
//        NSString *url = @"http://rapapi.org/mockjsdata/15885/getUserInfo";
        
        NSString *url = @"http://rapapi.org/mockjsdata/15885/getVerificationCode";
//        NSDictionary *dict = @{@"phoneNumber":@(13800138000), @"timeStamp":@(456461015645646)};
        
        NSURLSessionDataTask *dataTask = [[SYNetworkRequest shareRequest] requestWithUrl:url parameters:nil methord:@"GET" uploadProgress:^(NSProgress *progress) {
            NSLog(@"\nupload progress = %@", @(progress.fractionCompleted));
        } downloadProgress:^(NSProgress *progress) {
            NSLog(@"\ndownload progress = %@", @(progress.fractionCompleted));
        } complete:^(NSURLResponse *response, id responseObject, NSError *error) {
            NSLog(@"\nrespone = %@\nresponseObject = %@\n", response, responseObject);
        }];
        [dataTask resume];
    }
    else if (2 == indexPath.row)
    {
        // POST
//        NSString *url = @"http://rapapi.org/mockjsdata/15885/getVerificationCode";
        NSDictionary *dict = @{@"phoneNumber":@(13800138000), @"timeStamp":@(456461015645646)};
        
        NSString *url = @"http://rapapi.org/mockjsdata/15885/getUserInfo";
        
        NSURLSessionDataTask *dataTask = [[SYNetworkRequest shareRequest] requestWithUrl:url parameters:dict methord:@"post" uploadProgress:^(NSProgress *progress) {
            NSLog(@"\nupload progress = %@", @(progress.fractionCompleted));
        } downloadProgress:^(NSProgress *progress) {
            NSLog(@"\ndownload progress = %@", @(progress.fractionCompleted));
        } complete:^(NSURLResponse *response, id responseObject, NSError *error) {
            NSLog(@"\nrespone = %@\nresponseObject = %@\n", response, responseObject);
        }];
        [dataTask resume];
    }
    else if (3 == indexPath.row)
    {
        // UPLOAD
    }
    else if (4 == indexPath.row)
    {
        // DOWNLOAD
        NSString *url = @"http://img4.duitang.com/uploads/item/201210/24/20121024114802_sVwSR.jpeg";
        NSURLSessionDownloadTask *dataTask = [[SYNetworkRequest shareRequest] requestDownloadWithUrl:url parameters:nil downloadProgress:^(NSProgress *uploadProgress) {
            NSLog(@"\ndownload progress = %@", @(uploadProgress.fractionCompleted));
        } complete:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            NSLog(@"\nrespone = %@\nfilePath = %@\n", response, filePath);
        }];
        [dataTask resume];
    }
}

@end
