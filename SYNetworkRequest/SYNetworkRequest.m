//
//  SYNetworkRequest.m
//  zhangshaoyu
//
//  Created by zhangshaoyu on 16/7/25.
//  Copyright © 2016年 zhangshaoyu. All rights reserved.
//  https://github.com/AFNetworking/AFNetworking

#import "SYNetworkRequest.h"
#import "SYNetworkAFHTTPSessionManager.h"
#import <netinet/in.h>

static NSTimeInterval const APIServiceTimeout = 30.0;
static NSString *APIServiceHost;

/// 网络请求方式 GET
static NSString *const RequestGET = @"GET";
/// 网络请求方式 POST
static NSString *const RequestPOST = @"POST";

@interface SYNetworkRequest ()

@property (nonatomic, strong) NSMutableDictionary *networkDicts;

@property (nonatomic, strong) NSURL *hostUrl;
@property (nonatomic, strong) AFHTTPSessionManager *managerHttp;
@property (nonatomic, strong) AFURLSessionManager *managerUrl;

@end

@implementation SYNetworkRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (!self.hostUrl.host) {
            NSLog(@"<-------没有设置host，请先调用“startWithServiceHost:”设置host------->");
        }
        NSAssert(self.hostUrl.host != nil, @"self.hostUrl must be non-nil");
        NSParameterAssert(self.hostUrl.host);
        NSLog(@"<-------已调用“startWithServiceHost:”设置servicehost------->");
        
        // 初始化请求格式、返回格式
        self.timeout = APIServiceTimeout;
        self.responseType = ResponseContentTypeOther;
        self.requestType = RequestContentTypeOther;
    }
    
    return self;
}

+ (SYNetworkRequest *)shareRequest
{
    static SYNetworkRequest *network = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        network = [[self alloc] init];
    });
    
    return network;
}

/**
 *  启动设置服务器
 *
 *  @param host API服务器
 */
+ (void)startWithServiceHost:(NSString *)host
{
    APIServiceHost = host;
}

- (NSURL *)hostUrl
{
    if (!_hostUrl) {
        _hostUrl = [NSURL URLWithString:APIServiceHost];
    }
    
    return _hostUrl;
}

#pragma mark - 网络状态监测

/**
 *  网络监测（APP启动时设置）
 */
+ (void)networkMonitoring
{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

/**
 *  网络类型-WIFI
 *
 *  @return BOOL
 */
+ (BOOL)isWIFI
{
    return [[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi];
}

/**
 *  网络类型-WWAN
 *
 *  @return BOOL
 */
+ (BOOL)isWWAN
{
    return [[AFNetworkReachabilityManager sharedManager] isReachableViaWWAN];
}

/// 网络情况判断
+ (void)netWorkReachability:(void (^)(AFNetworkReachabilityStatus status))handle
{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        if (AFNetworkReachabilityStatusNotReachable == status || AFNetworkReachabilityStatusUnknown == status) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameUnReachable object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameReachable object:nil];
        }
        
        if (handle) {
            handle(status);
        }
    }];
}

/**
 *  网络判断
 *
 *  @return 是否有网
 */
+ (BOOL)isReachable
{
//    return [[AFNetworkReachabilityManager sharedManager] isReachable];
    
    // 或
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags) {
        NSLog(@"Error: Could not recover network reachability flags");
        return NO;
    }
    
    BOOL isReachable = (flags & kSCNetworkFlagsReachable);
    BOOL needsConnection = (flags & kSCNetworkFlagsConnectionRequired);
    BOOL isValidNetwork = ((isReachable && !needsConnection) ? YES : NO);
    
    return isValidNetwork;
}

#pragma mark - 网络请求

#pragma mark 普通请求（GET/POST/PUT/DELETE/HEAD/PATCH）

