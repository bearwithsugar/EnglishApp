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
#import "Functions/DownloadAudioService.h"
#import "Functions/MyThreadPool.h"
#import "Masonry.h"

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
//    NSMutableArray* timeIntervalBtnArray;
//    NSMutableArray* playChineseBtnArray;
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
    UIScrollView* contentDetailScrollView;
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
    
    //喇叭图标
    UIImageView* laba;
    
    //setting=======
    //播放次数
    NSInteger playTimes;
    
    //中文翻译
    NSMutableArray* translateLabelArray;
    //中文翻译是否隐藏
    BOOL translateIsHided;
    //连续播放下句
    BOOL continuePlay;
    
    UIImageView* loadPic;
    
}
//@property (nonatomic,strong) IBOutlet UIProgressView *progressView;

@property(nonatomic,strong)AVAudioPlayer *movePlayer ;
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
    
//    contentDetailScrollView=[[UIScrollView alloc]init];
//    [contentView addSubview:contentDetailScrollView];
    
    [self showChooseLessonView];
    
    //录音所用
    //self.progressView.progress = 0;
    translateIsHided = NO;
    continuePlay = NO;
    
  
}
-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"获取到的单元id是%@",_unitId);
}
-(void)titleShow{
    UILabel* title=[[UILabel alloc]init];
    title.text=_bookName;
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
        make.top.equalTo(title).with.offset(15);
        make.left.equalTo(title).with.offset(5);
        make.width.equalTo(@35);
        make.height.equalTo(@35);
    }];
    
    UIButton* returnBtn=[[UIButton alloc]init];
    [returnBtn setBackgroundImage:[UIImage imageNamed:@"icon_return_ffffff"] forState:UIControlStateNormal];
    [returnBtn setBackgroundImage:[UIImage imageNamed:@"icon_return_ffffff"] forState:UIControlStateHighlighted];
    [returnBtn addTarget:self action:@selector(popBack) forControlEvents:UIControlEventTouchUpInside];
    [touchField addSubview:returnBtn];
    
    [returnBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(touchField).with.offset(10);
        make.left.equalTo(touchField).with.offset(7);
        make.width.equalTo(@11);
        make.height.equalTo(@22.6);
    }];
    
    UITapGestureRecognizer* touchFunc=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(popBack)];
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
//选择课程的上一课下一课
-(void)chooseLesson{
    presentLession=[[UIView alloc]init];
    presentLession.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:presentLession];
    
    [presentLession mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(88);
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
        make.left.equalTo(self->presentLession).with.offset(12.14);
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
    [nextLessonLabel addTarget:self action:@selector(clickNextLesson) forControlEvents:UIControlEventTouchUpInside];
    [nextLessonLabel setTitle:@"下一课" forState:UIControlStateNormal];
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
    }else{
        if(!lessonArray || lessonArray.count == 0){
            lessonArray=chooseLessonView.lessonArray;
        }
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
    if (classId==nil) {
        NSLog(@"请先选择课程");
    }else{
        if(!lessonArray || lessonArray.count == 0){
            lessonArray=chooseLessonView.lessonArray;
        }
        if ([classId isEqualToString:
             [[lessonArray objectAtIndex:(lessonArray.count-1)]valueForKey:@"articleId"]
             ]){
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
    
    [presentLession addSubview:lessontitle];
    
    [lessontitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->presentLession).with.offset(7.72);
        make.left.equalTo(self->presentLession).with.offset(95);
        make.right.equalTo(self->presentLession).with.offset(-95);
        make.height.equalTo(@28.68);
    }];
    
    UITapGestureRecognizer* showLineGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showChooseLessonView)];
    [lessontitle addGestureRecognizer:showLineGesture];
}
//左侧显示书封面
-(void)learningBook{
    NSUInteger size=bookPicArray.count;
    
    contentView=[[UIView alloc]init];
    [self.view addSubview:contentView];
    
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(132.41);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    bookPicView=[[UIScrollView alloc]init];
    NSUInteger bookPicViewHeight;
    if (size<4) {
        bookPicViewHeight=700;
    }else{
        bookPicViewHeight=size*184+20;
    }
    bookPicView.contentSize=CGSizeMake(124, bookPicViewHeight);
    [contentView addSubview:bookPicView];
    
    [bookPicView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->contentView);
        make.left.equalTo(self->contentView);
        make.width.equalTo(@124);
        make.bottom.equalTo(self->contentView);
    }];
    
    for (int i=0;i<size; i++) {
        float y=19.86+183.17*i;
        float x=13.24;
        UIImageView* theBook=[[UIImageView alloc]initWithFrame:CGRectMake(x,y, 110, 172)];
        [theBook setUserInteractionEnabled:YES];
        theBook.tag=i;
        
        UILabel* showBigPic=[[UILabel alloc]initWithFrame:CGRectMake(16.55, 11.03, 77.27, 17.65)];
        [showBigPic setUserInteractionEnabled:YES];
        showBigPic.layer.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
        showBigPic.text=@"查看大图";
        showBigPic.tag=i;
        showBigPic.textColor=[UIColor whiteColor];
        showBigPic.font=[UIFont systemFontOfSize:12];
        showBigPic.textAlignment=NSTextAlignmentCenter;
        showBigPic.layer.cornerRadius=9;
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{

            NSDictionary* bookDic=[self->bookPicArray objectAtIndex:i];
            NSString* picUrl=[bookDic valueForKey:@"pictureUrl"];
            //        //路径中有特殊字符，转换一下
            picUrl=[picUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            UIImage* image = [LocalDataOperation getImage:[bookDic valueForKey:@"pictureId"] httpUrl:picUrl];
            
            dispatch_async(dispatch_get_main_queue(), ^{

                theBook.image= image;
                 [theBook addSubview:showBigPic];
                 [self->bookPicView addSubview:theBook];
                
                UITapGestureRecognizer* clickClassPic=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showContent:)];
                [theBook addGestureRecognizer:clickClassPic];
                
                UITapGestureRecognizer* clickBigPic=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showBigPicGesture:)];
                [showBigPic addGestureRecognizer:clickBigPic];
                if (theBook.tag==(size-1)) {
                    [self->loadPic removeFromSuperview];
                }
            });
        });
   }
}

