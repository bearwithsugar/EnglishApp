//
//  WordsTestViewController.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/21.
//  Copyright © 2018年 马一轩. All rights reserved.
//

#import "WordsTestViewController.h"
#import "../DiyGroup/ChooseLessonView.h"
#import "../Functions/ConnectionFunction.h"
#import "../Functions/DocuOperate.h"
#import "../Functions/VoicePlayer.h"
#import "../DiyGroup/TestType/TestFunctions.h"
#import "../DiyGroup/TestType/VoiceChooseChn.h"
#import "../DiyGroup/TestType/ChinSpellEnglish.h"
#import "../DiyGroup/TestType/ChnChooseEng.h"
#import "../DiyGroup/TestType/EngChooseChi.h"
#import "../Functions/WarningWindow.h"
#import "../DiyGroup/UnloginMsgView.h"
#import "../Functions/DownloadAudioService.h"
#import "../Functions/MyThreadPool.h"
#import "Masonry.h"

@interface WordsTestViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UIView* settingView;
    //显示当前课程的容器
    UIView* presentLession;
    //上一题下一题
    UIView* lastAndNextPanel;
    
    NSMutableArray* voiceArray;
    
    //选课信息界面
    ChooseLessonView* chooseLessonView;
    //自定义问题答案界面
    TestFunctions* questionAndAnswerView;
    
    
    BOOL showSetting;
    BOOL chooseLessonShow;
    //答案是否可选
    BOOL clickable;
    //上下题是否可点击是否可选
    BOOL nextclickable;
    BOOL lastclickable;
    
    NSArray* settingContent;
    //存放要测试的单词数组
    NSArray* testArray;
    //当前单元的课程数组
    NSArray* lessonArray;
    //存放用户信息
    NSDictionary* userInfo;
    //测试信息
    NSDictionary* testDetails;
    
    //记录当前测试坐标
    int testFlag;
    
    
    //上一题下一题按钮
    UIButton* nextSubBtn;
    UIButton* lastSubBtn;
    
    //当前课程id
    NSString* classId;
    //当前单元名称
    NSString* unitName;
    //当前课名称
    NSString* className;
    //当前课程的label
    UILabel* lessontitle;
    //当前题数
    UILabel* processTip;

    //播放音频所需
    VoicePlayer* voiceplayer;
    
}

@end

@implementation WordsTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=ssRGBHex(0xFCF8F7);
    voiceArray = [[NSMutableArray alloc]init];
    [self titleShow];
    [self settingView];
    
}
-(void)viewWillAppear:(BOOL)animated{
    if ([DocuOperate fileExistInPath:@"userInfo.plist"]) {
        
        if([_recentBookId isKindOfClass:[NSNull class]]){
            [self presentViewController:[WarningWindow MsgWithoutTrans:@"你还没有学习课本，不能进行测试！"] animated:YES completion:nil];
            return;
        }
        
        [self initData];
        [self chooseLessonViewInit];
        [self chooseLesson];
        [self presentLessionView];
    }
    else{
        UnloginMsgView* unloginView=[[UnloginMsgView alloc]initWithFrame:CGRectMake(0, 88.27, 414, 647)];
        [self.view addSubview:unloginView];
    }
}
//初始数据加载
-(void)initData{
    chooseLessonShow=showSetting=true;
    userInfo=[DocuOperate readFromPlist:@"userInfo.plist"];
    //为bool型设个值
    lastclickable=true;
    nextclickable=true;
    testDetails=[[NSDictionary alloc]init];
    
    if (![DocuOperate fileExistInPath:@"testDetails.plist"]) {
        NSDictionary* dic=[[NSDictionary alloc]initWithObjectsAndKeys:@"0",@"testFunc",@"0",@"testFlag", nil];
        [DocuOperate writeIntoPlist:@"testDetails.plist" dictionary:dic];
    }
        testDetails=[DocuOperate readFromPlist:@"testDetails.plist"];
    
    NSLog(@"teatdetail：%@",testDetails);
    testFlag=[[testDetails valueForKey:@"testFlag"]intValue];
}

