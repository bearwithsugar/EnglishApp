//
//  RechargeViewController.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/16.
//  Copyright © 2018年 马一轩. All rights reserved.
//

#import "RechargeViewController.h"
#import "../Functions/BackgroundImageWithColor.h"
#import "../Functions/netOperate/ConnectionFunction.h"
#import "../Functions/netOperate/NetSenderFunction.h"
#import "../Functions/DocuOperate.h"
#import "../Functions/PayMethods.h"
#import "../Functions/AgentFunction.h"
#import "../Functions/WarningWindow.h"
#import "../Common/HeadView.h"
#import "../WeChatSDK/WeChatSDK1.8.3/WXApi.h"
#import "../SVProgressHUD/SVProgressHUD.h"
#import "../Functions/MyThreadPool.h"
#import "../Functions/FixValues.h"
#import "Masonry.h"
#import <objc/runtime.h>
#import <StoreKit/StoreKit.h>

@interface RechargeViewController ()<SKPaymentTransactionObserver,SKProductsRequestDelegate>
{
    NSDictionary* userInfo;
    //策略视图
    UIView* strategyView;
    //学分提示
    UILabel* moneyTip;
    UITextField* inputMoneyField;
    int score;
    int money;
    
    UILabel* xuefenNumber;
    
    NSMutableArray *summaryItems;
    NSMutableArray *shippingMethods;
}
@property (nonatomic,strong) NSArray *profuctIdArr;
@property (nonatomic,copy) NSString *currentProId;
@end

@implementation RechargeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    score=0;
    money=0;
    [self titleShow];
    //[self inputMoney];
    //[self addScoreTip];
    //[self stategyView];
    xuefenNumber = [[UILabel alloc]init];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [self newStrategyView];
}
-(void)viewWillAppear:(BOOL)animated{
    if ([DocuOperate fileExistInPath:@"userInfo.plist"]) {
        userInfo=[DocuOperate readFromPlist:@"userInfo.plist"];
    }
     //[self payBtn];
    [self refreshXuefen];
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
//===================================================================
-(void)refreshXuefen{
    
    [MyThreadPool executeJob:^{
      NSURL* url=[FixValues getUrl];
        url=[url URLByAppendingPathComponent:@"account/score"];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSURLSession *session=[NSURLSession sharedSession];
        //添加请求头
        NSDictionary *headers = @{@"English-user": [self->userInfo valueForKey:@"userKey"]};
        [request setHTTPMethod:@"GET"];
        [request setAllHTTPHeaderFields:headers];
        
        NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSDictionary* dictionary=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            CFRunLoopStop(CFRunLoopGetMain());
            dispatch_async(dispatch_get_main_queue(), ^{
                self->xuefenNumber.text = [NSString stringWithFormat:@"%@",[dictionary valueForKey:@"data"]];

                   });
           
        }];
        [dataTask resume];
        //这里恢复RunLoop
        CFRunLoopRun();
    } Main:^{}];

  
}
-(void)newStrategyView{
    
    UIView* contentPanelView = [[UIView alloc]init];
    [self.view addSubview:contentPanelView];
    [contentPanelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(80);
        make.right.equalTo(self.view);
        make.left.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    UILabel* xuefenTip = [[UILabel alloc]init];
    xuefenTip.text = @"当前学分：";
    xuefenTip.textColor = ssRGBHex(0x9B9B9B);
    xuefenTip.font = [UIFont systemFontOfSize:14];
    xuefenTip.textAlignment = NSTextAlignmentRight;
    [contentPanelView addSubview:xuefenTip];
    [xuefenTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentPanelView);
        make.left.equalTo(contentPanelView);
        make.width.equalTo(contentPanelView).multipliedBy(0.5);
        make.height.equalTo(@100);
    }];
    
    xuefenNumber.textColor = ssRGBHex(0xFF7474);
    xuefenNumber.font = [UIFont systemFontOfSize:30];
    xuefenNumber.textAlignment = NSTextAlignmentLeft;
    [contentPanelView addSubview:xuefenNumber];
    [xuefenNumber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentPanelView);
        make.left.equalTo(xuefenTip.mas_right);
        make.right.equalTo(contentPanelView);
        make.height.equalTo(@100);
    }];
    
    UIButton* strategy1=[[UIButton alloc]init];
    [strategy1 setTitle:@"￥1\n100学分" forState:UIControlStateNormal];
    strategy1.titleLabel.font=[UIFont systemFontOfSize:14];
    strategy1.titleLabel.numberOfLines = 0;
    [strategy1 setTitleColor:ssRGBHex(0x4A4A4A) forState:UIControlStateNormal];
    strategy1.layer.borderColor=ssRGBHex(0xFF7474).CGColor;
    strategy1.layer.borderWidth=1;
    strategy1.layer.cornerRadius=10;
