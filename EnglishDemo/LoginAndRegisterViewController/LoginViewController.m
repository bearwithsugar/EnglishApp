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
#import "ViewController.h"
#import "../WeChatSDK/WeChatSDK1.8.3/WXApi.h"
#import "../AppDelegate.h"
#import "../Functions/netOperate/ConnectionFunction.h"
#import "../Functions/netOperate/NetSenderFunction.h"
#import "../Functions/DocuOperate.h"
#import "../Functions/DataFilter.h"
#import "../Functions/QQLogin.h"
#import "../Functions/WarningWindow.h"
#import "../Functions/FixValues.h"
#import "../Functions/MyThreadPool.h"
#import "../Functions/WechatLog.h"
#import "../Functions/AgentFunction.h"
#import "../Common/HeadView.h"
#import "../SVProgressHUD/SVProgressHUD.h"
#import "Masonry.h"
#import <AuthenticationServices/AuthenticationServices.h>
#import <objc/runtime.h>

@interface LoginViewController ()<ASAuthorizationControllerDelegate,ASAuthorizationControllerPresentationContextProviding>{

    PhonenumberLoginViewController* phonenumberLogin;
    RegisterViewController* registerView;
    ForgetPassViewController* forgetPass;
    
    UITextField* usernameTextField;
    UITextField* passwordTextField;
    
    UIView* buttonView;
    UIButton* weixinBtn;
    UIButton* qqBtn;
    
    NSDictionary* userDic;
}

@end
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wprotocol"
//去除协议方法未实现的警告
@implementation LoginViewController
#pragma clang diagnostic pop
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
    
    if (_userText!=nil && _passText!=nil) {
        usernameTextField.text = _userText;
        passwordTextField.text = _passText;
        _userText = _passText = nil;
    }else{
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
    [buttonView removeFromSuperview];
    buttonView = [[UIView alloc]init];
    [self.view addSubview:buttonView];
    
    [buttonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-120);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(300, 40));
    }];
 
    weixinBtn=[[UIButton alloc]init];
    [weixinBtn setBackgroundImage:[UIImage imageNamed:@"icon_weixindenglu"] forState:UIControlStateNormal];
    [weixinBtn addTarget:self action:@selector(WXlogin) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:weixinBtn];
    
    qqBtn=[[UIButton alloc]init];
    [qqBtn setBackgroundImage:[UIImage imageNamed:@"icon_qqdenglu"] forState:UIControlStateNormal];
    [qqBtn addTarget:self action:@selector(QQlogin) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:qqBtn];
    
    if ([WXApi isWXAppInstalled]) {
        [weixinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(buttonView);
            make.top.equalTo(buttonView);
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
     
        [qqBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weixinBtn.mas_right).with.offset(40);
            make.top.equalTo(buttonView);
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
        
        if (@available(iOS 13.0, *)) {
            ASAuthorizationAppleIDButton* appleLogBtn ;
            [appleLogBtn removeFromSuperview];
            appleLogBtn = [ASAuthorizationAppleIDButton buttonWithType:ASAuthorizationAppleIDButtonTypeSignIn style:ASAuthorizationAppleIDButtonStyleBlack];

            [buttonView addSubview:appleLogBtn];

            [appleLogBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(buttonView);
                make.centerY.equalTo(buttonView);
                make.size.mas_equalTo(CGSizeMake(140, 40));
            }];
            
            [appleLogBtn addTarget:self action:@selector(appleLog) forControlEvents:UIControlEventTouchUpInside];
            
        } else {
        // Fallback on earlier versions
        }
        
    }else {
        [qqBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(buttonView).with.offset(40);
            make.top.equalTo(buttonView);
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
        if (@available(iOS 13.0, *)) {
            ASAuthorizationAppleIDButton* appleLogBtn ;
            [appleLogBtn removeFromSuperview];
            appleLogBtn = [ASAuthorizationAppleIDButton buttonWithType:ASAuthorizationAppleIDButtonTypeSignIn style:ASAuthorizationAppleIDButtonStyleBlack];
            [buttonView addSubview:appleLogBtn];
            
            [appleLogBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(buttonView);
                make.right.equalTo(buttonView).with.offset(-40);
                make.size.mas_equalTo(CGSizeMake(140, 40));
            }];
            [appleLogBtn addTarget:self action:@selector(appleLog) forControlEvents:UIControlEventTouchUpInside];
        } else {
            // Fallback on earlier versions
        }
    }
    
}

