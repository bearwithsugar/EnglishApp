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
#import "Functions/ConnectionFunction.h"
#import "Functions/DocuOperate.h"
#import "Common/HeadView.h"
#import "Functions/WarningWindow.h"
#import "Common/HeadView.h"
#import "Functions/ConnectionInstance.h"
#import "Functions/MyThreadPool.h"

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
    
    
    
    [self unitInit];
    NSLog(@"unitArray的值是%@",unitArray);
    //此处用单元进度数组来判断token是否过期，因为单元数组接口不能验证
    if (unitProcessArray.count==0) {
        //提示框
        [self presentViewController:[WarningWindow transToLogin:@"您的账号在别处登录，请重新登录！" Navigation:self.navigationController]
                           animated:YES
                         completion:nil];
    }else{
        [self progressView];
    }

    [self titleShow];
    
}
-(void)viewWillAppear:(BOOL)animated{
//    JobBlock initUnitBlock = ^{
//        [self unitInit];
//    };
//    JobBlock refreshUI = ^{
//        [self->processMsg reloadData];
//    };
//
//    [MyThreadPool executeJob:initUnitBlock Main:refreshUI];
}
-(void)unitInit{
    
    ConnectionInstance* getUnitMsgInstance=[[ConnectionInstance alloc]init];
    
    ConnectionInstance* unitProcessInstance=[[ConnectionInstance alloc]init];
    
    NSDictionary* dataDic=[getUnitMsgInstance getUnitMsg:_bookId UserKey:[userInfo valueForKey:@"userKey"]];
    
    //[ConnectionFunction getUnitMsg:_bookId UserKey:[userInfo valueForKey:@"userKey"]];
    
    unitArray=[dataDic valueForKey:@"data"];
    
    unitProcessArray=[[unitProcessInstance unitProcess:_bookId UserKey:[userInfo valueForKey:@"userKey"]]valueForKey:@"data"];
    
//    [[ConnectionFunction unitProcess:_bookId UserKey:[userInfo valueForKey:@"userKey"]] valueForKey:@"data"];
    NSLog(@"显示单元进度数组%@",unitProcessArray);
}
-(void)titleShow{
    [HeadView titleShow:_bookName Color:ssRGBHex(0xFF7474) UIView:self.view UINavigationController:self.navigationController];
}
-(void)progressView{
    UIView* progressView=[[UIView alloc]initWithFrame:CGRectMake(0, 88.26, 414, 44.13)];
    [self.view addSubview:progressView];
    
    UILabel* wordShow=[[UILabel alloc]initWithFrame:CGRectMake(17.66, 13.24, 66.23, 18.76)];
    wordShow.text=@"当前进度";
    wordShow.textColor=ssRGBHex(0x9B9B9B);
    wordShow.font=[UIFont systemFontOfSize:12];
    [progressView addSubview:wordShow];
    
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
    
    processMsg=[[UITableView alloc]initWithFrame:CGRectMake(0, 134.62, 414, 647.72)];
    processMsg.dataSource=self;
    processMsg.delegate=self;
    [self.view addSubview:processMsg];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return unitArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //另一种cell格式，现在用不到
//    if (indexPath.row<=3) {
//        UnitsListTableViewCell* cell=[UnitsListTableViewCell createCellWithTableView:tableView];
//        [cell loadData:@"Unit 1" description:@"学习进度：35%"];
//        return cell;
//    }else{
//        UnitsListDownTableViewCell* cell=[UnitsListDownTableViewCell createCellWithTableView:tableView];
//        [cell loadData:@"Unit2"];
//        return cell;
//    }
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
