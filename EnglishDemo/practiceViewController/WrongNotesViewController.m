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
#import "../Functions/MyThreadPool.h"
#import "../SVProgressHUD/SVProgressHUD.h"
#import "Masonry.h"

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
    
}
-(void)viewWillAppear:(BOOL)animated{
    if ([DocuOperate fileExistInPath:@"userInfo.plist"]) {
        [self showContent];
       
    }
    else{
        UnloginMsgView* unloginView=[[UnloginMsgView alloc]init];
        [self.view addSubview:unloginView];
        
        [unloginView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(88.27);
            make.right.equalTo(self.view);
            make.left.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
    }
}

//初始数据加载
-(void)initDataOnlyOnce{
    testDetails=[[NSDictionary alloc]init];
    testArray=[[NSMutableArray alloc]init];
    wordArray=[[NSArray alloc]init];
    sentenceArray=[[NSArray alloc]init];
    if (![DocuOperate fileExistInPath:@"wrongsDetails.plist"]) {
        NSDictionary* dic=[[NSDictionary alloc]initWithObjectsAndKeys:@"0",@"testFunc", nil];
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
    
    __block NSDictionary* resultDic;
    ConBlock myBlock = ^(NSDictionary* dic){
        resultDic = [dic valueForKey:@"data"];
        self->wordArray=[resultDic valueForKey:@"bookWordInfos"];
        self->sentenceArray=[resultDic valueForKey:@"bookSentenceInfos"];
           
           
        for (NSDictionary* dic in self->wordArray) {
            [self->testArray addObject:dic];
           }
        for (NSDictionary* dic in self->sentenceArray) {
            [self->testArray addObject:dic];
           }

        //主线程更新UI。不能放到下面的exevcute的q原因是此代码块未执行的时候main中就可能会执行
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString* total=[NSString stringWithFormat:@"%lu",(unsigned long)self->testArray.count];
            NSString* present=[NSString stringWithFormat:@"%d",(self->testFlag+1)];
            present=[present stringByAppendingString:@"/"];
            self->processTip.text=[present stringByAppendingString:total];

            if ([self->testArray isKindOfClass:[NSNull class]]||self->testArray.count==0) {
                [self presentViewController:[WarningWindow MsgWithoutTrans:@"您还没有错题!先去做题吧！"] animated:YES completion:nil];
                [SVProgressHUD dismiss];
            }else{
               //加载内容
                dispatch_async(dispatch_get_main_queue(), ^{
                     [self addQAview];
                     [SVProgressHUD dismiss];
                });
              
            }
        });
        
        NSLog(@"错题信息是%@",self->testArray);
        
    };
    [SVProgressHUD show];
    [MyThreadPool executeJob:^{
        [ConnectionFunction getWrongMsgWithBlock:[self->userInfo valueForKey:@"userKey"] Id:self->_recentBookId Block:myBlock];
    } Main:^{}];
}

//标题栏显示
-(void)titleShow{
    UILabel* title=[[UILabel alloc]init];
    title.text=@"错题本";
    
    title.textColor=[UIColor whiteColor];
    title.backgroundColor=ssRGBHex(0xFF7474);
    title.font=[UIFont systemFontOfSize:18];
    title.textAlignment=NSTextAlignmentCenter;
    title.clipsToBounds = YES;
    [title setUserInteractionEnabled:YES];
    [self.view addSubview:title];
    
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(22);
        make.right.equalTo(self.view);
        make.left.equalTo(self.view);
        make.height.equalTo(@66);
    }];
    
    UILabel* touchField=[[UILabel alloc]init];
    [touchField setUserInteractionEnabled:YES];
    [title addSubview:touchField];
    
    [touchField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(title).with.offset(20);
        make.width.equalTo(@30);
        make.left.equalTo(self.view).with.offset(10);
        make.height.equalTo(@30);
    }];
    
    UIButton* returnBtn=[[UIButton alloc]init];
    [returnBtn setBackgroundImage:[UIImage imageNamed:@"icon_return_ffffff"] forState:UIControlStateNormal];
    [returnBtn setBackgroundImage:[UIImage imageNamed:@"icon_return_ffffff"] forState:UIControlStateHighlighted];
    [returnBtn addTarget:self action:@selector(popBack:) forControlEvents:UIControlEventTouchUpInside];
    [touchField addSubview:returnBtn];
    
    [returnBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(touchField).with.offset(2);
        make.width.equalTo(@10.7);
        make.left.equalTo(touchField).with.offset(5.45);
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
        make.width.equalTo(@22);
        make.right.equalTo(title).with.offset(-15);
        make.height.equalTo(@22);
    }];
}

