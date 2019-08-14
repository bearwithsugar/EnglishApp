//
//  ProcessLine.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/22.
//  Copyright © 2018 马一轩. All rights reserved.
//

#import "ProcessLine.h"

@implementation ProcessLine

-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
        self.layer.borderWidth=1;
        self.layer.borderColor=ssRGBHex(0xFF7474).CGColor;

    }
    return self;
}
-(void)percentLabel:(float)number{
    UILabel* percentLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width*(number/100), self.frame.size.height)];
    percentLabel.backgroundColor=ssRGBHex(0xFF7474);
    [self addSubview:percentLabel];
    
    UILabel* percentNumber=[[UILabel alloc]initWithFrame:CGRectMake((self.frame.size.width-35)/2, 0, 35, self.frame.size.height)];
    int percent=(int)(number);
    NSMutableString* tag=[NSMutableString stringWithFormat:@"%d",percent];
    [tag appendString:@"%"];
    percentNumber.text=tag;
    if (number<=54) {
        percentNumber.textColor=[UIColor blackColor];
    }else{
        percentNumber.textColor=[UIColor whiteColor];
    }
    percentNumber.font=[UIFont systemFontOfSize:10];
    percentNumber.textAlignment=NSTextAlignmentCenter;
    [self addSubview:percentNumber];
    
    
}
@end
