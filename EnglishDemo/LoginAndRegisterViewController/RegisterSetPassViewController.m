//
//  RegisterSetPassViewController.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/14.
//  Copyright © 2018年 马一轩. All rights reserved.
//

#import "RegisterSetPassViewController.h"
#import "../Functions/netOperate/ConnectionFunction.h"
#import "../Functions/netOperate/NetSenderFunction.h"
#import "../Common/HeadView.h"
#import "../Functions/WarningWindow.h"
#import "LoginViewController.h"
#import "Masonry.h"
#import <objc/runtime.h>

@interface RegisterSetPassViewController ()
{
    UITextField* passwordTextField;
    UITextField* passwordDefineTextField;
    LoginViewController* loginViewController;
}

@end

@implementation RegisterSetPassViewController

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
    UILabel* usernameLabel=[[UILabel alloc]init];
    usernameLabel.text=@"输入密码：";
    usernameLabel.textColor=ssRGBHex(0xFF7474);
    usernameLabel.font=[UIFont systemFontOfSize:14];
    [self.view addSubview:usernameLabel];
    
    UILabel* passwordLabel=[[UILabel alloc]init];
    passwordLabel.text=@"确认密码：";
    passwordLabel.textColor=ssRGBHex(0xFF7474);
    passwordLabel.font=[UIFont systemFontOfSize:14];
    [self.view addSubview:passwordLabel];
    
    passwordTextField=[[UITextField alloc]init];
    passwordTextField.placeholder=@"请输入登录密码";
    passwordTextField.secureTextEntry = YES;
    //[passwordTextField setValue:[UIFont boldSystemFontOfSize:12] forKeyPath:@"_placeholderLabel.font"];
    Ivar ivar =  class_getInstanceVariable([UITextField class], "_placeholderLabel");
    UILabel *placeholderLabel = object_getIvar(passwordTextField, ivar);
    placeholderLabel.font = [UIFont boldSystemFontOfSize:12];
    [self.view addSubview:passwordTextField];
    
    passwordDefineTextField=[[UITextField alloc]init];
    passwordDefineTextField.placeholder=@"请确认密码";
    passwordDefineTextField.secureTextEntry = YES;
    //[passwordDefineTextField setValue:[UIFont boldSystemFontOfSize:12] forKeyPath:@"_placeholderLabel.font"];
    Ivar ivar2 =  class_getInstanceVariable([UITextField class], "_placeholderLabel");
    UILabel *placeholderLabel2 = object_getIvar(passwordDefineTextField, ivar2);
    placeholderLabel2.font = [UIFont boldSystemFontOfSize:12];
    [self.view addSubview:passwordDefineTextField];
    
    UIView* lineView=[[UIView alloc]init];;
    lineView.layer.borderWidth=1;
    lineView.layer.borderColor=ssRGBHex(0xFF7474).CGColor;
    [self.view addSubview:lineView];
    
    UIView* lineView2=[[UIView alloc]init];
    lineView2.layer.borderWidth=1;
    lineView2.layer.borderColor=ssRGBHex(0xFF7474).CGColor;
    [self.view addSubview:lineView2];
    
    [usernameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(145);
        make.centerX.equalTo(self.view).with.offset(-110);
        make.width.equalTo(@90);
        make.height.equalTo(@22);
    }];
    
    [passwordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(195);
        make.centerX.equalTo(self.view).with.offset(-110);
        make.width.equalTo(@90);
        make.height.equalTo(@22);
    }];
    
    [passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(140);
        make.centerX.equalTo(self.view).with.offset(40);
        make.width.equalTo(@210);
        make.height.equalTo(@25);
    }];
    
    [passwordDefineTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(190);
        make.centerX.equalTo(self.view).with.offset(40);
        make.width.equalTo(@210);
        make.height.equalTo(@25);
    }];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(167);
        make.centerX.equalTo(self.view).with.offset(40);
        make.width.equalTo(@210);
        make.height.equalTo(@1);
    }];
    
    [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(217);
        make.centerX.equalTo(self.view).with.offset(40);
        make.width.equalTo(@210);
        make.height.equalTo(@1);
    }];
    
}
-(void)someButoon{
    UIButton* defineBtn=[[UIButton alloc]init];
    defineBtn.layer.cornerRadius=25;
    defineBtn.backgroundColor=ssRGBHex(0xFF7474);
    [defineBtn setTitle:@"注册" forState:UIControlStateNormal];
    defineBtn.titleLabel.font=[UIFont systemFontOfSize:14];
    [defineBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [defineBtn addTarget:self action:@selector(toRegister) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:defineBtn];
    
    [defineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view).with.offset(100);
        make.left.equalTo(self.view).with.offset(50);
        make.right.equalTo(self.view).with.offset(-50);
        make.height.equalTo(@50);
    }];
}
-(void)toRegister{
    if ([passwordDefineTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length==0||[passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length==0) {
        [self presentViewController: [WarningWindow MsgWithoutTrans:@"两次密码不能为空！"] animated:YES completion:nil];
        return;
    }
    
    ConBlock conBlk = ^(NSDictionary* dic){
        NSLog(@"注册结果是：%@",[dic valueForKey:@"message"]);
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[dic valueForKey:@"message"]isEqualToString:@"success"]) {
                [self popBack];
                [self pushToLogin];
            }else{
                [self presentViewController: [WarningWindow MsgWithoutTrans:[dic valueForKey:@"message"]] animated:YES completion:nil];
            }
        });
    };
    
    if ([passwordTextField.text isEqualToString:passwordDefineTextField.text]) {
        NetSenderFunction* sender = [[NetSenderFunction alloc]init];
        [sender postRequest:[[ConnectionFunction getInstance]toRegister_Post:[_phoneNumber longLongValue] Pass:passwordTextField.text Nick:@""] Block:conBlk];
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

//点击背景收起键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES]; //实现该方法是需要注意view需要是继承UIControl而来的
}

-(void)popBack{
    [self.navigationController popViewControllerAnimated:true];
}

-(void)pushToLogin{
    if(![self.navigationController.topViewController isKindOfClass:[loginViewController class]]) {
        loginViewController = [[LoginViewController alloc]init];
        loginViewController.userText = _phoneNumber;
        loginViewController.passText = passwordTextField.text;
    }
    [self.navigationController pushViewController:loginViewController animated:true];
}

@end
