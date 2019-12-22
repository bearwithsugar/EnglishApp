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

@interface RechargeViewController ()<PKPaymentAuthorizationViewControllerDelegate>
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
    [weixinBtn addTarget:self action:@selector(AppPay2) forControlEvents:UIControlEventTouchUpInside];
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

-(void)AppPay{
    
    if (![PKPaymentAuthorizationViewController class]) {
            //PKPaymentAuthorizationViewController需iOS8.0以上支持
            NSLog(@"操作系统不支持ApplePay，请升级至9.0以上版本，且iPhone6以上设备才支持");
            return;
        }
        //检查当前设备是否可以支付
        if (![PKPaymentAuthorizationViewController canMakePayments]) {
            //支付需iOS9.0以上支持
            NSLog(@"设备不支持ApplePay，请升级至9.0以上版本，且iPhone6以上设备才支持");
            return;
        }
        //检查用户是否可进行某种卡的支付，是否支持Amex、MasterCard、Visa与银联四种卡，根据自己项目的需要进行检测
        NSArray *supportedNetworks = @[PKPaymentNetworkAmex, PKPaymentNetworkMasterCard,PKPaymentNetworkVisa,PKPaymentNetworkChinaUnionPay];
        if (![PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:supportedNetworks]) {
            NSLog(@"没有绑定支付卡");
            return;
        }
        NSLog(@"可以支付，开始建立支付请求");
        //设置币种、国家码及merchant标识符等基本信息
        PKPaymentRequest *payRequest = [[PKPaymentRequest alloc]init];
        payRequest.countryCode = @"CN";     //国家代码
        payRequest.currencyCode = @"CNY";       //RMB的币种代码
        payRequest.merchantIdentifier = @"merchant.XueBenApp";  //申请的merchantID
        payRequest.supportedNetworks = supportedNetworks;   //用户可进行支付的银行卡
        payRequest.merchantCapabilities = PKMerchantCapability3DS|PKMerchantCapabilityEMV;      //设置支持的交易处理协议，3DS必须支持，EMV为可选，目前国内的话还是使用两者吧
    //    payRequest.requiredBillingAddressFields = PKAddressFieldEmail;
        //如果需要邮寄账单可以选择进行设置，默认PKAddressFieldNone(不邮寄账单)
        //楼主感觉账单邮寄地址可以事先让用户选择是否需要，否则会增加客户的输入麻烦度，体验不好，
        //payRequest.requiredShippingAddressFields = PKAddressFieldPostalAddress|PKAddressFieldPhone|PKAddressFieldName;
        //送货地址信息，这里设置需要地址和联系方式和姓名，如果需要进行设置，默认PKAddressFieldNone(没有送货地址)
    //
        //设置两种配送方式
        PKShippingMethod *freeShipping = [PKShippingMethod summaryItemWithLabel:@"包邮" amount:[NSDecimalNumber zero]];
        freeShipping.identifier = @"freeshipping";
        freeShipping.detail = @"6-8 天 送达";
        
        PKShippingMethod *expressShipping = [PKShippingMethod summaryItemWithLabel:@"极速送达" amount:[NSDecimalNumber decimalNumberWithString:@"10.00"]];
        expressShipping.identifier = @"expressshipping";
        expressShipping.detail = @"2-3 小时 送达";
        shippingMethods = [NSMutableArray arrayWithArray:@[freeShipping, expressShipping]];
        //shippingMethods为配送方式列表，类型是 NSMutableArray，这里设置成成员变量，在后续的代理回调中可以进行配送方式的调整。
        payRequest.shippingMethods = shippingMethods;
        
        
        
        NSDecimalNumber *subtotalAmount = [NSDecimalNumber decimalNumberWithMantissa:1275 exponent:-2 isNegative:NO];   //12.75
        PKPaymentSummaryItem *subtotal = [PKPaymentSummaryItem summaryItemWithLabel:@"商品价格" amount:subtotalAmount];
        
        NSDecimalNumber *discountAmount = [NSDecimalNumber decimalNumberWithString:@"-12.74"];      //-12.74
        PKPaymentSummaryItem *discount = [PKPaymentSummaryItem summaryItemWithLabel:@"优惠折扣" amount:discountAmount];
        
        NSDecimalNumber *methodsAmount = [NSDecimalNumber zero];
        PKPaymentSummaryItem *methods = [PKPaymentSummaryItem summaryItemWithLabel:@"包邮" amount:methodsAmount];
        
        NSDecimalNumber *totalAmount = [NSDecimalNumber zero];
        totalAmount = [totalAmount decimalNumberByAdding:subtotalAmount];
        totalAmount = [totalAmount decimalNumberByAdding:discountAmount];
        totalAmount = [totalAmount decimalNumberByAdding:methodsAmount];
        PKPaymentSummaryItem *total = [PKPaymentSummaryItem summaryItemWithLabel:@"Yasin" amount:totalAmount];  //最后这个是支付给谁。哈哈，快支付给我
        
        summaryItems = [NSMutableArray arrayWithArray:@[subtotal, discount, methods, total]];
        //summaryItems为账单列表，类型是 NSMutableArray，这里设置成成员变量，在后续的代理回调中可以进行支付金额的调整。
        payRequest.paymentSummaryItems = summaryItems;
        
        
        //ApplePay控件
        PKPaymentAuthorizationViewController *view = [[PKPaymentAuthorizationViewController alloc]initWithPaymentRequest:payRequest];
        view.delegate = self;
        [self presentViewController:view animated:YES completion:nil];
}

