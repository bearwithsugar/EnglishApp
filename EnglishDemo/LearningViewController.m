//
//  LearningViewController.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/19.
//  Copyright © 2018年 马一轩. All rights reserved.
//

#import "LearningViewController.h"
#import "DiyGroup/ChooseLessonView.h"
#import "Functions/ConnectionFunction.h"
#import "Functions/DocuOperate.h"
#import "Record/AudioRecorder.h"
#import "Functions/VoicePlayer.h"
#import "Functions/LocalDataOperation.h"
#import "Functions/WarningWindow.h"
#import "Common/LoadGif.h"


//使控制台打印完整信息
//#ifdef DEBUG
//#define NSLog(FORMAT, ...) fprintf(stderr, "%s:%zd\t%s\n", [[[NSString stringWithUTF8String: __FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat: FORMAT, ## __VA_ARGS__] UTF8String]);
//#else
//#define NSLog(FORMAT, ...) nil
//#endif

@interface LearningViewController ()<AudioRecorderDelegate,UIGestureRecognizerDelegate,AVAudioPlayerDelegate>{
    NSMutableArray* contentArray;
    UIView* content;
    UIView* settingView;
    UIView* bigPicView;
    //直接存放大图的imageview
    UIImageView* theBigPic;
    ChooseLessonView* chooseLessonView;
    NSMutableArray* autoPlayNextBtnArray;
    NSMutableArray* timeIntervalBtnArray;
    NSMutableArray* playChineseBtnArray;
    NSMutableArray* showTranslationBtnArray;
    NSMutableArray* replayTimesBtnArray;
    NSArray* settingArray;
    UIButton* angleBtn;
    BOOL settingShow;
    BOOL chooseLessonShow;
    //当前课程标题栏
    UIView* presentLession;
    //用户信息
    NSDictionary* userInfo;
    //存放左侧图片的数组
    NSArray* bookPicArray;
    //存放语句的数组
    NSArray* sentenceArray;
    //存放一个单元下的课的数组
    NSArray* lessonArray;
    //存放当前单元名
    NSString* unitName;
    //存放当前单元名
    NSString* className;
    //当前课程的label
    UILabel* lessontitle;
    //存放内容的句子
    NSMutableArray* titleArray;
    //左侧图书界面
    UIScrollView* bookPicView;
    //整个下方界面
    UIView* contentView;
    //右侧具体学习内容界面
    UIScrollView* contentDetailView;
    //是否正在录音
    BOOL isRecord;
    
    UITapGestureRecognizer* clickRecognize;
    //设置手势点击任何一点结束录音
    UITapGestureRecognizer* stopRecordTap;
    //跟读按钮
    UIButton* followReadBtn;
    //当前录音的句子编号
    NSString* recordingSentenceId;
    //播放音频所需
    VoicePlayer* voiceplayer;
    //当前课程id
    NSString* classId;
    //音频数组
    NSMutableArray* voiceArray;
    
}
//@property (nonatomic,strong) IBOutlet UIProgressView *progressView;
@end



@implementation LearningViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=ssRGBHex(0xFCF8F7);
    //为z数组分配空间
    contentArray=[[NSMutableArray alloc]init];
    sentenceArray=[[NSArray alloc]init];
    bookPicArray=[[NSArray alloc]init];

    
    //为字符串分配空间
