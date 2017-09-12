//
//  CacheNetworkRequest.m
//  DemoSYNetworkRequest
//
//  Created by zhangshaoyu on 2017/7/22.
//  Copyright © 2017年 zhangshaoyu. All rights reserved.
//

#import "CacheNetworkRequest.h"

@implementation CacheNetworkRequest

+ (NSURLSessionDataTask *)requestWithUrl:(NSString *)url
                              parameters:(NSDictionary *)dict
                                 methord:(RequestHttpType)type
                      requestContentType:(RequestContentType)requestType
                     responseContentType:(ResponseContentType)responseType
                                  upload:(void (^)(long long total, long long complete))upload
                                download:(void (^)(long long total, long long complete))download
                                complete:(void (^)(RequestNetworkStatus networkStatus, id object))complete
                                  target:(id)target
                              enableView:(BOOL)isEnable
                               cacheType:(NetworkCacheType)cacheType
                               cacheTime:(NSTimeInterval)cacheTime
{
    NSLog(@"\n<-----------------\n当前网络状态：%@\n----------------->", ([SYNetworkRequest isReachable] ? @"可用" : @"不可用"));
    
    /*
    // 没有网络时
    if (![SYNetworkRequest isReachable])
    {
        if (complete)
        {
            complete(RequestNetworkInvalideNet, nil);
        }
        
        return nil;
    }
    
    NSURLSessionDataTask *dataTask = nil;
    // 缓存处理
    if (cacheType == NetworkCacheTypeAlways || cacheType == NetworkCacheTypeNever)
    {
        // 不做缓存总是重新请求网络；无视缓存总是重新请求网络；
        dataTask = [self requestWithUrl:url parameters:dict methord:type requestContentType:requestType responseContentType:responseType upload:upload download:download complete:^(id object) {
            if (complete)
            {
                complete(object);
            }
            
            if (cacheType == NetworkCacheTypeAlways)
            {
                [[SYNetworkCache shareCache] deleteNetworkCacheWithKey:url];
                NSData *data = [object dataUsingEncoding:NSUTF8StringEncoding];
                [[SYNetworkCache shareCache] saveNetworkCacheData:data cachekey:url cacheTime:cacheTime];
            }
        } target:target enableView:isEnable];
        
    }
    else if (cacheType == NetworkCacheTypeWhileOverdue)
    {
        // 有缓存，缓存过期时才请求最新的
        NSData *data = [[SYNetworkCache shareCache] getNetworkCacheContentWithCacheKey:url];
        if (data)
        {
            NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (complete)
            {
                complete(string);
            }
            
            return nil;
        }
        else
        {
            dataTask = [self requestWithUrl:url parameters:dict methord:type requestContentType:requestType responseContentType:responseType upload:upload download:download complete:^(id object) {
                if (complete)
                {
                    complete(object);
                }
                
                [[SYNetworkCache shareCache] deleteNetworkCacheWithKey:url];
                NSData *data = [object dataUsingEncoding:NSUTF8StringEncoding];
                [[SYNetworkCache shareCache] saveNetworkCacheData:data cachekey:url cacheTime:cacheTime];
            } target:target enableView:isEnable];
        }
    }

    return dataTask;
    */
    
    NSLog(@"\n<-----------------\nurl = %@\ndict = %@\n----------------->", url, dict);
    
    NSURLSessionDataTask *dataTask = nil;
    if (cacheType == NetworkCacheTypeAlways || cacheType == NetworkCacheTypeNever || cacheType == NetworkCacheTypeWhileOverdue)
    {
        // 有缓存
        // 缓存key
        NSMutableString *keyCache = [[NSMutableString alloc] initWithString:url];;
        for (NSInteger index = 0; index < dict.allKeys.count; index++)
        {
            NSString *key = dict.allKeys[index];
            NSString *value = [dict objectForKey:key];
            NSString *keyValue = [NSString stringWithFormat:@"%@_%@", key, value];
            
            [keyCache appendFormat:@"&%@", keyValue];
            if (index != dict.allKeys.count - 1)
            {
                [keyCache appendString:@"&"];
            }
        }
        // 缓存
        NSData *data = [[SYNetworkCache shareCache] getNetworkCacheContentWithCacheKey:keyCache];
        // 存在缓存
        if (cacheType == NetworkCacheTypeAlways || cacheType == NetworkCacheTypeNever)
        {
            // 不做缓存总是重新请求网络；无视缓存总是重新请求网络；
            dataTask = [self requestWithUrl:url parameters:dict methord:type requestContentType:requestType responseContentType:responseType upload:upload download:download complete:^(RequestNetworkStatus networkStatus, id object) {
                
                if (complete)
                {
                    if (networkStatus == RequestNetworkInvalideNet)
                    {
                        if (data)
                        {
                            object = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                            networkStatus = RequestNetworkInvalideNetWithCache;
                        }
                        else
                        {
                            networkStatus = RequestNetworkInvalideNetWithoutCache;
                        }
                    }
                    else if (networkStatus == RequestNetworkInvalideServer)
                    {
                        if (data)
                        {
                            object = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                            networkStatus = RequestNetworkInvalideServerWithCache;
                        }
                        else
                        {
                            networkStatus = RequestNetworkInvalideServerWithoutCache;
                        }
                    }
                    complete(networkStatus, object);
                }
                
                NSLog(@"\n<-----------------\nnetworkStatus = %@\ncacheType = %@\nobject = %@\n----------------->", @(networkStatus), @(cacheType), object);
                
                if (cacheType == NetworkCacheTypeAlways)
                {
                    [[SYNetworkCache shareCache] deleteNetworkCacheWithKey:keyCache];
                    NSData *data = [object dataUsingEncoding:NSUTF8StringEncoding];
                    [[SYNetworkCache shareCache] saveNetworkCacheData:data cachekey:keyCache cacheTime:cacheTime];
                }
            } target:target enableView:isEnable];
        }
        else if (cacheType == NetworkCacheTypeWhileOverdue)
        {
            RequestNetworkStatus networkStatus = RequestNetworkValid;
            if (![SYNetworkRequest isReachable])
            {
                networkStatus = RequestNetworkInvalideNet;
            }
            
            id object = nil;
            if (data)
            {
                if (complete)
                {
                    if (![SYNetworkRequest isReachable])
                    {
                        networkStatus = RequestNetworkInvalideNetWithCache;
                    }      
                    
                    object = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    complete(networkStatus, object);
                }
                
                NSLog(@"\n<-----------------\nnetworkStatus = %@\ncacheType = %@\nobject = %@\n----------------->", @(networkStatus), @(cacheType), object);
                
                return nil;
            }
            else
            {
                dataTask = [self requestWithUrl:url parameters:dict methord:type requestContentType:requestType responseContentType:responseType upload:upload download:download complete:^(RequestNetworkStatus networkStatus, id object) {
                 
                    if (complete)
                    {
                        if (networkStatus == RequestNetworkInvalideNet)
                        {
                            networkStatus = RequestNetworkInvalideNetWithoutCache;
                        }
                        else if (networkStatus == RequestNetworkInvalideServer)
                        {
                            networkStatus = RequestNetworkInvalideServerWithoutCache;
                        }
                        complete(networkStatus, object);
                    }
                    
                    NSLog(@"\n<-----------------\nnetworkStatus = %@\ncacheType = %@\nobject = %@\n----------------->", @(networkStatus), @(cacheType), object);
                    
                    [[SYNetworkCache shareCache] deleteNetworkCacheWithKey:keyCache];
                    NSData *data = [object dataUsingEncoding:NSUTF8StringEncoding];
                    [[SYNetworkCache shareCache] saveNetworkCacheData:data cachekey:keyCache cacheTime:cacheTime];
                } target:target enableView:isEnable];
            }
        }
    }
    else
    {
        // 无缓存
        dataTask = [self requestWithUrl:url parameters:dict methord:type requestContentType:requestType responseContentType:responseType upload:upload download:download complete:^(RequestNetworkStatus networkStatus, id object) {
            
            NSLog(@"\n<-----------------\nnetworkStatus = %@\ncacheType = %@\nobject = %@\n----------------->", @(networkStatus), @(cacheType), object);
            
            if (complete)
            {
                complete(networkStatus, object);
            }
        } target:target enableView:isEnable];
    }
    
    return dataTask;
}

