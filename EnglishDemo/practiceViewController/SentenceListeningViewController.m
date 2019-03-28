//
//  SentenceListeningViewController.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/21.
//  Copyright © 2018年 马一轩. All rights reserved.
//

#import "SentenceListeningViewController.h"
#import "../DiyGroup/WordsListeningTableViewCell.h"
#import "../DiyGroup/ChooseLessonView.h"
#import "../Functions/ConnectionFunction.h"
#import "../DiyGroup/ChooseLessonView.h"
#import "../Functions/DocuOperate.h"
#import "../Functions/VoicePlayer.h"
#import "../Functions/WarningWindow.h"
#import "../DiyGroup/UnloginMsgView.h"

//使控制台打印完整信息
//#ifdef DEBUG
//#define NSLog(FORMAT, ...) fprintf(stderr, "%s:%zd\t%s\n", [[[NSString stringWithUTF8String: __FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat: FORMAT, ## __VA_ARGS__] UTF8String]);
//#else
//#define NSLog(FORMAT, ...) nil
//#endif

@interface SentenceListeningViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray* sentenceArray;
    BOOL chooseLessonShow;
    ChooseLessonView* chooseLessonView;
    //单元课程名称
    NSString* unitName;
    NSString* className;
    //显示当前课程的容器
    UIView* presentLession;
    //声明显示内容的tableview
    UITableView* sentencesList;
    //当前课程的label
    UILabel* lessontitle;
    //存放用户信息
    NSDictionary* userInfo;
    //当前课程id
    NSString* classId;
    //当前单元的课程数组
    NSArray* lessonArray;
    //播放音频所需
    VoicePlayer* voiceplayer;
    
    
}
@end

@implementation SentenceListeningViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    //初始化数组
    sentenceArray=[[NSArray alloc]init];
    lessonArray=[[NSArray alloc]init];
    //bool显示选课信息界面
    chooseLessonShow=true;
    //加载标题
    [self titleShow];
    
}
-(void)viewWillAppear:(BOOL)animated{
    if ([DocuOperate fileExistInPath:@"userInfo.plist"]) {
        userInfo=[DocuOperate readFromPlist:@"userInfo.plist"];
        //初始化选课信息
        [self chooseLessonViewInit];
        //加载上一课下一课界面
        [self chooseLesson];
        //加载当前课程标签
        [self presentLessionView];
    }
    else{
        UnloginMsgView* unloginView=[[UnloginMsgView alloc]initWithFrame:CGRectMake(0, 88.27, 414, 647)];
        [self.view addSubview:unloginView];
    }
}


-(void)titleShow{
    UILabel* title=[[UILabel alloc]initWithFrame:CGRectMake(0, 22.06, 414, 66.2)];
    title.text=@"句子听写";
    title.textColor=[UIColor whiteColor];
    title.backgroundColor=ssRGBHex(0xFF7474);
    title.font=[UIFont systemFontOfSize:18];
    title.textAlignment=NSTextAlignmentCenter;
    title.clipsToBounds = YES;
    [title setUserInteractionEnabled:YES];
    [self.view addSubview:title];
    
    UILabel* touchField=[[UILabel alloc]initWithFrame:CGRectMake(10, 20,30, 30)];
    touchField.backgroundColor=[UIColor blackColor];
    [touchField setUserInteractionEnabled:YES];
    [title addSubview:touchField];
    
    UIButton* returnBtn=[[UIButton alloc]initWithFrame:CGRectMake(5.45, 2.06, 10.7, 22.62)];
    [returnBtn setBackgroundImage:[UIImage imageNamed:@"icon_return_ffffff"] forState:UIControlStateNormal];
    [returnBtn setBackgroundImage:[UIImage imageNamed:@"icon_return_ffffff"] forState:UIControlStateHighlighted];
    [touchField addSubview:returnBtn];
    
    UITapGestureRecognizer* touchFunc=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(popBack:)];
    [touchField addGestureRecognizer:touchFunc];

    
    UIButton* setBtn=[[UIButton alloc]initWithFrame:CGRectMake(376.46, 22.06 , 22.06, 22.06)];
    [setBtn setBackgroundImage:[UIImage imageNamed:@"icon_setting"] forState:UIControlStateNormal];
    [setBtn setBackgroundImage:[UIImage imageNamed:@"icon_setting"] forState:UIControlStateHighlighted];
