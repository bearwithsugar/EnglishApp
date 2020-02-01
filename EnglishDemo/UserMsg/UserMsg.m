//
//  UserMsg.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/13.
//  Copyright © 2018年 马一轩. All rights reserved.
//

#import "UserMsg.h"
#import "LoginViewController.h"
#import "RechargeRecordViewController.h"
#import "CreditInstructionViewController.h"
#import "RechargeViewController.h"
#import "AboutSoftwareViewController.h"
#import "OpinionViewController.h"
#import "DeviceManagerViewController.h"
#import "../DiyGroup/UserMsgTableViewCell.h"
#import "../DiyGroup/XuefenTableViewCell.h"
#import "../DiyGroup/NewVersonTableViewCell.h"
#import "../Functions/DocuOperate.h"
#import "../Functions/netOperate/ConnectionFunction.h"
#import "../Functions/netOperate/NetSenderFunction.h"
#import "../Functions/LocalDataOperation.h"
#import "../Functions/QQLogin.h"
#import "../Functions/AgentFunction.h"
#import "../Functions/MyThreadPool.h"
#import "ModifyUserMsgViewController.h"
#import "Masonry.h"


@interface UserMsg ()<UITableViewDelegate,UITableViewDataSource>
{
    LoginViewController* loginAndRegister;
    RechargeRecordViewController* rechargeRecord;
    CreditInstructionViewController* creditInstruction;
    RechargeViewController* rechargeView;
    AboutSoftwareViewController* aboutSoftwareView;
    OpinionViewController* opinionView;
    DeviceManagerViewController* deviceManager;
    ModifyUserMsgViewController* modifyUserMsg;
    QQLogin* qqlogin;
    //学分显示cell
    XuefenTableViewCell* xuefenCell;
    UITableView* userMsg;
    //界面头像那一整个板块的显示
    UIView* headPicView;
    NSArray* saintArray;
    NSDictionary* userInfo;
    NSDictionary* versionMsg;
    int score;
    
}

@end

@implementation UserMsg

