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
                                complete:(void (^)(id object))complete
                                  target:(id)target
                              enableView:(BOOL)isEnable
                               cacheType:(NetworkCacheType)cacheType
                               cacheTime:(NSTimeInterval)cacheTime
{
    NSLog(@"当前网络状态：%@", ([SYNetworkRequest isReachable] ? @"可用" : @"不可用"));
    
    if (![SYNetworkRequest isReachable])
    {
        if (complete)
        {
            complete(nil);
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
}

+ (NSURLSessionDataTask *)requestWithUrl:(NSString *)url
                              parameters:(NSDictionary *)dict
                                 methord:(RequestHttpType)type
                      requestContentType:(RequestContentType)requestType
                     responseContentType:(ResponseContentType)responseType
                                  upload:(void (^)(long long total, long long complete))upload
                                download:(void (^)(long long total, long long complete))download
                                complete:(void (^)(id object))complete
                                  target:(id)target
                              enableView:(BOOL)isEnable
{
    NSLog(@"当前网络状态：%@", ([SYNetworkRequest isReachable] ? @"可用" : @"不可用"));
    
    if (![SYNetworkRequest isReachable])
    {
        if (complete)
        {
            complete(nil);
        }
        
        return nil;
    }
    
    NSLog(@"\nurl = %@ \ndict = %@", url, dict);
    
    // 显示加载符
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // 是否屏蔽当前视图控制器的视图交互-禁用
    if (target)
    {
        UIViewController *controller = (UIViewController *)target;
        controller.view.userInteractionEnabled = isEnable;
    }
    
    
    // 请求样式
    NSString *requestMethord = (RequestHttpTypePOST == type ? @"POST" : @"GET");
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
        
        NSLog(@"\n<--------\nresponseObject = %@\n-------->\n", responseObject);
        
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
        
        NSLog(@"\n<--------\nresponseString = %@\n-------->\n", responseString);
        
        if (complete)
        {
            complete(responseString);
        }
    }];
    
    // 请求开始
    [dataTask resume];
    
    return dataTask;
}


@end
