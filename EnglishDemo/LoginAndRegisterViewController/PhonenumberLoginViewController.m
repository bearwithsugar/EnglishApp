//
//  phonenumberLoginViewController.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/14.
//  Copyright © 2018年 马一轩. All rights reserved.
//

#import "PhonenumberLoginViewController.h"
#import "../Functions/ConnectionFunction.h"
#import "../Common/HeadView.h"

@interface PhonenumberLoginViewController (){
    UITextField* passwordTextField;
    UITextField* usernameTextField;
    NSDictionary* dataDic;
}

@end

@implementation PhonenumberLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    [self titleShow];
    [self inputArea];
    [self someButoon];
}
-(void)titleShow{
    
    [self.view addSubview:[HeadView titleShow:@"用户登录" Color:ssRGBHex(0xFF7474) Located:CGRectMake(0, 22.06, 414, 66.2) UINavigationController:self.navigationController]];
}
-(void)inputArea{
    UILabel* usernameLabel=[[UILabel alloc]initWithFrame:CGRectMake(66.23, 177.65, 61.82, 22.06)];
    usernameLabel.text=@"手机号：";
    usernameLabel.textColor=ssRGBHex(0xFF7474);
    usernameLabel.font=[UIFont systemFontOfSize:14];
    [self.view addSubview:usernameLabel];
    
    UILabel* passwordLabel=[[UILabel alloc]initWithFrame:CGRectMake(66.23, 222.89, 61.82, 22.06)];
    passwordLabel.text=@"验证码：";
    passwordLabel.textColor=ssRGBHex(0xFF7474);
    passwordLabel.font=[UIFont systemFontOfSize:14];
    [self.view addSubview:passwordLabel];
    
    usernameTextField=[[UITextField alloc]initWithFrame:CGRectMake(128.06, 166.62, 200, 25)];
    usernameTextField.placeholder=@"请输入手机号码";
    usernameTextField.text=@"13142220635";
    [usernameTextField setValue:[UIFont boldSystemFontOfSize:12] forKeyPath:@"_placeholderLabel.font"];
    [self.view addSubview:usernameTextField];
    
    passwordTextField=[[UITextField alloc]initWithFrame:CGRectMake(128.06, 219.58, 200, 25)];
    passwordTextField.placeholder=@"请输入验证码";
    passwordTextField.text=@"1111";
    [passwordTextField setValue:[UIFont boldSystemFontOfSize:12] forKeyPath:@"_placeholderLabel.font"];
    [self.view addSubview:passwordTextField];
    
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
    UIButton* getYzmBtn=[[UIButton alloc]initWithFrame:CGRectMake(58.51, 532.96, 298.08, 46.34)];
    getYzmBtn.layer.cornerRadius=25;
    getYzmBtn.layer.borderColor=ssRGBHex(0xFF7474).CGColor;
    getYzmBtn.layer.borderWidth=1;
    [getYzmBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    getYzmBtn.titleLabel.font=[UIFont systemFontOfSize:14];
    [getYzmBtn addTarget:self action:@selector(getYzm) forControlEvents:UIControlEventTouchUpInside];
    [getYzmBtn setTitleColor:ssRGBHex(0xFF7474) forState:UIControlStateNormal];
    [self.view addSubview:getYzmBtn];
    
    UIButton* loginBtn=[[UIButton alloc]initWithFrame:CGRectMake(58.51, 601.37, 298.08, 46.34)];
    loginBtn.layer.cornerRadius=25;
    loginBtn.backgroundColor=ssRGBHex(0xFF7474);
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    loginBtn.titleLabel.font=[UIFont systemFontOfSize:14];
    [loginBtn addTarget:self action:@selector(toLogin) forControlEvents:UIControlEventTouchUpInside];
    [loginBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [self.view addSubview:loginBtn];
}

-(void)getYzm{
    if ([self verifyMobile:usernameTextField.text]) {
        [ConnectionFunction getYzm:[usernameTextField.text longLongValue]];
        [self warnMsg:@"验证码已发送，60秒内有效！"];
    }else{
        NSLog(@"手机号不合法!");
    }
}
-(void)toLogin{
    NSLog(@"验证码打印：%d",[passwordTextField.text intValue]);
    dataDic=[ConnectionFunction login_yzm:[usernameTextField.text longLongValue] yzm:passwordTextField.text];
    if ([[dataDic valueForKey:@"message"]isEqualToString:@"success"]) {
        [self warnMsg:@"登录成功"];
    }else{
        [self warnMsg:[dataDic valueForKey:@"message"]];
    }
}
//验证电话号码格式
-(BOOL)verifyMobile:(NSString *)mobilePhone{
    NSString *express = @"^0{0,1}(13[0-9]|15[0-9]|18[0-9]|14[0-9])[0-9]{8}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF matches %@", express];
    BOOL boo = [pred evaluateWithObject:mobilePhone];
    return boo;
    
}
-(void)warnMsg:(NSString*)msg{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示信息" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:action1];
    [self presentViewController:alert animated:YES completion:nil];
}

//点击背景收起键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES]; //实现该方法是需要注意view需要是继承UIControl而来的
}

-(void)popBack{
    [self.navigationController popViewControllerAnimated:true];
}

@end
