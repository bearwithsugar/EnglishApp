//
//  WechatLog.h
//  EnglishDemo
//
//  Created by 马一轩 on 2020/1/23.
//  Copyright © 2020 马一轩. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WechatLog : NSObject

@property(nonatomic,copy) NSString* type;

+(WechatLog *) getInstance;

-(void)WXLoginAgent:(NSString*)code;

@end

NS_ASSUME_NONNULL_END