-(void)toLogin{
    
    if ([usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length==0||[passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length==0) {
        [self presentViewController: [WarningWindow MsgWithoutTrans:@"用户名或密码为空！"] animated:YES completion:nil];
        return;
    }
    [SVProgressHUD showWithStatus:@"登录中"];
    NSLog(@"设备x名称是%@",[[UIDevice currentDevice] name]);
    
    ConBlock conBlk = ^(NSDictionary* loginDic){
        //如果登录成功，获取s用户数据并写入文件然后跳转页面
        dispatch_async(dispatch_get_main_queue(), ^{
           if ([[loginDic valueForKey:@"message"]isEqualToString:@"success"]) {
               //dictionary：过滤字典中空值
               if ([DocuOperate writeIntoPlist:@"userInfo.plist"
                                    dictionary:[DataFilter DictionaryFilter:[loginDic valueForKey:@"data"]]]) {
                   [SVProgressHUD dismiss];
                   [self popToMain];
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
        });
    };
    NetSenderFunction* sender = [[NetSenderFunction alloc]init];
    [sender postRequest:[[ConnectionFunction getInstance]login_password_Post:[usernameTextField.text longLongValue]
                                                                        Pass:passwordTextField.text
                                                                        Name:[[UIDevice currentDevice] name]
                                                                          Id:[FixValues getUniqueId]]
                  Block:conBlk];
   

}
-(void)WXlogin{
    if ([WXApi isWXAppInstalled]) {
        WechatLog* we = [WechatLog getInstance];
        we.type = @"FORLOG";
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
    qqlogin.type = @"FORLOGIN";
    [qqlogin toQQlogin];
}
-(void)appleLog{
    if (@available(iOS 13.0,*)) {
        ASAuthorizationAppleIDProvider* appleIdProvider = [[ASAuthorizationAppleIDProvider alloc]init];
        ASAuthorizationOpenIDRequest* appleRequest = appleIdProvider.createRequest;
        appleRequest.requestedScopes = @[ASAuthorizationScopeEmail,ASAuthorizationScopeFullName];
        ASAuthorizationController* controller = [[ASAuthorizationController alloc]initWithAuthorizationRequests:@[appleRequest]];
        controller.delegate = self;
        controller.presentationContextProvider = self;
        [controller performRequests];
    }
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
        NetSenderFunction *sender = [[NetSenderFunction alloc]init];
        [sender postRequest:[[ConnectionFunction getInstance]userOccupation_Post:self->usernameTextField.text Type:@"phone" Other_type:@"xxx"] Block:^(NSDictionary * dic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self toLogin];
            });
        }];
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
        phonenumberLogin.phoneNumber = usernameTextField.text;
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

-(void)popToMain{
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[ViewController class]]) {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}

-(void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization API_AVAILABLE(ios(13.0)){
    ASAuthorizationAppleIDCredential* credential = authorization.credential;
    NSString* user = credential.user;
    NSPersonNameComponents* fullname = credential.fullName;
    [self appleLogRequestSend:user Name:fullname];
}
-(void)appleLogRequestSend:(NSString*)user Name:(NSPersonNameComponents*)fullname{
    ConBlock conBlk = ^(NSDictionary* dataDic){
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[dataDic valueForKey:@"message"]isEqualToString:@"success"]) {
                if ([DocuOperate writeIntoPlist:@"userInfo.plist" dictionary:[DataFilter DictionaryFilter:[dataDic valueForKey:@"data"]]]) {
                    [[FixValues navigationViewController] popViewControllerAnimated:true];
                }else{
                    [[AgentFunction theTopviewControler]presentViewController:[WarningWindow MsgWithoutTrans:@"登录信息保存失败"] animated:YES completion:nil];
                }
            }else if([[dataDic valueForKey:@"code"]intValue] == 400){
                VoidBlock warnBlk = ^{
                    ConBlock jobblock = ^(NSDictionary* resultDic){
                        [self appleLogRequestSend:user Name:fullname];
                    };
                    NetSenderFunction* sender = [[NetSenderFunction alloc]init];
                    [sender postRequest:[[ConnectionFunction getInstance]userOccupation_Post:user Type:@"other" Other_type:@"APPLE"] Block:jobblock];
                };
                [[AgentFunction theTopviewControler]
                presentViewController:[WarningWindow MsgWithBlock2:[dataDic valueForKey:@"message"] Msg:@"强制登录" Block1:warnBlk Msg2:@"取消" Block2:^{}] animated:YES completion:nil];
            }else{
                [[AgentFunction theTopviewControler]
                presentViewController:[WarningWindow MsgWithoutTrans:[dataDic valueForKey:@"message"]] animated:YES completion:nil];
            }
        });
    };
    NetSenderFunction* sender = [[NetSenderFunction alloc]init];
    [sender postRequest:[[ConnectionFunction getInstance]OtherLogin_Post:user
                                                               Nickname:[fullname.familyName stringByAppendingString:fullname.givenName]
                                                               DeviceId:[FixValues getUniqueId]
                                                             DeviceName:[[UIDevice currentDevice] name]
                                                                   Type:@"APPLE"
                                                                    Pic:@""]
                 Block:conBlk];
}
@end

