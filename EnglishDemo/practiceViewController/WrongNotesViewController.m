//
//  WrongNotesViewController.m
//  EnglishDemo
//
//  Created by 马一轩 on 2019/1/17.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import "WrongNotesViewController.h"
#import "../DiyGroup/ChooseLessonView.h"
#import "../Functions/ConnectionFunction.h"
#import "../Functions/DocuOperate.h"
#import "../Functions/VoicePlayer.h"
#import "../DiyGroup/TestType/TestFunctions.h"
#import "../DiyGroup/TestType/VoiceChooseChn.h"
#import "../DiyGroup/TestType/ChinSpellEnglish.h"
#import "../DiyGroup/TestType/ChnChooseEng.h"
#import "../DiyGroup/TestType/EngChooseChi.h"
#import "../DiyGroup/UnloginMsgView.h"
#import "../Functions/WarningWindow.h"

//#ifdef DEBUG
//#define NSLog(FORMAT, ...) fprintf(stderr, "%s:%zd\t%s\n", [[[NSString stringWithUTF8String: __FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat: FORMAT, ## __VA_ARGS__] UTF8String]);
//#else
//#define NSLog(FORMAT, ...) nil
//#endif

@interface WrongNotesViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    //设置界面
    UIView* settingView;
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
    
    //测试方式数组
    NSArray* settingContent;
    //存放要测试的单词数组
    NSMutableArray* testArray;
    NSArray* wordArray;
    NSArray* sentenceArray;
    //存放用户信息
    NSDictionary* userInfo;
    //测试详细偏好信息
    NSDictionary* testDetails;
    
    //记录当前测试坐标
    int testFlag;
    
    //上一题下一题按钮
    UIButton* nextSubBtn;
    UIButton* lastSubBtn;

    //当前题数
    UILabel* processTip;
    
    //播放音频所需
    VoicePlayer* voiceplayer;
    
}

@end

@implementation WrongNotesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=ssRGBHex(0xFCF8F7);
    [self titleShow];
    [self settingView];
    [self initDataOnlyOnce];
//    [self lastAndNext];
//    [self processTip];
//    [self addQAview];
    
}
-(void)viewWillAppear:(BOOL)animated{
    if ([DocuOperate fileExistInPath:@"userInfo.plist"]) {
        [self initData];
        if ([testArray isKindOfClass:[NSNull class]]||testArray.count==0) {
            [self presentViewController:[WarningWindow MsgWithoutTrans:@"您还没有错题!先去做题吧！"] animated:YES completion:nil];
        }else{
           [self showContent];
        }

    }
    else{
        UnloginMsgView* unloginView=[[UnloginMsgView alloc]initWithFrame:CGRectMake(0, 88.27, 414, 647)];
        [self.view addSubview:unloginView];
    }
}

//初始数据加载
-(void)initDataOnlyOnce{
    testDetails=[[NSDictionary alloc]init];
    testArray=[[NSMutableArray alloc]init];
    wordArray=[[NSArray alloc]init];
    sentenceArray=[[NSArray alloc]init];
    if (![DocuOperate fileExistInPath:@"wrongsDetails.plist"]) {
        NSDictionary* dic=[[NSDictionary alloc]initWithObjectsAndKeys:@"0",@"testFunc",@"0",@"testFlag", nil];
        [DocuOperate writeIntoPlist:@"wrongsDetails.plist" dictionary:dic];
    }
    testDetails=[DocuOperate readFromPlist:@"wrongsDetails.plist"];
    
}
-(void)initData{
    userInfo=[DocuOperate readFromPlist:@"userInfo.plist"];
    //为bool型设个值
    lastclickable=true;
    nextclickable=true;
    
    [testArray removeAllObjects];
    
    testDetails=[DocuOperate readFromPlist:@"wrongsDetails.plist"];
    _testFunction=[testDetails valueForKey:@"testFunc"];
    testFlag=[[testDetails valueForKey:@"testFlag"]intValue];
    
    NSDictionary* resultDic=[[ConnectionFunction getWrongMsg:[userInfo valueForKey:@"userKey"] Id:_recentBookId]valueForKey:@"data"];
    
    wordArray=[resultDic valueForKey:@"bookWordInfos"];
    sentenceArray=[resultDic valueForKey:@"bookSentenceInfos"];
    
    
    for (NSDictionary* dic in wordArray) {
        [testArray addObject:dic];
    }
    for (NSDictionary* dic in sentenceArray) {
        [testArray addObject:dic];
    }

    NSLog(@"错题信息是%@",testArray);
    

}