-(void)showBigPicGesture:(UITapGestureRecognizer*)sender{
    
    [self showBigPic:sender.view.tag];
}
-(void)showBigPic:(NSInteger)tag{
    bigPicView=[[UIView alloc]init];
    theBigPic=nil;
    theBigPic=[[UIImageView alloc]init];
    theBigPic.image=[LocalDataOperation getImage:[[bookPicArray objectAtIndex:tag]valueForKey:@"pictureId"]
                                         httpUrl:[[bookPicArray objectAtIndex:tag]valueForKey:@"pictureUrl"]];
    
    [bigPicView addSubview:theBigPic];
    
    [theBigPic mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self->bigPicView);
    }];
    
    UITapGestureRecognizer* clickBigPic=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(exitShowBigPic:)];
    [bigPicView addGestureRecognizer:clickBigPic];
    
    UILabel* exitShowBigPic=[[UILabel alloc]init];
    exitShowBigPic.layer.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
    exitShowBigPic.text=@"单击图片返回";
    exitShowBigPic.textColor=[UIColor whiteColor];
    exitShowBigPic.font=[UIFont systemFontOfSize:12];
    exitShowBigPic.textAlignment=NSTextAlignmentCenter;
    exitShowBigPic.layer.cornerRadius=9;
    [bigPicView addSubview:exitShowBigPic];
    
    [theBigPic mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->bigPicView).with.offset(30);
        make.centerX.equalTo(self->bigPicView);
        make.height.equalTo(@27);
        make.width.equalTo(@150);
    }];
    
    [self.view addSubview: bigPicView];
    
    [bigPicView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(132.41);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}
-(void)exitShowBigPic:(UITapGestureRecognizer*)sender{
    [bigPicView removeFromSuperview];
}

