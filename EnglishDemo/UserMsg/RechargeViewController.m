//
//  RechargeViewController.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/16.
//  Copyright © 2018年 马一轩. All rights reserved.
//

#import "RechargeViewController.h"
#import "../Functions/BackgroundImageWithColor.h"
#import "../Functions/ConnectionFunction.h"
#import "../Functions/DocuOperate.h"
#import "../Functions/PayMethods.h"
#import "../Functions/AgentFunction.h"
#import "../Functions/WarningWindow.h"
#import "../Common/HeadView.h"
#import "../WeChatSDK/WeChatSDK1.8.3/WXApi.h"
#import "Masonry.h"
#import <objc/runtime.h>

#import <PassKit/PassKit.h>                                 //用户绑定的银行卡信息
#import <PassKit/PKPaymentAuthorizationViewController.h>    //Apple pay的展示控件
#import <AddressBook/AddressBook.h>                         //用户联系信息相关

@interface RechargeViewController ()
{
    NSDictionary* userInfo;
    //策略视图
    UIView* strategyView;
    //学分提示
    UILabel* moneyTip;
    UITextField* inputMoneyField;
    int score;
    int money;
    
    NSMutableArray *summaryItems;
    NSMutableArray *shippingMethods;
}

@end

@implementation RechargeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    score=0;
    money=0;
    [self titleShow];
    [self inputMoney];
    [self addScoreTip];
    [self stategyView];
}
-(void)viewWillAppear:(BOOL)animated{
    if ([DocuOperate fileExistInPath:@"userInfo.plist"]) {
        userInfo=[DocuOperate readFromPlist:@"userInfo.plist"];
    }
     [self payBtn];
}
-(void)titleShow{
    [HeadView titleShow:@"学分充值" Color:ssRGBHex(0xFF7474) UIView:self.view UINavigationController:self.navigationController];
}
-(void)inputMoney{
    UILabel* inputMoneyLable=[[UILabel alloc]init];
    inputMoneyLable.text=@"输入金额：";
    inputMoneyLable.font=[UIFont systemFontOfSize:14];
    inputMoneyLable.textColor=ssRGBHex(0x4A4A4A);
    [self.view addSubview:inputMoneyLable];
    
    [inputMoneyLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(20);
        make.top.equalTo(self.view).with.offset(127);
        make.height.equalTo(@22);
        make.width.equalTo(@77);
    }];
    
    inputMoneyField=[[UITextField alloc]init];
    inputMoneyField.backgroundColor=ssRGBHex(0xFCF8F7);
    inputMoneyField.placeholder=@"请输入金额";
    //[inputMoneyField setValue:[UIFont boldSystemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
    
    Ivar ivar =  class_getInstanceVariable([UITextField class], "_placeholderLabel");
    UILabel *placeholderLabel = object_getIvar(inputMoneyField, ivar);
    placeholderLabel.font = [UIFont boldSystemFontOfSize:12];
    
    [inputMoneyField addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:inputMoneyField];
    
    [inputMoneyField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(127);
        make.left.equalTo(inputMoneyLable.mas_right).offset(10);
        make.height.equalTo(@25);
        make.right.equalTo(self.view).offset(-20);
    }];
    
    moneyTip=[[UILabel alloc]init];
    moneyTip.textColor=ssRGBHex(0xFF7474);
    moneyTip.font=[UIFont systemFontOfSize:12];
    [self.view addSubview:moneyTip];
    
    [moneyTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->inputMoneyField);
        make.top.equalTo(self->inputMoneyField.mas_bottom).offset(12);
        make.width.equalTo(@200);
    }];
    
    

}
-(void)addScoreTip{
    NSString* moneyAndScore=[NSString stringWithFormat:@"%d",money];
    moneyAndScore=[moneyAndScore stringByAppendingString:@"元 = "];
    moneyAndScore=[moneyAndScore stringByAppendingString:[NSString stringWithFormat:@"%d",score]];
    moneyAndScore=[moneyAndScore stringByAppendingString:@"学分"];
    moneyTip.text=moneyAndScore;
}

-(void)changedTextField:(UITextField*)textField
{
    money=[textField.text intValue];
    score=[[[AgentFunction getScore:money]valueForKey:@"score"]intValue];
    [self addScoreTip];
}

