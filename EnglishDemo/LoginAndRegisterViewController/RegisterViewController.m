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
    UILabel* phonenumberLabel=[[UILabel alloc]initWithFrame:CGRectMake(66.23, 177.65, 61.82, 22.06)];
    phonenumberLabel.text=@"手机号：";
    phonenumberLabel.textColor=ssRGBHex(0xFF7474);
    phonenumberLabel.font=[UIFont systemFontOfSize:14];
    [self.view addSubview:phonenumberLabel];
    
    UILabel* yanzhengLabel=[[UILabel alloc]initWithFrame:CGRectMake(66.23, 222.89, 61.82, 22.06)];
    yanzhengLabel.text=@"验证码：";
    yanzhengLabel.textColor=ssRGBHex(0xFF7474);
    yanzhengLabel.font=[UIFont systemFontOfSize:14];
    [self.view addSubview:yanzhengLabel];
    
    phonenumberTextField=[[UITextField alloc]initWithFrame:CGRectMake(128.06, 166.62, 200, 25)];
    phonenumberTextField.placeholder=@"请输入手机号码";
    phonenumberTextField.text=@"13142220635";
    [phonenumberTextField setValue:[UIFont boldSystemFontOfSize:12] forKeyPath:@"_placeholderLabel.font"];
    [self.view addSubview:phonenumberTextField];
    
    yanzhengTextField=[[UITextField alloc]initWithFrame:CGRectMake(128.06, 219.58, 200, 25)];
    yanzhengTextField.placeholder=@"请输入验证码";
    [yanzhengTextField setValue:[UIFont boldSystemFontOfSize:12] forKeyPath:@"_placeholderLabel.font"];
    [self.view addSubview:yanzhengTextField];
    
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
    [getYzmBtn setTitleColor:ssRGBHex(0xFF7474) forState:UIControlStateNormal];
    [getYzmBtn addTarget:self action:@selector(getYzm) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:getYzmBtn];
    
    UIButton* defineBtn=[[UIButton alloc]initWithFrame:CGRectMake(58.51, 601.37, 298.08, 46.34)];
    defineBtn.layer.cornerRadius=25;
    defineBtn.backgroundColor=ssRGBHex(0xFF7474);
    [defineBtn setTitle:@"确认" forState:UIControlStateNormal];
    defineBtn.titleLabel.font=[UIFont systemFontOfSize:14];
    [defineBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [defineBtn addTarget:self action:@selector(pushToSetPass) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:defineBtn];
}
//获取验证码
-(void)getYzm{
    if ([self verifyMobile:phonenumberTextField.text]) {
        NSDictionary* dataDic=[ConnectionFunction getYzm:[phonenumberTextField.text longLongValue]];
        [self warnMsg:[dataDic valueForKey:@"message"]];
    }else{
        NSLog(@"手机号不合法!");
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
-(void)pushToSetPass{
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
//            if (setPass==nil) {
//                setPass = [[RegisterSetPassViewController alloc]init];
//                setPass.phoneNumber=phonenumberTextField.text;
//            }
//            [self.navigationController pushViewController:setPass animated:true];
}


@end