//整个控制器周期只会调用一遍
- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *path=[[NSBundle mainBundle]pathForResource:@"UserMsg.plist" ofType:nil];
    saintArray=[NSArray arrayWithContentsOfFile:path];
    self.view.backgroundColor=[UIColor whiteColor];
    [self userTitle];
    
}
//每次页面出现的时候都会调用
-(void)viewWillAppear:(BOOL)animated{
    if ([DocuOperate fileExistInPath:@"userInfo.plist"]) {
        userInfo=[DocuOperate readFromPlist:@"userInfo.plist"];
    }else{
        userInfo=nil;
    }
    [self headPicView];
    [self userMsg];
    [self refreshScore];
    
}
-(void)refreshScore{
    ConBlock conBlk = ^(NSDictionary* scoreDic){
        self->score=[[scoreDic valueForKey:@"data"]intValue];
        NSIndexPath *path=[NSIndexPath indexPathForRow:0 inSection:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->userMsg reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationTop];
        });
    };
    if (userInfo==nil) {
        score=0;
    }else{
        [MyThreadPool executeJob:^{
            NetSenderFunction* sender= [[NetSenderFunction alloc]init];
            [sender getRequestWithHead:[self->userInfo valueForKey:@"userKey"]
                                  Path:[[ConnectionFunction getInstance]getScore_Get_H]
                                 Block:conBlk];
        } Main:^{}];
    }
    
}
-(void)userTitle{
    UILabel* userTitle=[[UILabel alloc]init];
    userTitle.text=@"个人中心";
    userTitle.textColor=ssRGBHex(0xFF7474);
    userTitle.font=[UIFont systemFontOfSize:18];
    userTitle.textAlignment=NSTextAlignmentCenter;
    userTitle.clipsToBounds = YES;
    [userTitle setUserInteractionEnabled:YES];
    [self.view addSubview:userTitle];
    
    UILabel* touchField=[[UILabel alloc]init];
    [touchField setUserInteractionEnabled:YES];
    [userTitle addSubview:touchField];
    
    [touchField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(userTitle).with.offset(20);
        make.left.equalTo(userTitle).with.offset(10);
        make.width.equalTo(@30);
        make.height.equalTo(@30);
    }];
    
    UIButton* returnBtn=[[UIButton alloc]init];
    [returnBtn setBackgroundImage:[UIImage imageNamed:@"icon_return_ff7474"] forState:UIControlStateNormal];
    [returnBtn setBackgroundImage:[UIImage imageNamed:@"icon_return_ff7474"] forState:UIControlStateHighlighted];
    [returnBtn addTarget:self action:@selector(popForTag:) forControlEvents:UIControlEventTouchUpInside];
    [touchField addSubview:returnBtn];
    
    [returnBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(touchField).with.offset(2);
        make.left.equalTo(touchField).with.offset(5.5);
        make.width.equalTo(@10.7);
        make.height.equalTo(@22.6);
    }];
    
    UITapGestureRecognizer* touchFunc=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(popForTag:)];
    [touchField addGestureRecognizer:touchFunc];

    [userTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(22);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@66);
    }];
    
}
-(void)headPicView{
    [headPicView removeFromSuperview];
    headPicView=[[UIView alloc]init];
    headPicView.backgroundColor=ssRGBHex(0xFF7474);
    [self.view addSubview:headPicView];
    
    [headPicView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(88);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@144);
    }];
    
    UIImageView* headPic=[[UIImageView alloc]init];
    headPic.layer.cornerRadius=33;
    //把多余部分去掉
    headPic.layer.masksToBounds = YES;
    headPic.image=[UIImage imageNamed:@"icon_head"];
    
    [headPicView addSubview:headPic];
    
    [headPic mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->headPicView).with.offset(40);
        make.left.equalTo(self->headPicView).with.offset(22);
        make.width.equalTo(@66);
        make.height.equalTo(@66);
    }];
    
    if (userInfo!=nil) {
        __block UIImage* headpic;
        [MyThreadPool executeJob:^{
            //通知主线程刷新
            headpic = [LocalDataOperation getImage:[self->userInfo valueForKey:@"userKey"]
                                                    httpUrl:[self->userInfo valueForKey:@"pictureUrl"]];
        } Main:^{
            //回调或者说是通知主线程刷新，
            if (headpic!=nil) {
               headPic.image=headpic;
            }
        }];
        
    }
    
    if (userInfo==nil) {
        UILabel* loginAndRegister=[[UILabel alloc]init];
        loginAndRegister.text=@"登录/注册";
        loginAndRegister.textColor=[UIColor whiteColor];
        loginAndRegister.font=[UIFont systemFontOfSize:18];
        [headPicView addSubview:loginAndRegister];
        
        [loginAndRegister mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self->headPicView).with.offset(55);
            make.left.equalTo(self->headPicView).with.offset(110);
            make.width.equalTo(@87);
            make.height.equalTo(@32);
        }];
        
        UITapGestureRecognizer* clickLogin=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pushToLogin)];
        [headPicView addGestureRecognizer:clickLogin];
    }else{
        UILabel* usernameLabel=[[UILabel alloc]init];
        usernameLabel.text=[userInfo valueForKey:@"nickname"];
        usernameLabel.font=[UIFont systemFontOfSize:18];
        usernameLabel.textColor=[UIColor whiteColor];
        [headPicView addSubview:usernameLabel];
        
        [usernameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self->headPicView).with.offset(40);
            make.left.equalTo(self->headPicView).with.offset(110);
            make.width.equalTo(@130);
            make.height.equalTo(@27.58);
        }];
        
        UILabel* phoneLabel=[[UILabel alloc]init];
        phoneLabel.text=[userInfo valueForKey:@"phone"];
        phoneLabel.font=[UIFont systemFontOfSize:13];
        phoneLabel.textColor=[UIColor whiteColor];
        [headPicView addSubview:phoneLabel];
        
        [phoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self->headPicView).with.offset(77.24);
            make.left.equalTo(self->headPicView).with.offset(110);
            make.width.equalTo(@130);
            make.height.equalTo(@20);
        }];
        
        UITapGestureRecognizer* modifyUserMsg = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(modifyUser)];
        [headPicView addGestureRecognizer:modifyUserMsg];
        headPicView.userInteractionEnabled = YES;
        
        UIButton* loginOut=[[UIButton alloc]init];
        [loginOut setTitle:@"退出登录" forState:UIControlStateNormal];
        loginOut.titleLabel.font=[UIFont systemFontOfSize:12];
        loginOut.backgroundColor=ssRGBHex(0xFF7474);
        loginOut.layer.borderColor=[UIColor whiteColor].CGColor;
        loginOut.layer.cornerRadius=12;
        loginOut.layer.borderWidth=1;
        [loginOut addTarget:self action:@selector(loginOut) forControlEvents:UIControlEventTouchUpInside];
        [headPicView addSubview:loginOut];
        
        [loginOut mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self->headPicView).with.offset(60);
            make.right.equalTo(self->headPicView).with.offset(-15);
            make.width.equalTo(@88.32);
            make.height.equalTo(@24);
        }];
    }
    
}
-(void)modifyUser{
    [self pushToModifyUserMsg];
}

