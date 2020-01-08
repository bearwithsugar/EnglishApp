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
#import "../../Functions/MyThreadPool.h"
#import "../../Functions/DownloadAudioService.h"
#import "../../Common/LoadGif.h"
#import "Masonry.h"


@implementation ChinSpellEnglish{
    
    //正确答案所在的位置
    NSUInteger rightAnswer;
    //答案是否可选
    BOOL clickable;
    UIButton* answer1;
    UIButton* answer2;
    UIButton* answer3;
    UIButton* answer4;
    
    UIView* questionPanel;
    
    UITextField* spellField;
    
    //播放音频所需
    VoicePlayer* voiceplayer;
    
    UIImageView* playBtn;

}



//问题界面
-(void)questionView{
    questionPanel=[[UIView alloc]init];
    questionPanel.backgroundColor=[UIColor whiteColor];
    [self addSubview:questionPanel];
    
    [questionPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.equalTo(self).multipliedBy(0.4);
    }];
    
    UILabel* questionTitle=[[UILabel alloc]init];
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
    
    [questionTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->questionPanel).with.offset(4.41);
        make.centerX.equalTo(self->questionPanel);
        make.width.equalTo(@300);
        make.height.equalTo(@74);
    }];
    
    
    playBtn=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_ceshi_laba1"]];
    UITapGestureRecognizer* playGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playVoice)];
    playBtn.userInteractionEnabled = YES;
    [playBtn addGestureRecognizer:playGesture];
    [questionPanel addSubview:playBtn];
    
    [playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self->questionPanel);
        make.centerX.equalTo(self->questionPanel);
        make.width.equalTo(self->questionPanel).multipliedBy(0.1);
        make.height.equalTo(self->questionPanel.mas_width).multipliedBy(0.1);
    }];
}
//答案界面
-(void)answerView{
    UILabel* answerTip=[[UILabel alloc]init];
    answerTip.text=@"根据中文意思拼写英文单词和句子";
    answerTip.textColor=ssRGBHex(0x9B9B9B );
    answerTip.font=[UIFont systemFontOfSize:12];
    answerTip.textAlignment=NSTextAlignmentCenter;
    [self addSubview:answerTip];
    
    [answerTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->questionPanel.mas_bottom).offset(20);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.equalTo(@20);
    }];
    
    spellField=[[UITextField alloc]init];
    [self addSubview:spellField];
    
    [spellField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->questionPanel.mas_bottom).with.offset(60);
        make.centerX.equalTo(self);
        make.width.equalTo(@250);
        make.height.equalTo(@36.41);
    }];
    
    UIView* lineView=[[UIView alloc]init];
    lineView.layer.borderWidth=1;
    lineView.layer.borderColor=ssRGBHex(0xF5A623).CGColor;
    [self addSubview:lineView];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->questionPanel.mas_bottom).with.offset(90);
        make.centerX.equalTo(self);
        make.width.equalTo(@250);
        make.height.equalTo(@1);
    }];
    
    UIButton* submitBtn=[[UIButton alloc]init];
    submitBtn.backgroundColor=ssRGBHex(0xF5A623);
    submitBtn.layer.cornerRadius=10;
    [submitBtn addTarget:self action:@selector(judgeTheAnswer) forControlEvents:UIControlEventTouchUpInside];
    [submitBtn setTitle:@"完成" forState:UIControlStateNormal];
    
    [self addSubview:submitBtn];
    
    [submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->questionPanel.mas_bottom).with.offset(140);
        make.centerX.equalTo(self);
        make.width.equalTo(@80);
        make.height.equalTo(@30);
    }];
        
}


