//
//  LoginViewController.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/13.
//  Copyright © 2018年 马一轩. All rights reserved.
//

#import "LoginViewController.h"
#import "PhonenumberLoginViewController.h"
#import "RegisterViewController.h"
#import "ForgetPassViewController.h"
#import "../Functions/ConnectionFunction.h"
#import "../AppDelegate.h"
#import "../Functions/DocuOperate.h"
#import "../Functions/DataFilter.h"
#import "../../WeChatSDK1.8.3/WXApi.h"
#import "../Functions/QQLogin.h"
#import "../Functions/WarningWindow.h"
#import "../Common/HeadView.h"

@interface LoginViewController (){

    PhonenumberLoginViewController* phonenumberLogin;
    RegisterViewController* registerView;
    ForgetPassViewController* forgetPass;
    
    UITextField* usernameTextField;
    UITextField* passwordTextField;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    [self titleShow];
    [self inputArea];
    [self someButoon];
    [self devideLine];
    [self otherLogin];
}
-(void)titleShow{
    [self.view addSubview:[HeadView titleShow:@"用户登录" Color:ssRGBHex(0xFF7474) Located:CGRectMake(0, 22.06, 414, 66.2) UINavigationController:self.navigationController]];
}
-(void)inputArea{
    UILabel* usernameLabel=[[UILabel alloc]initWithFrame:CGRectMake(66.23, 126.89, 49.68, 22.06)];
    usernameLabel.text=@"账号：";
    usernameLabel.textColor=ssRGBHex(0xFF7474);
    usernameLabel.font=[UIFont systemFontOfSize:14];
    [self.view addSubview:usernameLabel];
    
    UILabel* passwordLabel=[[UILabel alloc]initWithFrame:CGRectMake(66.23, 179.86, 49.68, 22.06)];
    passwordLabel.text=@"密码：";
    passwordLabel.textColor=ssRGBHex(0xFF7474);
    passwordLabel.font=[UIFont systemFontOfSize:14];
    [self.view addSubview:passwordLabel];
    
    usernameTextField=[[UITextField alloc]initWithFrame:CGRectMake(115.91, 126.89, 200, 25)];
    usernameTextField.placeholder=@"请输入手机号码";
    usernameTextField.text=@"18273120195";
    [usernameTextField setValue:[UIFont boldSystemFontOfSize:12] forKeyPath:@"_placeholderLabel.font"];
    [self.view addSubview:usernameTextField];
    
    passwordTextField=[[UITextField alloc]initWithFrame:CGRectMake(115.91, 179.86, 200, 25)];
    passwordTextField.placeholder=@"请输入登录密码";
    passwordTextField.text=@"cheng";
    [passwordTextField setValue:[UIFont boldSystemFontOfSize:12] forKeyPath:@"_placeholderLabel.font"];
    passwordTextField.secureTextEntry = YES;
    [self.view addSubview:passwordTextField];
    
    UIView* lineView=[[UIView alloc]initWithFrame:CGRectMake(115.91, 152.27, 223, 1)];
    lineView.layer.borderWidth=1;
    lineView.layer.borderColor=ssRGBHex(0xFF7474).CGColor;
    [self.view addSubview:lineView];
    
    UIView* lineView2=[[UIView alloc]initWithFrame:CGRectMake(115.91, 205.24, 223, 1)];
    lineView2.layer.borderWidth=1;
    lineView2.layer.borderColor=ssRGBHex(0xFF7474).CGColor;
    [self.view addSubview:lineView2];
    
    //密码可见
    UIButton* showPass=[[UIButton alloc]initWithFrame:CGRectMake(317.95, 184.27, 15.45, 11.03)];
    [showPass setBackgroundImage:[UIImage imageNamed:@"icon_bukejian"] forState:UIControlStateNormal];
    [showPass setBackgroundImage:[UIImage imageNamed:@"icon_bukejian"] forState:UIControlStateHighlighted];
    [showPass addTarget:self action:@selector(changePassVisible:) forControlEvents:UIControlEventTouchUpInside];
    [showPass addTarget:self action:@selector(changePassVisible:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showPass];
    
    UIButton* fastLogin=[[UIButton alloc]initWithFrame:CGRectMake(35.32, 241.65, 79.48, 18.75)];
    [fastLogin setTitle:@"手机快速登录" forState:UIControlStateNormal];
    fastLogin.titleLabel.font=[UIFont systemFontOfSize:12];
    [fastLogin setTitleColor:ssRGBHex(0x4A4A4A) forState:UIControlStateNormal];
    [fastLogin addTarget:self action:@selector(pushToPhonenumberLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:fastLogin];
    
    UIButton* forgetPass=[[UIButton alloc]initWithFrame:CGRectMake(325.68, 241.65, 52.99, 18.75)];
    [forgetPass setTitle:@"忘记密码" forState:UIControlStateNormal];
    forgetPass.titleLabel.font=[UIFont systemFontOfSize:12];
    [forgetPass setTitleColor:ssRGBHex(0xFF7474) forState:UIControlStateNormal];
    [forgetPass addTarget:self action:@selector(pushToForgetPass) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:forgetPass];
}

- (void)changePassVisible:(UIButton *)button{
    button.selected = !button.selected;
    if (button.selected){
       passwordTextField.secureTextEntry = NO;
    }else{
       passwordTextField.secureTextEntry = YES;
    }
    
}
-(void)someButoon{
    UIButton* loginBtn=[[UIButton alloc]initWithFrame:CGRectMake(58.51, 291.31, 298.08, 46.34)];
    loginBtn.layer.cornerRadius=25;
    loginBtn.backgroundColor=ssRGBHex(0xFF7474);
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    loginBtn.titleLabel.font=[UIFont systemFontOfSize:14];
    [loginBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(toLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    
    UIButton* registerBtn=[[UIButton alloc]initWithFrame:CGRectMake(58.51, 359.72, 298.08, 46.34)];
    registerBtn.layer.cornerRadius=25;
    registerBtn.layer.borderColor=ssRGBHex(0xFF7474).CGColor;
    registerBtn.layer.borderWidth=1;
    [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    registerBtn.titleLabel.font=[UIFont systemFontOfSize:14];
    [registerBtn setTitleColor:ssRGBHex(0xFF7474) forState:UIControlStateNormal];
    [registerBtn addTarget:self action:@selector(puchToRegister) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registerBtn];
}

-(void)devideLine{
    UIView* devideLine=[[UIView alloc]initWithFrame:CGRectMake(40.84, 562.75, 333.40, 1)];
    devideLine.layer.borderWidth=1;
    devideLine.layer.borderColor=ssRGBHex(0x9B9B9B).CGColor;
    [self.view addSubview:devideLine];
    
    UILabel* otherLoginTip=[[UILabel alloc]initWithFrame:CGRectMake(177.74, 550.62, 77.27, 22.06)];
    otherLoginTip.backgroundColor=[UIColor whiteColor];
    otherLoginTip.textAlignment=NSTextAlignmentCenter;
    otherLoginTip.text=@"第三方登录";
    otherLoginTip.font=[UIFont systemFontOfSize:14];
    otherLoginTip.textColor=ssRGBHex(0x9B9B9B);
    [self.view addSubview:otherLoginTip];
}
-(void)otherLogin{
    UIButton* weixinBtn=[[UIButton alloc]initWithFrame:CGRectMake(92.73, 596.96, 70.6, 70.6)];
    [weixinBtn setBackgroundImage:[UIImage imageNamed:@"icon_weixindenglu"] forState:UIControlStateNormal];
    [weixinBtn addTarget:self action:@selector(WXlogin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:weixinBtn];
    
    UILabel* weixinlabel=[[UILabel alloc]initWithFrame:CGRectMake(101.52, 687.44, 52.99, 18.75)];
    weixinlabel.text=@"微信登录";
    weixinlabel.textColor=ssRGBHex(0x50B674);
    weixinlabel.font=[UIFont systemFontOfSize:12];
    weixinlabel.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:weixinlabel];
    
    UIButton* qqBtn=[[UIButton alloc]initWithFrame:CGRectMake(250.60, 596.96, 70.6, 70.6)];
    [qqBtn setBackgroundImage:[UIImage imageNamed:@"icon_qqdenglu"] forState:UIControlStateNormal];
    [qqBtn addTarget:self action:@selector(QQlogin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:qqBtn];
    
    UILabel* qqlabel=[[UILabel alloc]initWithFrame:CGRectMake(262.75, 687.44, 52.99, 18.75)];
    qqlabel.text=@"QQ登录";
    qqlabel.textColor=ssRGBHex(0x4A90E2);
    qqlabel.font=[UIFont systemFontOfSize:12];
    qqlabel.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:qqlabel];
}

-(void)toLogin{
    NSLog(@"设备x名称是%@",[[UIDevice currentDevice] name]);
    
    NSDictionary* loginDic=
    [ConnectionFunction login_password:[usernameTextField.text longLongValue]
                                  Pass:passwordTextField.text
                                  Name:[[UIDevice currentDevice] name]
                                    Id:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    NSLog(@"登录结果是：%@",loginDic);
    //如果登录成功，获取s用户数据并写入文件然后跳转页面
    if ([[loginDic valueForKey:@"message"]isEqualToString:@"success"]) {
        //dictionary：过滤字典中空值
        if ([DocuOperate writeIntoPlist:@"userInfo.plist"
                             dictionary:[DataFilter DictionaryFilter:[loginDic valueForKey:@"data"]]]
            ) {
            [self popBack];
        }else{
            [self warnMsg:@"写入用户信息失败，稍后再试"];
        }
        
        
    }else if([[loginDic valueForKey:@"message"]isEqualToString:@"该账号绑定设备已达上限，请先用已绑定设备登录，解绑后再重新尝试。"]){
        [self warnMsg:[loginDic valueForKey:@"message"]];
    }else if([[loginDic valueForKey:@"message"]isEqualToString:@"账号或密码错误"]){
        [self presentViewController:[WarningWindow MsgWithoutTrans:@"账号或密码错误"] animated:YES completion:nil];
    }else
    {
        [self warnMsgWithOpe:[loginDic valueForKey:@"message"]];
    }

}
-(void)WXlogin{
    if ([WXApi isWXAppInstalled]) {
        SendAuthReq *req = [[SendAuthReq alloc] init];
        req.scope = @"snsapi_userinfo";
        req.state = @"App";
        [WXApi sendReq:req];
        
    }else {
        NSLog(@"请安装微信");
        
    }
}
-(void)QQlogin{
    QQLogin* qqlogin=[QQLogin getInstance];
    [qqlogin toQQlogin];
}
-(void)warnMsg:(NSString*)msg{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示信息" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:action1];
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)warnMsgWithOpe:(NSString*)msg{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示信息" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"强制登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ConnectionFunction userOccupation:self->usernameTextField.text Type:@"phone" Other_type:@"xxx"];
        [self toLogin];
        
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [action2 setValue:[UIColor redColor] forKey:@"titleTextColor"];
    [alert addAction:action1];
    [alert addAction:action2];
    [self presentViewController:alert animated:YES completion:nil];
}

//点击背景收起键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES]; //实现该方法是需要注意view需要是继承UIControl而来的
}

-(void)pushToPhonenumberLogin{
    if (phonenumberLogin==nil) {
        phonenumberLogin = [[PhonenumberLoginViewController alloc]init];
    }
    [self.navigationController pushViewController:phonenumberLogin animated:true];
}
-(void)puchToRegister{
    if (registerView==nil) {
        registerView = [[RegisterViewController alloc]init];
    }
    [self.navigationController pushViewController:registerView animated:true];
}
-(void)pushToForgetPass{
    if (forgetPass==nil) {
        forgetPass = [[ForgetPassViewController alloc]init];
    }
    [self.navigationController pushViewController:forgetPass animated:true];
}

-(void)popBack{
    [self.navigationController popViewControllerAnimated:true];
    //[self.navigationController popToRootViewControllerAnimated:true];
}

@end