/**
 *  网络请求（GET/POST/PUT/DELETE/HEAD/PATCH）
 *
 *  @param url              请求地址
 *  @param dict             请求参数
 *  @param methord          请求方式（GET/POST/PUT/DELETE/HEAD/PATCH）
 *  @param uploadProgress   上传进度回调
 *  @param downloadProgress 下载进度回调
 *  @param complete         请求结果回调
 *
 *  @return NSURLSessionDataTask
 */
- (NSURLSessionDataTask *)requestWithUrl:(NSString *)url
                              parameters:(NSDictionary *)dict
                                 methord:(NSString *)methord
                          uploadProgress:(void (^)(NSProgress *progress))uploadProgress
                        downloadProgress:(void (^)(NSProgress *progress))downloadProgress
                                complete:(void (^)(NSURLResponse *response, id responseObject, NSError *error))complete
{
    // 没有网络
    if (![SYNetworkRequest isReachable]) {
        if (complete) {
            NSError *error;
            complete(nil, nil, error);
        }
        
        return nil;
    }
    
    NSString *methordType = [methord uppercaseString];
    NSURLSessionDataTask *dataTask = [self.managerHttp dataTaskWithHTTPMethod:methordType URLString:url parameters:dict uploadProgress:uploadProgress downloadProgress:downloadProgress success:^(NSURLSessionDataTask *task, id responseObject) {
        if (complete) {
            complete(task.response, responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (complete) {
            complete(task.response, nil, error);
        }
    }];
    
    return dataTask;
}

#pragma mark https请求（GET/POST/PUT/DELETE/HEAD/PATCH）

/**
 *  https网络请求（GET/POST/PUT/DELETE/HEAD/PATCH）
 *
 *  @param url              请求地址
 *  @param dict             请求参数
 *  @param methord          请求方式（GET/POST/PUT/DELETE/HEAD/PATCH）
 *  @param isCertificates   是否忽略自建证书（NO时证书无效）
 *  @param certificatesFile 证书名称（如：httpsFile.cer）
 *  @param uploadProgress   上传进度回调
 *  @param downloadProgress 下载进度回调
 *  @param complete         请求结果回调
 *
 *  @return NSURLSessionDataTask
 */
- (NSURLSessionDataTask *)requestWithUrl:(NSString *)url
                              parameters:(NSDictionary *)dict
                                 methord:(NSString *)methord
                          isCertificates:(BOOL)isCertificates
                            certificates:(NSString *)certificatesFile
                          uploadProgress:(void (^)(NSProgress *progress))uploadProgress
                        downloadProgress:(void (^)(NSProgress *progress))downloadProgress
                                complete:(void (^)(NSURLResponse *response, id responseObject, NSError *error))complete
{
    // 证书配置-无证书
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    // allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    // 如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = NO;
    if (isCertificates ) {
        // 证书
        NSString *fileName = certificatesFile.stringByDeletingPathExtension;
        NSString *fileType = certificatesFile.pathExtension;
        NSString *cerPath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileType];
        NSData *certData = [NSData dataWithContentsOfFile:cerPath];
        NSSet *certSet = [[NSSet alloc] initWithObjects:certData, nil];
        // 证书配置-有证书
        securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        securityPolicy.pinnedCertificates = certSet; // 设置证书
        securityPolicy.allowInvalidCertificates = YES;
    }
    
    self.managerHttp.securityPolicy = securityPolicy;
    NSURLSessionDataTask *dataTask = [self.managerHttp dataTaskWithHTTPMethod:methord URLString:url parameters:dict uploadProgress:uploadProgress downloadProgress:downloadProgress success:^(NSURLSessionDataTask *task, id responseObject) {
        if (complete) {
            complete(task.response, responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (complete) {
            complete(task.response, nil, error);
        }
    }];
    
    return dataTask;
}

#pragma mark 文件上传请求

/**
 *  网络请求-文件上传
 *
 *  @param url            请求地址
 *  @param dict           请求参数
 *  @param isStream       文件流上传方式
 *  @param filePath       文件路径
 *  @param name           上传标识名称，如：@"file"，或@"iconImg"
 *  @param fileName       文件名称，如：@"filename.jpg"
 *  @param fileType       文件类型，如：@"image/jpeg"
 *  @param uploadProgress 上传进度回调
 *  @param complete       请求结果回调
 *
 *  @return NSURLSessionUploadTask
 */
- (NSURLSessionUploadTask *)requestUploadWithUrl:(NSString *)url
                                      parameters:(NSDictionary *)dict
                                      streamType:(BOOL)isStream
                                        filePath:(NSString *)filePath
                                            name:(NSString *)name
                                        fileName:(NSString *)fileName
                                        fileType:(NSString *)fileType
                                  uploadProgress:(void (^)(NSProgress *progress))uploadProgress
                                        complete:(void (^)(NSURLResponse *response, id responseObject, NSError *error))complete
{
    NSURLSessionUploadTask *uploadTask = nil;
    if (isStream) {
        uploadTask = [self uploadStreamWithUrl:url filePath:filePath name:name fileName:fileName fileType:fileType parameters:dict uploadProgress:uploadProgress complete:complete];
    } else {
        uploadTask = [self uploadWithUrl:url parameters:dict filePath:filePath uploadProgress:uploadProgress complete:complete];
    }
    
    return uploadTask;
}

- (NSURLSessionUploadTask *)uploadWithUrl:(NSString *)url
                               parameters:(NSDictionary *)dict
                                 filePath:(NSString *)filePath
                           uploadProgress:(void (^)(NSProgress *progress))uploadProgress
                                 complete:(void (^)(NSURLResponse *response, id responseObject, NSError *error))complete
{
    NSURL *requestUrl = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestUrl];
    
    NSURL *filePathUrl = [NSURL fileURLWithPath:filePath];
    NSURLSessionUploadTask *uploadTask = [self.managerHttp uploadTaskWithRequest:request fromFile:filePathUrl progress:^(NSProgress * _Nonnull progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (uploadProgress) {
                uploadProgress(progress);
            }
        });
    } completionHandler:complete];
    
    return uploadTask;
}

