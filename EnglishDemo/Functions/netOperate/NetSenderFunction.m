//
//  NetSenderFunction.m
//  EnglishDemo
//
//  Created by 马一轩 on 2020/1/29.
//  Copyright © 2020 马一轩. All rights reserved.
//

#import "NetSenderFunction.h"
#import "AgentFunction.h"

@implementation NetSenderFunction

#pragma mark --post系列方法
-(void)postRequest:(NSURL*)url Block:(ConBlock)block{
    NSLog(@"post-url:%@",url);
    NSURLSession *session=[NSURLSession sharedSession];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod=@"POST";
    [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    static NSDictionary *dataDic;
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        dataDic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        //这里改变RunLoop模式
        CFRunLoopStop(CFRunLoopGetMain());
        [AgentFunction isTokenExpired:dataDic];
        block(dataDic);
    }];
    
    [dataTask resume];
    //这里恢复RunLoop
    CFRunLoopRun();
}

-(void)postRequestWithHead:(NSURL*)url Head:(NSString*)headMsg Block:(ConBlock)block{
    NSLog(@"post-url:%@",url);
    NSURLSession *session=[NSURLSession sharedSession];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    
    //添加请求头
    NSDictionary *headers = @{ @"English-user": headMsg};
    [request setAllHTTPHeaderFields:headers];
    
    request.HTTPMethod=@"POST";
    [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    static NSDictionary *dataDic;
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        dataDic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        //这里改变RunLoop模式
        CFRunLoopStop(CFRunLoopGetMain());
        [AgentFunction isTokenExpired:dataDic];
        block(dataDic);
    }];
    
    [dataTask resume];
    //这里恢复RunLoop
    CFRunLoopRun();
}

//-(NSDictionary*)postRequestWithHeadAndVoidBlock:(NSURL*)url Head:(NSString*)headMsg Block:(VoidBlock)myBlock{
//    NSLog(@"post-url:%@",url);
//    NSURLSession *session=[NSURLSession sharedSession];
//    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
//
//    //添加请求头
//    NSDictionary *headers = @{ @"English-user": headMsg};
//    [request setAllHTTPHeaderFields:headers];
//
//    request.HTTPMethod=@"POST";
//    [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
//    static NSDictionary *dataDic;
//
//    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
//        dataDic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//        //这里改变RunLoop模式
//        CFRunLoopStop(CFRunLoopGetMain());
//        [AgentFunction isTokenExpired:dataDic];
//        myBlock();
//    }];
//
//    [dataTask resume];
//    //这里恢复RunLoop
//    CFRunLoopRun();
//    return dataDic;
//}

#pragma mark --get系列方法
-(void)getRequest:(NSURL*)url Block:(ConBlock)block{
    NSLog(@"get-url:%@",url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *session=[NSURLSession sharedSession];
    static NSDictionary* dictionary;
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dictionary=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        //这里改变RunLoop模式
        CFRunLoopStop(CFRunLoopGetMain());
        [AgentFunction isTokenExpired:dictionary];
        block(dictionary);
    }];
    [dataTask resume];
    //这里恢复RunLoop
    CFRunLoopRun();
}

-(void)getRequestWithHead:(NSString*)userkey Path:(NSURL*)url Block:(ConBlock)block{
    NSLog(@"get-url:%@",url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *session=[NSURLSession sharedSession];
    //添加请求头
    NSDictionary *headers = @{@"English-user": userkey};
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];
                               
    static NSDictionary* dictionary;
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dictionary=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        //这里改变RunLoop模式
        CFRunLoopStop(CFRunLoopGetMain());
        [AgentFunction isTokenExpired:dictionary];
        block(dictionary);

    }];
    [dataTask resume];
    //这里恢复RunLoop
    CFRunLoopRun();
}

#pragma mark --put方法
-(void)putRequestWithHead:(NSURL*)url Head:(NSString*)headMsg Block:(ConBlock)block{
    NSLog(@"put-url:%@",url);
    NSURLSession *session=[NSURLSession sharedSession];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    
    //添加请求头
    NSDictionary *headers = @{ @"English-user": headMsg};
    [request setHTTPMethod:@"PUT"];
    [request setAllHTTPHeaderFields:headers];
    
    [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    static NSDictionary *dataDic;
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        dataDic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        //这里改变RunLoop模式
        CFRunLoopStop(CFRunLoopGetMain());
        [AgentFunction isTokenExpired:dataDic];
        block(dataDic);
    }];
    
    [dataTask resume];
    //这里恢复RunLoop
    CFRunLoopRun();
}

#pragma mark --delete方法
-(void)deleteRequestWithHead:(NSURL*)url Head:(NSString*)headMsg Block:(ConBlock)block{
    NSURLSession *session=[NSURLSession sharedSession];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    NSLog(@"delete-url:%@",url);
    //添加请求头
    NSDictionary *headers = @{ @"English-user": headMsg};
    [request setHTTPMethod:@"DELETE"];
    [request setAllHTTPHeaderFields:headers];
    
    [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    static NSDictionary *dataDic;
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        dataDic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        //这里改变RunLoop模式
        CFRunLoopStop(CFRunLoopGetMain());
        [AgentFunction isTokenExpired:dataDic];
        block(dataDic);
    }];
    
    [dataTask resume];
    //这里恢复RunLoop
    CFRunLoopRun();
}

@end