//    [setBtn addTarget:self action:@selector(showSettingView) forControlEvents:UIControlEventTouchUpInside];
    [title addSubview:setBtn];
}

-(void)chooseLessonViewInit{
    chooseLessonView=[[ChooseLessonView alloc]initWithFrame:CGRectMake(0, 132.41, 414, 603.58) bookId:_bookId DefaultUnit:0];
}
//上一课下一课
-(void)chooseLesson{
    presentLession=[[UIView alloc]initWithFrame:CGRectMake(0, 88.27, 414, 44.13)];
    presentLession.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:presentLession];
    
    //上一课以及箭头
    UIButton* lastLessonBtn=[[UIButton alloc]initWithFrame:CGRectMake(12.14, 14.34, 8.83, 16.55)];
    [lastLessonBtn setBackgroundImage:[UIImage imageNamed:@"icon_shangyike"] forState:UIControlStateNormal];
    [lastLessonBtn addTarget:self action:@selector(clickLastLesson) forControlEvents:UIControlEventTouchUpInside];
    [presentLession addSubview:lastLessonBtn];
    UIButton* lastLessonLabel=[[UIButton alloc]initWithFrame:CGRectMake(29.8, 13.24, 39.74, 18.75)];
    [lastLessonLabel addTarget:self action:@selector(clickLastLesson) forControlEvents:UIControlEventTouchUpInside];
    [lastLessonLabel setTitle:@"上一课" forState:UIControlStateNormal];
    [lastLessonLabel setTitleColor:ssRGBHex(0x4A4A4A) forState:UIControlStateNormal];
    lastLessonLabel.titleLabel.font=[UIFont systemFontOfSize:12];
    [presentLession addSubview:lastLessonLabel];
    
    
    //下一课以及箭头
    UIButton* nextLessonBtn=[[UIButton alloc]initWithFrame:CGRectMake(391.91, 14.34, 8.83, 16.55)];
    [nextLessonBtn setBackgroundImage:[UIImage imageNamed:@"icon_xiayike"] forState:UIControlStateNormal];
    [nextLessonBtn addTarget:self action:@selector(clickNextLesson) forControlEvents:UIControlEventTouchUpInside];
    [presentLession addSubview:nextLessonBtn];
    UIButton* nextLessonLabel=[[UIButton alloc]initWithFrame:CGRectMake(341.13, 13.24, 39.74, 18.75)];
    [nextLessonLabel setTitle:@"下一课" forState:UIControlStateNormal];
    [nextLessonLabel addTarget:self action:@selector(clickNextLesson) forControlEvents:UIControlEventTouchUpInside];
    [nextLessonLabel setTitleColor:ssRGBHex(0x4A4A4A) forState:UIControlStateNormal];
    nextLessonLabel.titleLabel.font=[UIFont systemFontOfSize:12];
    [presentLession addSubview:nextLessonLabel];
    
}
-(void)clickLastLesson{
    if (classId==nil) {
        NSLog(@"请先选择课程");
    }else{
        if ([classId isEqualToString:[[lessonArray objectAtIndex:0]valueForKey:@"articleId"]]){
            NSLog(@"这是当前单元的第一课！没有上一课了！");
            [WarningWindow MsgWithoutTrans:@"这是当前单元的第一课！没有上一课了！"];
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
                   sentenceArray:[[ConnectionFunction getTestSentenceMsg:[[lessonArray objectAtIndex:(i-1)]valueForKey:@"articleId"] UserKey:[userInfo valueForKey:@"userKey"]]valueForKey:@"data"]
                      classId:[[lessonArray objectAtIndex:(i-1)]valueForKey:@"articleId"]];
        }
    }
    
}
-(void)clickNextLesson{
    if (classId==nil) {
        NSLog(@"请先选择课程");
    }else{
        if ([classId isEqualToString:[[lessonArray objectAtIndex:(lessonArray.count-1)]valueForKey:@"articleId"]]){
            NSLog(@"这是当前单元的最后一课！没有下一课了！");
             [WarningWindow MsgWithoutTrans:@"这是当前单元的最后一课！没有下一课了！"];
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
            //            NSDictionary* dataDic=
            //            [[ConnectionFunction getLessonMsg:[[lessonArray objectAtIndex:(i-1)]valueForKey:@"articleId"]
            //                                      UserKey:[userInfo valueForKey:@"userKey"]]valueForKey:@"data"];
            
            [self showContent:[[lessonArray objectAtIndex:(i+1)]valueForKey:@"articleName"]
                    className:@""
                   sentenceArray:[[ConnectionFunction getTestSentenceMsg:[[lessonArray objectAtIndex:(i+1)]valueForKey:@"articleId"] UserKey:[userInfo valueForKey:@"userKey"]]valueForKey:@"data"]
                      classId:[[lessonArray objectAtIndex:(i+1)]valueForKey:@"articleId"]];
        }
    }
    
}
//中间显示标题
-(void)presentLessionView{
    //中间标题
    lessontitle=[[UILabel alloc]initWithFrame:CGRectMake(97.15, 7.72, 220.80, 28.68)];
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
    UIButton* angleBtn=[[UIButton alloc]initWithFrame:CGRectMake(186.57, 9.93, 20.97, 12.13)];
    [angleBtn setBackgroundImage:[UIImage imageNamed:@"btn_down"] forState:UIControlStateNormal];
    [angleBtn setBackgroundImage:[UIImage imageNamed:@"icon_Rectangle_up"] forState:UIControlStateSelected];
    [angleBtn addTarget:self action:@selector(showChooseLessonView:) forControlEvents:UIControlEventTouchUpInside];
    [lessontitle addSubview:angleBtn];
    [presentLession addSubview:lessontitle];
}
//收起课程选择并显示内容
-(void)showChooseLessonView:(UIButton*)button{
    if (chooseLessonShow) {
        [self.view addSubview:chooseLessonView];
    }else{
        if (chooseLessonView.unitName!=nil&&chooseLessonView.className!=nil) {
            lessonArray=chooseLessonView.lessonArray;
            [self showContent:chooseLessonView.unitName
                    className:chooseLessonView.className
                   sentenceArray:[[ConnectionFunction getTestSentenceMsg:chooseLessonView.articleId UserKey:[userInfo valueForKey:@"userKey"]]valueForKey:@"data"]
                      classId:[[[chooseLessonView.dataArray valueForKey:@"bookSentences"]objectAtIndex:0] valueForKey:@"articleId"]
             ];
        }else{
            //收起选择课程界面
            [chooseLessonView removeFromSuperview];
        }
    }
    chooseLessonShow=!chooseLessonShow;
    button.selected=!button.selected;
    
}
-(void)showContent:(NSString*)unitname className:(NSString*)classname sentenceArray:(NSArray*)sentencearray classId:(NSString*)classid{
    //收起选择课程界面
    [chooseLessonView removeFromSuperview];
    //为当前单元课程名称赋值
    unitName=unitname;
    className=classname;
    sentenceArray=sentencearray;
    NSLog(@"句子数组的信息是%@",sentenceArray);
    classId=classid;
    //重新加载当前单元课程标签
    [lessontitle removeFromSuperview];
    [self presentLessionView];
    //加载内容
    [self contentView];
    [sentencesList reloadData];
}

