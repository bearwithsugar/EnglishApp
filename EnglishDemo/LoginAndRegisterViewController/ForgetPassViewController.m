//
//  ForgetPassViewController.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/14.
//  Copyright © 2018年 马一轩. All rights reserved.
//

#import "ForgetPassViewController.h"
#import "ResetPassViewController.h"
#import "../Functions/netOperate/ConnectionFunction.h"
#import "../Functions/netOperate/NetSenderFunction.h"
#import "../Common/HeadView.h"
#import "Masonry.h"
#import "../Functions/WarningWindow.h"
#import <objc/runtime.h>

@interface ForgetPassViewController (){
    ResetPassViewController* resetPass;
    UITextField* phonenumber;
    UITextField* yanzhengTextField;
}

@end

@implementation ForgetPassViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    [self titleShow];
    [self inputArea];
    [self someButoon];
}
-(void)titleShow{
    [HeadView titleShow:@"忘记密码" Color:ssRGBHex(0xFF7474) UIView:self.view UINavigationController:self.navigationController];
}
-(void)inputArea{
    UILabel* phonenumberLabel=[[UILabel alloc]init];
    phonenumberLabel.text=@"手机号：";
    //phonenumberLabel.textColor=ssRGBHex(0x9B9B9B);
    phonenumberLabel.textColor=ssRGBHex(0xFF7474);
    phonenumberLabel.font=[UIFont systemFontOfSize:14];
    [self.view addSubview:phonenumberLabel];
    
    phonenumber=[[UITextField alloc]init];
//    phonenumber.textColor=ssRGBHex(0x9B9B9B);
//    phonenumber.font=[UIFont systemFontOfSize:12];
    phonenumber.placeholder=@"请输入手机号";
    //[phonenumber setValue:[UIFont boldSystemFontOfSize:12] forKeyPath:@"_placeholderLabel.font"];
    Ivar ivar =  class_getInstanceVariable([UITextField class], "_placeholderLabel");
    UILabel *placeholderLabel = object_getIvar(phonenumber, ivar);
    placeholderLabel.font = [UIFont boldSystemFontOfSize:12];
    [self.view addSubview:phonenumber];
    
    UILabel* yanzhengLabel=[[UILabel alloc]init];
    yanzhengLabel.text=@"验证码：";
    yanzhengLabel.textColor=ssRGBHex(0xFF7474);
    yanzhengLabel.font=[UIFont systemFontOfSize:14];
    [self.view addSubview:yanzhengLabel];
    
    yanzhengTextField=[[UITextField alloc]init];
    yanzhengTextField.placeholder=@"请输入验证码";
    //[yanzhengTextField setValue:[UIFont boldSystemFontOfSize:12] forKeyPath:@"_placeholderLabel.font"];
    Ivar ivar2 =  class_getInstanceVariable([UITextField class], "_placeholderLabel");
    UILabel *placeholderLabel2 = object_getIvar(yanzhengTextField, ivar2);
    placeholderLabel2.font = [UIFont boldSystemFontOfSize:12];
    [self.view addSubview:yanzhengTextField];
    
    UIView* lineView=[[UIView alloc]init];
    lineView.layer.borderWidth=1;
    lineView.layer.borderColor=ssRGBHex(0xFF7474).CGColor;
    [self.view addSubview:lineView];
    
    UIView* lineView2=[[UIView alloc]init];
    lineView2.layer.borderWidth=1;
    lineView2.layer.borderColor=ssRGBHex(0xFF7474).CGColor;
    [self.view addSubview:lineView2];
    
    [phonenumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(145);
        make.centerX.equalTo(self.view).with.offset(-110);
        make.width.equalTo(@70);
        make.height.equalTo(@22);
    }];
    
    [yanzhengLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(195);
        make.centerX.equalTo(self.view).with.offset(-110);
        make.width.equalTo(@70);
        make.height.equalTo(@22);
    }];
    
    [phonenumber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(140);
        make.centerX.equalTo(self.view).with.offset(40);
        make.width.equalTo(@210);
        make.height.equalTo(@25);
    }];
    
    [yanzhengTextField mas_makeConstraints:^(MASConstraintMaker *make) {
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
    
    UIButton* defineBtn=[[UIButton alloc]init];
    defineBtn.layer.cornerRadius=25;
    defineBtn.backgroundColor=ssRGBHex(0xFF7474);
    [defineBtn setTitle:@"验证" forState:UIControlStateNormal];
    defineBtn.titleLabel.font=[UIFont systemFontOfSize:14];
    [defineBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [defineBtn addTarget:self action:@selector(pushToResetPass) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:defineBtn];
    
    [getYzmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view).with.offset(50);
        make.left.equalTo(self.view).with.offset(50);
        make.right.equalTo(self.view).with.offset(-50);
        make.height.equalTo(@50);
    }];
    
    [defineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view).with.offset(120);
        make.left.equalTo(self.view).with.offset(50);
        make.right.equalTo(self.view).with.offset(-50);
        make.height.equalTo(@50);
    }];
}

