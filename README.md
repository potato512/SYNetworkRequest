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


# 修改完善
* 20170725
  * 修改baseUrl初始化异常
~~~ javascript
NSURL *baseUrl = self.hostUrl;
if (![baseUrl.scheme isEqualToString:@"http"] && ![baseUrl.scheme isEqualToString:@"https"])
{
    baseUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", APIServiceHost]];
}
~~~

* 20170724 
  * 版本更新1.1.0
    * 添加更加请求方式
    * 初始化请求格式、返回格式
    * 新建文件SYNetworkAFHTTPSessionManager.h
~~~ javascript
/// 请求类型（POST、GET）
typedef NS_ENUM(NSInteger, RequestHttpType)
{
    /// 请求样式-POST
    RequestHttpTypePOST = 1,

    /// 请求样式-GET
    RequestHttpTypeGET = 2,

    /// 请求样式-PUT
    RequestHttpTypePUT = 3,

    /// 请求样式-DELETE
    RequestHttpTypeDELETE = 4,

    /// 请求样式-HEAD
    RequestHttpTypeHEAD = 5,

    /// 请求样式-PATCH
    RequestHttpTypePATCH = 6,
};
~~~
~~~ javascript
// 初始化请求格式、返回格式
self.responseType = ResponseContentTypeOther;
self.requestType = RequestContentTypeOther;
~~~