-(void)userMsg{
    userMsg=[[UITableView alloc]init];
    userMsg.dataSource=self;
    userMsg.delegate=self;
    [self.view addSubview:userMsg];
    
    [userMsg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(240);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
  
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return saintArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray* subArray=[saintArray objectAtIndex:section];
    return subArray.count ;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray* subArray=[saintArray objectAtIndex:indexPath.section];
    NSDictionary* dic=[subArray objectAtIndex:indexPath.row];
    NSString* name=[dic valueForKey:@"title"];
    NSString* image=[dic valueForKey:@"picture"];
    if (indexPath.row==0) {
        if (indexPath.section==0) {
            xuefenCell=[XuefenTableViewCell createCellWithTableView:tableView];
            [xuefenCell loadData:[NSString stringWithFormat:@"%d", score]];
            return xuefenCell;
        }else{
            NewVersonTableViewCell* cell=[NewVersonTableViewCell createCellWithTableView:tableView];
            if(userInfo==nil){
                [cell loadData:@""];
                [cell setNoVersion];
            }else{
                ConBlock conBlk = ^(NSDictionary* dic){
                    self->versionMsg = [[dic valueForKey:@"data"]firstObject];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if([DocuOperate fileExistInPath:@"version.plist"]){
                            NSDictionary* oldVersion = [DocuOperate readFromPlist:@"version.plist"];
                        if ([[oldVersion valueForKey:@"version"]isEqualToString:[self->versionMsg valueForKey:@"versionId"]]) {
                            [cell setNoVersion];
                        }else{
                            [cell setNewVersion];
                        }
                        }else{
                            [DocuOperate writeIntoPlist:@"version.plist" dictionary:[NSDictionary dictionaryWithObjectsAndKeys:[self->versionMsg valueForKey:@"versionId"],@"version", nil]];
                            [cell setNoVersion];
                        }
                        [cell loadData:[self->versionMsg valueForKey:@"versionName"]];
                    });
                };
    
                [MyThreadPool executeJob:^{
                    NetSenderFunction* sender = [[NetSenderFunction alloc]init];
                    [sender getRequestWithHead:[self->userInfo valueForKey:@"userKey"]
                                          Path:[[ConnectionFunction getInstance]getVersionMsg_Get_H]
                                         Block:conBlk];
                } Main:^{}];
            }

            return cell;
        }
    }else{
        UserMsgTableViewCell* cell=[UserMsgTableViewCell createCellWithTableView:tableView];
        [cell loadData:name logoImg:image];
        return cell;
    }
    
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @" ";
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 52.96;
}
-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    return @" ";
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==0) {
        if(indexPath.row==0){
            [self pushToRechargeView];
        }else if(indexPath.row==1) {
            [self pushToRechargeRecord];
        }else if(indexPath.row==2){
            [self pushToCreditInstruction];
        }else if(indexPath.row==3){
            [self pushToDeviceManager];
        }
    }else if(indexPath.section==1){
        if (indexPath.row==0) {
            
        }else if (indexPath.row==1){
            [self shareView];
        }else if (indexPath.row==2){
            [self pushToAboutSoftware];
        }else if (indexPath.row==3){
            [self pushToOpinion];
        }
    }
}

