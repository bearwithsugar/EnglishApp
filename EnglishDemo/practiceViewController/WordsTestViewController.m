//
//  WordsTestViewController.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/21.
//  Copyright © 2018年 马一轩. All rights reserved.
//

#import "WordsTestViewController.h"
#import "../DiyGroup/ChooseLessonView.h"
#import "../Functions/netOperate/ConnectionFunction.h"
#import "../Functions/netOperate/NetSenderFunction.h"
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

@interface WordsTestViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    UIView* settingView;
    //显示当前课程的容器
    UIView* presentLession;
    //上一题下一题
    UIView* lastAndNextPanel;
    
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
    //存档进度的字典
    NSMutableDictionary* testFlagDic;
    
    //记录当前测试坐标
    int testFlag;
    
    //上一题下一题按钮
    UIButton* nextSubBtn;
    UIButton* lastSubBtn;
    UIButton* setBtn;
    
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
@property(nonatomic ,strong) UITextField * firstResponderTextF;//记录将要编辑的输入框
@end

@implementation WordsTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=ssRGBHex(0xFCF8F7);
    [self titleShow];
    [self settingView];
    //监听键盘展示和隐藏的通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

}
-(void)viewWillAppear:(BOOL)animated{
    if ([DocuOperate fileExistInPath:@"userInfo.plist"]) {
        
        if([_recentBookId isKindOfClass:[NSNull class]]){
            [self presentViewController:[WarningWindow MsgWithoutTrans:@"你还没有学习课本，不能进行测试！"] animated:YES completion:nil];
            return;
        }
        
        [self initData];
        [self chooseLesson];
        [self presentLessionView];
        [self chooseLessonViewInit];
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
    
    setBtn=[[UIButton alloc]init];
    [setBtn setBackgroundImage:[UIImage imageNamed:@"icon_setting"] forState:UIControlStateNormal];
    [setBtn setBackgroundImage:[UIImage imageNamed:@"icon_setting"] forState:UIControlStateHighlighted];
    [setBtn addTarget:self action:@selector(showSettingView) forControlEvents:UIControlEventTouchUpInside];
    [title addSubview:setBtn];
    
    [setBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(title).with.offset(22);
        make.right.equalTo(title).with.offset(-15);
        make.width.equalTo(@25);
        make.height.equalTo(@25);
    }];
    setBtn.hidden = YES;
}
//选择菜单的初始化
-(void)chooseLessonViewInit{
    
    ShowContentBlock showContentBlock=^(NSArray* bookpicarray,NSArray* sentencearray,NSString* classid,NSString* unitname,NSString* classname){
        
        ConBlock conBlk = ^(NSDictionary* dic){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showContent:unitname
                        className:classname
                        testArray:[dic valueForKey:@"data"]
                          classId:classid];
                self->chooseLessonShow=!self->chooseLessonShow;
            });
        };
        
        NetSenderFunction* sender = [[NetSenderFunction alloc]init];
        
        if ([self->_testType isEqualToString:@"word"]) {
            [sender getRequestWithHead:[self->userInfo valueForKey:@"userKey"]
                                  Path:[[ConnectionFunction getInstance]getTestWordMsg_Get_H:self->chooseLessonView.articleId]
                                 Block:conBlk];
        }else{
            [sender getRequestWithHead:[self->userInfo valueForKey:@"userKey"]
                                  Path:[[ConnectionFunction getInstance]getTestSentenceMsg_Get_H:self->chooseLessonView.articleId]
                                 Block:conBlk];
        }

       
    };
    ConBlock conBlk = ^(NSDictionary* dic){
        dispatch_async(dispatch_get_main_queue(), ^{
            self->chooseLessonView=[[ChooseLessonView alloc]initWithBookId:self->_recentBookId DefaultUnit:0 UnitArray:[dic valueForKey:@"data"] ShowBlock:showContentBlock];
            [self showChooseLessonView];
        });
    };
    NetSenderFunction* sender = [[NetSenderFunction alloc]init];
    [sender getRequestWithHead:[userInfo valueForKey:@"userKey"] Path:[[ConnectionFunction getInstance]getUnitMsg_Get_H:_recentBookId] Block:conBlk];
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
        if(!lessonArray || lessonArray.count == 0){
            lessonArray=chooseLessonView.lessonArray;
        }
        if ([classId isEqualToString:[[lessonArray objectAtIndex:0]valueForKey:@"articleId"]]){
            NSLog(@"这是当前单元的第一课！没有上一课了！");
            [self presentViewController:[WarningWindow MsgWithoutTrans: @"这是当前单元的第一课！没有上一课了！"] animated:YES  completion:nil];
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
            ConBlock conBlk = ^(NSDictionary* dic){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showContent:[[self->lessonArray objectAtIndex:(i-1)]valueForKey:@"articleName"]
                        className:@""
                        testArray:[dic valueForKey:@"data"]
                          classId:[[self->lessonArray objectAtIndex:(i-1)]valueForKey:@"articleId"]];
                });
            };
            NetSenderFunction* sender = [[NetSenderFunction alloc]init];
            [sender getRequestWithHead:[userInfo valueForKey:@"userKey"]
                                  Path:[[ConnectionFunction getInstance]getTestWordMsg_Get_H:[[lessonArray objectAtIndex:(i-1)]valueForKey:@"articleId"]]
                                 Block:conBlk];
          
        }
    }
    
}
-(void)clickNextLesson{
    if (classId==nil) {
        NSLog(@"请先选择课程");
        [WarningWindow MsgWithoutTrans: @"请先选择课程"];
    }else{
        if(!lessonArray || lessonArray.count == 0){
            lessonArray=chooseLessonView.lessonArray;
        }
        if ([classId isEqualToString:[[lessonArray objectAtIndex:(lessonArray.count-1)]valueForKey:@"articleId"]]){
            NSLog(@"这是当前单元的最后一课！没有下一课了！");
            [self presentViewController:[WarningWindow MsgWithoutTrans: @"这是当前单元的最后一课！没有下一课了！"] animated:YES completion:nil];
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
        
            ConBlock conBlk = ^(NSDictionary* dic){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showContent:[[self->lessonArray objectAtIndex:(i+1)]valueForKey:@"articleName"]
                        className:@""
                        testArray:[dic valueForKey:@"data"]
                          classId:[[self->lessonArray objectAtIndex:(i+1)]valueForKey:@"articleId"]];
                });
            };
            NetSenderFunction* sender = [[NetSenderFunction alloc]init];
            [sender getRequestWithHead:[userInfo valueForKey:@"userKey"]
                                  Path:[[ConnectionFunction getInstance]getTestWordMsg_Get_H:[[lessonArray objectAtIndex:(i+1)]valueForKey:@"articleId"]]
                                 Block:conBlk];
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
        [testFlagDic setValue:[NSString stringWithFormat:@"%d",testFlag] forKey:classId];
        [self storeProcess];
        //[testDetails setValue:[NSString stringWithFormat:@"%d",testFlag] forKey:@"testFlag"];
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
        [testFlagDic setValue:[NSString stringWithFormat:@"%d",testFlag] forKey:classId];
        [self storeProcess];
        //[testDetails setValue:[NSString stringWithFormat:@"%d",testFlag] forKey:@"testFlag"];
    }
}

