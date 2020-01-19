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
#import "../WeChatSDK/WeChatSDK1.8.3/WXApi.h"
#import "../AppDelegate.h"
#import "../Functions/ConnectionFunction.h"
#import "../Functions/DocuOperate.h"
#import "../Functions/DataFilter.h"
#import "../Functions/QQLogin.h"
#import "../Functions/WarningWindow.h"
#import "../Functions/FixValues.h"
#import "../Functions/MyThreadPool.h"
#import "../Common/HeadView.h"
#import "../SVProgressHUD/SVProgressHUD.h"
#import "Masonry.h"
#import <objc/runtime.h>

@interface LoginViewController (){

    PhonenumberLoginViewController* phonenumberLogin;
    RegisterViewController* registerView;
    ForgetPassViewController* forgetPass;
    
    UITextField* usernameTextField;
    UITextField* passwordTextField;
    
    UIButton* weixinBtn;
    UILabel* weixinlabel;
    UIButton* qqBtn;
    UILabel* qqlabel;
    
    NSDictionary* userDic;
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
}
-(void)viewWillAppear:(BOOL)animated{
    [self otherLogin];
}
-(void)titleShow{
    [HeadView titleShow:@"用户登录" Color:ssRGBHex(0xFF7474) UIView:self.view UINavigationController:self.navigationController];
}
-(void)inputArea{
    UILabel* usernameLabel=[[UILabel alloc]init];
    usernameLabel.text=@"账号：";
    usernameLabel.textColor=ssRGBHex(0xFF7474);
    usernameLabel.font=[UIFont systemFontOfSize:14];
    [self.view addSubview:usernameLabel];
    
    UILabel* passwordLabel=[[UILabel alloc]init];
    passwordLabel.text=@"密码：";
    passwordLabel.textColor=ssRGBHex(0xFF7474);
    passwordLabel.font=[UIFont systemFontOfSize:14];
    [self.view addSubview:passwordLabel];
    
    usernameTextField=[[UITextField alloc]init];
    usernameTextField.placeholder=@"请输入手机号码";
    usernameTextField.text=@"";
    Ivar ivar =  class_getInstanceVariable([UITextField class], "_placeholderLabel");
    UILabel *placeholderLabel = object_getIvar(usernameTextField, ivar);
    placeholderLabel.font = [UIFont boldSystemFontOfSize:12];
   
    [self.view addSubview:usernameTextField];
    
    passwordTextField=[[UITextField alloc]init];
    passwordTextField.placeholder=@"请输入登录密码";
    passwordTextField.text=@"";
    //[passwordTextField setValue:[UIFont boldSystemFontOfSize:12] forKeyPath:@"_placeholderLabel.font"];
    Ivar ivar2 =  class_getInstanceVariable([UITextField class], "_placeholderLabel");
    UILabel *placeholderLabel2 = object_getIvar(passwordTextField, ivar2);
    placeholderLabel2.font = [UIFont boldSystemFontOfSize:12];
    passwordTextField.secureTextEntry = YES;
    
    [self.view addSubview:passwordTextField];
    
    UIView* lineView=[[UIView alloc]init];
    lineView.layer.borderWidth=1;
    lineView.layer.borderColor=ssRGBHex(0xFF7474).CGColor;
    [self.view addSubview:lineView];
    
    UIView* lineView2=[[UIView alloc]init];
    lineView2.layer.borderWidth=1;
    lineView2.layer.borderColor=ssRGBHex(0xFF7474).CGColor;
    [self.view addSubview:lineView2];
    
    //密码可见
    UIButton* showPass=[[UIButton alloc]init];
    [showPass setBackgroundImage:[UIImage imageNamed:@"icon_bukejian"] forState:UIControlStateNormal];
    [showPass setBackgroundImage:[UIImage imageNamed:@"icon_bukejian"] forState:UIControlStateHighlighted];
    [showPass addTarget:self action:@selector(changePassVisible:) forControlEvents:UIControlEventTouchUpInside];
    [showPass addTarget:self action:@selector(changePassVisible:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showPass];
    
    UIButton* fastLogin=[[UIButton alloc]init];
    [fastLogin setTitle:@"手机快速登录" forState:UIControlStateNormal];
    fastLogin.titleLabel.font=[UIFont systemFontOfSize:12];
    [fastLogin setTitleColor:ssRGBHex(0x4A4A4A) forState:UIControlStateNormal];
    [fastLogin addTarget:self action:@selector(pushToPhonenumberLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:fastLogin];
    
    UIButton* forgetPass=[[UIButton alloc]init];
    [forgetPass setTitle:@"忘记密码" forState:UIControlStateNormal];
    forgetPass.titleLabel.font=[UIFont systemFontOfSize:12];
    [forgetPass setTitleColor:ssRGBHex(0xFF7474) forState:UIControlStateNormal];
    [forgetPass addTarget:self action:@selector(pushToForgetPass) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:forgetPass];
    
    [usernameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(126.89);
        make.centerX.equalTo(self.view).with.offset(-100);
        make.width.equalTo(@50);
        make.height.equalTo(@22);
    }];
    
    [passwordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(179.86);
        make.centerX.equalTo(self.view).with.offset(-100);
        make.width.equalTo(@50);
        make.height.equalTo(@22);
    }];
    
    [usernameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(126.89);
        make.centerX.equalTo(self.view).with.offset(30);
        make.width.equalTo(@210);
        make.height.equalTo(@25);
    }];
    
    [passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(179.86);
        make.centerX.equalTo(self.view).with.offset(30);
        make.width.equalTo(@210);
        make.height.equalTo(@25);
    }];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(152.27);
        make.centerX.equalTo(self.view).with.offset(30);
        make.width.equalTo(@210);
        make.height.equalTo(@1);
    }];
    
    [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(205.24);
        make.centerX.equalTo(self.view).with.offset(30);
        make.width.equalTo(@210);
        make.height.equalTo(@1);
    }];
    
    [showPass mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(184.27);
        make.right.equalTo(self->passwordTextField);
        make.width.equalTo(@15.45);
        make.height.equalTo(@11);
    }];
    
    [fastLogin mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(241.65);
        make.left.equalTo(self.view).with.offset(35.32);
        make.width.equalTo(@80);
        make.height.equalTo(@19);
    }];
    
    [forgetPass mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(241.65);
        make.right.equalTo(self.view).with.offset(-35.32);
        make.width.equalTo(@50);
        make.height.equalTo(@19);
    }];
    
    [MyThreadPool executeJob:^{
        if ([DocuOperate fileExistInPath:@"password.plist"]) {
            self->userDic = [DocuOperate readFromPlist:@"password.plist"];
        }
    } Main:^{
        if (self->userDic!=nil) {
            self->usernameTextField.text = [self->userDic valueForKey:@"username"];
            self->passwordTextField.text = [self->userDic valueForKey:@"password"];
        }
    }];
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
    UIButton* loginBtn=[[UIButton alloc]init];
    loginBtn.layer.cornerRadius=25;
    loginBtn.backgroundColor=ssRGBHex(0xFF7474);
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    loginBtn.titleLabel.font=[UIFont systemFontOfSize:14];
    [loginBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(toLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    
    UIButton* registerBtn=[[UIButton alloc]init];
    registerBtn.layer.cornerRadius=25;
    registerBtn.layer.borderColor=ssRGBHex(0xFF7474).CGColor;
    registerBtn.layer.borderWidth=1;
    [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    registerBtn.titleLabel.font=[UIFont systemFontOfSize:14];
    [registerBtn setTitleColor:ssRGBHex(0xFF7474) forState:UIControlStateNormal];
    [registerBtn addTarget:self action:@selector(puchToRegister) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registerBtn];
    
    [loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view).with.offset(-50);
        make.left.equalTo(self.view).with.offset(50);
        make.right.equalTo(self.view).with.offset(-50);
        make.height.equalTo(@50);
    }];
    
    [registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view).with.offset(20);
        make.left.equalTo(self.view).with.offset(50);
        make.right.equalTo(self.view).with.offset(-50);
        make.height.equalTo(@50);
    }];
}

