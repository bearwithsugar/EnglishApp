//
//  ModifyUserMsgViewController.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/11/25.
//  Copyright © 2018 马一轩. All rights reserved.
//

#import "ModifyUserMsgViewController.h"
#import "../Functions/DocuOperate.h"
#import "../Functions/netOperate/ConnectionFunction.h"
#import "../Functions/netOperate/NetSenderFunction.h"
#import "../Functions/DataFilter.h"
#import "../Functions/LocalDataOperation.h"
#import "../Functions/BackgroundImageWithColor.h"
#import "../Functions/DocuOperate.h"
#import "../Functions/QQLogin.h"
#import "../Functions/MyThreadPool.h"
#import "../Functions/WechatLog.h"
#import "../DiyGroup/UnloginMsgView.h"
#import "SVProgressHUD.h"
#import "../Common/HeadView.h"
#import "../WeChatSDK/WeChatSDK1.8.3/WXApi.h"
#import "Masonry.h"
#import "../Functions/WarningWindow.h"

@interface ModifyUserMsgViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    NSDictionary* userInfo;
    UITextField* nicknameTextField;
    UITextField* phoneTextField;
    UIImageView* headPic;
    UIView* surfaceView;
    NSDictionary* binding;
    UIButton* wechatBinding;
    UIButton* QQBinding;
}

@end

@implementation ModifyUserMsgViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    [self titleView];
}

-(void)viewWillAppear:(BOOL)animated{
    if ([DocuOperate fileExistInPath:@"userInfo.plist"]) {
        userInfo=[DocuOperate readFromPlist:@"userInfo.plist"];
        [surfaceView removeFromSuperview];
        surfaceView = [UIView new];
        [self.view addSubview:surfaceView];
        [surfaceView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(75);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
        [self headPicView];
        [self detailMsg];
        [self defineBtn];
        [self loadData];
    }else{
        UnloginMsgView* unloginView=[[UnloginMsgView alloc]init];
        [self.view addSubview:unloginView];
        [unloginView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view);
            make.top.equalTo(self.view).with.offset(88.27);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
    }
    
}
-(void)titleView{
    [HeadView titleShow:@"个人信息" Color:ssRGBHex(0xFF7474) UIView:self.view UINavigationController:self.navigationController];
}
-(void)headPicView{
    
    headPic=[[UIImageView alloc]init];
    headPic.image=[UIImage imageNamed:@"icon_head"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage* headpic=[LocalDataOperation getImage:[self->userInfo valueForKey:@"userKey"]
                                              httpUrl:[self->userInfo valueForKey:@"pictureUrl"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (headpic==nil) {
            }else{
                self->headPic.image=headpic;
            }
        });
    });
    headPic.layer.cornerRadius=55;
    //把多余部分去掉
    headPic.layer.masksToBounds = YES;
    [surfaceView addSubview:headPic];
    
    [headPic mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->surfaceView).with.offset(90);
        make.height.equalTo(@110);
        make.width.equalTo(@110);
        make.centerX.equalTo(self->surfaceView);
    }];
}

