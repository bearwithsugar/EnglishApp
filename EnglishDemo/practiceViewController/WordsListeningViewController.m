//
//  WordsListeningViewController.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/21.
//  Copyright © 2018年 马一轩. All rights reserved.
//

#import "WordsListeningViewController.h"
#import "../DiyGroup/WordsListeningTableViewCell.h"
#import "../DiyGroup/ChooseLessonView.h"
#import "../Functions/ConnectionFunction.h"
#import "../DiyGroup/ChooseLessonView.h"
#import "../Functions/DocuOperate.h"
#import "../Functions/VoicePlayer.h"
#import "../Functions/WarningWindow.h"
#import "../DiyGroup/UnloginMsgView.h"
#import "../Functions/DownloadAudioService.h"
#import "../Functions/MyThreadPool.h"
#import "../Common/HeadView.h"
#import "../Common/LoadGif.h"
#import "Masonry.h"

@interface WordsListeningViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    //用来存放单词资源的数组
    NSArray* wordsArray;
    //bool用于显示选课信息界面的标签
    BOOL chooseLessonShow;
    //设置界面
    UIView* settingView;
    //单元课程名称
    NSString* unitName;
    NSString* className;
    //显示当前课程的容器
    UIView* presentLession;
    //选课信息界面
    ChooseLessonView* chooseLessonView;
    //声明显示内容的tableview
    UITableView* wordsList;
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

