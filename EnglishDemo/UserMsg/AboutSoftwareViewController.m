//
//  OboutSoftwareViewController.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/18.
//  Copyright © 2018年 马一轩. All rights reserved.
//

#import "AboutSoftwareViewController.h"
#import "../Common/HeadView.h"

@interface AboutSoftwareViewController ()

@end

@implementation AboutSoftwareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    [self titleShow];
    [self textShow];
}
-(void)titleShow{
    [self.view addSubview:[HeadView titleShow:@"关于本软件" Color:ssRGBHex(0xFF7474) Located:CGRectMake(0, 22.06, 414, 66.2) UINavigationController:self.navigationController]];
}
-(void)textShow{
    UITextView* textShow=[[UITextView alloc]initWithFrame:CGRectMake(22.08, 110.34, 369.83, 399.33)];
    textShow.text=@"“学伴”系列软件是针对课本同步学习的强大助手，能帮助同学快速掌握课程要点、巩固学习成果、强化知识记忆、提升考试成绩。 \n“小学英语学伴”APP采用简洁明了的操作界面，能迅速帮助你掌握软件使用技巧。APP具有以下几个特点： \n1、全面完整的课程体系 \n2、标准清晰的阅读语音 \n3、先进专业的跟读评分 \n4、智能贴心的学习记录更有多种测试练习和学习成绩的综合评价，是一款专业、易用的学习软件。 \n \n如果你对软件有好的建议，欢迎和我们联系。 \n客服QQ：123456789";
    textShow.editable=false;
    textShow.textColor=ssRGBHex(0x4A4A4A);
    textShow.font=[UIFont systemFontOfSize:14];
    [self.view addSubview:textShow];
}

-(void)popBack{
    [self.navigationController popViewControllerAnimated:true];
}


@end
