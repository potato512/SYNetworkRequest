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

#import <AFNetworking/AFURLSessionManager.h>

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *array;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"网络请求";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"stop" style:UIBarButtonItemStyleDone target:self action:@selector(cancelClick)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"https" style:UIBarButtonItemStyleDone target:self action:@selector(httpsClick)];
    
    self.array = @[@"network status", @"GET", @"POST", @"UPLOAD", @"DOWNLOAD", @"cache request-reload", @"cache request-never", @"cache request-overdate", @"cancel all"];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.tableFooterView = [UIView new];
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
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
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
        
        [[SYNetworkRequest shareRequest] setRequestType:RequestContentTypeOther];
        SYNetworkRequest.shareRequest.timeout = 10;
        NSURLSessionDataTask *dataTask = [[SYNetworkRequest shareRequest] requestWithUrl:url parameters:nil methord:@"GET" uploadProgress:^(NSProgress *progress) {
            NSLog(@"\nupload progress = %@", @(progress.fractionCompleted));
        } downloadProgress:^(NSProgress *progress) {
            NSLog(@"\ndownload progress = %@", @(progress.fractionCompleted));
        } complete:^(NSURLResponse *response, id responseObject, NSError *error) {
            NSLog(@"\nrespone = %@\nresponseObject = %@\n", response, responseObject);
        }];
        [dataTask resume];
        
        [SYNetworkRequest.shareRequest addRequest:dataTask];
    }
    else if (2 == indexPath.row)
    {
        // POST
//        NSString *url = @"http://rapapi.org/mockjsdata/15885/getVerificationCode";
//        NSDictionary *dict = @{@"phoneNumber":@(13800138000), @"timeStamp":@(456461015645646)};
        NSString *url = @"http://192.168.3.99:8082/system-front/APIUser/getMsgCode";
        NSDictionary *dict = @{@"phone":@(13510213244), @"msgType":@(1)};
//        NSString *url = @"http://192.168.3.99:8088/system-api/user/getTest";
//        NSDictionary *dict = @{};

//        NSString *url = @"http://rapapi.org/mockjsdata/15885/getVerificationCode";
//        NSDictionary *dict = @{@"phoneNumber":@(13800138000), @"timeStamp":@(456461015645646)};
//        NSString *url = @"http://192.168.3.99:8082/system-front/APIUser/getMsgCode";
//        NSDictionary *dict = @{@"phone":@(13510213244), @"msgType":@(1)};
//        NSString *url = @"http://192.168.3.99:8088/system-api/user/getTest";
//        NSDictionary *dict = @{};
        
        [[SYNetworkRequest shareRequest] setRequestType:RequestContentTypeXML];
        // [[SYNetworkRequest shareRequest] setResponseType:ResponseContentTypeJSON];
        SYNetworkRequest.shareRequest.timeout = 20;
        NSURLSessionDataTask *dataTask = [[SYNetworkRequest shareRequest] requestWithUrl:url parameters:dict methord:@"post" uploadProgress:^(NSProgress *progress) {
            NSLog(@"\nupload progress = %@", @(progress.fractionCompleted));
        } downloadProgress:^(NSProgress *progress) {
            NSLog(@"\ndownload progress = %@", @(progress.fractionCompleted));
        } complete:^(NSURLResponse *response, id responseObject, NSError *error) {
            NSString *object = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSLog(@"\nrespone = %@\nresponseObject = %@\nobject = %@\n", response, responseObject, object);
        }];
        [dataTask resume];
        
        [SYNetworkRequest.shareRequest addRequest:dataTask];
        
//        [self requestDataTask];
    }
    else if (3 == indexPath.row)
    {
        // UPLOAD
        [self requestUpload];
        
    }
    else if (4 == indexPath.row)
    {
        // DOWNLOAD
        NSString *url = @"http://img4.duitang.com/uploads/item/201210/24/20121024114802_sVwSR.jpeg";
        NSURLSessionDownloadTask *dataTask = [[SYNetworkRequest shareRequest] requestDownloadWithUrl:url parameters:nil methord:@"POST" downloadProgress:^(NSProgress *uploadProgress) {
            NSLog(@"\ndownload progress = %@", @(uploadProgress.fractionCompleted));
        } complete:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            NSLog(@"\nrespone = %@\nfilePath = %@\n", response, filePath);
        }];
        [dataTask resume];
        
        [SYNetworkRequest.shareRequest addRequest:dataTask];
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
        } complete:^(RequestNetworkStatus networkStatus, id object) {
      
        } target:self enableView:YES cacheType:cacheType cacheTime:NetworkCacheTimeDay];
        
        [dataTask resume];
        
        [SYNetworkRequest.shareRequest addRequest:dataTask];
    } else if (8 == indexPath.row) {
        [SYNetworkRequest.shareRequest cancelAllRequest];
    }
}

- (void)cancelClick
{
    NSString *url = @"http://rapapi.org/mockjsdata/15885/getVerificationCode";
    [SYNetworkRequest.shareRequest cancelRequest:url];
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
    
    [SYNetworkRequest.shareRequest addRequest:uploadTask];
    
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
    
    [SYNetworkRequest.shareRequest addRequest:downloadTask];
}


