//
//  OpinionViewController.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/18.
//  Copyright © 2018年 马一轩. All rights reserved.
//

#import "OpinionViewController.h"
#import <objc/message.h>
#import "../Functions/ConnectionFunction.h"
#import "../Functions/DocuOperate.h"
#import "../Functions/WarningWindow.h"
#import "../Common/HeadView.h"
#import "Masonry.h"

@interface OpinionViewController (){
    //意见
    UITextView* opinionText;
    NSDictionary* userInfo;
}

@end

@implementation OpinionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    [self titleShow];
    [self contentView];
    
    
}

-(void)titleShow{
    [HeadView titleShow:@"意见和问题反馈" Color:ssRGBHex(0xFF7474) UIView:self.view UINavigationController:self.navigationController];
}
-(void)contentView{
//    UITextField* opinionText=[[UITextField alloc]initWithFrame:CGRectMake(28.70, 116.96, 353.27, 119.23)];
//    opinionText.placeholder=@"请输入您的意见和问题，我们将及时给您回复！多谢您的支持！";
//    [self.view addSubview:opinionText];
    
    opinionText=[[UITextView alloc]init];
    [opinionText setContentInset:UIEdgeInsetsMake(5, 5, 5, 5)];
    //opinionText.placeholder=@"请输入您的意见和问题，我们将及时给您回复！多谢您的支持！";
    [self.view addSubview:opinionText];
    
    [opinionText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(117);
        make.left.equalTo(self.view).offset(22);
        make.right.equalTo(self.view).offset(-22);
        make.bottom.equalTo(self.view).offset(-100);
    }];
    
    
    NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:@"请输入您的意见和问题，我们将及时给您回复！多谢您的支持！" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor grayColor]}];

    ((void(*)(id,SEL,NSAttributedString *))objc_msgSend)(opinionText,NSSelectorFromString(@"setAttributedPlaceholder:"),attributedString);
    
    
    UIButton* submitBtn=[[UIButton alloc]init];
    [submitBtn setTitle:@"提交" forState:UIControlStateNormal];
    [submitBtn setBackgroundColor:ssRGBHex(0xFF7474)];
    [submitBtn addTarget:self action:@selector(submitOpinion) forControlEvents:UIControlEventTouchUpInside];
    submitBtn.titleLabel.font=[UIFont systemFontOfSize:14];
    [self.view addSubview:submitBtn];
    
    [submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(22);
        make.right.equalTo(self.view).offset(-22);
        make.bottom.equalTo(self.view).offset(-40);
        make.height.equalTo(@40);
    }];
}

-(void)submitOpinion{
    if ([DocuOperate fileExistInPath:@"userInfo.plist"]) {
        userInfo=[DocuOperate readFromPlist:@"userInfo.plist"];
        if (![[opinionText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]isEqualToString:@""]) {
            NSDictionary* feedbackDic=[ConnectionFunction feedback:[userInfo valueForKey:@"userKey"] Opinion:opinionText.text];
            if ([[feedbackDic valueForKey:@"message"]isEqualToString:@"success"]) {
                [self presentViewController:[WarningWindow MsgWithoutTrans:@"意见提交成功！"] animated:YES completion:nil];
            }else{
                [self presentViewController:[WarningWindow MsgWithoutTrans:@"意见提交失败，请稍后再试！"] animated:YES completion:nil];
            }
        }else{
            [self presentViewController:[WarningWindow MsgWithoutTrans:@"意见不能为空哦！"] animated:YES completion:nil];
        }
        
    }else{
        [self presentViewController:[WarningWindow transToLogin:@"您尚未登录，等您登录后在提交意见！" Navigation:self.navigationController] animated:YES completion:nil];
    }
    
}
-(void)popBack{
    [self.navigationController popViewControllerAnimated:true];
}

//点击背景收起键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES]; //实现该方法是需要注意view需要是继承UIControl而来的
}

@end