//标题栏显示
-(void)titleShow{
    UILabel* title=[[UILabel alloc]initWithFrame:CGRectMake(0, 22.06, 414, 66.2)];
    title.text=@"错题本";
    
    title.textColor=[UIColor whiteColor];
    title.backgroundColor=ssRGBHex(0xFF7474);
    title.font=[UIFont systemFontOfSize:18];
    title.textAlignment=NSTextAlignmentCenter;
    title.clipsToBounds = YES;
    [title setUserInteractionEnabled:YES];
    [self.view addSubview:title];
    
    UILabel* touchField=[[UILabel alloc]initWithFrame:CGRectMake(10, 20,30, 30)];
    [touchField setUserInteractionEnabled:YES];
    [title addSubview:touchField];
    
    UIButton* returnBtn=[[UIButton alloc]initWithFrame:CGRectMake(5.45, 2.06, 10.7, 22.62)];
    [returnBtn setBackgroundImage:[UIImage imageNamed:@"icon_return_ffffff"] forState:UIControlStateNormal];
    [returnBtn setBackgroundImage:[UIImage imageNamed:@"icon_return_ffffff"] forState:UIControlStateHighlighted];
    [returnBtn addTarget:self action:@selector(popBack:) forControlEvents:UIControlEventTouchUpInside];
    [touchField addSubview:returnBtn];
    
    UITapGestureRecognizer* touchFunc=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(popBack:)];
    [touchField addGestureRecognizer:touchFunc];

    
    UIButton* setBtn=[[UIButton alloc]initWithFrame:CGRectMake(376.46, 22.06 , 22.06, 22.06)];
    [setBtn setBackgroundImage:[UIImage imageNamed:@"icon_setting"] forState:UIControlStateNormal];
    [setBtn setBackgroundImage:[UIImage imageNamed:@"icon_setting"] forState:UIControlStateHighlighted];
    [setBtn addTarget:self action:@selector(showSettingView) forControlEvents:UIControlEventTouchUpInside];
    [title addSubview:setBtn];
}

-(void)lastAndNext{
    lastAndNextPanel=[[UIView alloc]initWithFrame:CGRectMake(0, 88.27, 414, 33.1)];
    lastAndNextPanel.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:lastAndNextPanel];
    
    lastSubBtn=[[UIButton alloc]initWithFrame:CGRectMake(17.66, 9.93, 55.20, 22.06)];
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
    
    [self processTip];
    
    nextSubBtn=[[UIButton alloc]initWithFrame:CGRectMake(341.13, 9.93, 55.20, 22.06)];
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
    
}
//显示当前是第几题了
-(void)processTip{
    processTip=[[UILabel alloc]initWithFrame:CGRectMake(195.95, 12.13, 60, 18.75)];
    NSString* total=[NSString stringWithFormat:@"%lu",(unsigned long)testArray.count];
    NSString* present=[NSString stringWithFormat:@"%d",(testFlag+1)];
    present=[present stringByAppendingString:@"/"];
    processTip.text=[present stringByAppendingString:total];
    processTip.textColor=ssRGBHex(0x9B9B9B);
    processTip.font=[UIFont systemFontOfSize:12];
    [lastAndNextPanel addSubview:processTip];
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
    settingView=[[UIView alloc]initWithFrame:CGRectMake(0, 88.27, 414, 647.72)];
    settingView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
    settingContent=@[@"根据英语发音选择中文意思",@"根据英文单词或句子选择中文意思",@"根据中文意思选择英文单词或句子",@"根据中文意思拼写英文单词或句子"];
    
    UITableView* settingList=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, 414, 213)];
    settingList.dataSource=self;
    settingList.delegate=self;
    [settingView addSubview:settingList];
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
    // cell.imageView.image=[UIImage imageNamed:image];
    
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //去除设置界面
    [settingView removeFromSuperview];
    if (indexPath.row!=[[testDetails valueForKey:@"testFunc"]integerValue]) {
        [questionAndAnswerView removeFromSuperview];
        [testDetails setValue:[NSString stringWithFormat:@"%ld",(long)indexPath.row] forKey:@"testFunc"];
        //NSLog(@"字典的值是%@",testDetails);
        [self addQAview];
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 52.96;
}

