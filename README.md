# SYNetworkRequest
网络请求封装

效果图

![request.gif](./request.gif)

使用注意事项
* 网络状态
  * 监测：[SYNetworkRequest networkMonitoring];
  * 状态：[SYNetworkRequest isReachable];
  * 类型：[SYNetworkRequest isWIFI]; 或 [SYNetworkRequest isWWAN];

* 初始化服务器地址：[SYNetworkRequest startWithServiceHost:@"http://wwww.hao123.com"];

// [[SYNetworkRequest shareRequest] setRequestType:RequestContentTypeOther];
// [[SYNetworkRequest shareRequest] setResponseType:ResponseContentTypeXML];

使用示例
~~~ javascript
#import "SYNetworkRequest.h"
~~~

~~~ javascript
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    // 网络环境监测
    [SYNetworkRequest networkMonitoring];

    [SYNetworkRequest startWithServiceHost:@"http://wwww.hao123.com"];
    // [[SYNetworkRequest shareRequest] setRequestType:RequestContentTypeOther];
    // [[SYNetworkRequest shareRequest] setResponseType:ResponseContentTypeXML];


    return YES;
}
~~~ 

~~~ javascript
BOOL isStatus = [SYNetworkRequest isReachable];
NSLog(@"网络状态 - %@", (isStatus ? @"有网" : @"无网"));
BOOL isWIFI = [SYNetworkRequest isWIFI];
BOOL isWWAN = [SYNetworkRequest isWWAN];
NSLog(@"网络类型 - %@", (isWIFI ? @"wifi" : (isWWAN ? @"wwan" : @"unknow")));
~~~ 

~~~ javascript
// GET
NSString *url = @"http://rapapi.org/mockjsdata/15885/getUserInfo";

NSURLSessionDataTask *dataTask = [[SYNetworkRequest shareRequest] requestWithUrl:url parameters:nil methord:@"GET" uploadProgress:^(NSProgress *progress) {
    NSLog(@"\nupload progress = %@", @(progress.fractionCompleted));
} downloadProgress:^(NSProgress *progress) {
    NSLog(@"\ndownload progress = %@", @(progress.fractionCompleted));
} complete:^(NSURLResponse *response, id responseObject, NSError *error) {
    NSLog(@"\nrespone = %@\nresponseObject = %@\n", response, responseObject);
}];
[dataTask resume];
~~~ 

~~~ javascript
// POST
NSString *url = @"http://rapapi.org/mockjsdata/15885/getVerificationCode";
NSDictionary *dict = @{@"phoneNumber":@(13800138000), @"timeStamp":@(456461015645646)};

NSURLSessionDataTask *dataTask = [[SYNetworkRequest shareRequest] requestWithUrl:url parameters:dict methord:@"post" uploadProgress:^(NSProgress *progress) {
    NSLog(@"\nupload progress = %@", @(progress.fractionCompleted));
} downloadProgress:^(NSProgress *progress) {
    NSLog(@"\ndownload progress = %@", @(progress.fractionCompleted));
} complete:^(NSURLResponse *response, id responseObject, NSError *error) {
    NSLog(@"\nrespone = %@\nresponseObject = %@\n", response, responseObject);
}];
[dataTask resume];
~~~ 

~~~ javascript
// UPLOAD

~~~ 

~~~ javascript
// DOWNLOAD
NSString *url = @"http://img4.duitang.com/uploads/item/201210/24/20121024114802_sVwSR.jpeg";
NSURLSessionDownloadTask *dataTask = [[SYNetworkRequest shareRequest] requestDownloadWithUrl:url parameters:nil downloadProgress:^(NSProgress *uploadProgress) {
NSLog(@"\ndownload progress = %@", @(uploadProgress.fractionCompleted));
} complete:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
NSLog(@"\nrespone = %@\nfilePath = %@\n", response, filePath);
}];
[dataTask resume];
~~~ 
