//
//  MoreRecommendViewController.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/20.
//  Copyright © 2018年 马一轩. All rights reserved.
//

#import "MoreRecommendViewController.h"
#import "Functions/WarningWindow.h"
#import "Common/HeadView.h"

@interface MoreRecommendViewController ()

@end

@implementation MoreRecommendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor whiteColor];
    [self titleShow];
    [self contentShow];
}
-(void)titleShow{
    [HeadView titleShow:@"更多软件推荐" Color:ssRGBHex(0xFF7474) UIView:self.view UINavigationController:self.navigationController];
}
-(void)contentShow{
    for (int i=0; i<1; i++) {
        float y=75.03*i+88.27;
        UIView* recommend=[[UIView alloc]initWithFrame:CGRectMake(0, y, 414, 75.03)];
        [self.view addSubview:recommend];
        //竖线左侧   小学语文同步练还有小星星
        UIView* alogo=[[UIView alloc]initWithFrame:CGRectMake(11.04, 34.2, 46.36 , 46.36)];
        alogo.layer.cornerRadius=10;
        alogo.layer.borderColor=ssRGBHex(0x9B9B9B).CGColor;
        alogo.layer.borderWidth=1;
        alogo.backgroundColor=ssRGBHex(0x9B9B9B);
        [recommend addSubview:alogo];
        UILabel* littleSchoolLabel=[[UILabel alloc]initWithFrame:CGRectMake(73.96, 38.62, 90.52, 18.75)];
        littleSchoolLabel.text=@"小学语文同步练";
        littleSchoolLabel.font=[UIFont systemFontOfSize:12];
        [recommend addSubview:littleSchoolLabel];
        
        for (int i=0; i<4; i++) {
            float x=71.76+2.20*(i+1)+13.24*i;
            UIImageView* star=[[UIImageView alloc]initWithFrame:CGRectMake(x, 61.79, 13.24, 12.13)];
            star.image=[UIImage imageNamed:@"icon_star_F5A623"];
            [recommend addSubview:star];
            
        }
        UIImageView* star=[[UIImageView alloc]initWithFrame:CGRectMake(135.79, 61.79, 13.24, 12.13)];
        star.image=[UIImage imageNamed:@"icon_star_ffffff"];
        [recommend addSubview:star];
        
        //间隔竖线
        UIView* devideLine=[[UIView alloc]initWithFrame:CGRectMake(188.78, 37.51, 2, 39.72)];
        devideLine.layer.borderColor=ssRGBHex(0x979797).CGColor;
        devideLine.layer.borderWidth=1;
        [recommend addSubview:devideLine];
        
        //竖线右侧
        UITextView* theDetail=[[UITextView alloc]initWithFrame:CGRectMake(211.96, 37.51, 140, 37.51)];
        theDetail.text=@"同步教材，同步练习！\n巩固知识，提升成绩！";
        theDetail.font=[UIFont systemFontOfSize:12];
        theDetail.editable=false;
        [recommend addSubview:theDetail];
        
        UIButton* loadBtn=[[UIButton alloc]initWithFrame:CGRectMake(351.07, 35.31, 44.16, 44.16)];
        [loadBtn setBackgroundImage:[UIImage imageNamed:@"icon_download"] forState:UIControlStateNormal];
        [loadBtn addTarget:self action:@selector(download) forControlEvents:UIControlEventTouchUpInside];
        [recommend addSubview:loadBtn];
    }
}
-(void)download{
    [self presentViewController:[WarningWindow MsgWithoutTrans:@"该功能尚未实现，敬请期待！"] animated:YES completion:nil];
}
-(void)popBack{
    [self.navigationController popViewControllerAnimated:true];
}
@end