-(void)playVoice{
    [playBtn removeFromSuperview];
    playBtn = [LoadGif imageViewfForPracticePlaying2];
    [questionPanel addSubview:playBtn];
    
    [playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self->questionPanel);
        make.centerX.equalTo(self->questionPanel);
        make.width.equalTo(self->questionPanel).multipliedBy(0.1);
        make.height.equalTo(self->questionPanel.mas_width).multipliedBy(0.1);
    }];
    
    //播放声音
    //音频播放空间分配
    
    VoidBlock stopBlock = ^{
        
        self->playBtn=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_ceshi_laba1"]];
        UITapGestureRecognizer* playGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playVoice)];
        self->playBtn.userInteractionEnabled = YES;
        [self->playBtn addGestureRecognizer:playGesture];
        self->playBtn.userInteractionEnabled = YES;
        [self->questionPanel addSubview:self->playBtn];
                   [self->playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                       make.centerY.equalTo(self->questionPanel);
                       make.centerX.equalTo(self->questionPanel);
                       make.width.equalTo(self->questionPanel).multipliedBy(0.1);
                       make.height.equalTo(self->questionPanel.mas_width).multipliedBy(0.1);
                   }];
        
    };
    
    JobBlock playBlock =^{
        
        NSString* playUrl;
        if ([super.testType isEqualToString:@"wrong"]) {
            if (super.testFlag < super.wordNum) {
                //错题本中单词
                playUrl=[DownloadAudioService getAudioPath:
                         [NSString stringWithFormat:@"%@",[[super.testArray objectAtIndex:super.testFlag] valueForKey:@"wordId"]]];
            }else{
                //错题本中句子
                playUrl=[DownloadAudioService getAudioPath:
                         [NSString stringWithFormat:@"%@",[[super.testArray objectAtIndex:super.testFlag] valueForKey:@"sentenceId"]]];
            }
        }else if([super.testType isEqualToString:@"word"]){
            //单词测试
            playUrl=[DownloadAudioService getAudioPath:
                     [NSString stringWithFormat:@"%@",[[super.testArray objectAtIndex:super.testFlag] valueForKey:@"wordId"]]];
        }else{
            //句子测试
            playUrl=[DownloadAudioService getAudioPath:
                     [NSString stringWithFormat:@"%@",[[super.testArray objectAtIndex:super.testFlag] valueForKey:@"sentenceId"]]];
        }
        
        if (self->voiceplayer!=NULL) {
            [self->voiceplayer interruptPlay];
            self->voiceplayer = NULL;
        }
        
        self->voiceplayer=[[VoicePlayer alloc]init];
        self->voiceplayer.url = playUrl;
        self->voiceplayer.myblock = stopBlock;
        [self->voiceplayer playAudio:0];
        //        if (self->continuePlay) {
        //            self->voiceplayer.urlArray = self->voiceArray;
        //            self->voiceplayer.startIndex = id+1;
        //        }
    };
    
    [MyThreadPool executeJob:playBlock Main:^{}];
    
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
    
    UILabel* rightAnswer=[[UILabel alloc]init];
    
    rightAnswer.text=answer;
    rightAnswer.textColor=ssRGBHex(0xFF7474 );
    rightAnswer.font=[UIFont systemFontOfSize:18];
    rightAnswer.textAlignment=NSTextAlignmentCenter;
    [self addSubview:rightAnswer];
    
    [rightAnswer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->questionPanel.mas_bottom).with.offset(100);
        make.centerX.equalTo(self);
        make.width.equalTo(@200);
        make.height.equalTo(@36);
    }];
    
    UIView* lineView=[[UIView alloc]initWithFrame:CGRectMake(115.91, 366, 178.84, 1)];
    lineView.layer.borderWidth=1;
    lineView.layer.borderColor=ssRGBHex(0xF5A623).CGColor;
    [self addSubview:lineView];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->questionPanel.mas_bottom).with.offset(130);
        make.centerX.equalTo(self);
        make.width.equalTo(@200);
        make.height.equalTo(@1);
    }];
    
    NSString* answerStr = spellField.text;
    NSCharacterSet  *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    answerStr = [answerStr stringByTrimmingCharactersInSet:set];
    
    if ([answerStr isEqualToString: answer]) {
        NSLog(@"拼写正确");
        rightAnswer.text=@"Yes！";
        rightAnswer.textColor=[UIColor greenColor];
    }else{
        NSLog(@"拼写错误");
        
        rightAnswer.text=answer;
        rightAnswer.textColor=ssRGBHex(0xFF7474 );
    }
    spellField.enabled=NO;
}

//点击背景收起键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self endEditing:YES]; //实现该方法是需要注意view需要是继承UIControl而来的
}
@end
