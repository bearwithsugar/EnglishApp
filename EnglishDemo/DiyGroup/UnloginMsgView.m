//
//  UnloginMsgView.m
//  EnglishDemo
//
//  Created by 马一轩 on 2019/1/25.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import "UnloginMsgView.h"

@implementation UnloginMsgView

-(id)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
       
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self msgLabel];
}
-(void)msgLabel{
    UILabel* msgLabel=[[UILabel alloc]initWithFrame:CGRectMake(50, 200, 314, 60)];
    msgLabel.text=@"您还没登录，等登录后查看！";
    msgLabel.font=[UIFont systemFontOfSize:17];
    msgLabel.textAlignment=NSTextAlignmentCenter;
    msgLabel.textColor=ssRGBHex(0x4A4A4A);
    [self addSubview:msgLabel];
}

@end