-(void)getYzm{
    if (![self verifyMobile:phonenumber.text]) {
        [self presentViewController:[WarningWindow MsgWithoutTrans:@"手机号不合法！"] animated:YES completion:nil];
        return;
    }
    if ([phonenumber.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length==0) {
        [self presentViewController: [WarningWindow MsgWithoutTrans:@"手机号不能为空！"] animated:YES completion:nil];
        return;
    }
    
    ConBlock conBlk = ^(NSDictionary* dataDic){
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[dataDic valueForKey:@"message"]isEqualToString:@"success"]) {
                [self presentViewController:[WarningWindow MsgWithoutTrans:@"已发送，1分钟有效"] animated:YES completion:nil];
            }else{
                [self presentViewController:[WarningWindow MsgWithoutTrans:[dataDic valueForKey:@"message"]] animated:YES completion:nil];
            }
        });
    };
    NetSenderFunction* sender = [[NetSenderFunction alloc]init];
    [sender getRequest:[[ConnectionFunction getInstance]getYzmForPassword_Post:[phonenumber.text longLongValue]] Block:conBlk];
}

-(BOOL)verifyMobile:(NSString *)mobilePhone{
    NSString *express = @"^0{0,1}(13[0-9]|15[0-9]|18[0-9]|14[0-9])[0-9]{8}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF matches %@", express];
    BOOL boo = [pred evaluateWithObject:mobilePhone];
    return boo;
    
}

-(void)popBack{
    [self.navigationController popViewControllerAnimated:true];
}
-(void)pushToResetPass{
    if ([yanzhengTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length==0||[phonenumber.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length==0) {
        [self presentViewController: [WarningWindow MsgWithoutTrans:@"验证码不能为空！"] animated:YES completion:nil];
        return;
    }
    
    ConBlock conBlk = ^(NSDictionary* dataDic){
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[dataDic valueForKey:@"message"]isEqualToString:@"success"]) {
                if (self->resetPass==nil) {
                    self->resetPass = [[ResetPassViewController alloc]init];
                }
                self->resetPass.phoneNumber=self->phonenumber.text;
                [self.navigationController pushViewController:self->resetPass animated:true];
            }else{
                [self presentViewController:[WarningWindow MsgWithoutTrans:[dataDic valueForKey:@"message"]] animated:YES completion:nil];
            }
        });
    };
    NetSenderFunction* sender = [[NetSenderFunction alloc]init];
    [sender postRequest:[[ConnectionFunction getInstance]verifyYzm_Post:[phonenumber.text longLongValue] yzm:yanzhengTextField.text] Block:conBlk];
}

//点击背景收起键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES]; //实现该方法是需要注意view需要是继承UIControl而来的
}

@end
