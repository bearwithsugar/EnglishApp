//
//  RegisterViewController.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/14.
//  Copyright © 2018年 马一轩. All rights reserved.
//

#import "RegisterViewController.h"
#import "RegisterSetPassViewController.h"
#import "../Functions/ConnectionFunction.h"
#import "../Common/HeadView.h"
#import "../Functions/WarningWindow.h"
#import "Masonry.h"
#import <objc/runtime.h>

@interface RegisterViewController (){
    RegisterSetPassViewController* setPass;
    UITextField* phonenumberTextField;
    UITextField* yanzhengTextField;
}

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    [self titleShow];
    [self inputArea];
    [self someButoon];
}
-(void)titleShow{
    [HeadView titleShow:@"手机验证" Color:ssRGBHex(0xFF7474) UIView:self.view UINavigationController:self.navigationController];
}
-(void)inputArea{
    UILabel* phonenumberLabel=[[UILabel alloc]init];
    phonenumberLabel.text=@"手机号：";
    phonenumberLabel.textColor=ssRGBHex(0xFF7474);
    phonenumberLabel.font=[UIFont systemFontOfSize:14];
    [self.view addSubview:phonenumberLabel];
    
    UILabel* yanzhengLabel=[[UILabel alloc]init];
    yanzhengLabel.text=@"验证码：";
    yanzhengLabel.textColor=ssRGBHex(0xFF7474);
    yanzhengLabel.font=[UIFont systemFontOfSize:14];
    [self.view addSubview:yanzhengLabel];
    
    phonenumberTextField=[[UITextField alloc]init];
    phonenumberTextField.placeholder=@"请输入手机号码";
    //[phonenumberTextField setValue:[UIFont boldSystemFontOfSize:12] forKeyPath:@"_placeholderLabel.font"];
    Ivar ivar =  class_getInstanceVariable([UITextField class], "_placeholderLabel");
    UILabel *placeholderLabel = object_getIvar(phonenumberTextField, ivar);
    placeholderLabel.font = [UIFont boldSystemFontOfSize:12];
    [self.view addSubview:phonenumberTextField];
    
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
    
    [phonenumberTextField mas_makeConstraints:^(MASConstraintMaker *make) {
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
    [getYzmBtn setTitleColor:ssRGBHex(0xFF7474) forState:UIControlStateNormal];
    [getYzmBtn addTarget:self action:@selector(getYzm) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:getYzmBtn];
    
    UIButton* defineBtn=[[UIButton alloc]init];
    defineBtn.layer.cornerRadius=25;
    defineBtn.backgroundColor=ssRGBHex(0xFF7474);
    [defineBtn setTitle:@"确认" forState:UIControlStateNormal];
    defineBtn.titleLabel.font=[UIFont systemFontOfSize:14];
    [defineBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [defineBtn addTarget:self action:@selector(pushToSetPass) forControlEvents:UIControlEventTouchUpInside];
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
//获取验证码
-(void)getYzm{

    NSDictionary* dataDic=[ConnectionFunction getYzmForReg:[phonenumberTextField.text longLongValue]];
    if (![[dataDic valueForKey:@"message"]isEqualToString:@"success"]) {
        [self warnMsg:[dataDic valueForKey:@"message"]];
    }else{
        [self warnMsg:[dataDic valueForKey:@"data"]];
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

-(void)popBack{
    [self.navigationController popViewControllerAnimated:true];
}

//点击背景收起键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES]; //实现该方法是需要注意view需要是继承UIControl而来的
}

-(void)pushToSetPass{
    
    if ([phonenumberTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length==0||[yanzhengTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length==0) {
        [self presentViewController: [WarningWindow MsgWithoutTrans:@"手机号或验证码为空！"] animated:YES completion:nil];
        return;
    }
    NSDictionary* dataDic=[ConnectionFunction verifyYzm:[phonenumberTextField.text longLongValue] yzm:yanzhengTextField.text ];
    NSLog(@"%@",[dataDic valueForKey:@"message"]);

    if ([[dataDic valueForKey:@"message"]isEqualToString:@"success"]) {
        if (setPass==nil) {
            setPass = [[RegisterSetPassViewController alloc]init];
            setPass.phoneNumber=phonenumberTextField.text;
        }
        [self.navigationController pushViewController:setPass animated:true];
    }else{
        [self warnMsg:[dataDic valueForKey:@"message"]];
    }
}


@end