#pragma mark --设置
//设置界面👇
-(void)settingView{
    //整体灰色背景
    settingView=[[UIView alloc]init];
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
    
    //下部分灰色背景
    UIView* settingGray=[[UIView alloc]init];
    settingGray.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    UITapGestureRecognizer* cancelGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cancelSetting)];
    [settingGray addGestureRecognizer:cancelGesture];
    [settingView addSubview:settingGray];

    [settingGray mas_makeConstraints:^(MASConstraintMaker *make) {
       make.top.equalTo(settingList.mas_bottom);
       make.left.equalTo(self->settingView);
       make.right.equalTo(self->settingView);
       make.height.equalTo(self->settingView);
    }];
}

-(void)cancelSetting{
    [settingView removeFromSuperview];
    showSetting = !showSetting;
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
        [self storeProcess];
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
            
            NetSenderFunction* sender = [[NetSenderFunction alloc]init];
            ConBlock conBlk = ^(NSDictionary* dic){
                dispatch_async(dispatch_get_main_queue(), ^{
                //传递参数，显示界面
                    [self showContent:self->chooseLessonView.unitName
                         className:self->chooseLessonView.className
                         testArray:[dic valueForKey:@"data"]
                           classId:[[[self->chooseLessonView.dataArray valueForKey:@"bookSentences"]objectAtIndex:0] valueForKey:@"articleId"]];
                });
            };
            if ([_testType isEqualToString:@"word"]) {
                [sender getRequestWithHead:[userInfo valueForKey:@"userKey"]
                                      Path:[[ConnectionFunction getInstance]getTestWordMsg_Get_H:chooseLessonView.articleId]
                                     Block:conBlk];
            }else{
                [sender getRequestWithHead:[userInfo valueForKey:@"userKey"]
                                      Path:[[ConnectionFunction getInstance]getTestSentenceMsg_Get_H:chooseLessonView.articleId]
                                     Block:conBlk];
            }
        }else{
            //收起选择课程界面
            [chooseLessonView removeFromSuperview];
        }
    }
    chooseLessonShow=!chooseLessonShow;
    
}
//加载数据，显示页面内容
-(void)showContent:(NSString*)unitname className:(NSString*)classname testArray:(NSArray*)testarray classId:(NSString*)classid{
    setBtn.hidden = NO;
    JobBlock myblock = ^{
        NSMutableArray* voiceArray = [[NSMutableArray alloc]init];
        for (NSDictionary* dic in testarray) {
            NSMutableDictionary* dictionary = [[NSMutableDictionary alloc]init];
            [dictionary setValue:[dic valueForKey:@"engUrl"] forKey:@"url"];
            if ([dic valueForKey:@"sentenceId"] == nil) {
                [dictionary setValue:[dic valueForKey:@"wordId"] forKey:@"id"];
            }else{
                [dictionary setValue:[dic valueForKey:@"sentenceId"] forKey:@"id"];
            }
            [voiceArray addObject:dictionary];
        }
        
        [voiceArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSString* playUrl=[obj valueForKey:@"url"];
                if (![playUrl isKindOfClass:[NSNull class]]) {
                    playUrl=[playUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                    [[DownloadAudioService getInstance] toLoadAudio:playUrl FileName:[obj valueForKey:@"id"]];
                }
            });
        }];
    };
    
    //收起选择课程界面
    [chooseLessonView removeFromSuperview];
    [MyThreadPool executeJob:myblock Main:^{}];
    //清除页面
    [questionAndAnswerView removeFromSuperview];
    
    //为当前单元课程名称赋值
    unitName=unitname;
    className=classname;
    //调用接口获取信息
    testArray=testarray;

    classId=classid;
    
    if (![DocuOperate fileExistInPath:@"testDetails.plist"]) {
        testFlagDic = [[NSMutableDictionary alloc]init];
        [testFlagDic setObject:@"0" forKey:classId];
        NSDictionary* dic=[[NSDictionary alloc]initWithObjectsAndKeys:@"0",@"testFunc",testFlagDic,@"testFlag", nil];
        [DocuOperate writeIntoPlist:@"testDetails.plist" dictionary:dic];
    }

    testDetails=[DocuOperate readFromPlist:@"testDetails.plist"];
    testFlagDic = [testDetails valueForKey:@"testFlag"];
    NSLog(@"teatdetail：%@",testDetails);
    
    if (![[testDetails valueForKey:@"testFlag"]valueForKey:classId]) {
        [testFlagDic setObject:@"0" forKey:classId];
    }
    testFlag=[[testFlagDic valueForKey:classId]intValue];
    
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
        questionAndAnswerView=[[VoiceChooseChn alloc]initWithFlag:testFlag TestArray:testArray TestType:_testType UserInfo:userInfo BookId:_recentBookId View:self ];
    }else if([testFunc isEqualToString:@"1"]){
        questionAndAnswerView=[[EngChooseChi alloc]initWithFlag:testFlag TestArray:testArray TestType:_testType UserInfo:userInfo BookId:_recentBookId View:self];
    }else if([testFunc isEqualToString:@"2"]){
        questionAndAnswerView=[[ChnChooseEng alloc]initWithFlag:testFlag TestArray:testArray TestType:_testType UserInfo:userInfo BookId:_recentBookId View:self];
    }else{
        questionAndAnswerView=[[ChinSpellEnglish alloc]initWithFlag:testFlag TestArray:testArray TestType:_testType UserInfo:userInfo BookId:_recentBookId View:self];
    }
    VoidBlock answerBlk = ^{
        if (self->testFlag!=self->testArray.count-1) {
            [self nextSubject:self->nextSubBtn];
        }
    };
    [questionAndAnswerView setAnswerBlk:answerBlk];
    
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

