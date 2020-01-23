//
//  QQLogin.h
//  EnglishDemo
//
//  Created by 马一轩 on 2019/1/24.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import <Foundation/Foundation.h>



NS_ASSUME_NONNULL_BEGIN

@interface QQLogin : NSObject

@property(nonatomic,copy)NSString* type;

-(id)initWithtype:(NSString*)type;

//qq登录启动
-(void)toQQlogin;

//qq分享
-(void)qqshare;

@end

NS_ASSUME_NONNULL_END
