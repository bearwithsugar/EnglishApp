//
//  ResetPassViewController.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/14.
//  Copyright © 2018年 马一轩. All rights reserved.
//

#import "ResetPassViewController.h"
#import "../Functions/ConnectionFunction.h"
#import "../Common/HeadView.h"

@interface ResetPassViewController (){
    UITextField* passwordTextField;
    UITextField* passwordDefineTextField;
}

@end

@implementation ResetPassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    [self titleShow];
    [self inputArea];
    [self someButoon];
}
-(void)titleShow{
    [HeadView titleShow:@"输入密码" Color:ssRGBHex(0xFF7474) UIView:self.view UINavigationController:self.navigationController];
}
-(void)inputArea{
    UILabel* usernameLabel=[[UILabel alloc]initWithFrame:CGRectMake(47.47, 165.51, 80.59, 22.06)];
    usernameLabel.text=@"输入密码：";
    usernameLabel.textColor=ssRGBHex(0xFF7474);
    usernameLabel.font=[UIFont systemFontOfSize:14];
    [self.view addSubview:usernameLabel];
    
    UILabel* passwordLabel=[[UILabel alloc]initWithFrame:CGRectMake(47.47, 222.89, 80.59, 22.06)];
    passwordLabel.text=@"确认密码：";
    passwordLabel.textColor=ssRGBHex(0xFF7474);
    passwordLabel.font=[UIFont systemFontOfSize:14];
    [self.view addSubview:passwordLabel];
    
    passwordTextField=[[UITextField alloc]initWithFrame:CGRectMake(128.06, 166.62, 200, 25)];
    passwordTextField.placeholder=@"请输入新密码";
    passwordTextField.secureTextEntry = YES;
    [passwordTextField setValue:[UIFont boldSystemFontOfSize:12] forKeyPath:@"_placeholderLabel.font"];
    [self.view addSubview:passwordTextField];
    
    passwordDefineTextField=[[UITextField alloc]initWithFrame:CGRectMake(128.06, 219.58, 200, 25)];
    passwordDefineTextField.placeholder=@"请确认密码";
    passwordDefineTextField.secureTextEntry = YES;
    [passwordDefineTextField setValue:[UIFont boldSystemFontOfSize:12] forKeyPath:@"_placeholderLabel.font"];
    [self.view addSubview:passwordDefineTextField];
    
    UIView* lineView=[[UIView alloc]initWithFrame:CGRectMake(128.06, 192, 223, 1)];
    lineView.layer.borderWidth=1;
    lineView.layer.borderColor=ssRGBHex(0xFF7474).CGColor;
    [self.view addSubview:lineView];
    
    UIView* lineView2=[[UIView alloc]initWithFrame:CGRectMake(128.06, 244.96, 223, 1)];
    lineView2.layer.borderWidth=1;
    lineView2.layer.borderColor=ssRGBHex(0xFF7474).CGColor;
    [self.view addSubview:lineView2];
    
    
}
-(void)someButoon{
    UIButton* defineBtn=[[UIButton alloc]initWithFrame:CGRectMake(58.51, 601.37, 298.08, 46.34)];
    defineBtn.layer.cornerRadius=25;
    defineBtn.backgroundColor=ssRGBHex(0xFF7474);
    [defineBtn setTitle:@"确认" forState:UIControlStateNormal];
    defineBtn.titleLabel.font=[UIFont systemFontOfSize:14];
    [defineBtn addTarget:self action:@selector(toResetPass) forControlEvents:UIControlEventTouchUpInside];
    [defineBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [self.view addSubview:defineBtn];
}

-(void)toResetPass{
    if ([passwordTextField.text isEqualToString:passwordDefineTextField.text]) {
        NSDictionary* dic= [ConnectionFunction resetPass:[_phoneNumber longLongValue] Pass:passwordTextField.text];
        NSLog(@"注册结果是：%@",[dic valueForKey:@"message"]);
        [self warnMsg:[dic valueForKey:@"message"]];
    }else{
        [self warnMsg:@"两次密码不一样！"];
    }
    
}

-(void)warnMsg:(NSString*)msg{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示信息" message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:action1];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)popBack{
    [self.navigationController popViewControllerAnimated:true];
}


@end
