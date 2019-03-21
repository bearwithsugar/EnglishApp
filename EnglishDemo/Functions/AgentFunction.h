//
//  AgentFunction.h
//  EnglishDemo
//
//  Created by 马一轩 on 2019/1/23.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AgentFunction : NSObject

//根据输入价格获取学分
+(NSMutableDictionary*)getScore:(int)price;

//微信分享
+(void)WXshare;

//获取到当前所在的视图
+(UIViewController *)theTopviewControler;

//如果token过期显示提示框
+(BOOL)isTokenExpired:(NSDictionary*)dic;

@end

NS_ASSUME_NONNULL_END
