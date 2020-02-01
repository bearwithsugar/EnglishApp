//
//  NetSenderFunction.h
//  EnglishDemo
//
//  Created by 马一轩 on 2020/1/29.
//  Copyright © 2020 马一轩. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetSenderFunction : NSObject

typedef void (^VoidBlock) (void);

typedef void (^ConBlock) (NSDictionary*);

#pragma mark --post系列方法
-(void)postRequest:(NSURL*)url Block:(ConBlock)block;

-(void)postRequestWithHead:(NSURL*)url Head:(NSString*)headMsg Block:(ConBlock)block;

#pragma mark --get系列方法
-(void)getRequest:(NSURL*)url Block:(ConBlock)block;

-(void)getRequestWithHead:(NSString*)userkey Path:(NSURL*)url Block:(ConBlock)block;

#pragma mark --put方法
-(void)putRequestWithHead:(NSURL*)url Head:(NSString*)headMsg Block:(ConBlock)block;

#pragma mark --delete方法
-(void)deleteRequestWithHead:(NSURL*)url Head:(NSString*)headMsg Block:(ConBlock)block;

@end

NS_ASSUME_NONNULL_END