//标题栏显示
-(void)titleShow{
    UILabel* title=[[UILabel alloc]init];
    if ([_testType isEqualToString:@"word"]) {
        title.text=@"单词测试";
    }else{
        title.text=@"句子测试";
    }
    title.textColor=[UIColor whiteColor];
    title.backgroundColor=ssRGBHex(0xFF7474);
    title.font=[UIFont systemFontOfSize:18];
    title.textAlignment=NSTextAlignmentCenter;
    title.clipsToBounds = YES;
    [title setUserInteractionEnabled:YES];
    [self.view addSubview:title];
    
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(22);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@66);
    }];
    
    UILabel* touchField=[[UILabel alloc]init];
    [touchField setUserInteractionEnabled:YES];
    [title addSubview:touchField];
    
    [touchField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(title).with.offset(20);
        make.left.equalTo(title).with.offset(10);
        make.width.equalTo(@30);
        make.height.equalTo(@30);
    }];
    
    UIButton* returnBtn=[[UIButton alloc]init];
    [returnBtn setBackgroundImage:[UIImage imageNamed:@"icon_return_ffffff"] forState:UIControlStateNormal];
    [returnBtn setBackgroundImage:[UIImage imageNamed:@"icon_return_ffffff"] forState:UIControlStateHighlighted];
    [returnBtn addTarget:self action:@selector(popBack:) forControlEvents:UIControlEventTouchUpInside];
    [touchField addSubview:returnBtn];
    
    [returnBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(touchField).with.offset(2);
        make.left.equalTo(touchField).with.offset(5.45);
        make.width.equalTo(@10.7);
        make.height.equalTo(@22.62);
    }];
    
    UITapGestureRecognizer* touchFunc=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(popBack:)];
    [touchField addGestureRecognizer:touchFunc];
    
    UIButton* setBtn=[[UIButton alloc]init];
    [setBtn setBackgroundImage:[UIImage imageNamed:@"icon_setting"] forState:UIControlStateNormal];
    [setBtn setBackgroundImage:[UIImage imageNamed:@"icon_setting"] forState:UIControlStateHighlighted];
    [setBtn addTarget:self action:@selector(showSettingView) forControlEvents:UIControlEventTouchUpInside];
    [title addSubview:setBtn];
    
    [setBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(title).with.offset(22);
        make.right.equalTo(title).with.offset(-15);
        make.width.equalTo(@22);
        make.height.equalTo(@22);
    }];
}
//选择菜单的初始化
-(void)chooseLessonViewInit{
    ShowContentBlock showContentBlock=^(NSArray* bookpicarray,NSArray* sentencearray,NSString* classid,NSString* unitname,NSString* classname){
        __weak WordsTestViewController*  weakSelf=self;
        NSArray* testarray;
        if ([self->_testType isEqualToString:@"word"]) {
            testarray=[[ConnectionFunction getTestWordMsg:self->chooseLessonView.articleId UserKey:[self->userInfo valueForKey:@"userKey"]]valueForKey:@"data"];
        }else{
            testarray=[[ConnectionFunction getTestSentenceMsg:self->chooseLessonView.articleId UserKey:[self->userInfo valueForKey:@"userKey"]]valueForKey:@"data"];
        }
        [weakSelf showContent:unitname className:classname testArray:testarray classId:classid];
        self->chooseLessonShow=!self->chooseLessonShow;
    };
    chooseLessonView=[[ChooseLessonView alloc]initWithBookId:_recentBookId DefaultUnit:0 ShowBlock:showContentBlock];
}

#pragma mark --上一课下一课
//上一课下一课

