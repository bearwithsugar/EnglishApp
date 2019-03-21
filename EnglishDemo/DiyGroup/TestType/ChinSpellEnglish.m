//
//  ChinChooseEnglish.m
//  EnglishDemo
//
//  Created by 马一轩 on 2019/1/14.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import "ChinSpellEnglish.h"
#import "../../Functions/ConnectionFunction.h"
#import "../../Functions/VoicePlayer.h"


@implementation ChinSpellEnglish{
    
    //正确答案所在的位置
    NSUInteger rightAnswer;
    //答案是否可选
    BOOL clickable;
    UIButton* answer1;
    UIButton* answer2;
    UIButton* answer3;
    UIButton* answer4;
    
    UITextField* spellField;
    
    //播放音频所需
    VoicePlayer* voiceplayer;

}



//问题界面
-(void)questionView{
    UIView* questionPanel;
    questionPanel=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 414, 187.58)];
    questionPanel.backgroundColor=[UIColor whiteColor];
    [self addSubview:questionPanel];
    
    UILabel* questionTitle=[[UILabel alloc]initWithFrame:CGRectMake(50, 4.41, 314, 73.93)];
    if ([super.testType isEqualToString:@"word"]) {
        questionTitle.text=[[super.testArray objectAtIndex:super.testFlag] valueForKey:@"wordChn"];
        questionTitle.font=[UIFont systemFontOfSize:48];
    }else if ([super.testType isEqualToString:@"sentence"]){
        questionTitle.text=[[super.testArray objectAtIndex:super.testFlag] valueForKey:@"sentenceChn"];
        questionTitle.font=[UIFont systemFontOfSize:22];
    }else{
        if (super.testFlag<super.wordNum) {
            questionTitle.text=[[[super.testArray objectAtIndex:super.testFlag] valueForKey:@"bookWord"] valueForKey:@"wordChn"];
            questionTitle.font=[UIFont systemFontOfSize:48];
        }else{
            questionTitle.text=[[[super.testArray objectAtIndex:super.testFlag] valueForKey:@"bookSentence"]valueForKey:@"sentenceChn"];
            questionTitle.font=[UIFont systemFontOfSize:22];
        }
    }
    
    questionTitle.textColor=ssRGBHex(0xFF7474);
    questionTitle.textAlignment=NSTextAlignmentCenter;
    [questionPanel addSubview:questionTitle];
    
    UIButton* playBtn=[[UIButton alloc]initWithFrame:CGRectMake(193.19, 116.96, 28.7, 26.48)];
    [playBtn setBackgroundImage:[UIImage imageNamed:@"icon_ceshi_laba"] forState:UIControlStateNormal];
    [playBtn addTarget:self action:@selector(playVoice) forControlEvents:UIControlEventTouchUpInside];
    [questionPanel addSubview:playBtn];
}
//答案界面
-(void)answerView{
    UILabel* answerTip=[[UILabel alloc]initWithFrame:CGRectMake(108.29, 205.23, 198.72, 18.75)];
    answerTip.text=@"根据中文意思拼写英文单词和句子";
    answerTip.textColor=ssRGBHex(0x9B9B9B );
    answerTip.font=[UIFont systemFontOfSize:12];
    answerTip.textAlignment=NSTextAlignmentCenter;
    [self addSubview:answerTip];
    
    spellField=[[UITextField alloc]initWithFrame:CGRectMake(119.23, 285.79, 276, 36.41)];
    [self addSubview:spellField];
    
    UIView* lineView=[[UIView alloc]initWithFrame:CGRectMake(115.91, 318.89, 178.84, 1)];
    lineView.layer.borderWidth=1;
    lineView.layer.borderColor=ssRGBHex(0xF5A623).CGColor;
    [self addSubview:lineView];
    
    UIButton* submitBtn=[[UIButton alloc]initWithFrame:CGRectMake(167, 400, 80,30)];
    submitBtn.backgroundColor=ssRGBHex(0xF5A623);
    submitBtn.layer.cornerRadius=10;
    [submitBtn addTarget:self action:@selector(judgeTheAnswer) forControlEvents:UIControlEventTouchUpInside];
    [submitBtn setTitle:@"完成" forState:UIControlStateNormal];
    
    [self addSubview:submitBtn];
        
}


-(void)playVoice{
    //播放声音
    //音频播放空间分配
    NSString* playUrl;
    if ([super.testType isEqualToString:@"wrong"]) {
        if (super.testFlag<super.wordNum) {
            //错题本中单词
            playUrl=[[[[super.testArray objectAtIndex:super.testFlag]
                       valueForKey:@"bookWord"]valueForKey:@"engUrl"]
                     stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        }else{
            //错题本中句子
            playUrl=[[[[super.testArray objectAtIndex:super.testFlag]
                       valueForKey:@"bookSentence"]valueForKey:@"engUrl"]
                     stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        }
    }else{
        //c单词测试和句子测试h返回信息是一样的
        playUrl=[[[super.testArray objectAtIndex:super.testFlag]valueForKey:@"engUrl"] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    }
    voiceplayer=[[VoicePlayer alloc]init];
    voiceplayer.url=playUrl;
    [voiceplayer.audioStream play];
}

-(void)judgeTheAnswer{
    NSString* answer;
    if ([super.testType isEqualToString:@"word"]) {
        answer=[[super.testArray objectAtIndex:super.testFlag] valueForKey:@"wordEng"];
    }else if(([super.testType isEqualToString:@"sentence"])){
        answer=[[super.testArray objectAtIndex:super.testFlag] valueForKey:@"sentenceEng"];
    }else{
        if (super.testFlag<super.wordNum) {
            answer=[[[super.testArray objectAtIndex:super.testFlag] valueForKey:@"bookWord"] valueForKey:@"wordEng"];
        }else{
            answer=[[[super.testArray objectAtIndex:super.testFlag] valueForKey:@"bookSentence"]valueForKey:@"sentenceEng"];
        }
    }
    
    if (spellField.text==answer) {
        NSLog(@"拼写正确");
    }else{
        NSLog(@"拼写错误");
        
        UILabel* rightAnswer=[[UILabel alloc]initWithFrame:CGRectMake(115.91, 334.34, 198.72, 36)];
        
        rightAnswer.text=answer;
        rightAnswer.textColor=ssRGBHex(0xFF7474 );
        rightAnswer.font=[UIFont systemFontOfSize:18];
        rightAnswer.textAlignment=NSTextAlignmentCenter;
        [self addSubview:rightAnswer];
        
        UIView* lineView=[[UIView alloc]initWithFrame:CGRectMake(115.91, 366, 178.84, 1)];
        lineView.layer.borderWidth=1;
        lineView.layer.borderColor=ssRGBHex(0xF5A623).CGColor;
        [self addSubview:lineView];
    }
    spellField.enabled=NO;
}
@end