-(void)AppPay2{
    if (! [PKPaymentAuthorizationViewController canMakePayments]) {
        // 提示用户该设备不支持Apple Pay
        NSLog(@"该设备不支持Apple Pay");
        return ;
    }
    PKPaymentRequest *request = [[PKPaymentRequest alloc] init];
    // 设置国家代码
    request.countryCode = @"US";
    //设置商户ID
    request.merchantIdentifier = @"merchant.XueBenApp";
    // 支付银行卡的范围
    request.merchantCapabilities = PKMerchantCapability3DS;
    // 支持的币种
    request.currencyCode = @"$";
    // 支付金额及商户名称
    request.paymentSummaryItems = [self paymentSummaryItems];
    // 收货地址
    request.shippingContact = [self shippingContact];
    // 显示地址信息
    //request.requiredShippingContactFields=PKContactFieldPostalAddress ;
    if (@available(iOS 10.0, *)) {
       request.supportedNetworks = [PKPaymentRequest availableNetworks];
    }
}

// 商品价格等信息
- (NSArray<PKPaymentSummaryItem *> *)paymentSummaryItems {
    NSMutableArray *items = [NSMutableArray array];
    PKPaymentSummaryItem *grandTotalItem = [PKPaymentSummaryItem summaryItemWithLabel:@"商户名称 " amount:[NSDecimalNumber decimalNumberWithString:@"10.0"] type:PKPaymentSummaryItemTypeFinal];
    [items addObject:grandTotalItem];
    return items;
}
// 收货地址信息
- (PKContact*)shippingContact {
    PKContact *contact = [[PKContact alloc]init];
    contact.name = ({
        NSPersonNameComponents *nameComponents = [[NSPersonNameComponents alloc] init];
        nameComponents.familyName = @"familyName";
        nameComponents.givenName = @"givenName";
        nameComponents;
    });
    contact.phoneNumber = [CNPhoneNumber phoneNumberWithStringValue:@"13142220635"];
    contact.emailAddress = @"emailAddress";
    contact.postalAddress = ({
        CNMutablePostalAddress *address = [[CNMutablePostalAddress alloc] init];
        address.street =@"street";
        address.city = @"city";
        address.state = @"state";
        address.postalCode = @"postalCode";
        address.country = @"country";
        address.ISOCountryCode = @"ISOCountryCode";
        address;
    });
    return contact;
}

-(void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion {
    //这里可以校验用户输入的账单地址和收货地址填的规格对不对，如果表单显示了用户账单地址和收货地址的话，用户是可以修改的
    //PKContact *billing = payment.billingContact;
    //PKContact *shipping = payment.shippingContact;

    //校验通后将payment.token相关支付信息发送给服务器，根据服务器返回的支付成功和失败做相应处理
     NSString *data = [[NSString alloc] initWithData:payment.token.paymentData
                                           encoding:NSUTF8StringEncoding];
     //解析json
     //拿到header,signature,data等相关字段传给App服务器
 }
- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
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