-(void)detailMsg{
    UILabel* nicknameLabel=[[UILabel alloc]init];
    nicknameLabel.text=@"昵称：";
    nicknameLabel.font=[UIFont systemFontOfSize:14];
    nicknameLabel.textAlignment=NSTextAlignmentCenter;
    [surfaceView addSubview:nicknameLabel];
    
    [nicknameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->surfaceView).with.offset(250);
        make.height.equalTo(@49);
        make.width.equalTo(@100);
        make.left.equalTo(self->surfaceView.mas_centerX).offset(-100);
    }];
    
    nicknameTextField=[[UITextField alloc]init];
    nicknameTextField.text=[userInfo valueForKey:@"nickname"];
    nicknameTextField.font=[UIFont systemFontOfSize:14];
    [surfaceView addSubview:nicknameTextField];
    
    [nicknameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->surfaceView).with.offset(250);
        make.height.equalTo(@49);
        make.width.equalTo(@100);
        make.left.equalTo(self->surfaceView.mas_centerX).offset(50);
    }];
    
    //中部横线
    UIView* lineView=[[UIView alloc]init];
    lineView.layer.borderColor=ssRGBHex(0x979797).CGColor;
    lineView.layer.borderWidth=1;
    [surfaceView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->surfaceView).with.offset(299);
        make.height.equalTo(@1);
        make.width.equalTo(self->surfaceView);
        make.left.equalTo(self->surfaceView);
    }];
    
    UILabel* phoneLabel=[[UILabel alloc]init];
    phoneLabel.text=@"电话号码：";
    phoneLabel.font=[UIFont systemFontOfSize:14];
    [surfaceView addSubview:phoneLabel];
    [phoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->surfaceView).with.offset(300);
        make.height.equalTo(@49);
        make.width.equalTo(@100);
        make.left.equalTo(self->surfaceView.mas_centerX).offset(-100);
    }];
    
    phoneTextField=[[UITextField alloc]init];
    phoneTextField.font=[UIFont systemFontOfSize:14];
    phoneTextField.text=[userInfo valueForKey:@"phone"];;
    [surfaceView addSubview:phoneTextField];
    [phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->surfaceView).with.offset(300);
        make.height.equalTo(@49);
        make.width.equalTo(@100);
        make.left.equalTo(self->surfaceView.mas_centerX).offset(50);
    }];
    
    //中部横线
    UIView* lineView2=[[UIView alloc]init];
    lineView2.layer.borderColor=ssRGBHex(0x979797).CGColor;
    lineView2.layer.borderWidth=1;
    [surfaceView addSubview:lineView2];
    [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->surfaceView).with.offset(349);
        make.height.equalTo(@1);
        make.width.equalTo(self->surfaceView);
        make.left.equalTo(self->surfaceView);
    }];
    
    UILabel* qqLabel=[[UILabel alloc]init];
    qqLabel.text=@"QQ绑定：";
    qqLabel.font=[UIFont systemFontOfSize:14];
    [surfaceView addSubview:qqLabel];
    [qqLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       make.top.equalTo(self->surfaceView).with.offset(350);
       make.height.equalTo(@49);
       make.width.equalTo(@100);
       make.left.equalTo(self->surfaceView.mas_centerX).offset(-100);
    }];
    
    QQBinding=[[UIButton alloc]init];
    [QQBinding removeFromSuperview];
    [QQBinding setTitle:@"未绑定" forState:UIControlStateNormal];
    [QQBinding addTarget:self action:@selector(QQBinding) forControlEvents:UIControlEventTouchUpInside];
    QQBinding.titleLabel.font=[UIFont systemFontOfSize:14];
    [QQBinding setTitleColor:ssRGBHex(0x979797) forState:UIControlStateNormal];
    [surfaceView addSubview:QQBinding];
    [QQBinding mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->surfaceView).with.offset(350);
        make.height.equalTo(@49);
        make.width.equalTo(@100);
        make.left.equalTo(self->surfaceView.mas_centerX).offset(50);
    }];
    
    //中部横线
    UIView* lineView3=[[UIView alloc]init];
    lineView3.layer.borderColor=ssRGBHex(0x979797).CGColor;
    lineView3.layer.borderWidth=1;
    [surfaceView addSubview:lineView3];
    [lineView3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->surfaceView).with.offset(399);
        make.height.equalTo(@1);
        make.width.equalTo(self->surfaceView);
        make.left.equalTo(self->surfaceView);
    }];

    if([WXApi isWXAppInstalled]){
        UILabel* wechatLabel=[[UILabel alloc]init];
        wechatLabel.text=@"微信绑定：";
        wechatLabel.font=[UIFont systemFontOfSize:14];
        [surfaceView addSubview:wechatLabel];
        [wechatLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self->surfaceView).with.offset(400);
            make.height.equalTo(@49);
            make.width.equalTo(@100);
            make.left.equalTo(self->surfaceView.mas_centerX).offset(-100);
        }];
        
        wechatBinding=[[UIButton alloc]init];
        [wechatBinding removeFromSuperview];
        wechatBinding.titleLabel.font=[UIFont systemFontOfSize:14];
        [wechatBinding setTitle:@"未绑定" forState:UIControlStateNormal];
        [wechatBinding setTitleColor:ssRGBHex(0x979797) forState:UIControlStateNormal];
        [wechatBinding addTarget:self action:@selector(WXBinding) forControlEvents:UIControlEventTouchUpInside];
        [surfaceView addSubview:wechatBinding];
        [wechatBinding mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self->surfaceView).with.offset(400);
            make.height.equalTo(@49);
            make.width.equalTo(@100);
            make.left.equalTo(self->surfaceView.mas_centerX).offset(50);
        }];
        
        //中部横线
        UIView* lineView4=[[UIView alloc]init];
        lineView4.layer.borderColor=ssRGBHex(0x979797).CGColor;
        lineView4.layer.borderWidth=1;
        [surfaceView addSubview:lineView4];
        [lineView4 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self->surfaceView).with.offset(449);
            make.height.equalTo(@1);
            make.width.equalTo(self->surfaceView);
            make.left.equalTo(self->surfaceView);
        }];
    }
}
-(void)loadData{
    ConBlock jobBlock = ^(NSDictionary* resultDic){
        self->binding = [resultDic valueForKey:@"data"];
        if(self->binding != NULL){
            NSString* qq = [NSString stringWithFormat:@"%@",[self->binding valueForKey:@"qq"]];
            NSString* weixin = [NSString stringWithFormat:@"%@",[self->binding valueForKey:@"weixin"]];
            if (![qq isEqualToString:@"0"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->QQBinding setTitle:@"已绑定" forState:UIControlStateNormal];
                    [self->QQBinding setTitleColor:ssRGBHex(0xFF7474) forState:UIControlStateNormal];
                });
            }
            if (![weixin isEqualToString:@"0"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->wechatBinding setTitle:@"已绑定" forState:UIControlStateNormal];
                    [self->wechatBinding setTitleColor:ssRGBHex(0xFF7474) forState:UIControlStateNormal];
                });
            }
        }
    };
    NetSenderFunction* sender = [[NetSenderFunction alloc]init];
    [sender getRequestWithHead:[self->userInfo valueForKey:@"userKey"]
                          Path:[[ConnectionFunction getInstance]getBindingMsg_Get_H]
                         Block:jobBlock];
}
-(void)defineBtn{
    UIButton* toModify=[[UIButton alloc]init];
    [toModify setTitle:@"保存" forState:UIControlStateNormal];
    toModify.titleLabel.font=[UIFont systemFontOfSize:14];
    toModify.backgroundColor=ssRGBHex(0xFF7474);
    [toModify addTarget:self action:@selector(modifyUserMsg) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:toModify];
    
    [toModify mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.height.equalTo(@40);
        make.bottom.equalTo(self.view).offset(-20);
        
    }];
}