-(void)shareView{
    // 1. 创建UIAlertControl变量，但并不穿GIAn
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"分享软件" message:@"分享软件将会赠送学分呦!" preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    // 3. 添加取消按钮
    // 3.1 UIAlertAction 表示一个按钮，同时，这个按钮带有处理事件的block
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"取消");
    }];
    // 3.2 添加到alertController上
    [alertController addAction:action];
    
    
    // 5. 添加确定按钮
    [alertController addAction:({
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"微信分享" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSLog(@"微信分享");
            [AgentFunction WXshare];
            
        }];
        action;
    })];
    
    [alertController addAction:({
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"QQ分享" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSLog(@"QQ分享");
            self->qqlogin = [QQLogin getInstance];
            [self->qqlogin qqshare];
            
        }];
        action;
    })];
    
    // 7. 显示（使用模态视图推出）
    [self presentViewController:alertController animated:YES completion:nil];
}
-(void)popBack{
    [self.navigationController popViewControllerAnimated:true];
}
-(void)popForTag:(UITapGestureRecognizer*)sender{
    [self.navigationController popViewControllerAnimated:true];
}

-(void)pushToLogin{
    if (loginAndRegister==nil) {
        loginAndRegister = [[LoginViewController alloc]init];
    }
    [self.navigationController pushViewController:loginAndRegister animated:true];
    
}
-(void)pushToRechargeRecord{
    if (rechargeRecord==nil) {
        rechargeRecord = [[RechargeRecordViewController alloc]init];
    }
    [self.navigationController pushViewController:rechargeRecord animated:true];
    
}
-(void)pushToCreditInstruction{
    if (creditInstruction==nil) {
        creditInstruction = [[CreditInstructionViewController alloc]init];
    }
    [self.navigationController pushViewController:creditInstruction animated:true];
    
}
-(void)pushToRechargeView{
    if (rechargeView==nil) {
        rechargeView = [[RechargeViewController alloc]init];
    }
    [self.navigationController pushViewController:rechargeView animated:true];
    
}
-(void)pushToAboutSoftware{
    if (aboutSoftwareView==nil) {
        aboutSoftwareView = [[AboutSoftwareViewController alloc]init];
    }
    [self.navigationController pushViewController:aboutSoftwareView animated:true];
    
}
-(void)pushToOpinion{
    if (opinionView==nil) {
        opinionView = [[OpinionViewController alloc]init];
    }
    [self.navigationController pushViewController:opinionView animated:true];
    
}
-(void)pushToDeviceManager{
    if (deviceManager==nil) {
        deviceManager = [[DeviceManagerViewController alloc]init];
    }
    [self.navigationController pushViewController:deviceManager animated:true];
    
}
-(void)pushToModifyUserMsg{
    if (modifyUserMsg==nil) {
        modifyUserMsg = [[ModifyUserMsgViewController alloc]init];
    }
    [self.navigationController pushViewController:modifyUserMsg animated:true];
}

-(void)loginOut{
    [DocuOperate deletePlist:@"userInfo.plist"];
    [DocuOperate deletePlist:@"testDetails.plist"];
    [DocuOperate deletePlist:@"wrongsDetails.plist"];
    [self pushToLogin];
 
}
@end


