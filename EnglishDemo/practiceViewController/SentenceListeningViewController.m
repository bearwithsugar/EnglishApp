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
#import "../Functions/netOperate/ConnectionFunction.h"
#import "../Functions/netOperate/NetSenderFunction.h"
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
        if([_bookId isKindOfClass:[NSNull class]]){
            [self presentViewController:[WarningWindow MsgWithoutTrans:@"你还没有学习课本，不能进行句子听写！"] animated:YES completion:nil];
            return;
        }
        
        userInfo=[DocuOperate readFromPlist:@"userInfo.plist"];

        //加载上一课下一课界面
        [self chooseLesson];
        //加载当前课程标签
        [self presentLessionView];
        //初始化选课信息
        [self chooseLessonViewInit];
        
    }
    else{
        UnloginMsgView* unloginView=[[UnloginMsgView alloc]initWithFrame:CGRectMake(0, 88.27, 414, 647)];
        [self.view addSubview:unloginView];
    }
}


-(void)titleShow{
    
    [HeadView titleShow:@"句子听写" Color:ssRGBHex(0xFF7474) UIView:self.view UINavigationController:self.navigationController];
}

-(void)chooseLessonViewInit{
    ShowContentBlock showContentBlock=^(NSArray* bookpicarray,NSArray* sentencearray,NSString* classid,NSString* unitname,NSString* classname){
        int i=0;
        for (NSDictionary* dic in self->lessonArray) {
            NSLog(@"此时的classid%@",self->classId);
            NSLog(@"lessonArray单个元素的内容%@",dic);
            if ([[dic valueForKey:@"articleId"]isEqualToString: self->classId]) {
                break;
            }
            i++;
        }
        ConBlock conBlk = ^(NSDictionary* dic){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showContent:unitname
                        className:classname
                    sentenceArray:[dic valueForKey:@"data"]
                          classId:classid];
            });
            self->chooseLessonShow=!self->chooseLessonShow;
        };
        NetSenderFunction* sender = [[NetSenderFunction alloc]init];
        [sender getRequestWithHead:[self->userInfo valueForKey:@"userKey"] Path:[[ConnectionFunction getInstance]getTestSentenceMsg_Get_H:self->chooseLessonView.articleId] Block:conBlk];
    };
    ConBlock conBlk = ^(NSDictionary* dic){
        dispatch_async(dispatch_get_main_queue(), ^{
            self->chooseLessonView=[[ChooseLessonView alloc]initWithBookId:self->_bookId DefaultUnit:0 UnitArray:[dic valueForKey:@"data"] ShowBlock:showContentBlock];
            [self showChooseLessonView];
        });
    };
    NetSenderFunction* sender = [[NetSenderFunction alloc]init];
    [sender getRequestWithHead:[userInfo valueForKey:@"userKey"] Path:[[ConnectionFunction getInstance]getUnitMsg_Get_H:_bookId] Block:conBlk];
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
           
            ConBlock conBlk = ^(NSDictionary* dic){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showContent:[[self->lessonArray objectAtIndex:(i-1)]valueForKey:@"articleName"]
                                className:@""
                            sentenceArray:[dic valueForKey:@"data"]
                              classId:[[self->lessonArray objectAtIndex:(i-1)]valueForKey:@"articleId"]];
                    self->chooseLessonShow=!self->chooseLessonShow;
                });
            };
            NetSenderFunction* sender = [[NetSenderFunction alloc]init];
            [sender getRequestWithHead:[self->userInfo valueForKey:@"userKey"] Path:[[ConnectionFunction getInstance]getTestSentenceMsg_Get_H:[[lessonArray objectAtIndex:(i-1)]valueForKey:@"articleId"]] Block:conBlk];
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
            
            ConBlock conBlk = ^(NSDictionary* dic){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showContent:[[self->lessonArray objectAtIndex:(i+1)]valueForKey:@"articleName"]
                           className:@""
                       sentenceArray:[dic valueForKey:@"data"]
                         classId:[[self->lessonArray objectAtIndex:(i+1)]valueForKey:@"articleId"]];
                });
                self->chooseLessonShow=!self->chooseLessonShow;
            };
            NetSenderFunction* sender = [[NetSenderFunction alloc]init];
            [sender getRequestWithHead:[self->userInfo valueForKey:@"userKey"]
                                  Path:[[ConnectionFunction getInstance]getTestSentenceMsg_Get_H:[[lessonArray objectAtIndex:(i+1)]valueForKey:@"articleId"]]
                                 Block:conBlk];
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
//收起课程选择并显示内容
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
            ConBlock conBlk = ^(NSDictionary* dic){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showContent:self->chooseLessonView.unitName
                        className:self->chooseLessonView.className
                       sentenceArray:[dic valueForKey:@"data"]
                          classId:[[[self->chooseLessonView.dataArray valueForKey:@"bookSentences"]objectAtIndex:0] valueForKey:@"articleId"]];
                });
            };
            NetSenderFunction* sender = [[NetSenderFunction alloc]init];
            [sender getRequestWithHead:[self->userInfo valueForKey:@"userKey"] Path:[[ConnectionFunction getInstance]getTestSentenceMsg_Get_H:chooseLessonView.articleId] Block:conBlk];
        }else{
            //收起选择课程界面
            [chooseLessonView removeFromSuperview];
        }
    }
    chooseLessonShow=!chooseLessonShow;
    
}
-(void)showContent:(NSString*)unitname className:(NSString*)classname sentenceArray:(NSArray*)sentencearray classId:(NSString*)classid{
    
    JobBlock myblock = ^{
        NSMutableArray* voiceArray = [[NSMutableArray alloc]init];
        for (NSDictionary* dic in sentencearray) {
            NSMutableDictionary* dictionary = [[NSMutableDictionary alloc]init];
            [dictionary setValue:[dic valueForKey:@"engUrl"] forKey:@"url"];
            [dictionary setValue:[dic valueForKey:@"sentenceId"] forKey:@"id"];
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
    [MyThreadPool executeJob:myblock Main:^{}];
    
    //收起选择课程界面
    [chooseLessonView removeFromSuperview];
    //为当前单元课程名称赋值
    unitName=unitname;
    className=classname;
    sentenceArray=sentencearray;
    NSLog(@"句子数组的信息是%@",sentenceArray);
    classId=classid;
    
    [MyThreadPool executeJob:^{
        NetSenderFunction* sender = [[NetSenderFunction alloc]init];
        [sender postRequestWithHead:[[ConnectionFunction getInstance]addUserArticleMsg_Post_H:self->chooseLessonView.articleId] Head:[self->userInfo valueForKey:@"userKey"] Block:^(NSDictionary * dic) {
        }];
    } Main:^{}];
    
    //重新加载当前单元课程标签
    [lessontitle removeFromSuperview];
    [self presentLessionView];
    //加载内容
    [self contentView];
    [sentencesList reloadData];
}

-(void)contentView{
    if (sentencesList == nil) {
        sentencesList=[[UITableView alloc]init];
        sentencesList.dataSource=self;
        sentencesList.delegate=self;
        [self.view addSubview:sentencesList];
        
        //无内容时不显示下划线
        UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
        [sentencesList setTableFooterView:v];
        
        
        [sentencesList mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(134.62);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
    }
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
    NSString* pic=@"laba_practice2";
    NSString* name=[cellDic valueForKey:@"sentenceEng"];
    NSString* description=[cellDic valueForKey:@"sentenceChn"];
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
    //播放声音
    //音频播放空间分配
    
    WordsListeningTableViewCell *cell = [sentencesList cellForRowAtIndexPath:indexPath];
    //把喇叭换成动图

    [cell clearLaba];
    [cell addPicForLaba:[LoadGif imageViewfForPracticePlaying]];
    
    JobBlock playBlock =^{
        NSString* playUrl=[[DownloadAudioService getInstance] getAudioPath:
                           [NSString stringWithFormat:@"%@",[[self->sentenceArray objectAtIndex:indexPath.row]valueForKey:@"sentenceId"]]];
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
