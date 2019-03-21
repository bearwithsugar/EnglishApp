//
//  ForgetPassViewController.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/14.
//  Copyright © 2018年 马一轩. All rights reserved.
//

#import "ForgetPassViewController.h"
#import "ResetPassViewController.h"
#import "../Functions/ConnectionFunction.h"
#import "../Common/HeadView.h"

@interface ForgetPassViewController (){
    ResetPassViewController* resetPass;
    UILabel* phonenumber;
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
    [self.view addSubview:[HeadView titleShow:@"忘记密码" Color:ssRGBHex(0xFF7474) Located:CGRectMake(0, 22.06, 414, 66.2) UINavigationController:self.navigationController]];
}
-(void)inputArea{
    UILabel* phonenumberLabel=[[UILabel alloc]initWithFrame:CGRectMake(66.23, 177.65, 61.82, 22.06)];
    phonenumberLabel.text=@"手机号：";
    phonenumberLabel.textColor=ssRGBHex(0x9B9B9B);
    phonenumberLabel.font=[UIFont systemFontOfSize:14];
    [self.view addSubview:phonenumberLabel];
    
    phonenumber=[[UILabel alloc]initWithFrame:CGRectMake(131.37, 177.65, 184.36, 22.06)];
    phonenumber.text=@"13142220635";
    phonenumber.textColor=ssRGBHex(0x9B9B9B);
    phonenumber.font=[UIFont systemFontOfSize:12];
    [self.view addSubview:phonenumber];
    
    UILabel* yanzhengLabel=[[UILabel alloc]initWithFrame:CGRectMake(66.23, 222.89, 61.82, 22.06)];
    yanzhengLabel.text=@"验证码：";
    yanzhengLabel.textColor=ssRGBHex(0xFF7474);
    yanzhengLabel.font=[UIFont systemFontOfSize:14];
    [self.view addSubview:yanzhengLabel];
    
    yanzhengTextField=[[UITextField alloc]initWithFrame:CGRectMake(128.06, 219.58, 200, 25)];
    yanzhengTextField.placeholder=@"请输入验证码";
    [yanzhengTextField setValue:[UIFont boldSystemFontOfSize:12] forKeyPath:@"_placeholderLabel.font"];
    [self.view addSubview:yanzhengTextField];
    
    UIView* lineView=[[UIView alloc]initWithFrame:CGRectMake(128.06, 244.96, 223, 1)];
    lineView.layer.borderWidth=1;
    lineView.layer.borderColor=ssRGBHex(0xFF7474).CGColor;
    [self.view addSubview:lineView];
    
    
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
    
    UIButton* defineBtn=[[UIButton alloc]initWithFrame:CGRectMake(58.51, 601.37, 298.08, 46.34)];
    defineBtn.layer.cornerRadius=25;
    defineBtn.backgroundColor=ssRGBHex(0xFF7474);
    [defineBtn setTitle:@"验证" forState:UIControlStateNormal];
    defineBtn.titleLabel.font=[UIFont systemFontOfSize:14];
    [defineBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [defineBtn addTarget:self action:@selector(pushToResetPass) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:defineBtn];
}

-(void)getYzm{
    NSDictionary* dataDic=[ConnectionFunction getYzm:[phonenumber.text longLongValue]];
    if ([[dataDic valueForKey:@"message"]isEqualToString:@"success"]) {
        [self warnMsg:@"已发送，1分钟有效"];
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

-(void)popBack{
    [self.navigationController popViewControllerAnimated:true];
}
-(void)pushToResetPass{
//    NSDictionary* dataDic=[ConnectionFunction verifyYzm:[phonenumber.text longLongValue] yzm:[yanzhengTextField.text intValue]];
//    NSLog(@"验证结果是：%@",[dataDic valueForKey:@"message"]);
//    if ([[dataDic valueForKey:@"message"]isEqualToString:@"success"]) {
//        if (resetPass==nil) {
//            resetPass.phoneNumber=phonenumber.text;
//            resetPass = [[ResetPassViewController alloc]init];
//        }
//        [self.navigationController pushViewController:resetPass animated:true];
//    }else{
//        [self warnMsg:[dataDic valueForKey:@"message"]];
//    }
            if (resetPass==nil) {
                resetPass = [[ResetPassViewController alloc]init];
                resetPass.phoneNumber=phonenumber.text;
            }
            [self.navigationController pushViewController:resetPass animated:true];
}
@end
