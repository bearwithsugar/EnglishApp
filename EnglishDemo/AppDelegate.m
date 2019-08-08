//
//  AppDelegate.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/11.
//  Copyright © 2018年 马一轩. All rights reserved.
//

#import "AppDelegate.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WeChatSDK/WeChatSDK1.8.3/WXApi.h"
#import "Functions/FixValues.h"
#import "Functions/ConnectionFunction.h"
#import "Functions/WarningWindow.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <AVFoundation/AVFoundation.h>



@interface AppDelegate ()<UIApplicationDelegate,WXApiDelegate>{
   
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
    [NSThread sleepForTimeInterval:3.0];
    [WXApi registerApp:[FixValues getAppId]];
    
    //测试真机是否可以正常播放音频，如果可以，就删掉下面这句话
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options{
    [WXApi handleOpenURL:url delegate:self];
    
    [TencentOAuth HandleOpenURL:url];
    
    [QQApiInterface handleOpenURL:url delegate:(id<QQApiInterfaceDelegate>)self];
    
    return YES;
}

-(void) onResp:(BaseResp*)resp{
    /*
     enum  WXErrCode {
     WXSuccess           = 0,    成功
     WXErrCodeCommon     = -1,  普通错误类型
     WXErrCodeUserCancel = -2,    用户点击取消并返回
     WXErrCodeSentFail   = -3,   发送失败
     WXErrCodeAuthDeny   = -4,    授权失败
     WXErrCodeUnsupport  = -5,   微信不支持
     };
     */
    if ([resp isKindOfClass:[SendAuthResp class]]) {   //授权登录的类。
        if (resp.errCode == 0) {  //成功。
            SendAuthResp *resp2 = (SendAuthResp *)resp;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"wxLogin" object:resp2.code];
            NSLog(@"授权的信息%@",resp2.code);
            [ConnectionFunction WXLoginAgent:resp2.code];
            
        }else{ //失败
            //            SHOWHUDERR(@"授权失败");
            NSLog(@"授权失败");
            [WarningWindow MsgWithoutTrans:@"授权失败"];
        }
    }
}

@end
