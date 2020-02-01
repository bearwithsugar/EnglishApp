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
    
    [self sendBlockCallBack:session Request:request Block:block];
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
    
    [self sendBlockCallBack:session Request:request Block:block];
    //这里恢复RunLoop
    CFRunLoopRun();
}

#pragma mark --get系列方法
-(void)getRequest:(NSURL*)url Block:(ConBlock)block{
    NSLog(@"get-url:%@",url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *session=[NSURLSession sharedSession];
    [self sendBlockCallBack:session Request:request Block:block];
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
                               
    [self sendBlockCallBack:session Request:request Block:block];
    
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
    
    [self sendBlockCallBack:session Request:request Block:block];
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
    
    [self sendBlockCallBack:session Request:request Block:block];
    
    //这里恢复RunLoop
    CFRunLoopRun();
}

-(void)sendBlockCallBack:(NSURLSession*)session Request:(NSMutableURLRequest*)request Block:(ConBlock)block{
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        if (data == nil) {
            return ;
        }
        NSDictionary* dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        //这里改变RunLoop模式
        CFRunLoopStop(CFRunLoopGetMain());
        [AgentFunction isTokenExpired:dataDic];
        block(dataDic);
    }];
    [dataTask resume];
}

@end