//    unitName=[[NSString alloc]init];
//    className=[[NSString alloc]init];
    settingArray=@[@"1",@"1",@"0",@"1",@"1"];
    chooseLessonShow=settingShow=true;
    angleBtn.selected=false;
    isRecord=false;
    
    userInfo=[DocuOperate readFromPlist:@"userInfo.plist"];
    [self titleShow];
    [self chooseLesson];
    [self presentLessionView];
    
    //????
   // [self learningBook];

    //固定的
    [self initSettingView];
    [self defaultSettings];
    [self defaultSettingsShow];
    
    [self chooseLessonViewInit];
    
    contentDetailView=[[UIScrollView alloc]initWithFrame:CGRectMake(136.89, 0, 300, 603.58)];
    [contentView addSubview:contentDetailView];
    
    [self showChooseLessonView];
    
    //录音所用
    //self.progressView.progress = 0;
    
    
  
}
-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"获取到的单元id是%@",_unitId);
}
-(void)titleShow{
    UILabel* title=[[UILabel alloc]initWithFrame:CGRectMake(0, 22.06, 414, 66.2)];
    title.text=_bookName;
    title.textColor=[UIColor whiteColor];
    title.backgroundColor=ssRGBHex(0xFF7474);
    title.font=[UIFont systemFontOfSize:18];
    title.textAlignment=NSTextAlignmentCenter;
    title.clipsToBounds = YES;
    [title setUserInteractionEnabled:YES];
    [self.view addSubview:title];
    
    UIButton* returnBtn=[[UIButton alloc]initWithFrame:CGRectMake(15.45, 22.06, 10.7, 22.62)];
    [returnBtn setBackgroundImage:[UIImage imageNamed:@"icon_return_ffffff"] forState:UIControlStateNormal];
    [returnBtn setBackgroundImage:[UIImage imageNamed:@"icon_return_ffffff"] forState:UIControlStateHighlighted];
    [returnBtn addTarget:self action:@selector(popBack) forControlEvents:UIControlEventTouchUpInside];
    [title addSubview:returnBtn];
    
    UIButton* setBtn=[[UIButton alloc]initWithFrame:CGRectMake(376.46, 22.06 , 22.06, 22.06)];
    [setBtn setBackgroundImage:[UIImage imageNamed:@"icon_setting"] forState:UIControlStateNormal];
    [setBtn setBackgroundImage:[UIImage imageNamed:@"icon_setting"] forState:UIControlStateHighlighted];
    [setBtn addTarget:self action:@selector(showSettingView) forControlEvents:UIControlEventTouchUpInside];
    [title addSubview:setBtn];
}
//选择课程的上一课下一课
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
    [nextLessonLabel addTarget:self action:@selector(clickNextLesson) forControlEvents:UIControlEventTouchUpInside];
    [nextLessonLabel setTitle:@"下一课" forState:UIControlStateNormal];
    [nextLessonLabel setTitleColor:ssRGBHex(0x4A4A4A) forState:UIControlStateNormal];
    nextLessonLabel.titleLabel.font=[UIFont systemFontOfSize:12];
    [presentLession addSubview:nextLessonLabel];
    
}
-(void)clickLastLesson{
    //[ConnectionFunction getLessonMsg:_articleId UserKey:[userInfo valueForKey:@"userKey"]];
    if (classId==nil) {
        NSLog(@"请先选择课程");
    }else{
        if ([classId isEqualToString:[[lessonArray objectAtIndex:0]valueForKey:@"articleId"]]){
            NSLog(@"这是当前单元的第一课！没有上一课了！");
            [self presentViewController:[WarningWindow MsgWithoutTrans:@"这是当前单元的第一课！没有上一课了！"]
                               animated:YES
                             completion:nil];
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
            NSDictionary* dataDic=
            [[ConnectionFunction getLessonMsg:[[lessonArray objectAtIndex:(i-1)]valueForKey:@"articleId"]
                                      UserKey:[userInfo valueForKey:@"userKey"]]valueForKey:@"data"];
            
            [self showContent:[dataDic valueForKey:@"bookPictures"]
                     senArray:[dataDic valueForKey:@"bookSentences"]
                      classId:[[[dataDic valueForKey:@"bookSentences"]objectAtIndex:0] valueForKey:@"articleId"]
                     unitName:[[lessonArray objectAtIndex:(i-1)]valueForKey:@"articleName"]
                    className:@""];
        }
    }
    
}
-(void)clickNextLesson{
    //[ConnectionFunction getLessonMsg:_articleId UserKey:[userInfo valueForKey:@"userKey"]];
    if (classId==nil) {
        NSLog(@"请先选择课程");
    }else{
        if ([classId isEqualToString:[[lessonArray objectAtIndex:(lessonArray.count-1)]valueForKey:@"articleId"]]){
            NSLog(@"这是当前单元的最后一课！没有下一课了！");
            //提示框
            [self presentViewController:
             [WarningWindow MsgWithoutTrans:@"这是当前单元的最后一课！没有下一课了！"]
                               animated:YES
                             completion:nil];
            
        }else{
            int i=0;
            for (NSDictionary* dic in lessonArray) {
                NSLog(@"此时的classid%@",classId);
                NSLog(@"lessonArray单个元素的内容%@",dic);
                if ([[dic valueForKey:@"articleId"]isEqualToString: classId]) {
                    break;
                }
                i++;
            }
            NSDictionary* dataDic=
            [[ConnectionFunction getLessonMsg:[[lessonArray objectAtIndex:(i+1)]valueForKey:@"articleId"]
                                      UserKey:[userInfo valueForKey:@"userKey"]]valueForKey:@"data"];
            [self showContent:[dataDic valueForKey:@"bookPictures"]
                     senArray:[dataDic valueForKey:@"bookSentences"]
                      classId:[[[dataDic valueForKey:@"bookSentences"]objectAtIndex:0] valueForKey:@"articleId"]
                     unitName:[[lessonArray objectAtIndex:(i+1)]valueForKey:@"articleName"]
                    className:@""];
            
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
    
//    UIButton* angleBtn=[[UIButton alloc]initWithFrame:CGRectMake(186.57, 9.93, 20.97, 12.13)];
//    [angleBtn setBackgroundImage:[UIImage imageNamed:@"btn_down"] forState:UIControlStateNormal];
//    [angleBtn setBackgroundImage:[UIImage imageNamed:@"icon_Rectangle_up"] forState:UIControlStateSelected];
//    [angleBtn addTarget:self action:@selector(showChooseLessonView:) forControlEvents:UIControlEventTouchUpInside];
//    [lessontitle addSubview:angleBtn];
    
    [presentLession addSubview:lessontitle];
    
    UITapGestureRecognizer* showLineGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showChooseLessonView)];
    [lessontitle addGestureRecognizer:showLineGesture];
}
//左侧显示书封面
-(void)learningBook{
    NSUInteger size=bookPicArray.count;
    
    contentView=[[UIView alloc]initWithFrame:CGRectMake(0, 132.41, 414, 603.58)];
    [self.view addSubview:contentView];
    
    bookPicView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 124, 603.58)];
    NSUInteger bookPicViewHeight;
    if (size<4) {
        bookPicViewHeight=700;
    }else{
        bookPicViewHeight=size*184+20;
    }
    bookPicView.contentSize=CGSizeMake(124, bookPicViewHeight);
    [contentView addSubview:bookPicView];
    
    for (int i=0;i<size; i++) {
        float y=19.86+183.17*i;
        float x=13.24;
        UIImageView* theBook=[[UIImageView alloc]initWithFrame:CGRectMake(x,y, 110, 172)];
        [theBook setUserInteractionEnabled:YES];
        theBook.tag=i;
        
        NSDictionary* bookDic=[bookPicArray objectAtIndex:i];
        //NSLog(@"bookDic%@",bookDic);
        NSString* picUrl=[bookDic valueForKey:@"pictureUrl"];
//        //路径中有特殊字符，转换一下
        picUrl=[picUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
//        NSURL* url=[NSURL URLWithString:picUrl];
//        NSData *imgData = [NSData dataWithContentsOfURL:url];
//        theBook.image=[UIImage imageWithData:imgData];
        theBook.image=[LocalDataOperation getImage:[bookDic valueForKey:@"pictureId"] httpUrl:picUrl];
        
        //暂时用其他图片代替
        //theBook.image=[UIImage imageNamed:@"group_book_learning"];
        [bookPicView addSubview:theBook];
        
        UILabel* showBigPic=[[UILabel alloc]initWithFrame:CGRectMake(16.55, 11.03, 77.27, 17.65)];
        [showBigPic setUserInteractionEnabled:YES];
        showBigPic.layer.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
        showBigPic.text=@"查看大图";
        showBigPic.tag=i;
        showBigPic.textColor=[UIColor whiteColor];
        showBigPic.font=[UIFont systemFontOfSize:12];
        showBigPic.textAlignment=NSTextAlignmentCenter;
        showBigPic.layer.cornerRadius=9;
        [theBook addSubview:showBigPic];
        
        UITapGestureRecognizer* clickClassPic=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showContent:)];
        [theBook addGestureRecognizer:clickClassPic];
        
        UITapGestureRecognizer* clickBigPic=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showBigPic:)];
        [showBigPic addGestureRecognizer:clickBigPic];
   }
}