-(void)chooseLesson{
    presentLession=[[UIView alloc]init];
    presentLession.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:presentLession];
    
    [presentLession mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(88.27);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@44);
    }];
    
    //上一课以及箭头
    UIButton* lastLessonBtn=[[UIButton alloc]init];
    [lastLessonBtn setBackgroundImage:[UIImage imageNamed:@"icon_shangyike"] forState:UIControlStateNormal];
    [lastLessonBtn addTarget:self action:@selector(clickLastLesson) forControlEvents:UIControlEventTouchUpInside];
    [presentLession addSubview:lastLessonBtn];
    
    [lastLessonBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->presentLession).with.offset(14.34);
        make.left.equalTo(self->presentLession).with.offset(15);
        make.width.equalTo(@8.83);
        make.height.equalTo(@16.55);
    }];
    
    UIButton* lastLessonLabel=[[UIButton alloc]init];
    [lastLessonLabel addTarget:self action:@selector(clickLastLesson) forControlEvents:UIControlEventTouchUpInside];
    [lastLessonLabel setTitle:@"上一课" forState:UIControlStateNormal];
    [lastLessonLabel setTitleColor:ssRGBHex(0x4A4A4A) forState:UIControlStateNormal];
    lastLessonLabel.titleLabel.font=[UIFont systemFontOfSize:12];
    [presentLession addSubview:lastLessonLabel];
    
    [lastLessonLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->presentLession).with.offset(13.24);
        make.left.equalTo(self->presentLession).with.offset(30);
        make.width.equalTo(@40);
        make.height.equalTo(@19);
    }];
    
    //下一课以及箭头
    UIButton* nextLessonBtn=[[UIButton alloc]init];
    [nextLessonBtn setBackgroundImage:[UIImage imageNamed:@"icon_xiayike"] forState:UIControlStateNormal];
    [nextLessonBtn addTarget:self action:@selector(clickNextLesson) forControlEvents:UIControlEventTouchUpInside];
    [presentLession addSubview:nextLessonBtn];
    
    [nextLessonBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->presentLession).with.offset(14.34);
        make.width.equalTo(@8.83);
        make.right.equalTo(self->presentLession).with.offset(-15);
        make.height.equalTo(@16.55);
    }];
    
    UIButton* nextLessonLabel=[[UIButton alloc]init];
    [nextLessonLabel setTitle:@"下一课" forState:UIControlStateNormal];
    [nextLessonLabel addTarget:self action:@selector(clickNextLesson) forControlEvents:UIControlEventTouchUpInside];
    [nextLessonLabel setTitleColor:ssRGBHex(0x4A4A4A) forState:UIControlStateNormal];
    nextLessonLabel.titleLabel.font=[UIFont systemFontOfSize:12];
    [presentLession addSubview:nextLessonLabel];
    
    [nextLessonLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->presentLession).with.offset(13.24);
        make.width.equalTo(@40);
        make.right.equalTo(self->presentLession).with.offset(-30);
        make.height.equalTo(@19);
    }];
    
}
-(void)clickLastLesson{
    if (classId==nil) {
        NSLog(@"请先选择课程");
        [WarningWindow MsgWithoutTrans: @"请先选择课程"];
    }else{
        if ([classId isEqualToString:[[lessonArray objectAtIndex:0]valueForKey:@"articleId"]]){
            NSLog(@"这是当前单元的第一课！没有上一课了！");
            [WarningWindow MsgWithoutTrans: @"这是当前单元的第一课！没有上一课了！"];
        }else{
            NSLog(@"上一课");
            int i=0;
            for (NSDictionary* dic in lessonArray) {
                NSLog(@"此时的classid%@",classId);
                NSLog(@"lessonArray单个元素的内容%@",dic);
                if ([[dic valueForKey:@"articleId"]isEqualToString: classId]) {
                    break;
                }
                i++;
            }
          
            [self showContent:[[lessonArray objectAtIndex:(i-1)]valueForKey:@"articleName"]
                    className:@""
                   testArray:[[ConnectionFunction getTestWordMsg:[[lessonArray objectAtIndex:(i-1)]valueForKey:@"articleId"] UserKey:[userInfo valueForKey:@"userKey"]]valueForKey:@"data"]
                      classId:[[lessonArray objectAtIndex:(i-1)]valueForKey:@"articleId"]];
        }
    }
    
}
-(void)clickNextLesson{
    if (classId==nil) {
        NSLog(@"请先选择课程");
        [WarningWindow MsgWithoutTrans: @"请先选择课程"];
    }else{
        if ([classId isEqualToString:[[lessonArray objectAtIndex:(lessonArray.count-1)]valueForKey:@"articleId"]]){
            NSLog(@"这是当前单元的最后一课！没有下一课了！");
            [WarningWindow MsgWithoutTrans: @"这是当前单元的最后一课！没有下一课了！"];
        }else{
            NSLog(@"下一课");
            int i=0;
            for (NSDictionary* dic in lessonArray) {
                NSLog(@"此时的classid%@",classId);
                NSLog(@"lessonArray单个元素的内容%@",dic);
                if ([[dic valueForKey:@"articleId"]isEqualToString: classId]) {
                    break;
                }
                i++;
            }
        
            [self showContent:[[lessonArray objectAtIndex:(i+1)]valueForKey:@"articleName"]
                    className:@""
                   testArray:[[ConnectionFunction getTestWordMsg:[[lessonArray objectAtIndex:(i+1)]valueForKey:@"articleId"] UserKey:[userInfo valueForKey:@"userKey"]]valueForKey:@"data"]
                      classId:[[lessonArray objectAtIndex:(i+1)]valueForKey:@"articleId"]];
        }
    }
    
}
//中间显示标题
-(void)presentLessionView{
    //中间标题
    lessontitle=[[UILabel alloc]init];
    lessontitle.layer.borderColor=ssRGBHex(0xFE8484).CGColor;
    lessontitle.layer.borderWidth=1;
    lessontitle.layer.cornerRadius=14.34;
    if (unitName==nil||className==nil) {
        lessontitle.text=@"请先选择课程";
        NSLog(@"为空");
    }else{
        NSString* title=[unitName stringByAppendingString:@"-"];
        title=[title stringByAppendingString:className];
        lessontitle.text=title;
    }
    lessontitle.textAlignment=NSTextAlignmentCenter;
    lessontitle.font=[UIFont systemFontOfSize:12];
    //显示子视图
    lessontitle.clipsToBounds = YES;
    //打开button父组件的人机交互
    [lessontitle setUserInteractionEnabled:YES];
   
    UITapGestureRecognizer* showLineGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showChooseLessonView)];
    [lessontitle addGestureRecognizer:showLineGesture];
    
    [presentLession addSubview:lessontitle];
    
    [lessontitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->presentLession).with.offset(7.72);
        make.left.equalTo(self->presentLession).with.offset(95);
        make.right.equalTo(self->presentLession).with.offset(-95);
        make.height.equalTo(@28.68);
    }];
}
-(void)lastAndNext{
    lastAndNextPanel=[[UIView alloc]init];
    lastAndNextPanel.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:lastAndNextPanel];
    
    [lastAndNextPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(139);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@33);
    }];
    
    lastSubBtn=[[UIButton alloc]init];
    if (testFlag==0) {
        [lastSubBtn setBackgroundColor:ssRGBHex(0x9B9B9B)];
    }else{
        [lastSubBtn setBackgroundColor:ssRGBHex(0xF5A623)];
    }
    lastSubBtn.layer.cornerRadius=8;
    [lastSubBtn setTitle:@"上一题" forState:UIControlStateNormal];
    lastSubBtn.titleLabel.font=[UIFont systemFontOfSize:10];
    [lastSubBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [lastSubBtn addTarget:self action:@selector(lastSubject:) forControlEvents:UIControlEventTouchUpInside];
    [lastAndNextPanel addSubview:lastSubBtn];
    
    [lastSubBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->lastAndNextPanel).with.offset(9.93);
        make.left.equalTo(self->lastAndNextPanel).with.offset(17.66);
        make.width.equalTo(@55.20);
        make.height.equalTo(@22.06);
    }];
    
    [self processTip];
    
    nextSubBtn=[[UIButton alloc]init];
    if (testFlag==testArray.count-1) {
        [nextSubBtn setBackgroundColor:ssRGBHex(0x9B9B9B)];
    }else{
        [nextSubBtn setBackgroundColor:ssRGBHex(0xF5A623)];
    }
    nextSubBtn.layer.cornerRadius=8;
    [nextSubBtn setTitle:@"下一题" forState:UIControlStateNormal];
    nextSubBtn.titleLabel.font=[UIFont systemFontOfSize:10];
    [nextSubBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextSubBtn addTarget:self action:@selector(nextSubject:) forControlEvents:UIControlEventTouchUpInside];
    [lastAndNextPanel addSubview:nextSubBtn];
    
    [nextSubBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->lastAndNextPanel).with.offset(9.93);
        make.right.equalTo(self->lastAndNextPanel).with.offset(-17.66);
        make.width.equalTo(@55.20);
        make.height.equalTo(@22.06);
    }];
    
}
//显示当前是第几题了
-(void)processTip{
    processTip=[[UILabel alloc]init];
    NSString* total=[NSString stringWithFormat:@"%lu",(unsigned long)testArray.count];
    NSString* present=[NSString stringWithFormat:@"%d",(testFlag+1)];
    present=[present stringByAppendingString:@"/"];
    processTip.text=[present stringByAppendingString:total];
    processTip.textColor=ssRGBHex(0x9B9B9B);
    processTip.font=[UIFont systemFontOfSize:12];
    processTip.textAlignment=NSTextAlignmentCenter;
    [lastAndNextPanel addSubview:processTip];
    
    [processTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->lastAndNextPanel).with.offset(12.13);
        make.centerX.equalTo(self.view);
        make.width.equalTo(@200);
        make.height.equalTo(@18.75);
    }];
}

