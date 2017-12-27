//
//  MyAFnetWork.h
//  AF封装
//
//  Created by apple on 2017/6/29.
//  Copyright © 2017年 hzq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface MyAFnetWork : NSObject
+ (NSURLSessionDataTask *_Nullable)POST:(NSString *_Nullable)URLString
                             parameters:(nullable id)parameters
              constructingBodyWithBlock:(nullable void (^)(id<AFMultipartFormData> _Nonnull))block
                                success:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject))success
                                failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;


@end