//    strategy1.layer.shadowOffset =  CGSizeMake(3, 3);
//    strategy1.layer.shadowOpacity = 0.8;
//    strategy1.layer.shadowColor =  [UIColor blackColor].CGColor;
    strategy1.tag = 100;
    [strategy1 addTarget:self action:@selector(AppStorePay:) forControlEvents:UIControlEventTouchUpInside];
    [contentPanelView addSubview:strategy1];
    [strategy1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(xuefenTip.mas_bottom).offset(50);
        make.left.equalTo(contentPanelView).offset(50);
        make.width.equalTo(contentPanelView).multipliedBy(0.3);
        make.height.equalTo(contentPanelView).multipliedBy(0.2);
    }];
    
    UIButton* strategy2=[[UIButton alloc]init];
    [strategy2 setTitle:@"￥6\n720学分" forState:UIControlStateNormal];
    strategy2.titleLabel.font=[UIFont systemFontOfSize:14];
    strategy2.titleLabel.numberOfLines = 0;
    [strategy2 setTitleColor:ssRGBHex(0x4A4A4A) forState:UIControlStateNormal];
    strategy2.layer.borderColor=ssRGBHex(0xFF7474).CGColor;
    strategy2.layer.borderWidth=1;
    strategy2.layer.cornerRadius=10;
//    strategy2.layer.shadowOffset =  CGSizeMake(3, 3);
//    strategy2.layer.shadowOpacity = 0.8;
//    strategy2.layer.shadowColor =  [UIColor blackColor].CGColor;
    strategy2.tag = 200;
    [strategy2 addTarget:self action:@selector(AppStorePay:) forControlEvents:UIControlEventTouchUpInside];
    [contentPanelView addSubview:strategy2];
    [strategy2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(xuefenTip.mas_bottom).offset(50);
        make.right.equalTo(contentPanelView).offset(-50);
        make.width.equalTo(contentPanelView).multipliedBy(0.3);
        make.height.equalTo(contentPanelView).multipliedBy(0.2);
    }];
    
    UIButton* strategy3=[[UIButton alloc]init];
    [strategy3 setTitle:@"￥12\n1680学分" forState:UIControlStateNormal];
    strategy3.titleLabel.font=[UIFont systemFontOfSize:14];
    strategy3.titleLabel.numberOfLines = 0;
    [strategy3 setTitleColor:ssRGBHex(0x4A4A4A) forState:UIControlStateNormal];
    strategy3.layer.borderColor=ssRGBHex(0xFF7474).CGColor;
    strategy3.layer.borderWidth=1;
    strategy3.layer.cornerRadius=10;
//    strategy3.layer.shadowOffset =  CGSizeMake(3, 3);
//    strategy3.layer.shadowOpacity = 0.8;
//    strategy3.layer.shadowColor =  [UIColor blackColor].CGColor;
    strategy3.tag = 300;
    [strategy3 addTarget:self action:@selector(AppStorePay:) forControlEvents:UIControlEventTouchUpInside];
    [contentPanelView addSubview:strategy3];
    [strategy3 mas_makeConstraints:^(MASConstraintMaker *make) {
       make.top.equalTo(strategy1.mas_bottom).offset(50);
       make.left.equalTo(contentPanelView).offset(50);
       make.width.equalTo(contentPanelView).multipliedBy(0.3);
       make.height.equalTo(contentPanelView).multipliedBy(0.2);
    }];
    
    
    UIButton* strategy4=[[UIButton alloc]init];
    [strategy4 setTitle:@"￥30\n4800学分" forState:UIControlStateNormal];
    strategy4.titleLabel.font=[UIFont systemFontOfSize:14];
    strategy4.titleLabel.numberOfLines = 0;
    [strategy4 setTitleColor:ssRGBHex(0x4A4A4A) forState:UIControlStateNormal];
    strategy4.layer.borderColor=ssRGBHex(0xFF7474).CGColor;
    strategy4.layer.borderWidth=1;
    strategy4.layer.cornerRadius=10;