#pragma mark --上一题下一题点击事件
//下一题点击事件
-(void)nextSubject:(UIButton*)btn{
    if (nextclickable) {
        clickable=true;
        testFlag=testFlag+1;
        
        //重新加载问题和答案
        [questionAndAnswerView removeFromSuperview];
        [self addQAview];
        
        if (testFlag==testArray.count-1) {
            btn.backgroundColor=ssRGBHex(0x9B9B9B);
            nextclickable=false;
        }
        lastSubBtn.backgroundColor=ssRGBHex(0xF5A623);
        lastclickable=true;
        
        //修改测试进程信息
        [testDetails setValue:[NSString stringWithFormat:@"%d",testFlag] forKey:@"testFlag"];
    }
    

}
//上一题点击事件
-(void)lastSubject:(UIButton*)btn{
    if (lastclickable) {
        clickable=true;
        testFlag=testFlag-1;
        
        //重新加载问题和答案
        [questionAndAnswerView removeFromSuperview];
        [self addQAview];
        
        if (testFlag==0) {
            btn.backgroundColor=ssRGBHex(0x9B9B9B);
            lastclickable=false;
        }
        nextSubBtn.backgroundColor=ssRGBHex(0xF5A623);
        nextclickable=true;
        
        //修改测试进程信息
        [testDetails setValue:[NSString stringWithFormat:@"%d",testFlag] forKey:@"testFlag"];
    }
}

