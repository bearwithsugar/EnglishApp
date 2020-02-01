//
//  WechatLog.m
//  EnglishDemo
//
//  Created by 马一轩 on 2020/1/23.
//  Copyright © 2020 马一轩. All rights reserved.
//

#import "WechatLog.h"
#import "DocuOperate.h"
#import "FixValues.h"
#import "AgentFunction.h"
#import "netOperate/NetSenderFunction.h"
#import "MyThreadPool.h"
#import "DataFilter.h"
#import "WarningWindow.h"

@implementation WechatLog

static WechatLog* instance = nil;

+(WechatLog *) getInstance{
    if (instance == nil) {
        instance = [[WechatLog alloc] init];//调用自己改写的”私有构造函数“
    }
    return instance;
}

//微信登录代理方法
-(void)WXLoginAgent:(NSString*)code{
    NetSenderFunction* sender1 = [[NetSenderFunction alloc]init];
    NetSenderFunction* sender2 = [[NetSenderFunction alloc]init];
    ConBlock blk1 = ^(NSDictionary* accessDic){
        NSString* access_token=[accessDic valueForKey:@"access_token"];
        NSString* openid=[accessDic valueForKey:@"openid"];
        ConBlock blk2 = ^(NSDictionary* userMsg){
            if([self->_type isEqualToString:@"FORLOG"]){
                [self WXtoLogin:userMsg];
            }else if([self->_type isEqualToString:@"FORBINDING"]){
                [self WXtoBinding:userMsg];
            }
        };
        [sender2 getRequest:[[ConnectionFunction getInstance]getWXuserMsg_Get:access_token Openid:openid] Block:blk2];
    };
    [sender1 getRequest:[[ConnectionFunction getInstance]getWXaccess_Get:code] Block:blk1];
}
//微信登录
-(void)WXtoLogin:(NSDictionary*)userMsg{
    ConBlock blk1 = ^(NSDictionary* wxLogDic){
         dispatch_async(dispatch_get_main_queue(), ^{
            if ([[wxLogDic valueForKey:@"message"]isEqualToString:@"success"]) {
                //dictionary：过滤字典中空值
                if ([DocuOperate writeIntoPlist:@"userInfo.plist" dictionary:[DataFilter DictionaryFilter:[wxLogDic valueForKey:@"data"]]]) {
                    [[FixValues navigationViewController] popViewControllerAnimated:true];
                }else{
                    [[AgentFunction theTopviewControler] presentViewController:[WarningWindow MsgWithoutTrans:@"登录信息保存失败"] animated:YES completion:nil];
                    
                }
            }else if([[wxLogDic valueForKey:@"message"]isEqualToString:@"该账号绑定设备已达上限，请先用已绑定设备登录，解绑后再重新尝试。"]){
                [[AgentFunction theTopviewControler] presentViewController:[WarningWindow  MsgWithoutTrans:[wxLogDic valueForKey:@"message"]] animated:YES completion:nil];
            }else{
                VoidBlock myBlock = ^{
                   [MyThreadPool executeJob:^{
                        NetSenderFunction* sender = [[NetSenderFunction alloc]init];
                        [sender postRequest:[[ConnectionFunction getInstance]userOccupation_Post:[userMsg valueForKey:@"openid"] Type:@"other" Other_type:@"WEIXIN"] Block:^(NSDictionary* dic){}];
                    } Main:^{}];
                    [self WXtoLogin:userMsg];
                };
                
                [[AgentFunction theTopviewControler]
                 presentViewController:[WarningWindow MsgWithBlock2:@"强制登录" Block1:myBlock Msg:@"取消" Block2:^{}]
                 animated:YES completion:nil];
            }
         });
    };
    NetSenderFunction* sender = [[NetSenderFunction alloc]init];
    [sender postRequest:[[ConnectionFunction getInstance]OtherLogin_Post:[userMsg valueForKey:@"openid"]
                                                                Nickname:[userMsg valueForKey:@"nickname"]
                                                                DeviceId:[FixValues getUniqueId]
                                                              DeviceName:[[UIDevice currentDevice] name]
                                                                    Type:@"WEIXIN"
                                                                     Pic:[userMsg valueForKey:@"headimgurl"]]
                  Block:blk1];
}

-(void)WXtoBinding:(NSDictionary*)userMsg{
    ConBlock jobblock = ^(NSDictionary* resultDic){
        if ([resultDic valueForKey:@"code"] && [[resultDic valueForKey:@"code"]intValue]==200) {
            self->_myBlock();
        }else{
            [[AgentFunction theTopviewControler]presentViewController:
             [WarningWindow MsgWithoutTrans:[resultDic valueForKey:@"message"]]
                                                             animated:YES
                                                           completion:nil];
        }
    };
    NetSenderFunction* sender = [[NetSenderFunction alloc]init];
    [sender postRequestWithHead:[[ConnectionFunction getInstance]toBinding_Post_H:[userMsg valueForKey:@"openid"] Type:@"WEIXIN" Picurl:[userMsg valueForKey:@"headimgurl"]]
                           Head:_userKey
                          Block:jobblock];
}



@end