-(void)modifyUserMsg{
    NSString* nickname=nicknameTextField.text;
    NSString* phone=phoneTextField.text;
    NSLog(@"userInfo%@",userInfo);
    if([[userInfo valueForKey:@"password"]isEqualToString:@""]){
        [self presentViewController:[WarningWindow MsgWithoutTrans:@"第三方账号无法修改个人信息！"]
                           animated:YES
                         completion:nil];
        return;
    }
    
    ConBlock conBlk = ^(NSDictionary* dataDic){
        NSLog(@"修改用户信息返回的数据%@",dataDic);
        //删除用户信息文件
        if ([DocuOperate deletePlist:@"userInfo.plist"]&&
            [DocuOperate writeIntoPlist:@"userInfo.plist" dictionary:[DataFilter DictionaryFilter:[dataDic valueForKey:@"data"]]]) {
            [self popBack];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self warnMsg:@"修改失败，请稍后再试。"];
            });
        }
    };
    NetSenderFunction* sender = [[NetSenderFunction alloc]init];
    [sender putRequestWithHead:[[ConnectionFunction getInstance]modifyUserMsg_Put_H:nickname Phone:phone Password:[userInfo valueForKey:@"password"]] Head:[userInfo valueForKey:@"userKey"] Block:conBlk];
    
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

-(void)WXBinding{
    VoidBlock myBlock = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"绑定成功"];
            [self->wechatBinding setTitle:@"已绑定" forState:UIControlStateNormal];
            [self->wechatBinding setTitleColor:ssRGBHex(0xFF7474) forState:UIControlStateNormal];
        });
    };
    if ([WXApi isWXAppInstalled]) {
        WechatLog* wechat = [WechatLog getInstance];
        wechat.myBlock = myBlock;
        wechat.type = @"FORBINDING";
        wechat.userKey = [userInfo valueForKey:@"userKey"];
        SendAuthReq *req = [[SendAuthReq alloc] init];
        req.scope = @"snsapi_userinfo";
        req.state = @"App";
        [WXApi sendReq:req];
    }else {
        NSLog(@"请安装微信");
    }
}

-(void)QQBinding{
    VoidBlock myBlock = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"绑定成功"];
            [self->QQBinding setTitle:@"已绑定" forState:UIControlStateNormal];
            [self->QQBinding setTitleColor:ssRGBHex(0xFF7474) forState:UIControlStateNormal];
        });
    };
    if ([WXApi isWXAppInstalled]) {
        QQLogin* qqlog = [QQLogin getInstance];
        qqlog.myBlock = myBlock;
        qqlog.type = @"FORBINDING";
        qqlog.userKey = [userInfo valueForKey:@"userKey"];
        [qqlog toQQlogin];
    }else {
        NSLog(@"请安装微信");
    }
}
//点击背景收起键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES]; //实现该方法是需要注意view需要是继承UIControl而来的
}


@end