#pragma mark --设置
//设置界面👇
-(void)settingView{
    //整体灰色背景
    settingView=[[UIView alloc]init];
    settingView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
    settingContent=@[@"根据英语发音选择中文意思",@"根据英文单词或句子选择中文意思",@"根据中文意思选择英文单词或句子",@"根据中文意思拼写英文单词或句子"];
    
    UITableView* settingList=[[UITableView alloc]init];
    settingList.dataSource=self;
    settingList.delegate=self;
    [settingView addSubview:settingList];
    
    [settingList mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->settingView);
        make.left.equalTo(self->settingView);
        make.right.equalTo(self->settingView);
        make.height.equalTo(@213);
    }];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4 ;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"flag";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.text=[settingContent objectAtIndex:indexPath.row];
    cell.textLabel.font=[UIFont systemFontOfSize:14];
    cell.textLabel.textColor=ssRGBHex(0x4A4A4A);
    cell.textLabel.textAlignment=NSTextAlignmentCenter;
   
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //去除设置界面
    [settingView removeFromSuperview];
    if (indexPath.row!=[[testDetails valueForKey:@"testFunc"]integerValue]) {
        [questionAndAnswerView removeFromSuperview];
        [testDetails setValue:[NSString stringWithFormat:@"%ld",(long)indexPath.row] forKey:@"testFunc"];
        NSLog(@"字典的值是%@",testDetails);
        [self addQAview];
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 52.96;
}