//点击左侧图片显示内容
-(void)showContent:(UITapGestureRecognizer*)sender{
    //清空一下存放右侧内容单元的数组，不然会影响缩放显示
    [contentArray  removeAllObjects];
    
    //注意异步！
    //添加图片学习信息
    [ConnectionFunction addUserPictureMsg:[[bookPicArray objectAtIndex:sender.view.tag]valueForKey:@"pictureId"]
                                                        UserKey:[userInfo valueForKey:@"userKey"]];
    //强转一下类型，不然出来的类型对不上
    NSString* page=[NSString stringWithFormat:@"%@",[[bookPicArray objectAtIndex:sender.view.tag]valueForKey:@"page"]];
    [contentDetailScrollView removeFromSuperview];
    [self learningContent:page PicTag:sender.view.tag];
}

//内容界面
-(void)learningContent:(NSString*)page PicTag:(NSInteger)picTag{
    contentDetailScrollView=[[UIScrollView alloc]init];
    
    NSUInteger contentDetailHeight = 0;
    titleArray=[[NSMutableArray alloc]init];
    voiceArray=[[NSMutableArray alloc]init];
    translateLabelArray = [[NSMutableArray alloc]init];
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
            //[self presentViewController:[WarningWindow MsgWithoutTrans:@"当前页面还没有句子！" ] animated:YES completion:nil];
            //如果没有句子显示大图
            [self showBigPic:picTag];
        }
    }
    [contentView addSubview:contentDetailScrollView];
    
    [contentDetailScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->contentView);
        make.left.equalTo(self->contentView).with.offset(136);
        make.bottom.equalTo(self->contentView);
        make.right.equalTo(self->contentView).with.offset(-20);
    }];
    
    for (int i=0; i<titleArray.count; i++) {
        NSDictionary* titleDic=titleArray[i];
        //内容的底板
        float y=15.44*(i+1)+57.37*i;
        content=[[UIView alloc]init];
        content.layer.backgroundColor=[UIColor whiteColor].CGColor;
        content.layer.cornerRadius=10;
        [contentDetailScrollView addSubview:content];
        
        [content mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self->contentDetailScrollView).offset(y);
            make.left.equalTo(self->contentDetailScrollView.mas_left);
            make.right.equalTo(self->contentDetailScrollView.mas_right);
            make.width.equalTo(self->contentDetailScrollView.mas_width);
            make.height.equalTo(@58);
        }];
        
        content.clipsToBounds = YES;
        
        //显示0/4
        UILabel* progressLabel=[[UILabel alloc]init];
        progressLabel.layer.cornerRadius=5;
        progressLabel.layer.backgroundColor=ssRGBHex(0x9B9B9B).CGColor;
        progressLabel.text=[NSString stringWithFormat:@"%d/%lu",(i+1),(unsigned long)titleArray.count];
        progressLabel.textAlignment=NSTextAlignmentCenter;
        progressLabel.font=[UIFont systemFontOfSize:10];
        progressLabel.textColor=[UIColor whiteColor];
        [content addSubview:progressLabel];
        
        [progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self->content).with.offset(4.41);
            make.left.equalTo(self->content).with.offset(8.83);
            make.height.equalTo(@15.44);
            make.width.equalTo(@35.32);
        }];

        
        //喇叭图标
        laba=[[UIImageView alloc]initWithFrame:CGRectMake(17.66, 32, 17.66, 16.55)];
        laba.image=[UIImage imageNamed:@"icon_laba2"];
        [content addSubview:laba];
        

        
        //学习内容
        UILabel* title=[[UILabel alloc]init];
        title.text=[titleDic valueForKey:@"sentenceEng"];
        title.font=[UIFont systemFontOfSize:16];
        title.adjustsFontSizeToFitWidth =YES;
        [content addSubview:title];
        
        [title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self->content).with.offset(26.48);
            make.left.equalTo(self->content).with.offset(46.36);
            make.height.equalTo(@24.27);
            make.right.equalTo(self->content);
        }];
        
        UILabel* translateLabel=[[UILabel alloc]initWithFrame:CGRectMake(46.36, 59.58, 200, 24.27)];
        translateLabel.text=[titleDic valueForKey:@"sentenceChn"];
        translateLabel.font=[UIFont systemFontOfSize:16];
        translateLabel.adjustsFontSizeToFitWidth =YES;
        [translateLabelArray addObject:translateLabel];
        if (!translateIsHided) {
            [content addSubview:translateLabel];
            
            [translateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self->content).with.offset(59.58);
                make.left.equalTo(self->content).with.offset(46.36);
                make.height.equalTo(@24.27);
                make.right.equalTo(self->content);
            }];
        }
        
        UIButton* playBtn=[[UIButton alloc]init];
        [playBtn setBackgroundImage:[UIImage imageNamed:@"icon_play"] forState:UIControlStateNormal];
        [playBtn addTarget:self action:@selector(playRecordBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [content addSubview:playBtn];
        
        [playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self->content).with.offset(120);
            make.left.equalTo(self->content).with.offset(40.51);
            make.height.equalTo(@33);
            make.width.equalTo(@33);
        }];
        
        
        followReadBtn=[[UIButton alloc]init];
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
        
        [followReadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self->content).with.offset(112.5);
            make.left.equalTo(self->content).with.offset(90);
            make.height.equalTo(@46);
            make.width.equalTo(@140);
        }];
        
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
    
    //修改录音所用的句子id
    NSDictionary* dic=[sentenceArray objectAtIndex:id];
    recordingSentenceId=[dic valueForKey:@"sentenceId"];
    recordingSentenceId=[recordingSentenceId stringByAppendingString:@".caf"];
    NSLog(@"当前句子id是%@",recordingSentenceId);
   
    VoidBlock addLearnMsg = ^{
        
        //添加句子学习信息记录
        
        NSString* sentenceId=[[self->titleArray objectAtIndex:id] valueForKey:@"sentenceId"];
        
        NSDictionary* dataDic=[ConnectionFunction addSentenceMsg:sentenceId UserKey:[self->userInfo valueForKey:@"userKey"]];
        
        NSLog(@"添加句子学习信息返回的数据是%@",dataDic);
        
    };

    [MyThreadPool executeJob:addLearnMsg Main:^{}];
    
    VoidBlock playBlock;
    
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

    VoidBlock myblock;
    
    for (UIView* label in contentArray) {
        //1.获取原始的frame
        CGRect originFrame = label.frame;
        //获取label中n/n的标签，一会用于变颜色
        UILabel* progressLabel=label.subviews[0];
        
        //获取喇叭图标
        UIView* labaView ;
        
        for (UIView* childView in label.subviews) {
            if ([childView isKindOfClass: [UIImageView class]]) {
                //获取喇叭图标
                labaView = childView;
            }
        }
        
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
    
            progressLabel.layer.backgroundColor=ssRGBHex(0xFF7474).CGColor;
            
            //把喇叭换成动图
            [labaView removeFromSuperview];
            UIImageView* labaWithLoop = [LoadGif imageViewfForPlaying];
            [label addSubview:labaWithLoop];
            [labaWithLoop mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(label).with.offset(32);
                make.left.equalTo(label).with.offset(17.66);
                make.width.equalTo(@17.66);
                make.height.equalTo(@16.55);
            }];
            
            myblock = ^{
                NSLog(@"播放完成");
                [labaWithLoop removeFromSuperview];
                [label addSubview:labaView];
            };
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
    
    //播放声音
    //音频播放空间分配
    
    playBlock =^{
        NSString* playUrl=[DownloadAudioService getAudioPath:
                           [NSString stringWithFormat:@"%@",[[self->voiceArray objectAtIndex:id]valueForKey:@"id"]]];
        if (self->voiceplayer!=NULL) {
            [self->voiceplayer interruptPlay];
            self->voiceplayer = NULL;
        }
        
        self->voiceplayer=[[VoicePlayer alloc]init];
        self->voiceplayer.url = playUrl;
        self->voiceplayer.myblock = myblock;
        [self->voiceplayer playAudio:self->playTimes];
        if (self->continuePlay) {
            self->voiceplayer.urlArray = self->voiceArray;
            self->voiceplayer.startIndex = id+1;
        }
    };
    
    [MyThreadPool executeJob:playBlock Main:^{}];
    
    flag=true;
    
}

