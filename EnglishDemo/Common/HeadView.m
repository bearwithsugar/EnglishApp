//
//  HeadView.m
//  EnglishDemo
//
//  Created by 马一轩 on 2019/2/21.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import "HeadView.h"
#import "Masonry.h"
#import "Masonry.h"
@interface HeadView(){

}

@end
@implementation HeadView

static UINavigationController* navigation;

+(void)titleShow:(NSString*)title Color:(UIColor*)color UIView:(UIView*)view UINavigationController: (UINavigationController*) navigationController{
    
    navigation=navigationController;
    
    UILabel* titleView=[[UILabel alloc]init];
    titleView.text=title;
    titleView.textColor=[UIColor whiteColor];
    titleView.backgroundColor=color;
    titleView.font=[UIFont systemFontOfSize:18];
    titleView.textAlignment=NSTextAlignmentCenter;
    titleView.clipsToBounds = YES;
    [titleView setUserInteractionEnabled:YES];
    
    UILabel* touchField=[[UILabel alloc]init];
    [touchField setUserInteractionEnabled:YES];
    [titleView addSubview:touchField];
    
    [touchField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleView).with.offset(5);
        make.top.equalTo(titleView).with.offset(15);
        make.width.equalTo(@35);
        make.height.equalTo(@35);
    }];
    
    UIButton* returnBtn=[[UIButton alloc]init];
    [returnBtn setBackgroundImage:[UIImage imageNamed:@"icon_return_ffffff"] forState:UIControlStateNormal];
    [returnBtn setBackgroundImage:[UIImage imageNamed:@"icon_return_ffffff"] forState:UIControlStateHighlighted];
    [returnBtn addTarget:self action:@selector(popBack:) forControlEvents:UIControlEventTouchUpInside];
    [touchField addSubview:returnBtn];
    
    [returnBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(touchField).with.offset(10.45);
        make.top.equalTo(touchField).with.offset(7);
        make.width.equalTo(@10.7);
        make.height.equalTo(@22.6);
    }];
    
    UITapGestureRecognizer* touchFunc=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(popBack:)];
    [touchField addGestureRecognizer:touchFunc];
    
    [view addSubview:titleView];
    
    [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view);
        make.right.equalTo(view);
        make.top.equalTo(view).with.offset(20);
        make.height.equalTo(@60);
    }];
    
}
+(void)popBack:(UITapGestureRecognizer*)sender{
    [navigation popViewControllerAnimated:true];
}
@end