-(void)lastAndNext{
    lastAndNextPanel=[[UIView alloc]init];
    lastAndNextPanel.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:lastAndNextPanel];
    
    [lastAndNextPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(88.27);
        make.right.equalTo(self.view);
        make.left.equalTo(self.view);
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
        make.width.equalTo(@55.2);
        make.left.equalTo(self->lastAndNextPanel).with.offset(17.66);
        make.height.equalTo(@22.06);
    }];
    
    nextSubBtn=[[UIButton alloc]init];
    if (testFlag==testArray.count-1 && testArray.count!=0) {
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
        make.width.equalTo(@55.2);
        make.right.equalTo(self->lastAndNextPanel).with.offset(-17.66);
        make.height.equalTo(@22.06);
    }];
    
}
//显示当前是第几题了
-(void)processTip{
    processTip=[[UILabel alloc]init];
    processTip.textColor=ssRGBHex(0x9B9B9B);
    processTip.font=[UIFont systemFontOfSize:12];
    processTip.textAlignment=NSTextAlignmentCenter;
    [lastAndNextPanel addSubview:processTip];
    
    [processTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->lastAndNextPanel).with.offset(12.13);
        make.width.equalTo(@50);
        make.centerX.equalTo(self->lastAndNextPanel);
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
        [MyThreadPool executeJob:^{
            [self->testDetails setValue:[NSString stringWithFormat:@"%ld",(long)indexPath.row] forKey:@"testFunc"];
            [DocuOperate writeIntoPlist:@"wrongsDetails.plist" dictionary:self->testDetails];
        } Main:^{}];
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

#pragma mark --加载页面
//加载数据，显示页面内容
-(void)showContent{

    testFlag=0;
    [self lastAndNext];
    [self processTip];
    [self initData];

    
}

-(void)addQAview{
    [questionAndAnswerView removeFromSuperview];
    NSString* testFunc=[testDetails valueForKey:@"testFunc"];
    if ([testFunc isEqualToString:@"0"]) {
        questionAndAnswerView=[VoiceChooseChn alloc];
        questionAndAnswerView.wordNum=[[NSString stringWithFormat:@"%lu",(unsigned long)wordArray.count]intValue];
        questionAndAnswerView=[questionAndAnswerView initWithFlag:testFlag TestArray:testArray TestType:_testType UserInfo:userInfo BookId:_recentBookId];
    }else if([testFunc isEqualToString:@"1"]){
        questionAndAnswerView=[EngChooseChi alloc];
        questionAndAnswerView.wordNum=[[NSString stringWithFormat:@"%lu",(unsigned long)wordArray.count]intValue];
        questionAndAnswerView=[questionAndAnswerView initWithFlag:testFlag TestArray:testArray TestType:_testType UserInfo:userInfo BookId:_recentBookId];
    }else if([testFunc isEqualToString:@"2"]){
        questionAndAnswerView=[ChnChooseEng alloc];
        questionAndAnswerView.wordNum=[[NSString stringWithFormat:@"%lu",(unsigned long)wordArray.count]intValue];
        questionAndAnswerView=[questionAndAnswerView initWithFlag:testFlag TestArray:testArray TestType:_testType UserInfo:userInfo BookId:_recentBookId];
    }else if([testFunc isEqualToString:@"3"]){
        questionAndAnswerView=[ChinSpellEnglish alloc];
        questionAndAnswerView.wordNum=[[NSString stringWithFormat:@"%lu",(unsigned long)wordArray.count]intValue];
        questionAndAnswerView=[questionAndAnswerView initWithFlag:testFlag TestArray:testArray TestType:_testType UserInfo:userInfo BookId:_recentBookId];
    }else{
        
    }
     NSString* total=[NSString stringWithFormat:@"%lu",(unsigned long)self->testArray.count];
     NSString* present=[NSString stringWithFormat:@"%d",(self->testFlag+1)];
        present=[present stringByAppendingString:@"/"];
     self->processTip.text=[present stringByAppendingString:total];
    
    [self.view addSubview:questionAndAnswerView];
    
    [questionAndAnswerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(172);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
}

-(void)popBack:(UITapGestureRecognizer*)sender{
    [settingView removeFromSuperview];
    [self.navigationController popViewControllerAnimated:true];
    [self->voiceplayer stopPlay];
}


@end