-(void)showSettingView{
    if (showSetting) {
        [self.view addSubview:settingView];
        [settingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(88.27);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
        
    }else{
        [settingView removeFromSuperview];
    }
    showSetting=!showSetting;
    
}

#pragma mark --点击箭头加载页面
//点击箭头触发事件
-(void)showChooseLessonView{
    if (chooseLessonShow) {
        [self.view addSubview:chooseLessonView];
        [chooseLessonView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(132.41);
            make.right.equalTo(self.view);
            make.left.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
    }else{
        if (chooseLessonView.unitName!=nil&&chooseLessonView.className!=nil) {
            lessonArray=chooseLessonView.lessonArray;
            
            NSArray* testarray;
            if ([_testType isEqualToString:@"word"]) {
                testarray=[[ConnectionFunction getTestWordMsg:chooseLessonView.articleId UserKey:[userInfo valueForKey:@"userKey"]]valueForKey:@"data"];
            }else{
                testarray=[[ConnectionFunction getTestSentenceMsg:chooseLessonView.articleId UserKey:[userInfo valueForKey:@"userKey"]]valueForKey:@"data"];
            }
           //传递参数，显示界面
            
            [self showContent:chooseLessonView.unitName
                    className:chooseLessonView.className
                    testArray:testarray
                      classId:[[[chooseLessonView.dataArray valueForKey:@"bookSentences"]objectAtIndex:0] valueForKey:@"articleId"]
             ];

        }else{
            //收起选择课程界面
            [chooseLessonView removeFromSuperview];
        }
    }
    chooseLessonShow=!chooseLessonShow;
    
}
//加载数据，显示页面内容
-(void)showContent:(NSString*)unitname className:(NSString*)classname testArray:(NSArray*)testarray classId:(NSString*)classid{
    
    JobBlock myblock = ^{
        for (NSDictionary* dic in testarray) {
            NSMutableDictionary* dictionary = [[NSMutableDictionary alloc]init];
            [dictionary setValue:[dic valueForKey:@"engUrl"] forKey:@"url"];
            if ([dic valueForKey:@"sentenceId"] == nil) {
                [dictionary setValue:[dic valueForKey:@"wordId"] forKey:@"id"];
            }else{
                [dictionary setValue:[dic valueForKey:@"sentenceId"] forKey:@"id"];
            }
            [self->voiceArray addObject:dictionary];
        }
        
        for (NSDictionary* dic in self->voiceArray) {
            NSString* playUrl=[dic valueForKey:@"url"];
            if ([playUrl isKindOfClass:[NSNull class]]) {
                continue;
            }
            playUrl=[playUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            [DownloadAudioService toLoadAudio:playUrl FileName:[dic valueForKey:@"id"]];
        }
    };
    
    [MyThreadPool executeJob:myblock Main:^{}];
    
    //收起选择课程界面
    [chooseLessonView removeFromSuperview];
    
    //清除页面
    [questionAndAnswerView removeFromSuperview];
    
    //为当前单元课程名称赋值
    unitName=unitname;
    className=classname;
    //调用接口获取信息
    testArray=testarray;

    classId=classid;
    
    [lessontitle removeFromSuperview];
    [self presentLessionView];
    //加载内容
    [self lastAndNext];
    
    [self addQAview];

}

-(void)addQAview{
    NSString* testFunc=[testDetails valueForKey:@"testFunc"];
    NSLog(@"testArray%@",testArray);
    if ([testFunc isEqualToString:@"0"]) {
        questionAndAnswerView=[[VoiceChooseChn alloc]initWithFlag:testFlag TestArray:testArray TestType:_testType UserInfo:userInfo];
    }else if([testFunc isEqualToString:@"1"]){
        questionAndAnswerView=[[EngChooseChi alloc]initWithFlag:testFlag TestArray:testArray TestType:_testType UserInfo:userInfo];
    }else if([testFunc isEqualToString:@"2"]){
        questionAndAnswerView=[[ChnChooseEng alloc]initWithFlag:testFlag TestArray:testArray TestType:_testType UserInfo:userInfo];
    }else{
        questionAndAnswerView=[[ChinSpellEnglish alloc]initWithFlag:testFlag TestArray:testArray TestType:_testType UserInfo:userInfo];
    }
    
    [processTip removeFromSuperview];
    [self processTip];
    [self.view addSubview:questionAndAnswerView];
    
    [questionAndAnswerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(172);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

-(void)popBack:(UITapGestureRecognizer*)sender{
    [DocuOperate writeIntoPlist:@"testDetails.plist" dictionary:testDetails];
    [self.navigationController popViewControllerAnimated:true];
}


@end
