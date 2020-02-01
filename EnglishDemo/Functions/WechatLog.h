//
//  WechatLog.h
//  EnglishDemo
//
//  Created by 马一轩 on 2020/1/23.
//  Copyright © 2020 马一轩. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "netOperate/ConnectionFunction.h"

NS_ASSUME_NONNULL_BEGIN

@interface WechatLog : NSObject


@property VoidBlock myBlock;
@property(nonatomic,copy) NSString* type;
@property(nonatomic,copy) NSString* userKey;

+(WechatLog *) getInstance;

-(void)WXLoginAgent:(NSString*)code;

@end

NS_ASSUME_NONNULL_END
