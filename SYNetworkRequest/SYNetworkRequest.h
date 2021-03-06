//
//  SYNetworkRequest.h
//  zhangshaoyu
//
//  Created by zhangshaoyu on 16/7/25.
//  Copyright © 2016年 zhangshaoyu. All rights reserved.
//

/*
 https://github.com/potato512/SYNetworkRequest
 https://github.com/AFNetworking/AFNetworking
 
 使用注意：
 网络状态
 监测：[SYNetworkRequest networkMonitoring];
 状态：[SYNetworkRequest isReachable];
 类型：[SYNetworkRequest isWIFI]; 或 [SYNetworkRequest isWWAN];
 
 初始化服务器地址：[SYNetworkRequest startWithServiceHost:@"http://wwww.hao123.com"];
 
 // [[SYNetworkRequest shareRequest] setRequestType:RequestContentTypeOther];
 // [[SYNetworkRequest shareRequest] setResponseType:ResponseContentTypeXML];
 
 */

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFHTTPSessionManager.h>

static NSString *const kNotificationNameUnReachable = @"NetworkNotReachable";
static NSString *const kNotificationNameReachable   = @"NetworkReachable";
/*
 // 接收网络状态变化通知，并执行相关方法
 // 没有网络状态通知
 [[NSNotificationCenter defaultCenter] receiveNotificationWithName:kNotificationNameUnReachable target:self selector:@selector(networkUnReachability:)];
 - (void)networkUnReachability:(NSNotification *)notification
 { }
 // 有网络状态通知
 [[NSNotificationCenter defaultCenter] receiveNotificationWithName:kNotificationNameReachable target:self selector:@selector(networkReachability:)];
 - (void)networkReachability:(NSNotification *)notification
 { }
*/


/// 异常情况（外网异常、外网异常有缓存、外网异常无缓存、服务器异常、服务器异常有缓存、服务器异常无缓存）
typedef NS_ENUM(NSInteger, RequestNetworkStatus) {
    /// 正常情况
    RequestNetworkValid = 0,
    /// 异常情况-外网异常
    RequestNetworkInvalideNet,
    /// 异常情况-外网异常有缓存
    RequestNetworkInvalideNetWithCache,
    /// 异常情况-外网异常无缓存
    RequestNetworkInvalideNetWithoutCache,
    /// 异常情况-服务器异常
    RequestNetworkInvalideServer,
    /// 异常情况-服务器异常有缓存
    RequestNetworkInvalideServerWithCache,
    /// 异常情况-服务器异常有缓存
    RequestNetworkInvalideServerWithoutCache
};

/// 请求数据样式（XML，或JSON，或其他；默认其他）
typedef NS_ENUM(NSInteger, RequestContentType) {
    /// 请求数据样式-XML
    RequestContentTypeXML = 1,
    /// 请求数据样式-JSON
    RequestContentTypeJSON,
    /// 请求数据样式-其他
    RequestContentTypeOther
};

/// 响应数据样式（XML，或JSON，或其他；默认JSON）
typedef NS_ENUM(NSInteger, ResponseContentType){
    /// 响应数据样式-XML
    ResponseContentTypeXML = 1,
    /// 响应数据样式-JSON
    ResponseContentTypeJSON,
    /// 响应数据样式-其他
    ResponseContentTypeOther
};

/// 请求类型（GET/POST/PUT/DELETE/HEAD/PATCH）
typedef NS_ENUM(NSInteger, RequestHttpType) {
    /// 请求样式-POST
    RequestHttpTypePOST = 1,
    /// 请求样式-GET
    RequestHttpTypeGET,
    /// 请求样式-PUT
    RequestHttpTypePUT,
    /// 请求样式-DELETE
    RequestHttpTypeDELETE,
    /// 请求样式-HEAD
    RequestHttpTypeHEAD,
    /// 请求样式-PATCH
    RequestHttpTypePATCH
};

@interface SYNetworkRequest : NSObject

/// 单例
+ (SYNetworkRequest *)shareRequest;

/// 网络请求超时（默认30）
@property (nonatomic, assign) NSTimeInterval timeout;

/// 响应数据样式（XML，或JSON，或其他；默认JSON）
@property (nonatomic, assign) ResponseContentType responseType;
/// 请求数据样式（XML，或JSON，或其他；默认其他）
@property (nonatomic, assign) RequestContentType requestType;

/**
 *  启动设置服务器
 *
 *  @param host API服务器
 */
+ (void)startWithServiceHost:(NSString *)host;

#pragma mark - 网络状态监测

/// 网络监测（APP启动时设置）
+ (void)networkMonitoring;

/// 网络类型-WIFI
+ (BOOL)isWIFI;
/// 网络类型-WWAN
+ (BOOL)isWWAN;
/// 网络判断
+ (BOOL)isReachable;

/// 网络情况判断
+ (void)netWorkReachability:(void (^)(AFNetworkReachabilityStatus status))handle;

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
                                complete:(void (^)(NSURLResponse *response, id responseObject, NSError *error))complete;

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
                                complete:(void (^)(NSURLResponse *response, id responseObject, NSError *error))complete;

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
                                        complete:(void (^)(NSURLResponse *response, id responseObject, NSError *error))complete;

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
                                            complete:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))complete;

#pragma mark - 请求管理

- (void)addRequest:(NSURLSessionTask *)task;

- (void)cancelRequest:(NSString *)url;

- (void)cancelAllRequest;

@end
