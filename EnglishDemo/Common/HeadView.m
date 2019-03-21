//
//  HeadView.m
//  EnglishDemo
//
//  Created by 马一轩 on 2019/2/21.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import "HeadView.h"
@interface HeadView(){

}

@end
@implementation HeadView

static UINavigationController* navigation;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


+(UIView*)titleShow:(NSString*)title Color:(UIColor*)color Located:(CGRect)cgrect UINavigationController: (UINavigationController*) navigationController{
    
    navigation=navigationController;
    
    UILabel* titleView=[[UILabel alloc]initWithFrame:cgrect];
    titleView.text=title;
    titleView.textColor=[UIColor whiteColor];
    titleView.backgroundColor=color;
    titleView.font=[UIFont systemFontOfSize:18];
    titleView.textAlignment=NSTextAlignmentCenter;
    titleView.clipsToBounds = YES;
    [titleView setUserInteractionEnabled:YES];
    
    UILabel* touchField=[[UILabel alloc]initWithFrame:CGRectMake(5, 15,35, 35)];
    //touchField.backgroundColor=[UIColor blackColor];
    [touchField setUserInteractionEnabled:YES];
    [titleView addSubview:touchField];
    
    UIButton* returnBtn=[[UIButton alloc]initWithFrame:CGRectMake(10.45, 7.06, 10.7, 22.62)];
    [returnBtn setBackgroundImage:[UIImage imageNamed:@"icon_return_ffffff"] forState:UIControlStateNormal];
    [returnBtn setBackgroundImage:[UIImage imageNamed:@"icon_return_ffffff"] forState:UIControlStateHighlighted];
    [touchField addSubview:returnBtn];
    
    UITapGestureRecognizer* touchFunc=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(popBack:)];
    [touchField addGestureRecognizer:touchFunc];
    
    return titleView;
    
}
+(void)popBack:(UITapGestureRecognizer*)sender{
    [navigation popViewControllerAnimated:true];
}
@end