- (void)httpsClick
{
    NSString *fileName = @"HoneywellProductPKI.cacert".stringByDeletingPathExtension;
    NSString *fileType = @"HoneywellProductPKI.cacert".pathExtension;
    
    NSLog(@"fileName == %@, fileType == %@", fileName, fileType);
    
    
    NSString *urlString = @"https://acscloud.honeywell.com.cn/v1/00100002/user";
    // 参数
    NSMutableDictionary *dict = [NSMutableDictionary new];
    // 参数-手机验证码
//    [dict setValue:@"SendVCode" forKey:@"type"];
//    [dict setValue:@"zh-CN" forKey:@"language"];
//    [dict setValue:@"+8613510213244" forKey:@"phoneNumber"];
    // 参数-登录
    [dict setValue:@"LoginUser" forKey:@"type"];
    [dict setValue:@"12345678" forKey:@"password"];
    [dict setValue:@"+8615899882491" forKey:@"phoneNumber"];
    [dict setValue:@"2371A6554DD28BBC8140AD55396AA071509D5" forKey:@"phoneUuid"];
    [dict setValue:@"ios" forKey:@"phoneType"];
    [dict setValue:@"zh-CN" forKey:@"language"];
    //
    [[SYNetworkRequest shareRequest] setRequestType:RequestContentTypeJSON];
    [[SYNetworkRequest shareRequest] setResponseType:ResponseContentTypeOther];
    NSURLSessionDataTask *dataTask = [[SYNetworkRequest shareRequest] requestWithUrl:urlString parameters:dict methord:@"POST" isCertificates:NO certificates:nil uploadProgress:nil downloadProgress:nil complete:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        NSLog(@"response == %@", response);
        NSLog(@"responseObject == %@, class = %@", responseObject, [responseObject class]);
        if ([responseObject isKindOfClass:[NSData class]])
        {
            NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSLog(@"result == %@", result);
        }
        else if ([responseObject isKindOfClass:[NSString class]])
        {
            
        }
        else if ([responseObject isKindOfClass:[NSDictionary class]])
        {
            
        }
        NSLog(@"error == %@", error);
    }];
    [dataTask resume];

    
    [SYNetworkRequest.shareRequest addRequest:dataTask];
    
    
    // 用户登录
//    NSString *urlString = @"https://acscloud.honeywell.com.cn/v1/00100002/user";
//    // 参数
//    NSMutableDictionary *dict = [NSMutableDictionary new];
//    [dict setValue:@"LoginUser" forKey:@"type"];
//    [dict setValue:@"12345678" forKey:@"password"];
//    [dict setValue:@"+8615899882491" forKey:@"phoneNumber"];
//    [dict setValue:@"2371A6554DD28BBC8140AD55396AA071509D5" forKey:@"phoneUuid"];
//    [dict setValue:@"ios" forKey:@"phoneType"];
//    [dict setValue:@"zh-CN" forKey:@"language"];
    // 手机验证码
//    NSString *urlString = @"https://acscloud.honeywell.com.cn/v1/00100002/user";
//    // 参数
//    NSMutableDictionary *dict = [NSMutableDictionary new];
//    [dict setValue:@"SendVCode" forKey:@"type"];
//    [dict setValue:@"zh-CN" forKey:@"language"];
//    [dict setValue:@"+8613510213244" forKey:@"phoneNumber"];
//    // 证书配置-无证书
//    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
//    // allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
//    // 如果是需要验证自建证书，需要设置为YES
//    securityPolicy.allowInvalidCertificates = NO;
//    // 请求
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.securityPolicy = securityPolicy;
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer]; // AFHTTPResponseSerializer AFJSONResponseSerializer
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain", nil];
//    // AFHTTPRequestSerializer AFJSONRequestSerializer
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    [manager.requestSerializer setValue:@"text/json" forHTTPHeaderField:@"Content-Type"];
//    manager.requestSerializer.timeoutInterval = 30.0;
//    [manager POST:urlString parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
//        NSLog(@"uploadProgress === %@", uploadProgress);
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"responseObject === %@", responseObject);
//        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"string === %@", string);
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
//        NSLog(@"dict === %@", dict);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"error === %@", error);
//    }];

    
    
    // 获取设备列表
//    // 请求地址
//    NSString *urlString = @"https://acscloud.honeywell.com.cn/v1/00100002/user/device/list";
////    // 证书
////    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"HoneywellProductPKI" ofType:@"cacert"];
////    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
////    NSSet *certSet = [[NSSet alloc] initWithObjects:certData, nil];
////    // 证书配置-有证书
////    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
////    [securityPolicy setAllowInvalidCertificates:YES]; // 是否允许,NO-- 不允许无效的证书
////    [securityPolicy setPinnedCertificates:certSet]; // 设置证书
//    // 证书配置-无证书
//    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
//    // allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
//    // 如果是需要验证自建证书，需要设置为YES
//    securityPolicy.allowInvalidCertificates = NO;
//    // 请求
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.securityPolicy = securityPolicy;
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer]; // AFHTTPResponseSerializer AFJSONResponseSerializer
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain", nil];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    manager.requestSerializer.timeoutInterval = 30.0;
//    [manager GET:urlString parameters:nil progress:^(NSProgress * progress){
//    } success:^(NSURLSessionDataTask *task, id responseObject) {
//        
//        NSLog(@"responseObject === %@", responseObject);
//        
//        NSArray * array = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
//        NSLog(@"array === %@", array);
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        NSLog(@"error ==%@",error.description);
//    }];
}

@end
