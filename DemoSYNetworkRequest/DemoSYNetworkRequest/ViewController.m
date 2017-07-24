//
//  ViewController.m
//  DemoSYNetworkRequest
//
//  Created by zhangshaoyu on 2017/7/22.
//  Copyright © 2017年 zhangshaoyu. All rights reserved.
//

#import "ViewController.h"
#import "SYNetworkRequest.h"
#import "CacheNetworkRequest.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *array;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"网络请求";
    
    self.array = @[@"network status", @"GET", @"POST", @"UPLOAD", @"DOWNLOAD", @"cache request-reload", @"cache request-never", @"cache request-overdate"];
    
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
//        NSDictionary *dict = @{@"phoneNumber":@(13800138000), @"timeStamp":@(456461015645646)};
//        NSString *url = @"http://192.168.3.99:8082/system-front/APIUser/getMsgCode";
//        NSDictionary *dict = @{@"phone":@(13510213244), @"msgType":@(1)};
        NSString *url = @"http://192.168.3.99:8088/system-api/user/getTest";
        NSDictionary *dict = @{};
        
        NSURLSessionDataTask *dataTask = [[SYNetworkRequest shareRequest] requestWithUrl:url parameters:dict methord:@"post" uploadProgress:^(NSProgress *progress) {
            NSLog(@"\nupload progress = %@", @(progress.fractionCompleted));
        } downloadProgress:^(NSProgress *progress) {
            NSLog(@"\ndownload progress = %@", @(progress.fractionCompleted));
        } complete:^(NSURLResponse *response, id responseObject, NSError *error) {
            NSString *object = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSLog(@"\nrespone = %@\nresponseObject = %@\nobject = %@\n", response, responseObject, object);
        }];
        [dataTask resume];
        
//        [self requestDataTask];
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
    else if (5 == indexPath.row || 6 == indexPath.row || 7 == indexPath.row)
    {
        // 缓存请求-reload/never/overDate
        NSString *url = @"http://rapapi.org/mockjsdata/15885/getUserInfo";
        
        NetworkCacheType cacheType = (5 == indexPath.row ? NetworkCacheTypeAlways : (6 == indexPath.row ? NetworkCacheTypeNever : NetworkCacheTypeWhileOverdue));
        NSURLSessionDataTask *dataTask = [CacheNetworkRequest requestWithUrl:url parameters:nil methord:RequestHttpTypeGET requestContentType:0 responseContentType:0 upload:^(long long total, long long complete) {
            NSLog(@"upload complete = %@", @(complete));
        } download:^(long long total, long long complete) {
            NSLog(@"download complete = %@", @(complete));
        } complete:^(id object) {
          
            NSLog(@"object = %@", object);

        } target:self enableView:YES cacheType:cacheType cacheTime:NetworkCacheTimeDay];
        
        [dataTask resume];
    }
}

#pragma mark - 源码示例

- (void)requestDataTask
{
    NSString *url = @"http://192.168.3.99:8082/system-front/APIUser/getMsgCode";
    NSDictionary *dict = @{@"phone":@(13510213244), @"msgType":@(1)};

    // 源码示例：Data Task
    
//    NSURL *URL = [NSURL URLWithString:url];
//    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    // Query String Parameter Encoding
//    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:dict error:nil];
    
    // URL Form Parameter Encoding
//    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:dict error:nil];
    
    // POST Content-Type: application/json {"foo": "bar", "baz": [1,2,3]}
//    NSURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:dict error:nil];
    
    
    
//    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
//    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
//        if (error)
//        {
//            NSLog(@"\nError = %@", error);
//        }
//        else
//        {
//            NSLog(@"\nresponse = %@\nresponseObject = %@\n", response, responseObject);
//        }
//    }];
//    [dataTask resume];
    
    
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    NSURLSessionDataTask *dataTask = [manager POST:url parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"\nsuccess response = %@\nresponseObject = %@\n", task.response, responseObject);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"\nfailure response = %@\nerror = %@\n", task.response, error);
//    }];
//    [dataTask resume];
}

- (void)requestUpload
{
    // 源码示例：Upload Task
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:@"http://example.com/upload"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURL *filePath = [NSURL fileURLWithPath:@"file://path/to/image.png"];
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request fromFile:filePath progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"Success: %@ %@", response, responseObject);
        }
    }];
    [uploadTask resume];
    
//    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:@"http://example.com/upload" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        [formData appendPartWithFileURL:[NSURL fileURLWithPath:@"file://path/to/image.jpg"] name:@"file" fileName:@"filename.jpg" mimeType:@"image/jpeg" error:nil];
//    } error:nil];
//    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
//    
//    NSURLSessionUploadTask *uploadTask;
//    uploadTask = [manager
//                  uploadTaskWithStreamedRequest:request
//                  progress:^(NSProgress * _Nonnull uploadProgress) {
//                      // This is not called back on the main queue.
//                      // You are responsible for dispatching to the main queue for UI updates
//                      dispatch_async(dispatch_get_main_queue(), ^{
//                          //Update the progress view
//                          [progressView setProgress:uploadProgress.fractionCompleted];
//                      });
//                  }
//                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
//                      if (error) {
//                          NSLog(@"Error: %@", error);
//                      } else {
//                          NSLog(@"%@ %@", response, responseObject);
//                      }
//                  }];
//    
//    [uploadTask resume];
}

- (void)requestDownload
{
    // 源码示例：Download
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:@"http://example.com/download.zip"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"File downloaded to: %@", filePath);
    }];
    [downloadTask resume];
}

@end