//    strategy4.layer.shadowOffset =  CGSizeMake(3, 3);
//    strategy4.layer.shadowOpacity = 0.8;
//    strategy4.layer.shadowColor =  [UIColor blackColor].CGColor;
    strategy4.tag = 400;
    [strategy4 addTarget:self action:@selector(AppStorePay:) forControlEvents:UIControlEventTouchUpInside];
    [contentPanelView addSubview:strategy4];
    [strategy4 mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(strategy2.mas_bottom).offset(50);
      make.right.equalTo(contentPanelView).offset(-50);
      make.width.equalTo(contentPanelView).multipliedBy(0.3);
      make.height.equalTo(contentPanelView).multipliedBy(0.2);
    }];
    
}
-(void)strategyOneToPay{
    
}
-(void)AppStorePay:(UIButton*)btn{
    NSString* product = [@"xuefen" stringByAppendingString:[NSString stringWithFormat:@"%ld",btn.tag]];
    _currentProId = product;
    if([SKPaymentQueue canMakePayments]){
       [self requestProductData:product];
    }else{
       NSLog(@"不允许程序内付费");
    }
}

//请求商品
- (void)requestProductData:(NSString *)type{
    NSLog(@"-------------请求对应的产品信息----------------");
    
    [SVProgressHUD showWithStatus:nil maskType:SVProgressHUDMaskTypeBlack];
    
    NSArray *product = [[NSArray alloc] initWithObjects:type,nil];
    
    NSSet *nsset = [NSSet setWithArray:product];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
    request.delegate = self;
    [request start];
    
}

//收到产品返回信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    
    NSLog(@"--------------收到产品反馈消息---------------------");
    NSArray *product = response.products;
    if([product count] == 0){
        [SVProgressHUD dismiss];
        NSLog(@"--------------没有商品------------------");
        return;
    }
    
    NSLog(@"productID:%@", response.invalidProductIdentifiers);
    NSLog(@"产品付费数量:%lu",(unsigned long)[product count]);
    
    SKProduct *p = nil;
    for (SKProduct *pro in product) {
        NSLog(@"%@", [pro description]);
        NSLog(@"%@", [pro localizedTitle]);
        NSLog(@"%@", [pro localizedDescription]);
        NSLog(@"%@", [pro price]);
        NSLog(@"%@", [pro productIdentifier]);
        
        if([pro.productIdentifier isEqualToString:_currentProId]){
            p = pro;
        }
    }
    
    SKPayment *payment = [SKPayment paymentWithProduct:p];
    
    NSLog(@"发送购买请求");
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

//请求失败
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    [SVProgressHUD showErrorWithStatus:@"支付失败"];
    NSLog(@"------------------错误-----------------:%@", error);
}

- (void)requestDidFinish:(SKRequest *)request{
    NSLog(@"------------反馈信息结束-----------------");
}
//沙盒测试环境验证
#define SANDBOX @"https://sandbox.itunes.apple.com/verifyReceipt"
//正式环境验证
#define AppStore @"https://buy.itunes.apple.com/verifyReceipt"
/**
 *  验证购买，避免越狱软件模拟苹果请求达到非法购买问题
 *
 */
