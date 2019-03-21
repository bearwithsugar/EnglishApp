//
//  Alipay.h
//  EnglishDemo
//
//  Created by 马一轩 on 2019/1/19.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PayMethods : NSObject
+(void)toAlipay:(NSString*)order;
+(void)toWXpay:(NSString*)appId
     PartnerId:(NSString*)partnerId
      PrepayId:(NSString*)prepayId
       Package:(NSString*)package
      NonceStr:(NSString*)nonceStr
     TimeStamp:(unsigned int)timeStamp
          Sign:(NSString*)sign;

@end

NS_ASSUME_NONNULL_END
