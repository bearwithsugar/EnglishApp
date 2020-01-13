//
//  EngChooseChi.m
//  EnglishDemo
//
//  Created by 马一轩 on 2019/1/14.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import "EngChooseChi.h"
#import "../../Functions/ConnectionFunction.h"
#import "../../Functions/VoicePlayer.h"
#import "../../Functions/MyThreadPool.h"
#import "../../Functions/DownloadAudioService.h"
#import "../../Common/LoadGif.h"
#import "Masonry.h"

@implementation EngChooseChi{
    //正确答案所在的位置
    NSUInteger rightAnswer;
    UIButton* answer1;
    UIButton* answer2;
    UIButton* answer3;
    UIButton* answer4;
    
    UIImageView* normalLaba;
    UIImageView* testLaba;
    
    UIView* questionPanel;
    UIView* playBtn;
    
    //播放音频所需
    VoicePlayer* voiceplayer;
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
        questionTitle.text=[[super.testArray objectAtIndex:super.testFlag] valueForKey:@"wordEng"];
        questionTitle.font=[UIFont systemFontOfSize:48];
    }else if ([super.testType isEqualToString:@"sentence"]){
        questionTitle.text=[[super.testArray objectAtIndex:super.testFlag] valueForKey:@"sentenceEng"];
        questionTitle.font=[UIFont systemFontOfSize:22];
    }else{
        if (super.testFlag<super.wordNum) {
            questionTitle.text=[[[super.testArray objectAtIndex:super.testFlag] valueForKey:@"bookWord"] valueForKey:@"wordEng"];
            questionTitle.font=[UIFont systemFontOfSize:48];
        }else{
            questionTitle.text=[[[super.testArray objectAtIndex:super.testFlag] valueForKey:@"bookSentence"]valueForKey:@"sentenceEng"];
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
    
//    UILabel* questionVoice=[[UILabel alloc]init];
//    NSString* voiceHelp = [[super.testArray objectAtIndex:super.testFlag] valueForKey:@"wordTag"];
//    if ([voiceHelp isEqualToString:@"无"]) {
//        questionVoice.text = @"";
//    }else{
//        questionVoice.text=[[super.testArray objectAtIndex:super.testFlag] valueForKey:@"wordTag"];
//    }
//    questionVoice.textColor=ssRGBHex(0x4A4A4A);
//    questionVoice.font=[UIFont systemFontOfSize:20];
//    questionVoice.textAlignment=NSTextAlignmentCenter;
//    [questionPanel addSubview:questionVoice];
//
//    [questionVoice mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self->questionPanel).with.offset(87.17);
//        make.centerX.equalTo(self->questionPanel);
//        make.width.equalTo(@120);
//        make.height.equalTo(@28);
//    }];
    
    playBtn=[[UIView alloc]init];
    [self addPicForLaba:
    [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_ceshi_laba1"]]
    ] ;
    
//    testLaba = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_ceshi_laba1"]];
//    [playBtn addSubview:testLaba];
//    [testLaba setHidden:YES];
    
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
    answerTip.text=@"根据英文单词或句子选择中文意思";
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
    
    UIView* answerView;
    answerView=[[UIView alloc]init];
    [self addSubview:answerView];
    
    [answerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(answerTip.mas_bottom).with.offset(18);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
    }];
    
    //创建数组
    NSMutableArray *answerArray = [NSMutableArray array];
    NSMutableArray* allAnswerArray = [[NSMutableArray alloc]init];
    
    JobBlock myBlock = ^{
        for (NSString* answer in [[super.testArray valueForKey:@"chnErrorChoice"]firstObject]) {
            [allAnswerArray addObject:answer];
        }
        
        //随机数
        self->rightAnswer = arc4random_uniform(4);
        
        for (int i=0; i<4; i++) {
            if (i==self->rightAnswer) {
                if ([super.testType isEqualToString:@"word"]){
                    [answerArray addObject:[[super.testArray objectAtIndex:super.testFlag] valueForKey:@"wordChn"]];
                }else if([super.testType isEqualToString:@"sentence"]){
                    [answerArray addObject:[[super.testArray objectAtIndex:super.testFlag] valueForKey:@"sentenceChn"]];
                }else{
                    if (super.testFlag<super.wordNum) {
                        [answerArray addObject:[[[super.testArray objectAtIndex:super.testFlag] valueForKey:@"bookWord"]valueForKey:@"wordChn"]];
                    }else{
                        [answerArray addObject:[[[super.testArray objectAtIndex:super.testFlag]valueForKey:@"bookSentence"] valueForKey:@"sentenceChn"]];
                    }
                    
                }
                
            }else{
                NSUInteger randomNum = arc4random_uniform((int)allAnswerArray.count-1);
                [answerArray addObject:[allAnswerArray objectAtIndex:randomNum]];
                [allAnswerArray removeObjectAtIndex:randomNum];
            }
        }
        
    };
    
    JobBlock setAnswer =^{
        self->answer1=[[UIButton alloc]init];
        [self->answer1 setBackgroundColor:[UIColor whiteColor]];
        [self->answer1 setTitle:[answerArray objectAtIndex:0] forState:UIControlStateNormal];
        //下面两行代码用来控制多行显示
        self->answer1.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self->answer1 setTitleEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        [self->answer1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self->answer1.titleLabel.font=[UIFont systemFontOfSize:20];
        self->answer1.tag=0;
        
        [self->answer1 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self->answer1 addTarget:self action:@selector(chooseAnswer:) forControlEvents:UIControlEventTouchUpInside];
        [answerView addSubview:self->answer1];
        
        self->answer2=[[UIButton alloc]init];
        [self->answer2 setBackgroundColor:[UIColor whiteColor]];
        [self->answer2 setTitle:[answerArray objectAtIndex:1] forState:UIControlStateNormal];
        //下面两行代码用来控制多行显示
        self->answer2.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self->answer2 setTitleEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        [self->answer2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self->answer2 setTitleColor:[UIColor whiteColor]forState:UIControlStateSelected];
        self->answer2.titleLabel.font=[UIFont systemFontOfSize:20];
        self->answer2.tag=1;
        
        [self->answer2 addTarget:self action:@selector(chooseAnswer:) forControlEvents:UIControlEventTouchUpInside];
        [answerView addSubview:self->answer2];
        
        self->answer3=[[UIButton alloc]init];
        [self->answer3 setBackgroundColor:[UIColor whiteColor]];
        [self->answer3 setTitle:[answerArray objectAtIndex:2] forState:UIControlStateNormal];
        //下面两行代码用来控制多行显示
        self->answer3.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self->answer3 setTitleEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        [self->answer3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self->answer3 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        self->answer3.titleLabel.font=[UIFont systemFontOfSize:20];
        self->answer3.tag=2;
        
        [self->answer3 addTarget:self action:@selector(chooseAnswer:) forControlEvents:UIControlEventTouchUpInside];
        [answerView addSubview:self->answer3];
        
        self->answer4=[[UIButton alloc]init];
        [self->answer4 setBackgroundColor:[UIColor whiteColor]];
        [self->answer4 setTitle:[answerArray objectAtIndex:3] forState:UIControlStateNormal];
        //下面两行代码用来控制多行显示
        self->answer4.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self->answer4 setTitleEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        [self->answer4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self->answer4 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        self->answer4.titleLabel.font=[UIFont systemFontOfSize:20];
        self->answer4.tag=3;
        
        [self->answer4 addTarget:self action:@selector(chooseAnswer:) forControlEvents:UIControlEventTouchUpInside];
        [answerView addSubview:self->answer4];
        
        [self->answer1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(answerView).with.offset(20);
            make.width.equalTo(answerView).multipliedBy(0.4);
            make.left.equalTo(answerView).with.offset(20);
            make.height.equalTo(answerView.mas_width).multipliedBy(0.25);
        }];
        
        [self->answer2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(answerView).with.offset(20);
            make.width.equalTo(answerView).multipliedBy(0.4);
            make.right.equalTo(answerView).with.offset(-20);
            make.height.equalTo(answerView.mas_width).multipliedBy(0.25);
        }];
        
        [self->answer3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(answerView).with.offset(-20);
            make.left.equalTo(answerView).with.offset(20);
            make.width.equalTo(answerView).multipliedBy(0.4);
            make.height.equalTo(answerView.mas_width).multipliedBy(0.25);
        }];
        
        [self->answer4 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(answerView).with.offset(-20);
            make.right.equalTo(answerView).with.offset(-20);
            make.width.equalTo(answerView).multipliedBy(0.4);
            make.height.equalTo(answerView.mas_width).multipliedBy(0.25);
        }];
    };
    
    [MyThreadPool executeJob:myBlock Main:setAnswer];
    
   

}