-(void)verifyPurchaseWithPaymentTransaction{
    
//以下是拼接请求头的过程
    //从沙盒中获取交易凭证并且拼接成请求体数据
    NSURL *receiptUrl=[[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData=[NSData dataWithContentsOfURL:receiptUrl];
    NSString *receiptString=[receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];//转化为base64字符串
    NSString *bodyString = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\"}", receiptString];//拼接请求数据
    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    //创建请求到苹果官方进行购买验证
    NSURL *url=[NSURL URLWithString:SANDBOX];
    //NSURL *url=[NSURL URLWithString:AppStore];
    
//网络请求而已。。
    NSURLSession *session=[NSURLSession sharedSession];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    //添加请求头
    request.HTTPBody=bodyData;
    request.HTTPMethod=@"POST";
    [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    static NSDictionary *dic;
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
       dic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
       //这里改变RunLoop模式
       CFRunLoopStop(CFRunLoopGetMain());

    }];
    [dataTask resume];
    //这里恢复RunLoop
    CFRunLoopRun();
//网络请求结束
    NSLog(@"验证支付返回信息%@",dic);
    if([dic[@"status"] intValue]==0){
        [SVProgressHUD dismiss];
        if (!(dic == nil)) {
            NetSenderFunction* sender = [[NetSenderFunction alloc]init];
            ConBlock conBlk = ^(NSDictionary* dic){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self refreshXuefen];
                });
            };
             NSLog(@"购买成功！");
            NSArray* strategy = [[[dic valueForKey:@"receipt"]
                                   valueForKey:@"in_app"]
                                  valueForKey:@"product_id"];
            if ([strategy[0] isEqualToString:@"xuefen100"]) {
                [sender postRequestWithHead:[[ConnectionFunction getInstance]increaseScore_Post_H:@"1" StrategyId:@"1"] Head:[userInfo valueForKey:@"userKey"] Block:conBlk];
            }else if ([strategy[0] isEqualToString:@"xuefen200"]) {
                [sender postRequestWithHead:[[ConnectionFunction getInstance]increaseScore_Post_H:@"6" StrategyId:@"1"] Head:[userInfo valueForKey:@"userKey"] Block:conBlk];
            }else if ([strategy[0] isEqualToString:@"xuefen300"]) {
                [sender postRequestWithHead:[[ConnectionFunction getInstance]increaseScore_Post_H:@"12" StrategyId:@"1"] Head:[userInfo valueForKey:@"userKey"] Block:conBlk];
            }else if ([strategy[0] isEqualToString:@"xuefen400"]) {
                [sender postRequestWithHead:[[ConnectionFunction getInstance]increaseScore_Post_H:@"30" StrategyId:@"1"] Head:[userInfo valueForKey:@"userKey"] Block:conBlk];
            }
   
        }

    }else{
        NSLog(@"购买失败，未通过验证！");
    }
}
//监听购买结果
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transaction{
    
    
    for(SKPaymentTransaction *tran in transaction){
        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchased:{
                NSLog(@"交易完成");
                [self verifyPurchaseWithPaymentTransaction];
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
            }
                break;
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"商品添加进列表");
                break;
            case SKPaymentTransactionStateRestored:{
                NSLog(@"已经购买过商品");
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
            }
                break;
            case SKPaymentTransactionStateFailed:{
                NSLog(@"交易失败");
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                [SVProgressHUD showErrorWithStatus:@"购买失败"];
            }
                break;
            default:
                break;
        }
    }
}