- (NSURLSessionUploadTask *)uploadStreamWithUrl:(NSString *)url
                                       filePath:(NSString *)filePath
                                           name:(NSString *)name
                                       fileName:(NSString *)fileName
                                       fileType:(NSString *)fileType
                                     parameters:(NSDictionary *)dict
                                 uploadProgress:(void (^)(NSProgress *progress))uploadProgress
                                       complete:(void (^)(NSURLResponse *response, id responseObject, NSError *error))complete
{
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:name fileName:fileName mimeType:fileType error:nil];
    } error:nil];
    
    NSURLSessionUploadTask *uploadTask = [self.managerHttp uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull progress) {
        // This is not called back on the main queue.
        // You are responsible for dispatching to the main queue for UI updates
        dispatch_async(dispatch_get_main_queue(), ^{
            if (uploadProgress) {
                uploadProgress(progress);
            }
        });
    } completionHandler:complete];
    
    return uploadTask;
}

#pragma mark 文件下载请求

/**
 *  网络请求-文件下载
 *
 *  @param url                   请求地址
 *  @param dict                  请求参数
 *  @param methord               请求方式（GET/POST/PUT/DELETE/HEAD/PATCH）
 *  @param downloadProgress      下载进度回调
 *  @param complete              下载结果回调
 *
 *  @return NSURLSessionDownloadTask
 */
- (NSURLSessionDownloadTask *)requestDownloadWithUrl:(NSString *)url
                                          parameters:(NSDictionary *)dict
                                             methord:(NSString *)methord
                                    downloadProgress:(void (^)(NSProgress *uploadProgress))downloadProgress
                                            complete:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))complete
{
    NSMutableURLRequest *request = [self.managerHttp.requestSerializer requestWithMethod:methord URLString:url parameters:dict error:nil];
    
    NSURLSessionDownloadTask *downloadTask = [self.managerHttp downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (downloadProgress) {
                downloadProgress(progress);
            }
        });
    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *directoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [directoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:complete];
    
    return downloadTask;
}

