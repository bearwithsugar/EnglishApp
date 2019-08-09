//
//  CreditInstructionViewController.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/16.
//  Copyright © 2018年 马一轩. All rights reserved.
//

#import "CreditInstructionViewController.h"
#import "../Common/HeadView.h"

@interface CreditInstructionViewController ()

@end

@implementation CreditInstructionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    [self titleShow];
    [self textShow];
}
-(void)titleShow{
    [HeadView titleShow:@"学分使用说明" Color:ssRGBHex(0xFF7474) UIView:self.view UINavigationController:self.navigationController];
}
-(void)textShow{
    UITextView* textShow=[[UITextView alloc]initWithFrame:CGRectMake(22.08, 110.34, 369.83, 399.33)];
    textShow.text=@"学分在“学伴”系列软件中使用，学习每一课（单元）需要50个学分。学分可通过微信或者支付宝方式进行充值购买，也可以通过注册、贡献、分享等其他活动获取（根据软件发布的活动规则执行）。 \n1、新用户注册即可获得100学分； \n2、1元=100积分，也可通过购买套餐方式获得优惠； \n3、下载推荐的软件并注册科免费获取一定数量的学分； \n4、分享“学伴”系列软件到朋友圈可获得100学分； \n5、提交意见和反馈问题得到采纳可获得50学分。同一注册用户的学分可在“学伴”系列软件中通用，严禁通过非法途径盗取或篡改学分。 \n \n如充值成功而学分获取失败请联系客服QQ。 \n客服QQ：434594395";
    textShow.editable=false;
    textShow.textColor=ssRGBHex(0x4A4A4A);
    textShow.font=[UIFont systemFontOfSize:14];
    [self.view addSubview:textShow];
}

-(void)popBack{
    [self.navigationController popViewControllerAnimated:true];
}

@end
