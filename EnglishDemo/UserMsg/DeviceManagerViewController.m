//
//  DeviceManagerViewController.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/20.
//  Copyright © 2018年 马一轩. All rights reserved.
//

#import "DeviceManagerViewController.h"
#import "../Functions/netOperate/ConnectionFunction.h"
#import "../Functions/netOperate/NetSenderFunction.h"
#import "../Functions/DocuOperate.h"
#import "../LoginAndRegisterViewController/LoginViewController.h"
#import "../Functions/WarningWindow.h"
#import "../Functions/AgentFunction.h"
#import "../Functions/DocuOperate.h"
#import "../DiyGroup/UnloginMsgView.h"
#import "../Common/HeadView.h"
#import "../Functions/FixValues.h"
#import "Masonry.h"

@interface DeviceManagerViewController (){
    NSDictionary* userInfo;
    NSArray* deviceArray;
    UILabel* deviceLabel;
    UIView* deviceShowView;
    LoginViewController* loginAndRegister;
    UnloginMsgView* unloginView;
}

@end

@implementation DeviceManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    userInfo=[[NSDictionary alloc]init];
    deviceArray=[[NSArray alloc]init];

    [self titleShow];
    [self textShow];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [deviceShowView removeFromSuperview];
    [unloginView removeFromSuperview];
    
    if ([DocuOperate fileExistInPath:@"userInfo.plist"]) {
        userInfo=[DocuOperate readFromPlist:@"userInfo.plist"];
        
        ConBlock conBlk = ^(NSDictionary* dic){
            self->deviceArray=[dic valueForKey:@"data"];;
            NSLog(@"拿到的设备信息是%@",self->deviceArray);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self deviceShow];
            });
        };
        NetSenderFunction* sender = [[NetSenderFunction alloc]init];
        [sender getRequestWithHead:[userInfo valueForKey:@"userKey"] Path:[[ConnectionFunction getInstance]deviceBinding_Get_H] Block:conBlk];
    }else{
        unloginView=[[UnloginMsgView alloc]init];
        [self.view addSubview:unloginView];
        
        [unloginView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.top.equalTo(self.view).with.offset(88);
            make.bottom.equalTo(self.view);
        }];
    }
}
-(void)titleShow{
    [HeadView titleShow:@"设备管理" Color:ssRGBHex(0xFF7474) UIView:self.view UINavigationController:self.navigationController];
}
-(void)textShow{
    UITextView* textShow=[[UITextView alloc]init];
    textShow.text=@"注意：同一账号最多可以在两台手机上使用，账户登录时默认绑定了当前设备，如需在第三台设备上使用，需要在本机上对当前设备进行解绑。";
    textShow.editable=false;
    textShow.textColor=ssRGBHex(0xF43530 );
    textShow.font=[UIFont systemFontOfSize:12];
    [self.view addSubview:textShow];
    
    [textShow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(22);
        make.right.equalTo(self.view).with.offset(-22);
        make.top.equalTo(self.view).with.offset(110);
        make.height.equalTo(@60);
    }];
}

-(void)deviceShow{
    deviceShowView=[[UIView alloc]init];
    [self.view addSubview:deviceShowView];
    
    [deviceShowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view).with.offset(174);
        make.bottom.equalTo(self.view);
    }];
    
    if (deviceArray.count==0) {
        deviceLabel=[[UILabel alloc]init];
        deviceLabel.text=@"您尚未登录，请在登录后查看绑定设备！";
        deviceLabel.textColor=ssRGBHex(0x4A4A4A);
        deviceLabel.font=[UIFont systemFontOfSize:14];
        [deviceShowView addSubview:deviceLabel];
        
        [deviceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self->deviceShowView).with.offset(40);
            make.right.equalTo(self->deviceShowView);
            make.top.equalTo(self->deviceShowView);
            make.height.equalTo(@53);
        }];
        
    }else{
        for (NSDictionary* device in deviceArray) {
            float y=0+52.96*[deviceArray indexOfObject:device];
            deviceLabel=[[UILabel alloc]init];
            [deviceLabel setUserInteractionEnabled:YES];
            NSString* deviceName=[device valueForKey:@"deviceName"];
            UIButton* releaseBtn=[[UIButton alloc]init];
            [releaseBtn setTitle:@"解绑" forState:UIControlStateNormal];
            releaseBtn.titleLabel.font=[UIFont systemFontOfSize:10];
            releaseBtn.layer.backgroundColor=ssRGBHex(0xFF7474 ).CGColor;
            releaseBtn.layer.cornerRadius=11.03;
            [releaseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            releaseBtn.tag=[deviceArray indexOfObject:device];
            [releaseBtn addTarget:self action:@selector(releaseDevice:) forControlEvents:UIControlEventTouchUpInside];
            [deviceLabel addSubview:releaseBtn];
            
            [releaseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self->deviceLabel).with.offset(-30);
                make.top.equalTo(self->deviceLabel).with.offset(14);
                make.width.equalTo(@70);
                make.height.equalTo(@22);
            }];
            
            if ([[device valueForKey:@"deviceId"] isEqualToString:[FixValues getUniqueId]]) {
                deviceName=[deviceName stringByAppendingString:@"(当前设备)"];
            }
            deviceLabel.text=deviceName;
            deviceLabel.textColor=ssRGBHex(0x4A4A4A);
            deviceLabel.font=[UIFont systemFontOfSize:14];
            [deviceShowView addSubview:deviceLabel];
            
            [deviceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self->deviceShowView).with.offset(20);
                make.right.equalTo(self->deviceShowView);
                make.top.equalTo(self->deviceShowView).with.offset(y);
                make.height.equalTo(@53);
            }];
            
            
        }
    }
    
}
-(void)releaseDevice:(UIButton*)btn{
    ConBlock conBlk = ^(NSDictionary* dic){
        //此处判断条件在重写代码后未验证！！
        if ([[dic valueForKey:@"message"]isEqualToString:@"succself->ess"]) {
            NSLog(@"解除绑定成功");
            if ([[[self->deviceArray objectAtIndex:btn.tag]valueForKey:@"deviceId"]isEqualToString:[[[UIDevice currentDevice] identifierForVendor] UUIDString]]) {
                   //如果是当前设备
                   NSLog(@"是当前设备");
                   [DocuOperate deletePlist:@"userInfo.plist"];
                   [self pushToLogin];
               }else{
                   [self popBack];
               }
               
           }else{
               NSLog(@"不是当前设备");
               NSLog(@"解除绑定成功");
               dispatch_async(dispatch_get_main_queue(), ^{
                   [[AgentFunction theTopviewControler]presentViewController:[WarningWindow MsgWithoutTrans:@"解除绑定失败！"] animated:YES completion:nil];
               });
           }
    };
    NetSenderFunction* sender = [[NetSenderFunction alloc]init];
    [sender deleteRequestWithHead:[[ConnectionFunction getInstance]deleteBinding_Delete_H:[[deviceArray objectAtIndex:btn.tag]valueForKey:@"deviceId"]] Head:[userInfo valueForKey:@"userKey"] Block:conBlk];
}
-(void)pushToLogin{
    if (loginAndRegister==nil) {
        loginAndRegister = [[LoginViewController alloc]init];
    }
    [self.navigationController pushViewController:loginAndRegister animated:true];
    
    NSMutableArray * array =[[NSMutableArray alloc]initWithArray:self.navigationController.viewControllers];
    //删除最后一个，也就是自己
    [array removeObjectAtIndex:array.count-2];
    [self.navigationController setViewControllers:array animated:YES];
    
}

-(void)popBack{
    [self.navigationController popViewControllerAnimated:true];
}
@end
