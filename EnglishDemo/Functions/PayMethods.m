//
//  Alipay.m
//  EnglishDemo
//
//  Created by 马一轩 on 2019/1/19.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import "PayMethods.h"
#import <AlipaySDK/AlipaySDK.h>
#import "../WeChatSDK/WeChatSDK1.8.3/WXApiObject.h"
#import "../WeChatSDK/WeChatSDK1.8.3/WXApi.h"

@implementation PayMethods
+(void)toAlipay:(NSString*)order{
    //应用注册scheme,在AliSDKDemo-Info.plist定义URL types
    NSString *appScheme = @"xuebanEnglish";
    // NOTE: 将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = order;
    
    // NOTE: 调用支付结果开始支付
    [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
        NSLog(@"result = %@",resultDic);
    }];
}
+(void)toWXpay:(NSString*)appId
     PartnerId:(NSString*)partnerId
      PrepayId:(NSString*)prepayId
       Package:(NSString*)package
      NonceStr:(NSString*)nonceStr
     TimeStamp:(unsigned int)timeStamp
          Sign:(NSString*)sign{
    
    [WXApi registerApp:appId];
    
    PayReq *req = [[PayReq alloc] init];
    req.partnerId=partnerId;
    req.prepayId=prepayId;
    req.package=package;
    req.nonceStr=nonceStr;
    req.timeStamp=timeStamp;
    req.sign=sign;
    
    if ([WXApi isWXAppInstalled]==YES) {
        NSLog(@"安装了微信");
        [WXApi sendReq:req];
    }else{
        NSLog(@"未安装微信");
    }
}

@end
