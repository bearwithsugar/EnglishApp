//
//  AgentFunction.m
//  EnglishDemo
//
//  Created by 马一轩 on 2019/1/23.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import "AgentFunction.h"
#import "../WeChatSDK/WeChatSDK1.8.3/WXApi.h"
#import "../WeChatSDK/WeChatSDK1.8.3/WXApiObject.h"
#import "WarningWindow.h"



@implementation AgentFunction

//根据输入价格获取学分
+(NSMutableDictionary*)getScore:(int)price{
    NSMutableDictionary* scoreDic=[[NSMutableDictionary alloc]init];
    [scoreDic removeAllObjects];
    if (price<5) {
        [scoreDic setValue:[NSString stringWithFormat:@"%d",price*100] forKey:@"score"];
        [scoreDic setValue:[NSString stringWithFormat:@"%d",1] forKey:@"strategy"];
    }else if(price<10&&price>=5){
        [scoreDic setValue:[NSString stringWithFormat:@"%d",price*120] forKey:@"score"];
        [scoreDic setValue:[NSString stringWithFormat:@"%d",1] forKey:@"strategy"];
    }else if(price<20&&price>=10){
        [scoreDic setValue:[NSString stringWithFormat:@"%d",price*140] forKey:@"score"];
        [scoreDic setValue:[NSString stringWithFormat:@"%d",1] forKey:@"strategy"];
    }else{
        [scoreDic setValue:[NSString stringWithFormat:@"%d",price*160] forKey:@"score"];
        [scoreDic setValue:[NSString stringWithFormat:@"%d",1] forKey:@"strategy"];
    }
     return scoreDic;
}

//微信分享
+(void)WXshare{
    NSString *kLinkURL = @"https://a.app.qq.com/o/simple.jsp?pkgname=com.suuben.xxenglish";
    NSString *kLinkTitle = @"小学英语辅导神器";
    NSString *kLinkDescription = @"还在为学好英语而苦恼，还在为辅导孩子而爆炸?学伴英语帮您解决困惑，伴随孩子成长！本应用整合了当前小学英语各个版本教材，与教材同步的朗读与联系。";
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc]init];
    // 是否是文档
    req.bText =  NO;
    // 好友列表
    req.scene = WXSceneSession;
    //创建分享内容对象
    WXMediaMessage *urlMsg = [WXMediaMessage message];
    urlMsg.title = kLinkTitle;//分享标题
    urlMsg.description = kLinkDescription;//分享描述
    [urlMsg setThumbImage:[UIImage imageNamed:@"test"]];//分享图片,使用SDK的setThumbImage方法可压缩图片大小
    //创建多媒体对象
    WXWebpageObject *obj = [WXWebpageObject object];
    obj.webpageUrl = kLinkURL;//分享链接
    //完成发送对象实例
    urlMsg.mediaObject = obj;
    req.message = urlMsg;
    //发送分享信息
    [WXApi sendReq:req];
}

//获取到当前所在的视图
+ (UIViewController *)theTopviewControler{
    UIViewController *rootVC = [[UIApplication sharedApplication].delegate window].rootViewController;
    
    UIViewController *parent = rootVC;
    
    while ((parent = rootVC.presentedViewController) != nil ) {
        rootVC = parent;
    }
    
    while ([rootVC isKindOfClass:[UINavigationController class]]) {
        rootVC = [(UINavigationController *)rootVC topViewController];
    }
    
    return rootVC;
}
//如果token过期显示提示框
+(BOOL)isTokenExpired:(NSDictionary*)dic {
    if ([[dic valueForKey:@"message"]isEqualToString:@"token认证失败"]) {
        //提示框
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[self theTopviewControler]
             presentViewController:
             [WarningWindow transToLogin:@"您的账号在别处登录，请重新登录！"
                              Navigation:[self theTopviewControler].navigationController]
             animated:YES
             completion:nil];
        });
       
       return true;
    }
    else{
        return false;
    }
}
@end
