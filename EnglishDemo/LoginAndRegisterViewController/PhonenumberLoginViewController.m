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
#import "../Functions/WarningWindow.h"
#import "../Functions/FixValues.h"
#import "../Functions/DocuOperate.h"
#import "../Functions/DataFilter.h"
#import "../ViewController.h"
#import "Masonry.h"

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
    [HeadView titleShow:@"用户登录" Color:ssRGBHex(0xFF7474) UIView:self.view UINavigationController:self.navigationController];
}
-(void)inputArea{
    UILabel* usernameLabel=[[UILabel alloc]init];
    usernameLabel.text=@"手机号：";
    usernameLabel.textColor=ssRGBHex(0xFF7474);
    usernameLabel.font=[UIFont systemFontOfSize:14];
    [self.view addSubview:usernameLabel];
    
    UILabel* passwordLabel=[[UILabel alloc]init];
    passwordLabel.text=@"验证码：";
    passwordLabel.textColor=ssRGBHex(0xFF7474);
    passwordLabel.font=[UIFont systemFontOfSize:14];
    [self.view addSubview:passwordLabel];
    
    usernameTextField=[[UITextField alloc]init];
    usernameTextField.placeholder=@"请输入手机号码";
    [usernameTextField setValue:[UIFont boldSystemFontOfSize:12] forKeyPath:@"_placeholderLabel.font"];
    [self.view addSubview:usernameTextField];
    
    passwordTextField=[[UITextField alloc]init];
    passwordTextField.placeholder=@"请输入验证码";
    [passwordTextField setValue:[UIFont boldSystemFontOfSize:12] forKeyPath:@"_placeholderLabel.font"];
    [self.view addSubview:passwordTextField];
    
    UIView* lineView=[[UIView alloc]init];
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
        make.width.equalTo(@70);
        make.height.equalTo(@22);
    }];
    
    [passwordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(195);
        make.centerX.equalTo(self.view).with.offset(-110);
        make.width.equalTo(@70);
        make.height.equalTo(@22);
    }];
    
    [usernameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(140);
        make.centerX.equalTo(self.view).with.offset(40);
        make.width.equalTo(@210);
        make.height.equalTo(@25);
    }];
    
    [passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
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
    UIButton* getYzmBtn=[[UIButton alloc]init];
    getYzmBtn.layer.cornerRadius=25;
    getYzmBtn.layer.borderColor=ssRGBHex(0xFF7474).CGColor;
    getYzmBtn.layer.borderWidth=1;
    [getYzmBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    getYzmBtn.titleLabel.font=[UIFont systemFontOfSize:14];
    [getYzmBtn addTarget:self action:@selector(getYzm) forControlEvents:UIControlEventTouchUpInside];
    [getYzmBtn setTitleColor:ssRGBHex(0xFF7474) forState:UIControlStateNormal];
    [self.view addSubview:getYzmBtn];
    
    UIButton* loginBtn=[[UIButton alloc]init];
    loginBtn.layer.cornerRadius=25;
    loginBtn.backgroundColor=ssRGBHex(0xFF7474);
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    loginBtn.titleLabel.font=[UIFont systemFontOfSize:14];
    [loginBtn addTarget:self action:@selector(toLogin) forControlEvents:UIControlEventTouchUpInside];
    [loginBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [self.view addSubview:loginBtn];
    
    [getYzmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view).with.offset(50);
        make.left.equalTo(self.view).with.offset(50);
        make.right.equalTo(self.view).with.offset(-50);
        make.height.equalTo(@50);
    }];
    
    [loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view).with.offset(120);
        make.left.equalTo(self.view).with.offset(50);
        make.right.equalTo(self.view).with.offset(-50);
        make.height.equalTo(@50);
    }];
}

-(void)getYzm{
    NSDictionary* dataDic=[ConnectionFunction getYzmForPassword:[usernameTextField.text longLongValue]];
    if (![[dataDic valueForKey:@"message"]isEqualToString:@"success"]) {
        [self warnMsg:[dataDic valueForKey:@"message"]];
    }else{
        [self warnMsg:[dataDic valueForKey:@"data"]];
    }

}
-(void)toLogin{
    if ([usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length==0||[passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length==0) {
        [self presentViewController: [WarningWindow MsgWithoutTrans:@"手机号或验证码为空！"] animated:YES completion:nil];
        return;
    }
    NSLog(@"验证码打印：%d",[passwordTextField.text intValue]);
    dataDic=[ConnectionFunction login_yzm:[usernameTextField.text longLongValue]
                                      Yzm:passwordTextField.text
                                   Device:[FixValues getUniqueId]
                                     Name:[[UIDevice currentDevice] name]];
    if ([[dataDic valueForKey:@"message"]isEqualToString:@"success"]) {
        if ([DocuOperate writeIntoPlist:@"userInfo.plist"
                             dictionary:[DataFilter DictionaryFilter:[dataDic valueForKey:@"data"]]]
            ) {
            [self pushToMain];
        }else{
            [self warnMsg:@"写入用户信息失败，稍后再试"];
        }
    }else{
        [self warnMsg:[dataDic valueForKey:@"message"]];
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

-(void)pushToMain{
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[ViewController class]]) {
            ViewController *A =(ViewController *)controller;
            [self.navigationController popToViewController:A animated:YES];
        }
    }
    
}

@end
