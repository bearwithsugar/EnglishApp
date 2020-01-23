//
//  QQLogin.m
//  EnglishDemo
//
//  Created by 马一轩 on 2019/1/24.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import "QQLogin.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "../Functions/ConnectionFunction.h"
#import "../Functions/DocuOperate.h"
#import "../Functions/DataFilter.h"
#import "../Functions/WarningWindow.h"
#import "../Functions/FixValues.h"
#import "../Functions/AgentFunction.h"

@interface QQLogin ()<UIApplicationDelegate,TencentSessionDelegate>{
    NSDictionary* userMsg;
}
@property (nonatomic, strong) TencentOAuth *tencentOAuth;
@end

@implementation QQLogin

-(id)initWithtype:(NSString*)type{
    if (self == [super init]) {
        _type = type;
    }
    return self;
}

//qq登录启动
-(void)toQQlogin{
    NSArray* permissions = [self getPermissions];
    //授权列表数组 根据实际需要添加
    _tencentOAuth = [[TencentOAuth alloc]initWithAppId:@"101537865" andDelegate:self];
    _tencentOAuth.redirectURI = @"";
    _tencentOAuth.authShareType = AuthShareType_QQ;
    [_tencentOAuth authorize:permissions inSafari:NO];
}

//========================================================
-(void)getUserInfoResponse:(APIResponse *)response
{
    NSLog(@"respons:%@",response.jsonResponse);
    userMsg=[[NSDictionary alloc]initWithDictionary:response.jsonResponse];
    NSLog(@"userMsg的内容是%@",userMsg);
    if ([_type isEqualToString:@"FORLOGIN"]) {
        [self qqLoginReturnMsg];
    }else if([_type isEqualToString:@"FORBAND"]){
        [self qqLoginReturnMsgforBand];
    }
}
-(void)qqLoginReturnMsg{
    NSDictionary* qqLoginDic=[ConnectionFunction OtherLogin:_tencentOAuth.openId
                                                   Nickname:[userMsg valueForKey:@"nickname"]
                                                   DeviceId:[FixValues getUniqueId]
                                                 DeviceName:[[UIDevice currentDevice] name]
                                                       Type:@"QQ"
                                                        Pic:[userMsg valueForKey:@"figureurl_2"]];
    if ([[qqLoginDic valueForKey:@"message"]isEqualToString:@"success"]) {
       
        if ([DocuOperate writeIntoPlist:@"userInfo.plist" dictionary:[DataFilter DictionaryFilter:[qqLoginDic valueForKey:@"data"]]]) {
            [[FixValues navigationViewController] popViewControllerAnimated:true];
        }else{
            [[AgentFunction theTopviewControler]
             presentViewController:[WarningWindow MsgWithoutTrans:@"登录信息保存失败"] animated:YES completion:nil];
        }
    }else if([[qqLoginDic valueForKey:@"code"]intValue] == 400){
         [[AgentFunction theTopviewControler]
                presentViewController:[self forceLogin:[qqLoginDic valueForKey:@"message"]
                                                Openid:[userMsg valueForKey:@"openid"]
                                                  Type:@"other"
                                               UserMsg:userMsg] animated:YES completion:nil];
    }else{
        [[AgentFunction theTopviewControler]
         presentViewController:[self forceLogin:[qqLoginDic valueForKey:@"message"]
                                         Openid:[userMsg valueForKey:@"openid"]
                                           Type:@"other"
                                        UserMsg:userMsg] animated:YES completion:nil];
    }
}
-(void)qqLoginReturnMsgforBand{
    
}
//强制登录专用提示框
-(UIAlertController*)forceLogin:(NSString*)message Openid:(NSString*)openid Type:(NSString*)type UserMsg:(NSDictionary*)usermsg{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示信息" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"强制登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ConnectionFunction userOccupation:self->_tencentOAuth.openId Type:type Other_type:@"QQ"];
        [self qqLoginReturnMsg];
        
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [action2 setValue:[UIColor redColor] forKey:@"titleTextColor"];
    [alert addAction:action1];
    [alert addAction:action2];
    
    return alert;
}

//========================================================

//授权列表数组 根据实际需要添加
- (NSMutableArray*)getPermissions
{
    NSMutableArray * g_permissions = [[NSMutableArray alloc]initWithObjects:kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,nil];
    return g_permissions;
    
}


- (void)tencentDidLogin {
    [_tencentOAuth getUserInfo];
    
    if (_tencentOAuth.accessToken && 0 != [_tencentOAuth.accessToken length]) {
        // 记录登录用户的OpenID、Token以及过期时间
    } else {
        NSLog(@"登录不成功 没有获取accesstoken");
    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
    if (cancelled) {
        NSLog(@"用户取消登录");
    } else {
        NSLog(@"登录失败");
    }
}

- (void)tencentDidNotNetWork {
     NSLog(@"无网络连接，请设置网络");
}
//qq分享
-(void)qqshare{
    _tencentOAuth = [[TencentOAuth alloc]initWithAppId:@"101537865" andDelegate:self];
    
    
    NSString *utf8String = @"https://a.app.qq.com/o/simple.jsp?pkgname=com.suuben.xxenglish";
    
    NSString *title = @"小学英语辅导神器";
    NSString *description = @"还在为学号英语而苦恼，还在为辅导孩子而爆炸?学伴英语帮您解决困惑，伴随孩子成长！本应用整合了当前小学英语各个版本教材，与教材同步的朗读与联系。";
    NSString *previewImageUrl = @"/test";
    QQApiNewsObject *newsObj = [QQApiNewsObject
                                objectWithURL:[NSURL URLWithString:utf8String]
                                title:title
                                description:description
                                previewImageURL:[NSURL URLWithString:previewImageUrl]];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
    //将内容分享到qq
    [QQApiInterface sendReq:req];
    //将内容分享到qzone
    // QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
}

//处理来至QQ的响应
- (void)onResp:(QQBaseResp *)resp{
    NSLog(@" qq返回----resp %@",resp);
}


@end