-(void)contentView{
    UITableView* wordsList=[[UITableView alloc]initWithFrame:CGRectMake(0, 134.62, 414, 603.58)];
    wordsList.dataSource=self;
    wordsList.delegate=self;
    [self.view addSubview:wordsList];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return sentenceArray.count ;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WordsListeningTableViewCell* cell=[WordsListeningTableViewCell createCellWithTableView:tableView];
    NSDictionary* cellDic=[sentenceArray objectAtIndex:indexPath.row];
    NSString* pic=@"icon_juzitingxia_laba";
    NSString* name=[cellDic valueForKey:@"sentenceEng"];
    NSString* description=[cellDic valueForKey:@"sentenceChn"];
    [cell loadData:pic name:name description:description];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 52.96;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //播放声音
    //音频播放空间分配
    NSString* playUrl=[[[sentenceArray objectAtIndex:indexPath.row]valueForKey:@"engUrl"] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    voiceplayer=[[VoicePlayer alloc]init];
    voiceplayer.url=playUrl;
    [voiceplayer.audioStream play];
}

-(void)showChooseLessonView{
    NSLog(@"执行了这里的代码");
    if (chooseLessonShow) {
        [self.view addSubview:chooseLessonView];
    }else{
        [chooseLessonView removeFromSuperview];
    }
    chooseLessonShow=!chooseLessonShow;
    
}
-(void)popBack:(UITapGestureRecognizer*)sender{
    [self.navigationController popViewControllerAnimated:true];
}

@end