-(void)storeProcess{
    if (testFlagDic!=nil) {
        [MyThreadPool executeJob:^{
            [self->testDetails setValue:self->testFlagDic forKey:@"testFlag"];
            [DocuOperate replacePlist:@"testDetails.plist" dictionary:self->testDetails];
        } Main:^{}];
    }
}

-(void)popBack:(UITapGestureRecognizer*)sender{
    [self.navigationController popViewControllerAnimated:true];
    [self->voiceplayer stopPlay];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if ([self.firstResponderTextF isFirstResponder])[self.firstResponderTextF resignFirstResponder];
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    self.firstResponderTextF = textField;//当将要开始编辑的时候，获取当前的textField
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark : UIKeyboardWillShowNotification/UIKeyboardWillHideNotification

- (void)keyboardWillShow:(NSNotification *)notification{
    CGRect rect = [self.firstResponderTextF.superview convertRect:self.firstResponderTextF.frame toView:self.view];//获取相对于self.view的位置
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];//获取弹出键盘的fame的value值
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:self.view.window];//获取键盘相对于self.view的frame ，传window和传nil是一样的
    CGFloat keyboardTop = keyboardRect.origin.y;
    NSNumber * animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];//获取键盘弹出动画时间值
    NSTimeInterval animationDuration = [animationDurationValue doubleValue];
    if (keyboardTop < CGRectGetMaxY(rect)) {//如果键盘盖住了输入框
        CGFloat gap = keyboardTop - CGRectGetMaxY(rect) - 10;//计算需要网上移动的偏移量（输入框底部离键盘顶部为10的间距）
        __weak typeof(self)weakSelf = self;
        [UIView animateWithDuration:animationDuration animations:^{
            weakSelf.view.frame = CGRectMake(weakSelf.view.frame.origin.x, gap, weakSelf.view.frame.size.width, weakSelf.view.frame.size.height);
        }];
    }
}
- (void)keyboardWillHide:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSNumber * animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];//获取键盘隐藏动画时间值
    NSTimeInterval animationDuration = [animationDurationValue doubleValue];
    if (self.view.frame.origin.y < 0) {//如果有偏移，当影藏键盘的时候就复原
        __weak typeof(self)weakSelf = self;
        [UIView animateWithDuration:animationDuration animations:^{
            weakSelf.view.frame = CGRectMake(weakSelf.view.frame.origin.x, 0, weakSelf.view.frame.size.width, weakSelf.view.frame.size.height);
        }];
    }
}
- (void)dealloc{
    //移除键盘通知监听者
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


@end
