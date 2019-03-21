//
//  TestFunctions.m
//  EnglishDemo
//
//  Created by 马一轩 on 2019/1/14.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import "TestFunctions.h"
#import "../../Functions/ConnectionFunction.h"
#import "../../Functions/VoicePlayer.h"

@implementation TestFunctions{
    
    
}

-(id)initWithFrame:(CGRect)frame
          TestFlag:(int)testFlag
         TestArray:(NSArray*)testArray
          TestType:(NSString*)testType
          UserInfo:(NSDictionary*)userInfo
{
    if (self=[super initWithFrame:frame]) {
        _testFlag=testFlag;
        _testArray=testArray;
        _testType=testType;
        _userInfo=userInfo;
        _clickable=true;
        [self questionView];
        [self answerView];
        [self wrongFrom];
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
}
//问题界面
-(void)questionView{
    
}
//答案界面
-(void)answerView{
   
}
-(void)wrongFrom{
    if ([_testType isEqualToString:@"wrong"]) {
        UILabel* wrongFrom=[[UILabel alloc]initWithFrame:CGRectMake(50, 550, 314, 50)];
        wrongFrom.textAlignment=NSTextAlignmentCenter;
        //        if (super.testFlag<super.wordNum) {
        //            wrongFrom.text=@"错题来源";
        //        }
        wrongFrom.text=[[_testArray objectAtIndex:_testFlag] valueForKey:@"articleName"];
        wrongFrom.textColor=ssRGBHex(0x9B9B9B);
        wrongFrom.font=[UIFont systemFontOfSize:12];
        [self addSubview:wrongFrom];
    }
}


@end