-(void)devideLine{
    UIView* devideLine=[[UIView alloc]init];
    devideLine.layer.borderWidth=1;
    devideLine.layer.borderColor=ssRGBHex(0x9B9B9B).CGColor;
    [self.view addSubview:devideLine];
    
    UILabel* otherLoginTip=[[UILabel alloc]init];
    otherLoginTip.backgroundColor=[UIColor whiteColor];
    otherLoginTip.textAlignment=NSTextAlignmentCenter;
    otherLoginTip.text=@"第三方登录";
    otherLoginTip.font=[UIFont systemFontOfSize:14];
    otherLoginTip.textColor=ssRGBHex(0x9B9B9B);
    [self.view addSubview:otherLoginTip];
    
    [devideLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(30);
        make.bottom.equalTo(self.view).with.offset(-230);
        make.right.equalTo(self.view).with.offset(-30);
        make.height.equalTo(@1);
    }];
    
    [otherLoginTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).with.offset(-219);
        make.width.equalTo(@80);
        make.height.equalTo(@22);
    }];
}
-(void)otherLogin{
    [weixinBtn removeFromSuperview];
    [weixinlabel removeFromSuperview];
    [qqBtn removeFromSuperview];
    [qqlabel removeFromSuperview];
    
    weixinBtn=[[UIButton alloc]init];
    [weixinBtn setBackgroundImage:[UIImage imageNamed:@"icon_weixindenglu"] forState:UIControlStateNormal];
    [weixinBtn addTarget:self action:@selector(WXlogin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:weixinBtn];
    
    weixinlabel=[[UILabel alloc]init];
    weixinlabel.text=@"微信登录";
    weixinlabel.textColor=ssRGBHex(0x50B674);
    weixinlabel.font=[UIFont systemFontOfSize:12];
    weixinlabel.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:weixinlabel];
    
    qqBtn=[[UIButton alloc]init];
    [qqBtn setBackgroundImage:[UIImage imageNamed:@"icon_qqdenglu"] forState:UIControlStateNormal];
    [qqBtn addTarget:self action:@selector(QQlogin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:qqBtn];
    
    qqlabel=[[UILabel alloc]init];
    qqlabel.text=@"QQ登录";
    qqlabel.textColor=ssRGBHex(0x4A90E2);
    qqlabel.font=[UIFont systemFontOfSize:12];
    qqlabel.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:qqlabel];

    
    if ([WXApi isWXAppInstalled]) {
        [weixinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view).with.offset(-80);
            make.bottom.equalTo(self.view).with.offset(-120);
            make.width.equalTo(@70);
            make.height.equalTo(@70);
        }];
        [weixinlabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view).with.offset(-80);
            make.bottom.equalTo(self.view).with.offset(-60);
            make.width.equalTo(@70);
            make.height.equalTo(@19);
        }];
        
        [qqBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view).with.offset(80);
            make.bottom.equalTo(self.view).with.offset(-120);
            make.width.equalTo(@70);
            make.height.equalTo(@70);
        }];
        
        [qqlabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view).with.offset(80);
            make.bottom.equalTo(self.view).with.offset(-60);
            make.width.equalTo(@70);
            make.height.equalTo(@19);
        }];
        
    }else {
        [qqBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.bottom.equalTo(self.view).with.offset(-120);
            make.width.equalTo(@70);
            make.height.equalTo(@70);
        }];
        
        [qqlabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.bottom.equalTo(self.view).with.offset(-60);
            make.width.equalTo(@70);
            make.height.equalTo(@19);
        }];
    }
    
}

