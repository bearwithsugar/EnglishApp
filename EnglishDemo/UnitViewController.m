//
//  UnitViewController.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/13.
//  Copyright © 2018年 马一轩. All rights reserved.
//

#import "UnitViewController.h"
#import "LearningViewController.h"
#import "DiyGroup/UnitsListTableViewCell.h"
#import "DiyGroup/UnitsListDownTableViewCell.h"
#import "Functions/netOperate/ConnectionFunction.h"
#import "Functions/DocuOperate.h"
#import "Common/HeadView.h"
#import "Functions/WarningWindow.h"
#import "Common/HeadView.h"
#import "Functions/netOperate/NetSenderFunction.h"
#import "Functions/MyThreadPool.h"
#import "SVProgressHUD.h"
#import "Masonry.h"

@interface UnitViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    //存储用户信息
    NSDictionary* userInfo;
    //存储全部单元信息
    NSArray* unitArray;
    //存储被选择单元的id
    NSString* unitId;
    //存储单元进度信息
    NSArray* unitProcessArray;
    //tableview
    UITableView* processMsg;
}
@end

@implementation UnitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor whiteColor];
    NSLog(@"这边拿到的书籍id的值是%@",_bookId);
    NSLog(@"这边拿到的书籍名称的值是%@",_bookName);
    userInfo=[DocuOperate readFromPlist:@"userInfo.plist"];
    //初始化数组
    unitArray=[[NSArray alloc]init];
    unitProcessArray=[[NSArray alloc]init];
    [SVProgressHUD show];
    [self unitInit];
}
-(void)unitInit{
    NetSenderFunction* sender = [[NetSenderFunction alloc]init];
    NetSenderFunction* sender1 = [[NetSenderFunction alloc]init];
    ConBlock blk2 = ^(NSDictionary* dic){
        self->unitProcessArray = [dic valueForKey:@"data"];
        NSLog(@"显示单元进度数组%@",self->unitProcessArray);
        NSLog(@"unitArray的值是%@",self->unitArray);
        //此处用单元进度数组来判断token是否过期，因为单元数组接口不能验证
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self->unitProcessArray.count==0) {
                [SVProgressHUD dismiss];
                //提示框
                    [self presentViewController:[WarningWindow transToLogin:@"您的账号在别处登录，请重新登录！" Navigation:self.navigationController]
                                   animated:YES
                                 completion:nil];
            }else{
                [self progressView];
                [SVProgressHUD dismiss];
            }

            [self titleShow];
        });
    };
    
    ConBlock blk1 = ^(NSDictionary* dic){
        self->unitArray = [dic valueForKey:@"data"];
        [sender1 getRequestWithHead:[self->userInfo valueForKey:@"userKey"]
                               Path:[[ConnectionFunction getInstance]unitProcess_Get_H:self->_bookId]
                              Block:blk2];
    };
    [sender getRequestWithHead:[userInfo valueForKey:@"userKey"]
                          Path:[[ConnectionFunction getInstance]getUnitMsg_Get_H:_bookId]
                         Block:blk1];
    
}
-(void)titleShow{
    [HeadView titleShow:_bookName Color:ssRGBHex(0xFF7474) UIView:self.view UINavigationController:self.navigationController];
}
-(void)progressView{
    UIView* progressView=[[UIView alloc]init];
    [self.view addSubview:progressView];
    
    [progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(88.26);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@44.13);
    }];
    
    UILabel* wordShow=[[UILabel alloc]init];
    wordShow.text=@"当前进度";
    wordShow.textColor=ssRGBHex(0x9B9B9B);
    wordShow.font=[UIFont systemFontOfSize:12];
    [progressView addSubview:wordShow];
    
    [wordShow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(progressView).with.offset(13.24);
        make.left.equalTo(progressView).with.offset(17.66);
        make.width.equalTo(@70);
        make.height.equalTo(@19);
    }];
    
    UILabel* lessontitle=[[UILabel alloc]initWithFrame:CGRectMake(97.15, 7.72, 220.80, 28.68)];
    lessontitle.layer.borderColor=ssRGBHex(0xFE8484).CGColor;
    lessontitle.layer.borderWidth=1;
    lessontitle.layer.cornerRadius=14.34;
    if ([_recentLesson isKindOfClass:[NSNull class]]) {
        lessontitle.text=@"";
    }else{
        lessontitle.text=_recentLesson;
    }
    lessontitle.textAlignment=NSTextAlignmentCenter;
    lessontitle.font=[UIFont systemFontOfSize:12];
    [progressView addSubview:lessontitle];
    
    [lessontitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(progressView).with.offset(7.72);
        make.left.equalTo(progressView).with.offset(100);
        make.height.equalTo(@29);
        make.right.equalTo(progressView).with.offset(-100);
    }];
    
    processMsg=[[UITableView alloc]init];
    processMsg.dataSource=self;
    processMsg.delegate=self;
    [self.view addSubview:processMsg];
    
    //无内容时不显示下划线
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [processMsg setTableFooterView:v];
    
    [processMsg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(progressView);
        make.left.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.right.equalTo(self.view);
    }];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return unitArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UnitsListTableViewCell* cell=[UnitsListTableViewCell createCellWithTableView:tableView];
    //单元进度和单元长度不一致j会报错
//    NSLog(@"unitArray的长度是：%lu",(unsigned long)unitArray.count);
//    NSLog(@"unitProcessArray的长度是：%lu",(unsigned long)unitProcessArray.count);
    for (int i=0; i<unitArray.count;i++) {
        NSDictionary* unitMsg=unitArray[i];
        if (indexPath.row==i) {
            NSString* processPercent=@"学习进度：";
            //NSLog(@"unitProcessArray的值是%@",unitProcessArray);
            NSDictionary* userUnitDic=[[unitProcessArray objectAtIndex:i]valueForKey:@"userUnit"];
            processPercent=[processPercent stringByAppendingString:[[userUnitDic valueForKey:@"learningRate"] stringValue]];
            processPercent=[processPercent stringByAppendingString:@"%"];
            [cell loadData:[unitMsg valueForKey:@"unitName"] description:processPercent];
        }
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    unitId=[[unitArray objectAtIndex:indexPath.row] valueForKey:@"unitId"];
    [self pushToLearningView:indexPath.row];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 52.96;
}

-(void)pushToLearningView:(NSInteger)clickedUnit{
    LearningViewController* learningView;
    if (learningView==nil) {
        learningView = [[LearningViewController alloc]init];
    }
    learningView.bookId=_bookId;
    learningView.unitId=unitId;
    learningView.bookName=_bookName;
    learningView.defaultUnit=clickedUnit;
    
    [self.navigationController pushViewController:learningView animated:true];
    
}
@end