+ (NSURLSessionDataTask *)requestWithUrl:(NSString *)url
                              parameters:(NSDictionary *)dict
                                 methord:(RequestHttpType)type
                      requestContentType:(RequestContentType)requestType
                     responseContentType:(ResponseContentType)responseType
                                  upload:(void (^)(long long total, long long complete))upload
                                download:(void (^)(long long total, long long complete))download
                                complete:(void (^)(RequestNetworkStatus networkStatus, id object))complete
                                  target:(id)target
                              enableView:(BOOL)isEnable
{
    // 没有网络时
    if (![SYNetworkRequest isReachable])
    {
        if (complete)
        {
            RequestNetworkStatus networkStatus = RequestNetworkInvalideNet;
            complete(networkStatus, nil);
        }
        
        return nil;
    }
    
    // 显示加载符
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // 是否屏蔽当前视图控制器的视图交互-禁用
    if (target)
    {
        UIViewController *controller = (UIViewController *)target;
        controller.view.userInteractionEnabled = isEnable;
    }
    
    // 请求样式
    NSString *requestMethord = @"POST";
    switch (type)
    {
        case RequestHttpTypeGET: requestMethord = @"GET";  break;
        case RequestHttpTypePOST: requestMethord = @"POST"; break;
        case RequestHttpTypePUT: requestMethord = @"PUT"; break;
        case RequestHttpTypeDELETE: requestMethord = @"DELETE"; break;
        case RequestHttpTypeHEAD: requestMethord = @"HEAD"; break;
        case RequestHttpTypePATCH: requestMethord = @"PATCH"; break;
    }
    // 请求参数
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    
    [[SYNetworkRequest shareRequest] setResponseType:responseType];
    [[SYNetworkRequest shareRequest] setRequestType:requestType];
    
    NSURLSessionDataTask *dataTask = [[SYNetworkRequest shareRequest] requestWithUrl:url parameters:requestDict methord:requestMethord uploadProgress:^(NSProgress *progress) {
        // 是否屏蔽当前视图控制器的视图交互-有效
        if (target)
        {
            UIViewController *controller = (UIViewController *)target;
            controller.view.userInteractionEnabled = YES;
        }
        
        if (upload)
        {
            upload(progress.totalUnitCount, progress.completedUnitCount);
        }
        
    } downloadProgress:^(NSProgress *progress) {
        // 是否屏蔽当前视图控制器的视图交互-有效
        if (target)
        {
            UIViewController *controller = (UIViewController *)target;
            controller.view.userInteractionEnabled = YES;
        }
        
        if (download)
        {
            download(progress.totalUnitCount, progress.completedUnitCount);
        }
    } complete:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        // 隐藏加载符
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        // 是否屏蔽当前视图控制器的视图交互-有效
        if (target)
        {
            UIViewController *controller = (UIViewController *)target;
            controller.view.userInteractionEnabled = YES;
        }
        
        NSString *responseString = nil;
        if ([responseObject isKindOfClass:[NSString class]])
        {
            responseString = [[NSString alloc] initWithString:responseObject];
        }
        else if ([responseObject isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *objectDict = (NSDictionary *)responseObject;
            if (objectDict && 0 != objectDict.count)
            {
                NSError *error = nil;
                BOOL isValidJSON = [NSJSONSerialization isValidJSONObject:objectDict];
                if (isValidJSON)
                {
                    // NSJSONWritingOptions 是"NSJSONWritingPrettyPrinted"的话有换位符\n；是"0"的话没有换位符\n。
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:objectDict options:0 error:&error];
                    responseString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                }
            }
        }
        else if ([responseObject isKindOfClass:[NSData class]])
        {
            responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        }
        
        if (complete)
        {
            RequestNetworkStatus networkStatus = RequestNetworkValid;
            if (error)
            {
                networkStatus = RequestNetworkInvalideServer;
            }
            complete(networkStatus, responseString);
        }
    }];
    
    // 请求开始
    [dataTask resume];
    
    return dataTask;
}


@end
