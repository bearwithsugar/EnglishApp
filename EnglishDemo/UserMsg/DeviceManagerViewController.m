//
//  DeviceManagerViewController.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/20.
//  Copyright © 2018年 马一轩. All rights reserved.
//

#import "DeviceManagerViewController.h"
#import "../Functions/ConnectionFunction.h"
#import "../Functions/DocuOperate.h"
#import "../LoginAndRegisterViewController/LoginViewController.h"
#import "../Functions/WarningWindow.h"
#import "../Functions/AgentFunction.h"
#import "../Functions/DocuOperate.h"
#import "../DiyGroup/UnloginMsgView.h"
#import "../Common/HeadView.h"
#import "../Functions/FixValues.h"

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
        [self dataInit];
        [self deviceShow];
    }else{
        unloginView=[[UnloginMsgView alloc]initWithFrame:CGRectMake(0, 88.27, 414, 647)];
        [self.view addSubview:unloginView];
    }
}
-(void)titleShow{
    [self.view addSubview:[HeadView titleShow:@"设备管理" Color:ssRGBHex(0xFF7474) Located:CGRectMake(0, 22.06, 414, 66.2) UINavigationController:self.navigationController]];
}
-(void)textShow{
    UITextView* textShow=[[UITextView alloc]initWithFrame:CGRectMake(22.08, 110.34, 369.83, 399.33)];
    textShow.text=@"注意：同一账号最多可以在两台手机上使用，账户登录时默认绑定了当前设备，如需在第三台设备上使用，需要在本机上对当前设备进行解绑。";
    textShow.editable=false;
    textShow.textColor=ssRGBHex(0xF43530 );
    textShow.font=[UIFont systemFontOfSize:12];
    [self.view addSubview:textShow];
}
-(void)dataInit{
    deviceArray=[[ConnectionFunction deviceBinding:[userInfo valueForKey:@"userKey"]]valueForKey:@"data"];;
    NSLog(@"拿到的设备信息是%@",deviceArray);
}
-(void)deviceShow{
    deviceShowView=[[UIView alloc]initWithFrame:CGRectMake(0, 174.34, 414, 400)];
    
    if (deviceArray.count==0) {
        deviceLabel=[[UILabel alloc]initWithFrame:CGRectMake(40, 0, 414, 52.96)];
        deviceLabel.text=@"您尚未登录，请在登录后查看绑定设备！";
        deviceLabel.textColor=ssRGBHex(0x4A4A4A);
        deviceLabel.font=[UIFont systemFontOfSize:14];
        [deviceShowView addSubview:deviceLabel];
    }else{
        for (NSDictionary* device in deviceArray) {
            float y=0+52.96*[deviceArray indexOfObject:device];
            deviceLabel=[[UILabel alloc]initWithFrame:CGRectMake(17.66, y, 414, 52.96)];
            [deviceLabel setUserInteractionEnabled:YES];
            NSString* deviceName=[device valueForKey:@"deviceName"];
            UIButton* releaseBtn=[[UIButton alloc]initWithFrame:CGRectMake(303.60, 14.34, 70.65, 22.06)];
            [releaseBtn setTitle:@"解绑" forState:UIControlStateNormal];
            releaseBtn.titleLabel.font=[UIFont systemFontOfSize:10];
            releaseBtn.layer.backgroundColor=ssRGBHex(0xFF7474 ).CGColor;
            releaseBtn.layer.cornerRadius=11.03;
            [releaseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            releaseBtn.tag=[deviceArray indexOfObject:device];
            [releaseBtn addTarget:self action:@selector(releaseDevice:) forControlEvents:UIControlEventTouchUpInside];
            [deviceLabel addSubview:releaseBtn];
            if ([[device valueForKey:@"deviceId"] isEqualToString:[FixValues getUniqueId]]) {
                deviceName=[deviceName stringByAppendingString:@"(当前设备)"];
            }
            deviceLabel.text=deviceName;
            deviceLabel.textColor=ssRGBHex(0x4A4A4A);
            deviceLabel.font=[UIFont systemFontOfSize:14];
            [deviceShowView addSubview:deviceLabel];
            
            
        }
    }
    [self.view addSubview:deviceShowView];
    
}
-(void)releaseDevice:(UIButton*)btn{
    if ([ConnectionFunction deleteBinding:[userInfo valueForKey:@"userKey"] DeviceId:[[deviceArray objectAtIndex:btn.tag]valueForKey:@"deviceId"]]) {

        NSLog(@"解除绑定成功");
        if ([[[deviceArray objectAtIndex:btn.tag]valueForKey:@"deviceId"]isEqualToString:[[[UIDevice currentDevice] identifierForVendor] UUIDString]]) {
            //如果是当前设备
            NSLog(@"是当前设备");
            [DocuOperate deletePlist:@"userInfo.plist"];
            [self pushToLogin];
        }else{
            //[[AgentFunction theTopviewControler]presentViewController:[WarningWindow MsgWithoutTrans:@"解除绑定成功！"] animated:YES completion:nil];
            [self popBack];
        }
        
    }else{
        NSLog(@"不是当前设备");
        NSLog(@"解除绑定成功");
        [[AgentFunction theTopviewControler]presentViewController:[WarningWindow MsgWithoutTrans:@"解除绑定失败！"] animated:YES completion:nil];
    }
    
    
  
}
-(void)pushToLogin{
    if (loginAndRegister==nil) {
        loginAndRegister = [[LoginViewController alloc]init];
    }
    [self.navigationController pushViewController:loginAndRegister animated:true];
    //[self.view removeFromSuperview];
    
    NSMutableArray * array =[[NSMutableArray alloc]initWithArray:self.navigationController.viewControllers];
    //删除最后一个，也就是自己
    [array removeObjectAtIndex:array.count-2];
    [self.navigationController setViewControllers:array animated:YES];
    
}

-(void)popBack{
    [self.navigationController popViewControllerAnimated:true];
}
@end