//选择答案触发事件
-(void)chooseAnswer:(UIButton*)btn{
    if (super.clickable) {
        if (btn.tag==rightAnswer) {
            NSLog(@"选择正确");
            btn.backgroundColor=ssRGBHex(0x00CC00);
            super.clickable=false;
            
        }else{
            NSLog(@"错误");
            btn.backgroundColor=ssRGBHex(0xFF7474);
            NSString* subjectType;
            if ([super.testType isEqualToString:@"word"]) {
                subjectType=@"2";
            }else{
                subjectType=@"1";
            }
            NSDictionary* dic= [ConnectionFunction addWrongMsg:[super.userInfo valueForKey:@"userKey"] Id:[NSString stringWithFormat:@"%@",[[super.testArray objectAtIndex:super.testFlag]valueForKey:@"wordId"]] Type:subjectType];
            NSLog(@"testarray是%@",[super.testArray objectAtIndex:super.testFlag]);
            NSLog(@"错题添加结果%@",dic);
        }
        btn.selected=true;
    }
    
    
    
}
//高亮显示
-(void)highlightAnswer{
    if (answer1.tag==rightAnswer) {
        answer1.selected=true;
        answer1.backgroundColor=ssRGBHex(0xFF7474);
    }else if (answer2.tag==rightAnswer){
        answer2.selected=true;
        answer2.backgroundColor=ssRGBHex(0xFF7474);
    }else if (answer3.tag==rightAnswer){
        answer3.selected=true;
        answer3.backgroundColor=ssRGBHex(0xFF7474);
    }else if (answer4.tag==rightAnswer){
        answer4.selected=true;
        answer4.backgroundColor=ssRGBHex(0xFF7474);
    }
}

-(void)playVoice{
    
    [self clearLaba];

    [self addPicForLaba:[LoadGif imageViewfForPracticePlaying2]];

//    [normalLaba setHidden:YES];
//    [testLaba setHidden:NO];

    
    //播放声音
    //音频播放空间分配
    
    VoidBlock stopBlock = ^{
        [self clearLaba];
        [self addPicForLaba:
         [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_ceshi_laba1"]]
         ] ;
//        [self->normalLaba setHidden:NO];
//        [self->testLaba setHidden:YES];
    };
    
    //播放声音
    //音频播放空间分配
    
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

    };
    
    [MyThreadPool executeJob:playBlock Main:^{}];
    
}

-(void)addPicForLaba:(UIImageView*)image{
    [playBtn addSubview:image];
    [image mas_makeConstraints:^(MASConstraintMaker *make) {
              make.edges.equalTo(playBtn);
    }];
    normalLaba = image;
}

-(void)clearLaba{
    [normalLaba removeFromSuperview];
}
@end