@implementation WordsListeningViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    //初始化数组
    wordsArray=[[NSArray alloc]init];
    lessonArray=[[NSArray alloc]init];
    //bool显示选课信息界面
    chooseLessonShow=NO;
    //加载标题
    [self titleShow];
    [self showChooseLessonView];

}
-(void)viewWillAppear:(BOOL)animated{
    if ([DocuOperate fileExistInPath:@"userInfo.plist"]) {
        if([_bookId isKindOfClass:[NSNull class]]){
            [self presentViewController:[WarningWindow MsgWithoutTrans:@"你还没有学习课本，不能进行单词听写！"] animated:YES completion:nil];
            return;
        }
        userInfo = [DocuOperate readFromPlist:@"userInfo.plist"];
        //初始化选课信息
        [self chooseLessonViewInit];
        [self contentViewInit]; 
        //加载上一课下一课界面
        [self chooseLesson];
        //加载当前课程标签
        [self presentLessionView];
    }
    else{
        UnloginMsgView* unloginView=[[UnloginMsgView alloc]init];
        [self.view addSubview:unloginView];
        
        [unloginView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(88.27);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
    }
    
}

-(void)titleShow{
    
    [HeadView titleShow:@"单词听写" Color:ssRGBHex(0xFF7474) UIView:self.view UINavigationController:self.navigationController];

}

-(void)chooseLessonViewInit{
    ShowContentBlock showContentBlock=^(NSArray* bookpicarray,NSArray* sentencearray,NSString* classid,NSString* unitname,NSString* classname){
        __weak WordsListeningViewController*  weakSelf=self;
        
        [weakSelf showContent:unitname
                    className:classname
                   wordsArray:[[ConnectionFunction getTestWordMsg:self->chooseLessonView.articleId
                                                          UserKey:[self->userInfo valueForKey:@"userKey"]]valueForKey:@"data"]
                      classId:classid];
        self->chooseLessonShow=!self->chooseLessonShow;
    };
    chooseLessonView=[[ChooseLessonView alloc]initWithBookId:_bookId DefaultUnit:0 ShowBlock:showContentBlock];
}

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
    }else{
        if(!lessonArray || lessonArray.count == 0){
            lessonArray=chooseLessonView.lessonArray;
        }
        if ([classId isEqualToString:[[lessonArray objectAtIndex:0]valueForKey:@"articleId"]]){
            NSLog(@"这是当前单元的第一课！没有上一课了！");
            [self presentViewController:[WarningWindow MsgWithoutTrans:@"这是当前单元的第一课！没有上一课了！"] animated:YES completion:nil];
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
                   wordsArray:[[ConnectionFunction getTestWordMsg:[[lessonArray objectAtIndex:(i-1)]valueForKey:@"articleId"] UserKey:[userInfo valueForKey:@"userKey"]]valueForKey:@"data"]
                      classId:[[lessonArray objectAtIndex:(i-1)]valueForKey:@"articleId"]];
        }
    }
    
}
-(void)clickNextLesson{
    if (classId==nil) {
        NSLog(@"请先点击这里选择课程");
    }else{
        if(!lessonArray || lessonArray.count == 0){
            lessonArray=chooseLessonView.lessonArray;
        }
        if ([classId isEqualToString:[[lessonArray objectAtIndex:(lessonArray.count-1)]valueForKey:@"articleId"]]){
            NSLog(@"这是当前单元的最后一课！没有下一课了！");
            [self presentViewController:[WarningWindow MsgWithoutTrans:@"这是当前单元的最后一课！没有下一课了！"] animated:YES completion:nil];
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
                   wordsArray:[[ConnectionFunction getTestWordMsg:[[lessonArray objectAtIndex:(i+1)]valueForKey:@"articleId"] UserKey:[userInfo valueForKey:@"userKey"]]valueForKey:@"data"]
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
        lessontitle.text=@"请先点击这里选择课程";
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
-(void)contentViewInit{
    wordsList=[[UITableView alloc]init];
    wordsList.dataSource=self;
    wordsList.delegate=self;
}
-(void)contentView{
    [self.view addSubview:wordsList];
    
    //无内容时不显示下划线
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [wordsList setTableFooterView:v];

    
    [wordsList mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(134.62);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

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
            [self showContent:chooseLessonView.unitName
                    className:chooseLessonView.className
                   wordsArray:[[ConnectionFunction getTestWordMsg:chooseLessonView.articleId UserKey:[userInfo valueForKey:@"userKey"]]valueForKey:@"data"]
                      classId:[[[chooseLessonView.dataArray valueForKey:@"bookSentences"]objectAtIndex:0] valueForKey:@"articleId"]
             ];
        }else{
            //收起选择课程界面
            [chooseLessonView removeFromSuperview];
        }
    }
    chooseLessonShow=!chooseLessonShow;

}
-(void)showContent:(NSString*)unitname className:(NSString*)classname wordsArray:(NSArray*)wordsarray classId:(NSString*)classid{
    
    JobBlock myblock = ^{
        //如果不这样做一下字典准换会出现no summary
        NSMutableArray* voiceArray = [[NSMutableArray alloc]init];
        for (NSDictionary* dic in wordsarray) {
            NSMutableDictionary* dictionary = [[NSMutableDictionary alloc]init];
            [dictionary setValue:[dic valueForKey:@"engUrl"] forKey:@"url"];
            [dictionary setValue:[dic valueForKey:@"wordId"] forKey:@"id"];
            [voiceArray addObject:dictionary];
        }
        
        for (NSDictionary* dic in voiceArray) {
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
    
    //为当前单元课程名称赋值
    unitName=unitname;
    className=classname;
    //调用接口获取信息
    wordsArray=wordsarray;
    
    classId=classid;
    
    [MyThreadPool executeJob:^{
        [ConnectionFunction addUserArticleMsg:self->chooseLessonView.articleId UserKey:[self->userInfo valueForKey:@"userKey"]];
    } Main:^{}];

    //重新加载当前单元课程标签
    [lessontitle removeFromSuperview];
    [self presentLessionView];
    //加载内容
    [self contentView];

    [wordsList reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return wordsArray.count;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //单词表，这里的cell重用机制有问题
    WordsListeningTableViewCell* cell=[WordsListeningTableViewCell createCellWithTableView:tableView];
    if (![wordsArray objectAtIndex:indexPath.row]) {
        return NULL;
    }
    NSDictionary* cellDic=[wordsArray objectAtIndex:indexPath.row];
    NSString* pic=@"laba_practice2";
    NSString* name=[cellDic valueForKey:@"wordEng"];
    NSString* wordTag=[cellDic valueForKey:@"wordTag"];
    NSString* description=[cellDic valueForKey:@"wordChn"];
    wordTag=[wordTag stringByAppendingString:@"  "];
    description=[wordTag stringByAppendingString:description];
    [cell loadData:[[UIImageView alloc]initWithImage:[UIImage imageNamed:pic]]
              name:name
       description:description];
    return cell;
    }
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 52.96;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
 
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WordsListeningTableViewCell *cell = [wordsList cellForRowAtIndexPath:indexPath];
    //把喇叭换成动图
    [cell clearLaba];
    [cell addPicForLaba:[LoadGif imageViewfForPracticePlaying]];
    
    JobBlock playBlock =^{
        
       
        NSString* playUrl=[DownloadAudioService getAudioPath:
                           [NSString stringWithFormat:@"%@",[[self->wordsArray objectAtIndex:indexPath.row]valueForKey:@"wordId"]]];
        if (self->voiceplayer!=NULL) {
            [self->voiceplayer interruptPlay];
            self->voiceplayer = NULL;
        }
        
        self->voiceplayer=[[VoicePlayer alloc]init];
        self->voiceplayer.url = playUrl;
        self->voiceplayer.myblock = ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell clearLaba];
                [cell addPicForLaba:[[UIImageView alloc]initWithImage:[UIImage imageNamed: @"laba_practice2"]]];
            });
        };
        [self->voiceplayer playAudio:0];

    };
    [MyThreadPool executeJob:playBlock Main:^{}];
}

-(void)popBack:(UITapGestureRecognizer*)sender{
    [self.navigationController popViewControllerAnimated:true];
    [self->voiceplayer stopPlay];
}
@end
