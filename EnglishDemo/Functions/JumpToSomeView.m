//
//  JumpToSomeView.m
//  EnglishDemo
//
//  Created by 马一轩 on 2019/1/22.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import "JumpToSomeView.h"
#import "../LoginAndRegisterViewController/LoginViewController.h"

@interface JumpToSomeView(){
    
}
@end

@implementation JumpToSomeView
  LoginViewController *loginView;

//跳转到登录页面
+(void)pushToLoginView:(UINavigationController*)navigationController{
    if (loginView==nil) {
        loginView = [[LoginViewController alloc]init];
    }
    [navigationController pushViewController:loginView animated:true];
}


@end