#pragma mark - AFHTTPSessionManager

#pragma mark getter

- (AFHTTPSessionManager *)managerHttp
{
    if (_managerHttp == nil) {
        NSURL *baseUrl = self.hostUrl;
        if (![baseUrl.scheme isEqualToString:@"http"] && ![baseUrl.scheme isEqualToString:@"https"]) {
            baseUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", APIServiceHost]];
        }
        
        _managerHttp = [[AFHTTPSessionManager alloc] initWithBaseURL:baseUrl];
        if ([baseUrl.scheme isEqualToString:@"https"]) {
            _managerHttp.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        }
    }
    
    return _managerHttp;
}

#pragma mark setter

- (void)setTimeout:(NSTimeInterval)timeout
{
    _timeout = timeout;
    self.managerHttp.requestSerializer.timeoutInterval = _timeout;
}

/*
 // 请求格式
 AFHTTPRequestSerializer            二进制格式
 AFJSONRequestSerializer            JSON
 AFPropertyListRequestSerializer    PList(是一种特殊的XML,解析起来相对容易)
 
 // 返回格式
 AFHTTPResponseSerializer           二进制格式
 AFJSONResponseSerializer           JSON
 AFXMLParserResponseSerializer      XML,只能返回XMLParser,还需要自己通过代理方法解析
 AFXMLDocumentResponseSerializer (Mac OS X)
 AFPropertyListResponseSerializer   PList
 AFImageResponseSerializer          Image
 AFCompoundResponseSerializer       组合
 */
- (void)setRequestType:(RequestContentType)requestType
{    
    _requestType = requestType;
    
    // 请求数据样式
    if (RequestContentTypeXML == requestType) {
        self.managerHttp.requestSerializer = [AFPropertyListRequestSerializer serializer];
    } else if (RequestContentTypeJSON == requestType) {
        self.managerHttp.requestSerializer = [AFJSONRequestSerializer serializer];
        [self.managerHttp.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//        self.managerHttp.requestSerializer.timeoutInterval = self.timeout;
    } else if (RequestContentTypeOther == requestType) {
        // 默认
        self.managerHttp.requestSerializer = [AFHTTPRequestSerializer serializer];
    }
}

- (void)setResponseType:(ResponseContentType)responseType
{
    _responseType = responseType;
    
    // 响应数据格式
    if (ResponseContentTypeXML == responseType) {
        // 返回格式-xml
        self.managerHttp.responseSerializer = [AFXMLParserResponseSerializer serializer];
    } else if (ResponseContentTypeJSON == responseType) {
        // 返回格式-json 默认
        self.managerHttp.responseSerializer = [AFJSONResponseSerializer serializer];
    } else if (ResponseContentTypeOther == responseType) {
        // 返回格式-其他
        self.managerHttp.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
}

#pragma mark - 请求管理

 - (NSMutableDictionary *)networkDicts
{
    if (_networkDicts == nil) {
        _networkDicts = [[NSMutableDictionary alloc] init];
    }
    return _networkDicts;
}

- (void)addRequest:(NSURLSessionTask *)task
{
    if ([task isKindOfClass:[NSURLSessionDataTask class]] || [task isKindOfClass:[NSURLSessionDownloadTask class]] || [task isKindOfClass:[NSURLSessionUploadTask class]]) {
        NSString *key = task.currentRequest.URL.absoluteString;
        if ([self.networkDicts.allKeys containsObject:key]) {
            
        } else {
            [self.networkDicts setObject:task forKey:key];
        }
    }
}

- (void)cancelRequest:(NSString *)url
{
    if ([self.networkDicts.allKeys containsObject:url]) {
        NSURLSessionTask *task = [self.networkDicts objectForKey:url];
        [task cancel];
        [self.networkDicts removeObjectForKey:url];
    }
}

- (void)cancelAllRequest
{
    for (NSURLSessionTask *task in self.networkDicts.allValues) {
        [task cancel];
    }
    [self.networkDicts removeAllObjects];
}

@end
