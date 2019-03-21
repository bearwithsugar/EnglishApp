//
//  WarningWindow.h
//  EnglishDemo
//
//  Created by 马一轩 on 2019/1/22.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WarningWindow : NSObject

//跳转到登录界面的警告 选项为跳转和取消
+(UIAlertController*)transToLoginWithCancel:(NSString*)message Navigation:(UINavigationController*)navigation;

//跳转到登录界面的警告,选项只有跳转
+(UIAlertController*)transToLogin:(NSString*)message Navigation:(UINavigationController*)navigation;

//仅仅提供提示，没有跳转
+(UIAlertController*)MsgWithoutTrans:(NSString*)messagel;


@end

NS_ASSUME_NONNULL_END
