//
//  EngVoiceChooseEng.m
//  EnglishDemo
//
//  Created by 马一轩 on 2019/1/14.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import "ChnChooseEng.h"
#import "../../Functions/ConnectionFunction.h"
#import "../../Functions/VoicePlayer.h"
#import "../../Functions/MyThreadPool.h"
#import "../../Functions/DownloadAudioService.h"
#import "Masonry.h"

@implementation ChnChooseEng{
    //正确答案所在的位置
    NSUInteger rightAnswer;
    UIButton* answer1;
    UIButton* answer2;
    UIButton* answer3;
    UIButton* answer4;
    
    UIView* questionPanel;
    
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
    
    UIButton* playBtn=[[UIButton alloc]init];
    [playBtn setBackgroundImage:[UIImage imageNamed:@"icon_ceshi_laba"] forState:UIControlStateNormal];
    [playBtn addTarget:self action:@selector(playVoice) forControlEvents:UIControlEventTouchUpInside];
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
    answerTip.text=@"根据中文意思选择英文单词或句子";
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
        for (NSDictionary* dic in super.testArray) {
            if ([super.testType isEqualToString:@"word"]){
                [allAnswerArray addObject:[dic valueForKey:@"wordEng"]];
            }else if([super.testType isEqualToString:@"sentence"]){
                [allAnswerArray addObject:[dic valueForKey:@"sentenceEng"]];
            }else{
                if (super.testFlag<super.wordNum) {
                    [allAnswerArray addObject:[[dic valueForKey:@"bookWord"]valueForKey:@"wordEng"]];
                }else{
                    [allAnswerArray addObject:[[dic valueForKey:@"bookSentence"] valueForKey:@"sentenceEng"]];
                }
                
            }
        }
        
        //随机数
        self->rightAnswer = arc4random_uniform(4);
        
        for (int i=0; i<4; i++) {
            if (i==self->rightAnswer) {
                if ([super.testType isEqualToString:@"word"]){
                    [answerArray addObject:[[super.testArray objectAtIndex:super.testFlag] valueForKey:@"wordEng"]];
                    [allAnswerArray removeObject:[[super.testArray objectAtIndex:super.testFlag] valueForKey:@"wordEng"]];
                }else if([super.testType isEqualToString:@"sentence"]){
                    [answerArray addObject:[[super.testArray objectAtIndex:super.testFlag] valueForKey:@"sentenceEng"]];
                    [allAnswerArray removeObject:[[super.testArray objectAtIndex:super.testFlag] valueForKey:@"sentenceEng"]];
                }else{
                    if (super.testFlag<super.wordNum) {
                        [answerArray addObject:[[[super.testArray objectAtIndex:super.testFlag] valueForKey:@"bookWord"]valueForKey:@"wordEng"]];
                        [allAnswerArray removeObject:[[[super.testArray objectAtIndex:super.testFlag] valueForKey:@"bookWord"]valueForKey:@"wordEng"]];
                    }else{
                        [answerArray addObject:[[[super.testArray objectAtIndex:super.testFlag]valueForKey:@"bookSentence"] valueForKey:@"sentenceEng"]];
                        [allAnswerArray removeObject:[[[super.testArray objectAtIndex:super.testFlag] valueForKey:@"bookSentence"] valueForKey:@"sentenceEng"]];
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
            //[self highlightAnswer];
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
        self->voiceplayer.myblock = ^{};
        [self->voiceplayer playAudio:0];
        //        if (self->continuePlay) {
        //            self->voiceplayer.urlArray = self->voiceArray;
        //            self->voiceplayer.startIndex = id+1;
        //        }
    };
    
    [MyThreadPool executeJob:playBlock Main:^{}];
    
}
@end