-(void)showBigPic:(UITapGestureRecognizer*)sender{
    
    bigPicView=[[UIView alloc]initWithFrame:CGRectMake(0, 132.41, 414, 603.58)];
    theBigPic=nil;
    theBigPic=[[UIImageView alloc]initWithImage:[LocalDataOperation getImage:[[bookPicArray objectAtIndex:sender.view.tag]valueForKey:@"pictureId"] httpUrl:[[bookPicArray objectAtIndex:sender.view.tag]valueForKey:@"pictureUrl"]]];
    //NSLog(@"图片大小%@",NSStringFromCGSize(theBigPic.frame.size));
    
    UIScrollView* bigPicScroll=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 414, 603.58)];
    bigPicScroll.contentSize=CGSizeMake(530, 769);
    bigPicScroll.backgroundColor=[UIColor grayColor];
    [bigPicScroll addSubview:theBigPic];
    
    [bigPicView addSubview:bigPicScroll];
    
    UITapGestureRecognizer* clickBigPic=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(exitShowBigPic:)];
    [bigPicView addGestureRecognizer:clickBigPic];
    
    UILabel* exitShowBigPic=[[UILabel alloc]initWithFrame:CGRectMake(136.89, 29.79, 143.52, 26.48)];
    exitShowBigPic.layer.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
    exitShowBigPic.text=@"单击图片返回";
    exitShowBigPic.textColor=[UIColor whiteColor];
    exitShowBigPic.font=[UIFont systemFontOfSize:12];
    exitShowBigPic.textAlignment=NSTextAlignmentCenter;
    exitShowBigPic.layer.cornerRadius=9;
    [bigPicView addSubview:exitShowBigPic];
    
    [self.view addSubview: bigPicView];
}
-(void)exitShowBigPic:(UITapGestureRecognizer*)sender{
    [bigPicView removeFromSuperview];
}

//点击左侧图片显示内容
-(void)showContent:(UITapGestureRecognizer*)sender{
    //清空一下存放右侧内容单元的数组，不然会影响缩放显示
    [contentArray  removeAllObjects];
    //添加图片学习信息
    [ConnectionFunction addUserPictureMsg:[[bookPicArray objectAtIndex:sender.view.tag]valueForKey:@"pictureId"]
                                                        UserKey:[userInfo valueForKey:@"userKey"]];
    //NSLog(@"添加图片学习信息的值是%@",dataDic);
    //强转一下类型，不然出来的类型对不上
    NSString* page=[NSString stringWithFormat:@"%@",[[bookPicArray objectAtIndex:sender.view.tag]valueForKey:@"page"]];
    [contentDetailView removeFromSuperview];
    [self learningContent:page];
}

