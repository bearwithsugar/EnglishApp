//
//  RechargeRecordViewController.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/16.
//  Copyright © 2018年 马一轩. All rights reserved.
//

#import "RechargeRecordViewController.h"
#import "../Functions/DocuOperate.h"
#import "../Functions/ConnectionFunction.h"
#import "../DiyGroup/OrderTableViewCell.h"
#import "../DiyGroup/UnloginMsgView.h"
#import "../Common/HeadView.h"

@interface RechargeRecordViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSDictionary* userInfo;
    NSArray* orderDic;
}
@end

@implementation RechargeRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    [self titleShow];
    
}
-(void)viewWillAppear:(BOOL)animated{
    if ([DocuOperate fileExistInPath:@"userInfo.plist"]) {
        userInfo=[DocuOperate readFromPlist:@"userInfo.plist"];
        orderDic=[[ConnectionFunction orderMsg:[userInfo valueForKey:@"userKey"]]valueForKey:@"data"];
        [self rechargeMsg];
    }
    else{
        UnloginMsgView* unloginView=[[UnloginMsgView alloc]initWithFrame:CGRectMake(0, 88.27, 414, 647)];
        [self.view addSubview:unloginView];
    }

    //NSLog(@"拿到的日期是%@",[self returndate:[NSNumber numberWithLong:1547883896000]]);
}
-(NSString *)returndate:(NSNumber *)num{
    NSString *str1=[NSString stringWithFormat:@"%@",num];
    int x=[[str1 substringToIndex:10] intValue];
    NSDate* date1 = [NSDate dateWithTimeIntervalSince1970:x];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
    [dateformatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
    return [dateformatter stringFromDate:date1];
    
}

-(void)titleShow{
    [self.view addSubview:[HeadView titleShow:@"充值记录" Color:ssRGBHex(0xFF7474) Located:CGRectMake(0, 22.06, 414, 66.2) UINavigationController:self.navigationController]];
}
-(void)rechargeMsg{
    UITableView* rechargeMsg=[[UITableView alloc]initWithFrame:CGRectMake(0, 88.27, 414, 647.72)];
    rechargeMsg.dataSource=self;
    rechargeMsg.delegate=self;
    [self.view addSubview:rechargeMsg];
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return orderDic.count ;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* date=[self returndate:[[orderDic objectAtIndex:indexPath.row]valueForKey:@"updateTime"]];
    OrderTableViewCell* cell=[OrderTableViewCell createCellWithTableView:tableView];
    [cell loadData:date
             Score:[NSString stringWithFormat:@"%@",[[orderDic objectAtIndex:indexPath.row]valueForKey:@"price"]]
       description:@""];
    return cell;
}

-(void)popBack{
    [self.navigationController popViewControllerAnimated:true];
}



@end
