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
    NSDictionary* accessDic=[ConnectionFunction getWXaccess:code];
    NSString* access_token=[accessDic valueForKey:@"access_token"];
    NSString* openid=[accessDic valueForKey:@"openid"];
    NSDictionary* userMsg=[ConnectionFunction getWXuserMsg:access_token Openid:openid];
    if([_type isEqualToString:@"FORLOG"]){
        [self WXtoLogin:userMsg];
    }else if([_type isEqualToString:@"FORBINDING"]){
        [self WXtoBinding:userMsg];
    }
}
//微信登录
-(void)WXtoLogin:(NSDictionary*)userMsg{
    NSDictionary* wxLogDic=[ConnectionFunction OtherLogin:[userMsg valueForKey:@"openid"]
                                   Nickname:[userMsg valueForKey:@"nickname"]
                                   DeviceId:[FixValues getUniqueId]
                                 DeviceName:[[UIDevice currentDevice] name]
                                       Type:@"WEIXIN"
                                        Pic:[userMsg valueForKey:@"headimgurl"]];
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
            [ConnectionFunction userOccupation:[userMsg valueForKey:@"openid"] Type:@"other" Other_type:@"WEIXIN"];
            [self WXtoLogin:userMsg];
        };
        
        [[AgentFunction theTopviewControler]
         presentViewController:[WarningWindow MsgWithBlock2:@"强制登录" Block1:myBlock Msg:@"取消" Block2:^{}]
         animated:YES completion:nil];
    }
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
    [ConnectionFunction toBinding:_userKey OpenId:[userMsg valueForKey:@"openid"] Type:@"WEIXIN" Picurl:[userMsg valueForKey:@"headimgurl"] Block:jobblock];
}



@end
