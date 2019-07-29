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
//static NSMutableArray *alertArray;
//
//+ (void)initialize
//{
//    alertArray = [[NSMutableArray alloc]init];
//}

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
    
    [alert addAction:action1];
    
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
        //assert(0);
        
//        [UIView animateWithDuration:1.0f animations:^{
//
//            window.alpha = 0;
//
//            window.frame = CGRectMake(0, window.bounds.size.width, 0, 0);
//
//        } completion:^(BOOL finished) {
//
//            exit(0);
//
//        }];
        exit(0);
        
    }];
    
    [alert addAction:action1];
    
    return alert;
}



@end