//交易结束
- (void)completeTransaction:(SKPaymentTransaction *)transaction{
    NSLog(@"交易结束");
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)dealloc{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//===================================================================

//-(void)payBtn{
//
//    UIButton* weixinBtn=[[UIButton alloc]init];
//    [weixinBtn setTitle:@"微信支付" forState:UIControlStateNormal];
//    weixinBtn.titleLabel.font=[UIFont systemFontOfSize:14];
//    [weixinBtn setTitleColor:ssRGBHex(0x4A4A4A) forState:UIControlStateNormal];
//    weixinBtn.backgroundColor=[UIColor whiteColor];
//    weixinBtn.layer.borderColor=ssRGBHex(0x9B9B9B).CGColor;
//    weixinBtn.layer.borderWidth=1;
//    [weixinBtn addTarget:self action:@selector(WeChatpay) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:weixinBtn];
//
//    UIImageView* weixinPic=[[UIImageView alloc]init];
//    weixinPic.image=[UIImage imageNamed:@"icon_weixinzhifu"];
//    [weixinBtn addSubview:weixinPic];
//
//    UIButton* zhifubaoBtn=[[UIButton alloc]init];
//    [zhifubaoBtn setTitle:@"支付宝支付" forState:UIControlStateNormal];
//    zhifubaoBtn.titleLabel.font=[UIFont systemFontOfSize:14];
//    [zhifubaoBtn setTitleColor:ssRGBHex(0x4A4A4A) forState:UIControlStateNormal];
//    zhifubaoBtn.backgroundColor=[UIColor whiteColor];
//    [zhifubaoBtn addTarget:self action:@selector(Alipay) forControlEvents:UIControlEventTouchUpInside];
//    zhifubaoBtn.layer.borderColor=ssRGBHex(0x9B9B9B).CGColor;
//    zhifubaoBtn.layer.borderWidth=1;
//    [self.view addSubview:zhifubaoBtn];
//
//    UIImageView* zhifubaoPic=[[UIImageView alloc]init];
//    zhifubaoPic.image=[UIImage imageNamed:@"icon_zhifubaozhifu"];
//    [zhifubaoBtn addSubview:zhifubaoPic];
//
//    [zhifubaoPic mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(zhifubaoBtn).offset(11);
//        make.height.equalTo(@28);
//        make.width.equalTo(@28);
//        make.top.equalTo(zhifubaoBtn).offset(11);
//    }];
//
//    [zhifubaoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.view).offset(50);
//        make.height.equalTo(@50);
//        make.right.equalTo(@-50);
//        make.top.equalTo(weixinBtn.mas_bottom).offset(20);
//    }];
//
//    [weixinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.view).offset(50);
//        make.height.equalTo(@50);
//        make.right.equalTo(@-50);
//        make.bottom.equalTo(self.view).offset(-150);
//    }];
//
//    [weixinPic mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(weixinBtn).offset(11);
//        make.height.equalTo(@28);
//        make.width.equalTo(@28);
//        make.top.equalTo(weixinBtn).offset(11);
//    }];
//
//}
-(void)wasClicked:(UIButton*)btn{
    if (btn!= self.selectedBtn) {
        self.selectedBtn.selected = NO;
        btn.selected = YES;
        self.selectedBtn = btn;
    }else{
        self.selectedBtn.selected = YES;
        
    }
    
}
//-(void)Alipay{
//    if(![self isNumber:inputMoneyField.text]){
//        [self presentViewController:[WarningWindow MsgWithoutTrans:@"输入金额格式不正确。"] animated:YES completion:nil];
//        return;
//
//    }
//    if (userInfo==nil) {
//        NSLog(@"请先登录");
//        [self presentViewController:[WarningWindow transToLogin:@"您尚未登录，请先登录再充值！" Navigation:self.navigationController] animated:YES completion:nil];
//    }else{
//        NSLog(@"userInfo%@",userInfo);
//        NSDictionary* payDic=[ConnectionFunction Alipay:[userInfo valueForKey:@"userKey"]
//                                                  Money:[NSString stringWithFormat:@"%d",money]
//                                               Strategy:[[AgentFunction getScore:money]
//                                                         valueForKey:@"strategy"]];
//        [PayMethods toAlipay:[payDic valueForKey:@"data"]];
//
//    }
//}
//-(void)WeChatpay{
//    if(![self isNumber:inputMoneyField.text]){
//        [self presentViewController:[WarningWindow MsgWithoutTrans:@"输入金额格式不正确。"] animated:YES completion:nil];
//        return;
//
//    }
//    if (![WXApi isWXAppInstalled]) {
//         [self presentViewController:[WarningWindow MsgWithoutTrans:@"您未下载微信！"] animated:YES completion:nil];
//        return;
//    }
//    if (userInfo==nil) {
//        NSLog(@"请先登录");
//        [self presentViewController:[WarningWindow transToLogin:@"您尚未登录，请先登录再充值！" Navigation:self.navigationController] animated:YES completion:nil];
//    }else{
//        NSDictionary* wxDic=[[ConnectionFunction WeChatpay:[userInfo valueForKey:@"userKey"]
//                                                     Money:[NSString stringWithFormat:@"%d",money]
//                                                  Strategy:[[AgentFunction getScore:money]
//                                                            valueForKey:@"strategy"]]valueForKey:@"data"];
//
//        [PayMethods toWXpay:[wxDic valueForKey:@"appid"]
//                  PartnerId:[wxDic valueForKey:@"partnerid"]
//                   PrepayId:[wxDic valueForKey:@"prepayid"]
//                    Package:[wxDic valueForKey:@"package"]
//                   NonceStr:[wxDic valueForKey:@"noncestr"]
//                  TimeStamp:[[wxDic valueForKey:@"timestamp"]intValue]
//                       Sign:[wxDic valueForKey:@"sign"]];
//
//
//    }
//}

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