#pragma mark --setting

-(void)initSettingView{
    //整体灰色背景
    settingView=[[UIView alloc]init];
    settingView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    //上部分白色背景
    UILabel* settingLabel=[[UILabel alloc]init];
    settingLabel.backgroundColor=[UIColor whiteColor];
    settingLabel.clipsToBounds = YES;
    [settingLabel setUserInteractionEnabled:YES];
    [settingView addSubview:settingLabel];
    
    [settingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->settingView);
        make.left.equalTo(self->settingView);
        make.right.equalTo(self->settingView);
        make.height.equalTo(@180);
    }];
    
    //左侧标题数组  ,@"播放时间间隔",@"播放中文语音"
    NSArray* tagLabelArray=@[@"自动播放下句",@"显示中文翻译",@"单句重复次数"];
    for (NSString* title in tagLabelArray) {
        float y=-4.413+22.06*([tagLabelArray indexOfObject:title]+1)+22.06*[tagLabelArray indexOfObject:title];
        UILabel* tagLabel=[[UILabel alloc]init];
        tagLabel.text=title;
        tagLabel.font=[UIFont systemFontOfSize:14];
        [settingLabel addSubview:tagLabel];
        
        [tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(settingLabel).with.offset(y);
            make.centerX.equalTo(settingLabel).with.offset(-120);
            make.width.equalTo(@100);
            make.height.equalTo(@22);
        }];
    }
    
    //右侧label边框加载,@"252" ,@"168.01"
    NSArray* btnWidth=@[@"168",@"168.02",@"252.01"];
    NSMutableArray* btnLabelArray=[[NSMutableArray alloc]init];
    for (NSString* x in btnWidth) {
        float y=-4.413+17.65*([btnWidth indexOfObject:x]+1)+26.48*[btnWidth indexOfObject:x];
        UILabel* btnLabel=[[UILabel alloc]init];
        [settingLabel addSubview:btnLabel];
        btnLabel.layer.borderWidth=1;
        btnLabel.layer.borderColor=ssRGBHex(0xFF7474).CGColor;
        btnLabel.layer.cornerRadius=8;
        btnLabel.clipsToBounds = YES;
        [btnLabel setUserInteractionEnabled:YES];
        [btnLabelArray addObject:btnLabel];
        
        [btnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(settingLabel).with.offset(y);
            make.centerX.equalTo(settingLabel).with.offset(50);
            make.width.equalTo(@(x.floatValue));
            make.height.equalTo(@26.48);
        }];
    }

    //右侧按钮数组
    autoPlayNextBtnArray=[[NSMutableArray alloc]init];
    showTranslationBtnArray=[[NSMutableArray alloc]init];
    replayTimesBtnArray=[[NSMutableArray alloc]init];
    
    //下面三个方法为三种不同的选项添加按钮
    NSArray* openBtnArray=@[@"打开",@"关闭"];
    NSArray* addArray=@[@"0",@"1"];
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
                [showTranslationBtnArray addObject:openBtn];
                //4和5
                openBtn.tag=[openBtnArray indexOfObject:title]+4;
                [openBtn addTarget:self action:@selector(actionOfShowTranslation:) forControlEvents:UIControlEventTouchUpInside];
            }

        }
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
        [[btnLabelArray objectAtIndex:2] addSubview:timesBtn];
        [replayTimesBtnArray addObject:timesBtn];
        [timesBtn addTarget:self action:@selector(actionOfReplayTimes:) forControlEvents:UIControlEventTouchUpInside];
    }
}
-(void)defaultSettings{
    NSString* flag=[[NSString alloc]init];
    flag=@"1";
    UIButton* btn1=[autoPlayNextBtnArray objectAtIndex:flag.intValue];
    btn1.selected=true;
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
    for (UIButton* btn in showTranslationBtnArray) {
        if (btn.selected) {
            btn.backgroundColor=ssRGBHex(0xFF7474);
        }
    }
    for (UIButton* btn in replayTimesBtnArray) {
        if (btn.selected) {
            btn.backgroundColor=ssRGBHex(0xFF7474);
            playTimes = btn.tag;
        }
    }
    
}