//内容界面
-(void)learningContent:(NSString*)page{
    contentDetailView=[[UIScrollView alloc]initWithFrame:CGRectMake(136.89, 0, 300, 603.58)];
    
    NSUInteger contentDetailHeight = 0;
    titleArray=[[NSMutableArray alloc]init];
    voiceArray=[[NSMutableArray alloc]init];
    for (NSDictionary* dic in sentenceArray) {
        if ([[NSString stringWithFormat:@"%@",[dic valueForKey:@"page"]]isEqualToString:page]) {
            [titleArray addObject:dic];
            [voiceArray addObject:dic];
        }
    }
    //添加滚动页面长度
    if (sentenceArray.count<8) {
        contentDetailHeight=600;
    }else{
        contentDetailHeight=titleArray.count*73+130;
        NSLog(@"页面长度是%lu",(unsigned long)contentDetailHeight);
        if (contentDetailHeight==130) {
            [self presentViewController:[WarningWindow MsgWithoutTrans:@"当前页面还没有句子！" ] animated:YES completion:nil];
        }
    }
    contentDetailView.contentSize=CGSizeMake(124, contentDetailHeight);
    [contentView addSubview:contentDetailView];
    
    for (int i=0; i<titleArray.count; i++) {
        NSDictionary* titleDic=titleArray[i];
        //内容的底板
        float y=15.44*(i+1)+57.37*i;
        content=[[UIView alloc]initWithFrame:CGRectMake(0, y, 256.12, 57.37)];
        content.layer.backgroundColor=[UIColor whiteColor].CGColor;
        content.layer.cornerRadius=10;
//        //打开button父组件的人机交互
//        [content setUserInteractionEnabled:YES];
        [contentDetailView addSubview:content];
        content.clipsToBounds = YES;
        
        //显示0/4
        UILabel* progressLabel=[[UILabel alloc]initWithFrame:CGRectMake(8.83, 4.41, 35.32, 15.44)];
        progressLabel.layer.cornerRadius=5;
        progressLabel.layer.backgroundColor=ssRGBHex(0x9B9B9B).CGColor;
        progressLabel.text=[NSString stringWithFormat:@"%d/%lu",(i+1),(unsigned long)titleArray.count];
        progressLabel.textAlignment=NSTextAlignmentCenter;
        progressLabel.font=[UIFont systemFontOfSize:10];
        progressLabel.textColor=[UIColor whiteColor];
        [content addSubview:progressLabel];
        
        //喇叭图标
        UIImageView* laba=[[UIImageView alloc]initWithFrame:CGRectMake(17.66, 32, 17.66, 16.55)];
        laba.image=[UIImage imageNamed:@"icon_laba"];
        [content addSubview:laba];
        
        //学习内容
        UILabel* title=[[UILabel alloc]initWithFrame:CGRectMake(46.36, 26.48, 200, 24.27)];
        title.text=[titleDic valueForKey:@"sentenceEng"];
        title.font=[UIFont systemFontOfSize:16];
        title.adjustsFontSizeToFitWidth =YES;
        [content addSubview:title];
        
        UILabel* translate=[[UILabel alloc]initWithFrame:CGRectMake(46.36, 59.58, 200, 24.27)];
        translate.text=[titleDic valueForKey:@"sentenceChn"];
        translate.font=[UIFont systemFontOfSize:16];
        translate.adjustsFontSizeToFitWidth =YES;
        [content addSubview:translate];
        
        
        
//        //添加各种按钮
//        UILabel* timeShow=[[UILabel alloc]initWithFrame:CGRectMake(15.45, 119.17, 33.1, 33.1)];
//        timeShow.layer.borderColor=ssRGBHex(0xFF7474).CGColor;
//        timeShow.layer.borderWidth=1;
//        timeShow.layer.cornerRadius=16.5;
//        timeShow.text=@"98";
//        timeShow.textAlignment=NSTextAlignmentCenter;
//        timeShow.textColor=ssRGBHex(0xFF7474);
//        timeShow.font=[UIFont systemFontOfSize:12];
//        [content addSubview:timeShow];
        
        UIButton* playBtn=[[UIButton alloc]initWithFrame:CGRectMake(40.51, 119.17, 33.1, 33.1)];
        [playBtn setBackgroundImage:[UIImage imageNamed:@"icon_play"] forState:UIControlStateNormal];
        [playBtn addTarget:self action:@selector(playRecordBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [content addSubview:playBtn];
        
        
        followReadBtn=[[UIButton alloc]initWithFrame:CGRectMake(90.40, 112.55, 136.89, 46.34)];
        followReadBtn.layer.backgroundColor=ssRGBHex(0xFF7474).CGColor;
        followReadBtn.layer.cornerRadius=5;
        [followReadBtn setTitle:@"我来跟读" forState:UIControlStateNormal];
        [followReadBtn setTitle:@"正在录音" forState:UIControlStateSelected];
        [followReadBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [followReadBtn setImage:[UIImage imageNamed:@"voice_light"] forState:UIControlStateNormal];
        [followReadBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, -10, 0.0, 0.0)];
        [followReadBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -10)];
        //录音按钮
        [followReadBtn addTarget:self action:@selector(startRecordBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        followReadBtn.tag=i;
        [content addSubview:followReadBtn];
        
        //添加点击事件
        clickRecognize=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickContent:)];
//        //r重写手势代理
        clickRecognize.delegate = self;
        [content addGestureRecognizer:clickRecognize];
        
        //把这些label加入数组中
        content.tag=i;
        [contentArray addObject:content];
    }
}
//点击内容展示收缩
-(void)clickContent:(UITapGestureRecognizer*)sender{
    
    //获取句子id
    NSInteger id=sender.view.tag;

    
    //因为下面为了标记扩大了tag值，在这里判断一下并修改回来
    if (id>=100) {
        id-=100;
    }
    
    //播放声音
    //音频播放空间分配
    //NSString* playUrl=[[[voiceArray objectAtIndex:id]valueForKey:@"engUrl"] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSString* playUrl=[[voiceArray objectAtIndex:id]valueForKey:@"engUrl"];
    playUrl=[playUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //播放句子路径是
    //NSLog(@"播放句子路径是%@",playUrl);
    voiceplayer=[[VoicePlayer alloc]init];
    voiceplayer.url=playUrl;
    [voiceplayer.audioStream play];
    
    //修改录音所用的句子id
    NSDictionary* dic=[sentenceArray objectAtIndex:id];
    recordingSentenceId=[dic valueForKey:@"sentenceId"];
    recordingSentenceId=[recordingSentenceId stringByAppendingString:@".caf"];
    NSLog(@"当前句子id是%@",recordingSentenceId);
    
    //添加句子学习信息记录
    NSString* sentenceId=[[titleArray objectAtIndex:id] valueForKey:@"sentenceId"];
    NSDictionary* dataDic=[ConnectionFunction addSentenceMsg:sentenceId UserKey:[userInfo valueForKey:@"userKey"]];
    NSLog(@"添加句子学习信息返回的数据是%@",dataDic);
    
    BOOL flag=YES;
    //遍历缩小其他控件
    for (UIView* label in contentArray) {
        
        if (label.tag>=100) {
            //1.获取原始的frame
            CGRect originFrame = label.frame;
            originFrame.origin.y-=110.34;
            label.frame = originFrame;
            label.tag=label.tag-100;
        }
    }

    
    for (UIView* label in contentArray) {
        //1.获取原始的frame
        CGRect originFrame = label.frame;
        //获取label中n/n的标签，一会用于变颜色
        UILabel* progressLabel=label.subviews[0];
        //找到点击的label
        if (sender.self.view.tag==label.tag) {
            //2.修改高
            //if语句防止多次点击时高度变化
            if (originFrame.size.height <=100) {
                originFrame.size.height += 110.34;
                //3.重新赋值
                label.frame = originFrame;
            }
            flag=false;
            //label.userInteractionEnabled=NO;
            //去除手势
            //[label removeGestureRecognizer:clickRecognize];
            progressLabel.layer.backgroundColor=ssRGBHex(0xFF7474).CGColor;
        }
        else{
            progressLabel.layer.backgroundColor=ssRGBHex(0x9B9B9B).CGColor;
            //非点击的按钮恢复原状态
            if (originFrame.size.height>=167.71) {
                originFrame.size.height -= 110.34;
                label.frame = originFrame;
                //使得他不可以再被点击
//                label.userInteractionEnabled=NO;
            }
            //label.userInteractionEnabled=YES;
            //恢复y坐标位置
            if (flag==false) {
                originFrame.origin.y+=110.34;
                label.frame = originFrame;
                label.tag=label.tag+100;
            }
        }
    
    }
    flag=true;
    
}

#pragma mark --setting

-(void)initSettingView{
    //整体灰色背景
    settingView=[[UIView alloc]initWithFrame:CGRectMake(0, 88.27, 414, 647.72)];
    settingView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    //上部分白色背景
    UILabel* settingLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 414, 236.13)];
    settingLabel.backgroundColor=[UIColor whiteColor];
    settingLabel.clipsToBounds = YES;
    [settingLabel setUserInteractionEnabled:YES];
    [settingView addSubview:settingLabel];
    
    //左侧标题数组
    NSArray* tagLabelArray=@[@"自动播放下句",@"播放时间间隔",@"播放中文语音",@"显示中文翻译",@"单句重复次数"];
    for (NSString* title in tagLabelArray) {
        float y=-4.413+22.06*([tagLabelArray indexOfObject:title]+1)+22.06*[tagLabelArray indexOfObject:title];
        UILabel* tagLabel=[[UILabel alloc]initWithFrame:CGRectMake(19.87, y, 92.73, 22.06)];
        tagLabel.text=title;
        tagLabel.font=[UIFont systemFontOfSize:14];
        [settingLabel addSubview:tagLabel];
    }
    
    //右侧label边框加载
    NSArray* btnWidth=@[@"168",@"252",@"168.01",@"168.02",@"252.01"];
    NSMutableArray* btnLabelArray=[[NSMutableArray alloc]init];
    for (NSString* x in btnWidth) {
        float y=-4.413+17.65*([btnWidth indexOfObject:x]+1)+26.48*[btnWidth indexOfObject:x];
        UILabel* btnLabel=[[UILabel alloc]initWithFrame:CGRectMake(134.68,y, x.floatValue, 26.48)];
        [settingLabel addSubview:btnLabel];
        btnLabel.layer.borderWidth=1;
        btnLabel.layer.borderColor=ssRGBHex(0xFF7474).CGColor;
        btnLabel.layer.cornerRadius=8;
        btnLabel.clipsToBounds = YES;
        [btnLabel setUserInteractionEnabled:YES];
        [btnLabelArray addObject:btnLabel];
    }

    //右侧按钮数组
    autoPlayNextBtnArray=[[NSMutableArray alloc]init];
    timeIntervalBtnArray=[[NSMutableArray alloc]init];
    playChineseBtnArray=[[NSMutableArray alloc]init];
    showTranslationBtnArray=[[NSMutableArray alloc]init];
    replayTimesBtnArray=[[NSMutableArray alloc]init];
    
    //下面三个方法为三种不同的选项添加按钮
    NSArray* openBtnArray=@[@"打开",@"关闭"];
    NSArray* addArray=@[@"0",@"2",@"3"];
    for (NSString* number in addArray) {
        for (NSString* title in openBtnArray) {
            float x=84*[openBtnArray indexOfObject:title];
            UIButton* openBtn=[[UIButton alloc]initWithFrame:CGRectMake(x, 0, 84, 26.48)];
            [openBtn setTitle:title forState:UIControlStateNormal];
            [openBtn setTitleColor:ssRGBHex(0xFF7474) forState:UIControlStateNormal];
            [openBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            openBtn.titleLabel.font=[UIFont systemFontOfSize:13];
            [[btnLabelArray objectAtIndex:number.intValue] addSubview:openBtn];
            if ([addArray indexOfObject:number]==0) {
                //把按钮加到对应的按钮数组中
                [autoPlayNextBtnArray addObject:openBtn];
                //0和1
                openBtn.tag=[openBtnArray indexOfObject:title];
                [openBtn addTarget:self action:@selector(actionOfAutoPlay:) forControlEvents:UIControlEventTouchUpInside];
            }
            if ([addArray indexOfObject:number]==1) {
                //把按钮加到对应的按钮数组中
                [playChineseBtnArray addObject:openBtn];
                //2和3
                openBtn.tag=[openBtnArray indexOfObject:title]+2;
                [openBtn addTarget:self action:@selector(actionOfPlayChinese:) forControlEvents:UIControlEventTouchUpInside];
            }
            if ([addArray indexOfObject:number]==2) {
                //把按钮加到对应的按钮数组中
                [showTranslationBtnArray addObject:openBtn];
                //4和5
                openBtn.tag=[openBtnArray indexOfObject:title]+4;
                [openBtn addTarget:self action:@selector(actionOfShowTranslation:) forControlEvents:UIControlEventTouchUpInside];
            }
        
        }
    }
    
    NSArray* secondBtnArray=@[@"1s",@"2s",@"3s"];
    for (NSString* title in secondBtnArray) {
        float x=84*[secondBtnArray indexOfObject:title];
        UIButton* secondBtn=[[UIButton alloc]initWithFrame:CGRectMake(x, 0, 84, 26.48)];
        [secondBtn setTitle:title forState:UIControlStateNormal];
        [secondBtn setTitleColor:ssRGBHex(0xFF7474) forState:UIControlStateNormal];
        [secondBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        secondBtn.titleLabel.font=[UIFont systemFontOfSize:13];
        secondBtn.tag=[secondBtnArray indexOfObject:title];
        [[btnLabelArray objectAtIndex:1] addSubview:secondBtn];
        [timeIntervalBtnArray addObject:secondBtn];
        [secondBtn addTarget:self action:@selector(actionOfTimeInterval:) forControlEvents:UIControlEventTouchUpInside];
    }

    NSArray* timesBtnArray=@[@"1遍",@"2遍",@"3遍"];
    for (NSString* title in timesBtnArray) {
        float x=84*[timesBtnArray indexOfObject:title];
        UIButton* timesBtn=[[UIButton alloc]initWithFrame:CGRectMake(x, 0, 84, 26.48)];
        [timesBtn setTitle:title forState:UIControlStateNormal];
        [timesBtn setTitleColor:ssRGBHex(0xFF7474) forState:UIControlStateNormal];
        [timesBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        timesBtn.titleLabel.font=[UIFont systemFontOfSize:13];
        timesBtn.tag=[timesBtnArray indexOfObject:title];
        [[btnLabelArray objectAtIndex:4] addSubview:timesBtn];
        [replayTimesBtnArray addObject:timesBtn];
        [timesBtn addTarget:self action:@selector(actionOfReplayTimes:) forControlEvents:UIControlEventTouchUpInside];
    }
}
-(void)defaultSettings{
    NSString* flag=[[NSString alloc]init];
    flag=@"1";
    UIButton* btn1=[autoPlayNextBtnArray objectAtIndex:flag.intValue];
    btn1.selected=true;
    flag=[settingArray objectAtIndex:1];
    UIButton* btn2=[timeIntervalBtnArray objectAtIndex:flag.intValue];
    btn2.selected=true;
    flag=[settingArray objectAtIndex:2];
    UIButton* btn3=[playChineseBtnArray objectAtIndex:0];
    btn3.selected=true;
    flag=[settingArray objectAtIndex:3];
    UIButton* btn4=[showTranslationBtnArray objectAtIndex:flag.intValue];
    btn4.selected=true;
    flag=[settingArray objectAtIndex:4];
    UIButton* btn5=[replayTimesBtnArray objectAtIndex:flag.intValue];
    btn5.selected=true;
}
-(void)defaultSettingsShow{
    for (UIButton* btn in autoPlayNextBtnArray) {
        if (btn.selected) {
            btn.backgroundColor=ssRGBHex(0xFF7474);
        }
    }
    for (UIButton* btn in timeIntervalBtnArray) {
        if (btn.selected) {
            btn.backgroundColor=ssRGBHex(0xFF7474);
        }
    }
    for (UIButton* btn in playChineseBtnArray) {
        if (btn.selected) {
            btn.backgroundColor=ssRGBHex(0xFF7474);
        }
    }
    for (UIButton* btn in showTranslationBtnArray) {
        if (btn.selected) {
            btn.backgroundColor=ssRGBHex(0xFF7474);
        }
    }
    for (UIButton* btn in replayTimesBtnArray) {
        if (btn.selected) {
            btn.backgroundColor=ssRGBHex(0xFF7474);
        }
    }
    
}

//点击各种设置的处理函数
-(void)actionOfAutoPlay:(UIButton*)btn{
    for (UIButton* button in autoPlayNextBtnArray) {
        if(button.tag==btn.tag){
            button.selected=true;
            button.backgroundColor=ssRGBHex(0xFF7474);
            continue;
        }
        button.selected=false;
        button.backgroundColor=[UIColor whiteColor];
    }
}
-(void)actionOfTimeInterval:(UIButton*)btn{
    for (UIButton* button in timeIntervalBtnArray) {
        if(button.tag==btn.tag){
            button.selected=true;
            button.backgroundColor=ssRGBHex(0xFF7474);
            continue;
        }
        button.selected=false;
        button.backgroundColor=[UIColor whiteColor];
    }
}
-(void)actionOfPlayChinese:(UIButton*)btn{
    for (UIButton* button in playChineseBtnArray) {
        if(button.tag==btn.tag){
            button.selected=true;
            button.backgroundColor=ssRGBHex(0xFF7474);
            continue;
        }
        button.selected=false;
        button.backgroundColor=[UIColor whiteColor];
    }
}
-(void)actionOfShowTranslation:(UIButton*)btn{
    for (UIButton* button in showTranslationBtnArray) {
        if(button.tag==btn.tag){
            button.selected=true;
            button.backgroundColor=ssRGBHex(0xFF7474);
            continue;
        }
        button.selected=false;
        button.backgroundColor=[UIColor whiteColor];
    }
}
-(void)actionOfReplayTimes:(UIButton*)btn{
    for (UIButton* button in replayTimesBtnArray) {
        if(button.tag==btn.tag){
            button.selected=true;
            button.backgroundColor=ssRGBHex(0xFF7474);
            continue;
        }
        button.selected=false;
        button.backgroundColor=[UIColor whiteColor];
    }
}

//显示设置界面、显示选择课程界面相应函数
-(void)showSettingView{
    if (settingShow) {
        [self.view addSubview:settingView];
        
    }else{
        [settingView removeFromSuperview];
    }
    settingShow=!settingShow;
    
}
#pragma mark --下拉按钮
//点击下拉按钮
-(void)showChooseLessonView{
    if (chooseLessonShow) {
        [self.view addSubview:chooseLessonView];
    }else{
        if (chooseLessonView.unitName!=nil&&chooseLessonView.className!=nil) {
            lessonArray=chooseLessonView.lessonArray;
            //classid：在这个dataArray中很多字典中都可以返回id，此处拿其中一个字典：bookSentences
            [self showContent:[chooseLessonView.dataArray valueForKey:@"bookPictures"]
                     senArray:[chooseLessonView.dataArray valueForKey:@"bookSentences"]
                      classId:[[[chooseLessonView.dataArray valueForKey:@"bookSentences"]objectAtIndex:0] valueForKey:@"articleId"]
                     unitName:chooseLessonView.unitName
                    className:chooseLessonView.className]; 
            
        }else{
            [chooseLessonView removeFromSuperview];
        }
        
    }
    chooseLessonShow=!chooseLessonShow;
    //button.selected=!button.selected;
    
}
//点击收起按钮，显示内容
-(void)showContent:(NSArray*)bookpicarray senArray:(NSArray*)sentencearray classId:(NSString*)classid unitName:(NSString*)unitname className:(NSString*)classname{
    
    //刷新内容界面
    [contentView removeFromSuperview];
    [contentArray  removeAllObjects];
    //刷新音频数组
    [voiceArray removeAllObjects];
    //收起菜单
    [chooseLessonView removeFromSuperview];
    
    bookPicArray=bookpicarray;
    sentenceArray=sentencearray;
    //NSLog(@"语句数组的内容是%@",sentenceArray);
    classId=classid;
    unitName=unitname;
    className=classname;
    //NSDictionary * dataDic=
    NSDictionary* buyState=[ConnectionFunction articleBuyState:chooseLessonView.articleId UserKey:[userInfo valueForKey:@"userKey"]];
//    NSLog(@"课程购买状态%@",buyState);
//    NSLog(@"课程状态%@",[buyState valueForKey:@"data"]);
    //判断字典内容为空
    if ([[buyState valueForKey:@"data"] isKindOfClass:[NSNull class]]) {
        NSLog(@"您还未购买该课程");
        [self presentViewController:[self warnWindow:@"您还未购买该课程，购买该课程需要100学分！"] animated:YES completion:nil];
    }else{
        //添加学习进度信息
        //加载gif动画
        UIImageView* loadPic=[LoadGif imageViewStartAnimating:CGRectMake(177, 300, 60, 60)];
        [self.view addSubview:loadPic];
        
        NSDictionary* dataDic=[ConnectionFunction addUserArticleMsg:chooseLessonView.articleId UserKey:[userInfo valueForKey:@"userKey"]];
        NSLog(@"添加课程学习信息返回的是%@",dataDic);
        [lessontitle removeFromSuperview];
        
        [self presentLessionView];
        [self learningBook];
        
        //加载完成，移除gif
        [loadPic removeFromSuperview];
    }
    
    

    
}
#pragma mark 用户提示框
-(UIAlertController*)warnWindow:(NSString*)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示信息" message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"购买" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        int score=[[[ConnectionFunction getScore:[self->userInfo valueForKey:@"userKey"]]valueForKey:@"data"]intValue];
        //NSLog(@"学分是%@",[ConnectionFunction getScore:[self->userInfo valueForKey:@"userKey"]]);
        if (score>=100) {
            //添加学习进度信息
            NSDictionary* dataDic=[ConnectionFunction addUserArticleMsg:self->chooseLessonView.articleId UserKey:[self->userInfo valueForKey:@"userKey"]];
            NSLog(@"添加课程学习信息返回的是%@",dataDic);
            [self->lessontitle removeFromSuperview];
            
            [self presentLessionView];
            [self learningBook];
        }
        else{
            [self presentViewController:[WarningWindow MsgWithoutTrans:@"您的学分不足，请充值！"] animated:YES completion:nil];
        }

        
        
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:action1];
    [alert addAction:action2];
    
    return alert;
}

#pragma mark --chooseLesson
-(void)chooseLessonViewInit{
    
    chooseLessonView=[[ChooseLessonView alloc]initWithFrame:CGRectMake(0, 132.41, 414, 603.58) bookId:_bookId DefaultUnit:_defaultUnit];
    
}
-(void)popBack{
    [self.navigationController popViewControllerAnimated:true];
}

#pragma mark - record
//存放录音文件路径
- (NSString *)getFilePathWithFileName:(NSString *)fileName{
    NSString * filePath = [DocuOperate documentsDirectory];
    filePath = [filePath stringByAppendingPathComponent:fileName];
   
    return filePath;
}
//开始录音和停止录音
-(void)startRecordBtnAction:(UIButton*)btn{
    //手动停止录音
//    if (!isRecord) {
//        NSLog(@"开始录音");
//        //转换为录音状态
//        isRecord=true;
//        //设置手势点击任何一点结束录音
//        [followReadBtn setEnabled:NO];
//        stopRecordTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(stopRecord:)];
//        stopRecordTap.cancelsTouchesInView=NO;
//        [self.view addGestureRecognizer:stopRecordTap];
//
//        recordingSentenceId=[[sentenceArray objectAtIndex:btn.tag]valueForKey:@"sentenceId"];
//        recordingSentenceId=[recordingSentenceId stringByAppendingString:@".caf"];
//
//        [[AudioRecorder shareInstance] startRecordWithFilePath:[self getFilePathWithFileName:recordingSentenceId]];
//        [[AudioRecorder shareInstance] setRecorderDelegate:self];
//
//    }else{
//        //self.progressView.progress = 0;
//        [[AudioRecorder shareInstance] stopRecord];
//        [self.view endEditing:YES];
//        isRecord=false;
//    }
    
    //下面是根据网络给的，使得录音声音大一点
    NSError *audioError = nil;
    BOOL success = [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&audioError];
    if(!success)
      {
         NSLog(@"error doing outputaudioportoverride - %@", [audioError localizedDescription]);
       }
    //==================
    
    NSLog(@"开始录音");
    [followReadBtn setUserInteractionEnabled:NO];
    recordingSentenceId=[[sentenceArray objectAtIndex:btn.tag]valueForKey:@"sentenceId"];
    recordingSentenceId=[recordingSentenceId stringByAppendingString:@".caf"];

    if ([DocuOperate fileExistInPath:recordingSentenceId]) {
        [DocuOperate deleteFileInDocuments:recordingSentenceId];
        NSLog(@"删除声音文件%@",recordingSentenceId);
    }
    [[AudioRecorder shareInstance] startRecordWithFilePath:[self getFilePathWithFileName:recordingSentenceId]];
    [[AudioRecorder shareInstance] setRecorderDelegate:self];
    
    //自动停止录音
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(stopRecord) userInfo:nil repeats:NO];

}

