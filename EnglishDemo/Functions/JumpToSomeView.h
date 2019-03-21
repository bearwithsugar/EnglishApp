//
//  JumpToSomeView.h
//  EnglishDemo
//
//  Created by 马一轩 on 2019/1/22.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JumpToSomeView : NSObject

//跳转到登录页面
+(void)pushToLoginView:(UINavigationController*)navigationController;

@end

NS_ASSUME_NONNULL_END