-(void)showSettingView{
    if (showSetting) {
        [self.view addSubview:settingView];
    }else{
        [settingView removeFromSuperview];
    }
    showSetting=!showSetting;
    
}

#pragma mark --加载页面
//加载数据，显示页面内容
-(void)showContent{
    
    //加载内容
    [self lastAndNext];
    
    [self addQAview];
    
}

-(void)addQAview{
    [questionAndAnswerView removeFromSuperview];
    NSString* testFunc=[testDetails valueForKey:@"testFunc"];
    if ([testFunc isEqualToString:@"0"]) {
        questionAndAnswerView=[VoiceChooseChn alloc];
        questionAndAnswerView.wordNum=[[NSString stringWithFormat:@"%lu",(unsigned long)wordArray.count]intValue];
        questionAndAnswerView=[questionAndAnswerView initWithFrame:CGRectMake(0, 121.37, 414, 647.72) TestFlag:testFlag TestArray:testArray TestType:_testType UserInfo:userInfo];
    }else if([testFunc isEqualToString:@"1"]){
        questionAndAnswerView=[EngChooseChi alloc];
        questionAndAnswerView.wordNum=[[NSString stringWithFormat:@"%lu",(unsigned long)wordArray.count]intValue];
        questionAndAnswerView=[questionAndAnswerView initWithFrame:CGRectMake(0, 121.37, 414, 563.86) TestFlag:testFlag TestArray:testArray TestType:_testType UserInfo:userInfo];
    }else if([testFunc isEqualToString:@"2"]){
        questionAndAnswerView=[ChnChooseEng alloc];
        questionAndAnswerView.wordNum=[[NSString stringWithFormat:@"%lu",(unsigned long)wordArray.count]intValue];
        questionAndAnswerView=[questionAndAnswerView initWithFrame:CGRectMake(0, 121.37, 414, 563.86) TestFlag:testFlag TestArray:testArray TestType:_testType UserInfo:userInfo];
    }else if([testFunc isEqualToString:@"3"]){
        questionAndAnswerView=[ChinSpellEnglish alloc];
        questionAndAnswerView.wordNum=[[NSString stringWithFormat:@"%lu",(unsigned long)wordArray.count]intValue];
        questionAndAnswerView=[questionAndAnswerView initWithFrame:CGRectMake(0, 121.37, 414, 563.86) TestFlag:testFlag TestArray:testArray TestType:_testType UserInfo:userInfo];
    }else{
        
    }
    [processTip removeFromSuperview];
    [self processTip];
    [self.view addSubview:questionAndAnswerView];
}

-(void)playVoice{
    //播放声音
    //音频播放空间分配
    NSString* playUrl=[[[testArray objectAtIndex:testFlag]valueForKey:@"engUrl"] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    voiceplayer=[[VoicePlayer alloc]init];
    voiceplayer.url=playUrl;
    [voiceplayer.audioStream play];
}

-(void)popBack:(UITapGestureRecognizer*)sender{
    //[DocuOperate deletePlist:@"wrongsDetails.plist"];
    [settingView removeFromSuperview];
    [DocuOperate writeIntoPlist:@"wrongsDetails.plist" dictionary:testDetails];
    [self.navigationController popViewControllerAnimated:true];
}


@end