//停止录音
-(void)stopRecord:(UITapGestureRecognizer*)tap{
    NSLog(@"结束录音");
    //self.progressView.progress = 0;
    [[AudioRecorder shareInstance] stopRecord];
    [self.view removeGestureRecognizer:stopRecordTap];
    [self.view endEditing:YES];
    isRecord=false;
    [followReadBtn setUserInteractionEnabled:YES];
}
//停止录音
-(void)stopRecord{
    NSLog(@"结束录音了");
    //self.progressView.progress = 0;
    [[AudioRecorder shareInstance] stopRecord];
    isRecord=false;
    [followReadBtn setEnabled:YES];
}
//播放录音声音
-(void)playRecordBtnAction{
//    NSLog(@"播放声音");
//    //由于录音配置那里设置了是pcm，avaudioplayer播放器是播放不了的，需要加头部变成wav才能播放，此处不使用avaudioplayer
//    //直接使用系统铃声的接口播放录音，30秒内还是可以播放的,不过要第二次运行才出声音，原因未明
//    NSLog(@"录音文件名%@",recordingSentenceId);
//    NSURL * url = [NSURL fileURLWithPath:[self getFilePathWithFileName:recordingSentenceId]];
//    SystemSoundID soundID;
//    /*根据声音的路径创建ID    （__bridge在两个框架之间强制转换类型，值转换内存，不修改内存管理的
//     权限）在转换数据类型的时候，不希望该对象的内存管理权限发生改变，原来是MRC类型，转换了还是 MRC。*/
//    AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(url), &soundID);
//    //播放音频
//    AudioServicesPlayAlertSound(soundID);
//    //添加震动，只有在iphone上才可以，模拟器没有效果。
//    //    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    /* 初始化url */
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //默认情况下扬声器播放
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    
    NSURL *url = [[NSURL alloc] initFileURLWithPath:[self getFilePathWithFileName:recordingSentenceId]];
    
    /* 初始化音频文件 */
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    
    /* 加载缓冲 */
    [self.player prepareToPlay];
    //设置声音的大小
    self.player.volume = 0.7;
    NSLog(@"当前播放的音量是：%f",self.player.volume);//范围为（0到1）；
    
    
    
    //震动
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self.player play];
}
-(void)dealloc{
    NSLog(@"我被销毁了");
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    // 判断是不是UIButton的类
    if ([touch.view isKindOfClass:[UIButton class]])
    {
        return NO;
    }
    else
    {
        return YES;
    }
    //方法二，判断点击的位置
    //CGPoint location = [touch locationInView:self.view];
    /*
     if(CGRectContainsPoint(self.btn.frame, location))
     {
     [self GoOtherView:nil];
     return NO;
     }else{
     return YES;
     }
     */
    
}

@end
