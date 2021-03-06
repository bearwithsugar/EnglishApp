//
//  WarningWindow.m
//  EnglishDemo
//
//  Created by 马一轩 on 2019/1/22.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import "WarningWindow.h"
#import "../LoginAndRegisterViewController/LoginViewController.h"
#import "JumpToSomeView.h"
#import "ConnectionFunction.h"

@interface WarningWindow(){
    
}
@end

@implementation WarningWindow


//跳转到登录界面的警告 选项为跳转和取消
+(UIAlertController*)transToLoginWithCancel:(NSString*)message Navigation:(UINavigationController*)navigation{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示信息" message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"去登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [JumpToSomeView pushToLoginView:navigation];
        
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:action1];
    [alert addAction:action2];
    
    return alert;
}

//跳转到登录界面的警告,选项只有跳转
+(UIAlertController*)transToLogin:(NSString*)message Navigation:(UINavigationController*)navigation{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示信息" message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"去登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [JumpToSomeView pushToLoginView:navigation];
        
    }];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:action1];
    [alert addAction:action2];
    
    return alert;
}

//仅仅提供提示，没有跳转
+(UIAlertController*)MsgWithoutTrans:(NSString*)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示信息" message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:action1];
    
    return alert;
}

//退出程序
+(UIAlertController*)ExitAPP:(NSString*)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示信息" message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"退出App,检查网络！" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        exit(0);
        
    }];
    
    [alert addAction:action1];
    
    return alert;
}

//执行代码块
+(UIAlertController*)MsgWithBlock:(NSString*)title Block:(JobBlock)block{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示信息" message:title
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        block();
        
    }];
    
    [alert addAction:action1];
    
    return alert;
}

//执行代码块
+(UIAlertController*)MsgWithBlock2:(NSString*)title Msg:(NSString*)message1 Block1:(JobBlock)block1 Msg2:(NSString*)message2 Block2:(JobBlock)block2{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示信息" message:title
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:message1 style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        block1();
        
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:message2 style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        block2();
    }];
    
    [alert addAction:action1];
    [alert addAction:action2];
    
    return alert;
}

@end
