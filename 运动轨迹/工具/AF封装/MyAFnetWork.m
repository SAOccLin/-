//
//  MyAFnetWork.m
//  AF封装
//
//  Created by apple on 2017/6/29.
//  Copyright © 2017年 hzq. All rights reserved.
//

#import "MyAFnetWork.h"
@interface MyAFnetWork ()

@end
@implementation MyAFnetWork

+ (NSURLSessionDataTask *_Nullable)POST:(NSString *_Nullable)URLString
                             parameters:(nullable id)parameters
              constructingBodyWithBlock:(nullable void (^)(id<AFMultipartFormData> _Nonnull))block
                                success:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject))success
                                failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure{
//    AFHTTPSessionManager *manage = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:@"https://u.sunsyi.com"]];//正式
    
//    AFHTTPSessionManager *manage = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:@"https://u.sunyie.com"]];//测试
    
    AFHTTPSessionManager *manage = [AFHTTPSessionManager manager];
    
    manage.requestSerializer = [AFHTTPRequestSerializer serializer];
    manage.responseSerializer = [AFHTTPResponseSerializer serializer];
    //因AFNetworking 2.0开始格式有误，下面这句代码必须添加，否则有些格式无法识别
    manage.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    [manage.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    // 设置超时时间
    [manage.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manage.requestSerializer.timeoutInterval = 60.f;
    [manage.requestSerializer didChangeValueForKey:@"timeoutInterval"];
//    //单向认证
//    [manage setSecurityPolicy:[self customSecurityPolicy]];
    
    URLString= [URLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    return [manage POST:URLString parameters:parameters constructingBodyWithBlock:block progress:nil success:success failure:failure];
}


+ (AFSecurityPolicy*)customSecurityPolicy
{
    //先导入证书
    //在这加证书，一般情况适用于单项认证
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"u.sunsyi.com" ofType:@"cer"];//正式
    
//    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"u.sunyie.com" ofType:@"cer"];//测试
    
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    if (certData==nil) {
        return nil;
    }
    NSSet * set = [[NSSet alloc]initWithObjects:certData,nil];
    // AFSSLPinningModeCertificate 使用证书验证模式
//    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey];
    // allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    // 如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    //validatesDomainName 是否需要验证域名，默认为YES；
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    securityPolicy.validatesDomainName = NO;
    securityPolicy.pinnedCertificates = set;
    return securityPolicy;
}

@end