-(void)toLogin{
    
    if ([usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length==0||[passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length==0) {
        [self presentViewController: [WarningWindow MsgWithoutTrans:@"用户名或密码为空！"] animated:YES completion:nil];
        return;
    }
    [SVProgressHUD showWithStatus:@"登录中"];
    NSLog(@"设备x名称是%@",[[UIDevice currentDevice] name]);
    
    NSDictionary* loginDic=
    [ConnectionFunction login_password:[usernameTextField.text longLongValue]
                                  Pass:passwordTextField.text
                                  Name:[[UIDevice currentDevice] name]
                                    Id:[FixValues getUniqueId]];
    NSLog(@"登录结果是：%@",loginDic);
    //如果登录成功，获取s用户数据并写入文件然后跳转页面
    if ([[loginDic valueForKey:@"message"]isEqualToString:@"success"]) {
        //dictionary：过滤字典中空值
        if ([DocuOperate writeIntoPlist:@"userInfo.plist"
                             dictionary:[DataFilter DictionaryFilter:[loginDic valueForKey:@"data"]]]
            ) {
            [SVProgressHUD dismiss];
            [self popBack];
            NSDictionary* usernameDic = [[NSDictionary alloc]
                                                   initWithObjectsAndKeys:self->usernameTextField.text,@"username",
                                                        self->passwordTextField.text,@"password", nil];
            [MyThreadPool executeJob:^{
                [DocuOperate writeIntoPlist:@"password.plist" dictionary:usernameDic];
            } Main:^{
                NSLog(@"记住密码成功");
            }];
            
        }else{
            [self warnMsg:@"写入用户信息失败，稍后再试"];
        }
        
        
    }else if([[loginDic valueForKey:@"message"]isEqualToString:@"该账号已在其他设备登录，是否确认登录？"]){
        [SVProgressHUD dismiss];
        [self warnMsgWithOpe:[loginDic valueForKey:@"message"]];
    }else if([[loginDic valueForKey:@"message"]isEqualToString:@"账号或密码错误"]){
        [SVProgressHUD dismiss];
        [self presentViewController:[WarningWindow MsgWithoutTrans:@"账号或密码错误"] animated:YES completion:nil];
    }else
    {
        [self warnMsg:[loginDic valueForKey:@"message"]];
        [SVProgressHUD dismiss];
    }

}
-(void)WXlogin{
    if ([WXApi isWXAppInstalled]) {
        SendAuthReq *req = [[SendAuthReq alloc] init];
        req.scope = @"snsapi_userinfo";
        req.state = @"App";
        [WXApi sendReq:req];
        
    }else {
        [self presentViewController: [WarningWindow MsgWithoutTrans:@"您的手机未安装微信！"] animated:YES completion:nil];
        return;
        
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
        [SVProgressHUD showWithStatus:@"登录中"];
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
}

@end