-(void)stategyView{
    UITextView* strategiesState=[[UITextView alloc]init];
    strategiesState.text=@"根据充值金额的大小赠送相应数量的学分，具体规则如下：\n \n1、金额 < 5元，不赠送学分，学分=金额*100；\n \n2、5元<=金额<10元，赠送0.2倍学分，学分=金额*1.2*100；\n \n3、10元<=金额<20元，赠送0.4倍学分，学分=金额*1.4*100；\n \n4、20元<=金额，赠送0.6倍学分，学分=金额*1.6*100";
    strategiesState.font=[UIFont systemFontOfSize:14];
    strategiesState.textColor=ssRGBHex(0x4A4A4A);
    strategiesState.editable=false;
    [self.view addSubview:strategiesState];
    
    [strategiesState mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.top.equalTo(self.view).offset(200);
        make.right.equalTo(@-30);
        make.bottom.equalTo(self.view).offset(-200);
    }];
}
-(void)payBtn{
    
    UIButton* weixinBtn=[[UIButton alloc]init];
    [weixinBtn setTitle:@"微信支付" forState:UIControlStateNormal];
    weixinBtn.titleLabel.font=[UIFont systemFontOfSize:14];
    [weixinBtn setTitleColor:ssRGBHex(0x4A4A4A) forState:UIControlStateNormal];
    weixinBtn.backgroundColor=[UIColor whiteColor];
    weixinBtn.layer.borderColor=ssRGBHex(0x9B9B9B).CGColor;
    weixinBtn.layer.borderWidth=1;
    [weixinBtn addTarget:self action:@selector(WeChatpay) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:weixinBtn];
    
    UIImageView* weixinPic=[[UIImageView alloc]init];
    weixinPic.image=[UIImage imageNamed:@"icon_weixinzhifu"];
    [weixinBtn addSubview:weixinPic];
    
    UIButton* zhifubaoBtn=[[UIButton alloc]init];
    [zhifubaoBtn setTitle:@"支付宝支付" forState:UIControlStateNormal];
    zhifubaoBtn.titleLabel.font=[UIFont systemFontOfSize:14];
    [zhifubaoBtn setTitleColor:ssRGBHex(0x4A4A4A) forState:UIControlStateNormal];
    zhifubaoBtn.backgroundColor=[UIColor whiteColor];
    [zhifubaoBtn addTarget:self action:@selector(Alipay) forControlEvents:UIControlEventTouchUpInside];
    zhifubaoBtn.layer.borderColor=ssRGBHex(0x9B9B9B).CGColor;
    zhifubaoBtn.layer.borderWidth=1;
    [self.view addSubview:zhifubaoBtn];
    
    UIImageView* zhifubaoPic=[[UIImageView alloc]init];
    zhifubaoPic.image=[UIImage imageNamed:@"icon_zhifubaozhifu"];
    [zhifubaoBtn addSubview:zhifubaoPic];
    
    [zhifubaoPic mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(zhifubaoBtn).offset(11);
        make.height.equalTo(@28);
        make.width.equalTo(@28);
        make.top.equalTo(zhifubaoBtn).offset(11);
    }];
    
    [zhifubaoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(50);
        make.height.equalTo(@50);
        make.right.equalTo(@-50);
        make.top.equalTo(weixinBtn.mas_bottom).offset(20);
    }];

    [weixinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(50);
        make.height.equalTo(@50);
        make.right.equalTo(@-50);
        make.bottom.equalTo(self.view).offset(-150);
    }];
    
    [weixinPic mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weixinBtn).offset(11);
        make.height.equalTo(@28);
        make.width.equalTo(@28);
        make.top.equalTo(weixinBtn).offset(11);
    }];
    
}
-(void)wasClicked:(UIButton*)btn{
    if (btn!= self.selectedBtn) {
        self.selectedBtn.selected = NO;
        btn.selected = YES;
        self.selectedBtn = btn;
    }else{
        self.selectedBtn.selected = YES;
        
    }
    
}
-(void)Alipay{
    if(![self isNumber:inputMoneyField.text]){
        [self presentViewController:[WarningWindow MsgWithoutTrans:@"输入金额格式不正确。"] animated:YES completion:nil];
        return;
        
    }
    if (userInfo==nil) {
        NSLog(@"请先登录");
        [self presentViewController:[WarningWindow transToLogin:@"您尚未登录，请先登录再充值！" Navigation:self.navigationController] animated:YES completion:nil];
    }else{
        NSLog(@"userInfo%@",userInfo);
        NSDictionary* payDic=[ConnectionFunction Alipay:[userInfo valueForKey:@"userKey"]
                                                  Money:[NSString stringWithFormat:@"%d",money]
                                               Strategy:[[AgentFunction getScore:money]
                                                         valueForKey:@"strategy"]];
        [PayMethods toAlipay:[payDic valueForKey:@"data"]];
        
    }
}
-(void)WeChatpay{
    if(![self isNumber:inputMoneyField.text]){
        [self presentViewController:[WarningWindow MsgWithoutTrans:@"输入金额格式不正确。"] animated:YES completion:nil];
        return;
        
    }
    if (![WXApi isWXAppInstalled]) {
         [self presentViewController:[WarningWindow MsgWithoutTrans:@"您未下载微信！"] animated:YES completion:nil];
        return;
    }
    if (userInfo==nil) {
        NSLog(@"请先登录");
        [self presentViewController:[WarningWindow transToLogin:@"您尚未登录，请先登录再充值！" Navigation:self.navigationController] animated:YES completion:nil];
    }else{
        NSDictionary* wxDic=[[ConnectionFunction WeChatpay:[userInfo valueForKey:@"userKey"]
                                                     Money:[NSString stringWithFormat:@"%d",money]
                                                  Strategy:[[AgentFunction getScore:money]
                                                            valueForKey:@"strategy"]]valueForKey:@"data"];
        
        [PayMethods toWXpay:[wxDic valueForKey:@"appid"]
                  PartnerId:[wxDic valueForKey:@"partnerid"]
                   PrepayId:[wxDic valueForKey:@"prepayid"]
                    Package:[wxDic valueForKey:@"package"]
                   NonceStr:[wxDic valueForKey:@"noncestr"]
                  TimeStamp:[[wxDic valueForKey:@"timestamp"]intValue]
                       Sign:[wxDic valueForKey:@"sign"]];

        
    }
}

- (BOOL)isNumber:(NSString *)strValue
{
    if (strValue == nil || [strValue length] <= 0)
    {
        return NO;
    }
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
    NSString *filtered = [[strValue componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    if (![strValue isEqualToString:filtered])
    {
        return NO;
    }
    return YES;
}
//点击背景收起键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES]; //实现该方法是需要注意view需要是继承UIControl而来的
}



-(void)popBack{
    [self.navigationController popViewControllerAnimated:true];
}
@end
