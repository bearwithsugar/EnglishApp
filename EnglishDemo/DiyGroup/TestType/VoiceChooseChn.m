//
//  ChooseChineseType.m
//  EnglishDemo
//
//  Created by 马一轩 on 2019/1/13.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import "VoiceChooseChn.h"
#import "../../Functions/ConnectionFunction.h"
#import "../../Functions/VoicePlayer.h"
#import "../../Functions/MyThreadPool.h"
#import "../../Functions/DownloadAudioService.h"

@implementation VoiceChooseChn{
    //正确答案所在的位置
    NSUInteger rightAnswer;
    UIButton* answer1;
    UIButton* answer2;
    UIButton* answer3;
    UIButton* answer4;
    
    //播放音频所需
    VoicePlayer* voiceplayer;
}
//问题界面
-(void)questionView{
    UIView* questionPanel;
    questionPanel=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 414, 187.58)];
    questionPanel.backgroundColor=[UIColor whiteColor];
    [self addSubview:questionPanel];

    UIButton* playBtn=[[UIButton alloc]initWithFrame:CGRectMake(193.19, 64, 28.7, 26.48)];
    [playBtn setBackgroundImage:[UIImage imageNamed:@"icon_ceshi_laba"] forState:UIControlStateNormal];
    [playBtn addTarget:self action:@selector(playVoice) forControlEvents:UIControlEventTouchUpInside];
    [questionPanel addSubview:playBtn];
}
//答案界面
-(void)answerView{
    UILabel* answerTip=[[UILabel alloc]initWithFrame:CGRectMake(108.29, 205.23, 198.72, 18.75)];
    answerTip.text=@"根据英文发音选择中文意思";
    answerTip.textColor=ssRGBHex(0x9B9B9B );
    answerTip.font=[UIFont systemFontOfSize:12];
    answerTip.textAlignment=NSTextAlignmentCenter;
    [self addSubview:answerTip];

    UIView* answerView;
    answerView=[[UIView alloc]initWithFrame:CGRectMake(53, 239.44, 308, 293.51)];
    [self addSubview:answerView];

    //创建数组
    NSMutableArray* answerArray = [NSMutableArray array];
    NSMutableArray* allAnswerArray = [[NSMutableArray alloc]init];
    
    JobBlock myBlock = ^{
        for (NSDictionary* dic in super.testArray) {
            if ([super.testType isEqualToString:@"word"]){
                [allAnswerArray addObject:[dic valueForKey:@"wordChn"]];
            }else if([super.testType isEqualToString:@"sentence"]){
                [allAnswerArray addObject:[dic valueForKey:@"sentenceChn"]];
            }else{
                //因为这里是遍历，所以不能用wordflag来判断当前是不是单词或者句子
                if([[dic valueForKey:@"bookWord"]valueForKey:@"wordChn"] == nil){
                    [allAnswerArray addObject:[[dic valueForKey:@"bookSentence"] valueForKey:@"sentenceChn"]];
                }else{
                    [allAnswerArray addObject:[[dic valueForKey:@"bookWord"]valueForKey:@"wordChn"]];
                }
                
            }
        }

        //随机数
        self->rightAnswer = arc4random_uniform(4);
    
        for (int i=0; i<4; i++) {
            if (i==self->rightAnswer) {
                if ([super.testType isEqualToString:@"word"]){
                    [answerArray addObject:[[super.testArray objectAtIndex:super.testFlag] valueForKey:@"wordChn"]];
                    [allAnswerArray removeObject:[[super.testArray objectAtIndex:super.testFlag] valueForKey:@"wordChn"]];
                }else if([super.testType isEqualToString:@"sentence"]){
                    [answerArray addObject:[[super.testArray objectAtIndex:super.testFlag] valueForKey:@"sentenceChn"]];
                    [allAnswerArray removeObject:[[super.testArray objectAtIndex:super.testFlag] valueForKey:@"sentenceChn"]];
                }else{
                    if (super.testFlag<super.wordNum) {
                        [answerArray addObject:[[[super.testArray objectAtIndex:super.testFlag] valueForKey:@"bookWord"]valueForKey:@"wordChn"]];
                        [allAnswerArray removeObject:[[[super.testArray objectAtIndex:super.testFlag] valueForKey:@"bookWord"]valueForKey:@"wordChn"]];
                    }else{
                        [answerArray addObject:[[[super.testArray objectAtIndex:super.testFlag]valueForKey:@"bookSentence"] valueForKey:@"sentenceChn"]];
                        [allAnswerArray removeObject:[[[super.testArray objectAtIndex:super.testFlag] valueForKey:@"bookSentence"] valueForKey:@"sentenceChn"]];
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
        self->answer1=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 132.47, 132.47)];
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
        
        self->answer2=[[UIButton alloc]initWithFrame:CGRectMake(175.53, 0, 132.47, 132.47)];
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
        
        self->answer3=[[UIButton alloc]initWithFrame:CGRectMake(0, 161.1, 132.47, 132.47)];
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
        
        self->answer4=[[UIButton alloc]initWithFrame:CGRectMake(175.52, 161.1, 132.47, 132.47)];
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
            NSDictionary* dic=[[NSDictionary alloc]init];
            if ([super.testType isEqualToString:@"word"]) {
                subjectType=@"2";
                dic= [ConnectionFunction addWrongMsg:[super.userInfo valueForKey:@"userKey"] Id:[NSString stringWithFormat:@"%@",[[super.testArray objectAtIndex:super.testFlag]valueForKey:@"wordId"]] Type:subjectType];
            }else{
                subjectType=@"1";
                dic= [ConnectionFunction addWrongMsg:[super.userInfo valueForKey:@"userKey"] Id:[NSString stringWithFormat:@"%@",[[super.testArray objectAtIndex:super.testFlag]valueForKey:@"sentenceId"]] Type:subjectType];
            }
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
                         [NSString stringWithFormat:@"%@",[[[super.testArray objectAtIndex:super.testFlag]valueForKey:@"bookSentence"] valueForKey:@"wordId"]]];
            }else{
                //错题本中句子
                playUrl=[DownloadAudioService getAudioPath:
                         [NSString stringWithFormat:@"%@",[[[super.testArray objectAtIndex:super.testFlag] valueForKey:@"bookSentence"] valueForKey:@"sentenceId"]]];
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
