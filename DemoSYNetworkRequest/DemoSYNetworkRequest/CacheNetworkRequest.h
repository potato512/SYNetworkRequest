//
//  CacheNetworkRequest.h
//  DemoSYNetworkRequest
//
//  Created by zhangshaoyu on 2017/7/22.
//  Copyright © 2017年 zhangshaoyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYNetworkRequest.h"
#import "SYNetworkCache.h"

@interface CacheNetworkRequest : NSObject

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
                               cacheTime:(NSTimeInterval)cacheTime;

@end
