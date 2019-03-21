//
//  FixValues.h
//  EnglishDemo
//
//  Created by 马一轩 on 2019/1/22.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FixValues : NSObject

//接口路径
+(NSURL*)getUrl;

//微信获取token路径
+(NSURL*)getWXaccessUrl;

//微信获取openid路径
+(NSURL*)getWXuserMsgUrl;

//微信端appid
+(NSString*)getAppId;

//微信端secret
+(NSString*)getAppSecret;

//获取当前活动的navigationViewController
+ (UINavigationController *)navigationViewController;

@end

NS_ASSUME_NONNULL_END
