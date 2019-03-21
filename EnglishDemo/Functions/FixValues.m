//
//  FixValues.m
//  EnglishDemo
//
//  Created by 马一轩 on 2019/1/22.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import "FixValues.h"

@implementation FixValues

//接口路径
+(NSURL*)getUrl{
    return [NSURL URLWithString:@"http://www.suuben.com/english/api"];
}

//微信获取token路径
+(NSURL*)getWXaccessUrl{
    return [NSURL URLWithString:@"https://api.weixin.qq.com/sns/oauth2/access_token"];
}

//微信获取用户信息的路径
+(NSURL*)getWXuserMsgUrl{
    return [NSURL URLWithString:@"https://api.weixin.qq.com/sns/userinfo"];
}

//微信端appid
+(NSString*)getAppId{
    return @"wx792dd85564113966";
}

//微信端secret
+(NSString*)getAppSecret{
    return @"c24f77fbf422708d32e113f6c101549a";
}

//获取当前活动的navigationViewController
+ (UINavigationController *)navigationViewController {
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    if ([window.rootViewController isKindOfClass:[UINavigationController class]]) {
        
        return (UINavigationController *)window.rootViewController;
        
    } else if ([window.rootViewController isKindOfClass:[UITabBarController class]]) {
        
        UIViewController *selectVc = [((UITabBarController *)window.rootViewController)selectedViewController];
        
        if ([selectVc isKindOfClass:[UINavigationController class]]) {
            
            return (UINavigationController *)selectVc;
            
        }
        
    }
    
    return nil;
    
}

@end