//点击各种设置的处理函数
-(void)actionOfAutoPlay:(UIButton*)btn{
    if (btn.tag == 0) {
        continuePlay = YES;
    }else{
        continuePlay = NO;
    }
    
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
    if (translateLabelArray.count!=0) {
        if (btn.tag == 5) {
            for (UILabel* label in translateLabelArray) {
                [label removeFromSuperview];
            }
            translateIsHided = YES;
        }else{
            for (int i = 0; i < contentArray.count ; i++) {
                UIView *view = [contentArray objectAtIndex:i];
                [view addSubview:[translateLabelArray objectAtIndex:i]];
            }
            translateIsHided = NO;
        }
    }
}
-(void)actionOfReplayTimes:(UIButton*)btn{
    for (UIButton* button in replayTimesBtnArray) {
        if(button.tag==btn.tag){
            button.selected=true;
            playTimes = button.tag;
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
        
        [settingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(88.27);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
        
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
        [chooseLessonView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(132.41);
            make.right.equalTo(self.view);
            make.left.equalTo(self.view);
            make.bottom.equalTo(self.view);
            //make.width.equalTo(self.view);
        }];
    }else{
        if (chooseLessonView.unitName!=nil&&chooseLessonView.className!=nil) {
            lessonArray=chooseLessonView.lessonArray;
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
////点击收起按钮，显示内容


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
    //判断字典内容为空
    if ([[buyState valueForKey:@"data"] isKindOfClass:[NSNull class]]) {
        NSLog(@"您还未购买该课程");
        [self presentViewController:[self warnWindow:@"您还未购买该课程，购买该课程需要100学分！"] animated:YES completion:nil];
    }else{
        //添加学习进度信息
        //加载gif动画
        loadPic=[LoadGif imageViewStartAnimating];
        [self.view addSubview:loadPic];
        
        [loadPic mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.view);
            make.centerX.equalTo(self.view);
            make.width.equalTo(@60);
            make.height.equalTo(@60);
        }];
        
        NSDictionary* dataDic=[ConnectionFunction addUserArticleMsg:chooseLessonView.articleId UserKey:[userInfo valueForKey:@"userKey"]];
        NSLog(@"添加课程学习信息返回的是%@",dataDic);
        [lessontitle removeFromSuperview];
        
        [self presentLessionView];
        [self learningBook];
    }
    
    [self loadAudioMsg];
}

-(void)loadAudioMsg{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (self->sentenceArray != nil) {
            
            for (NSObject *object in self->sentenceArray) {
                NSString* playUrl=[object valueForKey:@"engUrl"];
                playUrl=[playUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                [DownloadAudioService toLoadAudio:playUrl FileName:[NSString stringWithFormat:@"%@", [object valueForKey:@"id"]]];
            }
            
        }
    });
}


#pragma mark 用户提示框
-(UIAlertController*)warnWindow:(NSString*)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示信息" message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"购买" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        int score=[[[ConnectionFunction getScore:[self->userInfo valueForKey:@"userKey"]]valueForKey:@"data"]intValue];
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
    ShowContentBlock showContentBlock=^(NSArray* bookpicarray,NSArray* sentencearray,NSString* classid,NSString* unitname,NSString* classname){
        __weak LearningViewController*  weakSelf=self;
        [weakSelf showContent:bookpicarray senArray:sentencearray classId:classid unitName:unitname className:classname];
        self->chooseLessonShow=!self->chooseLessonShow;
    };
    
    chooseLessonView=[[ChooseLessonView alloc]initWithBookId:_bookId DefaultUnit:_defaultUnit ShowBlock:showContentBlock];
    
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
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wunused-variable"
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(stopRecord) userInfo:nil repeats:NO];
    #pragma clang diagnostic pop
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
    
}

@end
