//
//  RequestInstance.m
//  EnglishDemo
//
//  Created by 马一轩 on 2019/3/28.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import "RequestInstance.h"
#import "AgentFunction.h"

@implementation RequestInstance

-(NSDictionary*)getRequest:(NSURL*)url{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *session=[NSURLSession sharedSession];
    NSLog(@"request请求%@",request);
    static NSDictionary* dictionary;
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dictionary=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        //这里改变RunLoop模式
        CFRunLoopStop(CFRunLoopGetMain());
        [AgentFunction isTokenExpired:dictionary];
    }];
    [dataTask resume];
    //这里恢复RunLoop
    CFRunLoopRun();
    return dictionary;
    
}

-(NSDictionary*)getRequestWithHead:(NSURL*)url Head:(NSString*)headMsg{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *session=[NSURLSession sharedSession];
    NSLog(@"get方法中url是：%@",url);
    //添加请求头
    NSDictionary *headers = @{@"English-user": headMsg};
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];
    
    static NSDictionary* dictionary;
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dictionary=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        //这里改变RunLoop模式
        CFRunLoopStop(CFRunLoopGetMain());
        //NSLog(@"网络响应：response：%@",response);
        // NSLog(@"返回数据：response：%@",data);
        NSLog(@"错误：%@",error);
        NSString *html = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"数据为：%@",html);
        [AgentFunction isTokenExpired:dictionary];
        //        if ([AgentFunction isTokenExpired:dictionary]) {
        //
        //            dictionary=@{@"1":@"code"};
        //        }
    }];
    [dataTask resume];
    //这里恢复RunLoop
    CFRunLoopRun();
    return dictionary;
}

-(NSDictionary*)postRequest:(NSURL*)url{
    NSURLSession *session=[NSURLSession sharedSession];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    NSLog(@"post方法中url是：%@",url);
    request.HTTPMethod=@"POST";
    [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    static NSDictionary *dataDic;
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        dataDic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        //这里改变RunLoop模式
        CFRunLoopStop(CFRunLoopGetMain());
        NSString *html = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"数据是：%@",html);
        NSLog(@"错误是：%@",error);
        //NSLog(@"响应是：%@",response);
        [AgentFunction isTokenExpired:dataDic];
        
    }];
    
    [dataTask resume];
    //这里恢复RunLoop
    CFRunLoopRun();
    return dataDic;
}

-(NSDictionary*)postRequestWithHead:(NSURL*)url Head:(NSString*)headMsg{
    NSURLSession *session=[NSURLSession sharedSession];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    NSLog(@"post方法的url是：%@",url);
    
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
        NSString *html = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"数据是：%@",html);
        NSLog(@"错误是：%@",error);
        //NSLog(@"响应是：%@",response);
        [AgentFunction isTokenExpired:dataDic];
        
    }];
    
    [dataTask resume];
    //这里恢复RunLoop
    CFRunLoopRun();
    return dataDic;
}

@end
