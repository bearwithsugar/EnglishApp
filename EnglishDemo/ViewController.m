//
//  ViewController.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/11.
//  Copyright © 2018年 马一轩. All rights reserved.
//

#import "ViewController.h"
#import "UserMsg/UserMsg.h"
#import "UnitViewController.h"
#import "LoginAndRegisterViewController/LoginViewController.h"
#import "MyShelfViewController.h"
#import "MoreRecommendViewController.h"
#import "practiceViewController/WordsListeningViewController.h"
#import "practiceViewController/SentenceListeningViewController.h"
#import "practiceViewController/WordsTestViewController.h"
#import "DiyGroup/ProcessLine.h"
#import "DiyGroup/ChoosePublishTableViewCell.h"
#import "Functions/ConnectionFunction.h"
#import "Functions/DocuOperate.h"
#import "practiceViewController/WrongNotesViewController.h"
#import "Functions/LocalDataOperation.h"
#import "Functions/WarningWindow.h"
#import "Common/LoadGif.h"
#import "AppDelegate.h"
#import "Functions/DataFilter.h"
#import "Functions/FixValues.h"
#import "Functions/ConnectionInstance.h"
#import "Reachability.h"
#import "Functions/MyThreadPool.h"
#import "Masonry.h"


//使控制台打印完整信息
//#ifdef DEBUG
//#define NSLog(FORMAT, ...) fprintf(stderr, "%s:%zd\t%s\n", [[[NSString stringWithUTF8String: __FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat: FORMAT, ## __VA_ARGS__] UTF8String]);
//#else
//#define NSLog(FORMAT, ...) nil
//#endif


//首先为需要的对象分配内存空间
//当页面d第一次出现时一次性加载 单元练习  标题栏 标题菜单 和其他固定界面

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UserMsg* userMsg;
    UnitViewController* unitMsg;
    //跨函数添加的view
    UIView* myShelfView;
    UIView* myProgress;
    UIView* processDetails;
    UIView* myShelfThree;
    UIView* refreshPanelProcess;
    //当前书籍界面
    UIView* bookPicView;
    //听课文等固定标签的图层
    UIView* processFixView;
    //书架概览图层
    UIView* bookScanView;
    
    UIView* synchronousPractice;
    LoginViewController* loginView;
    MyShelfViewController* myShelfVC;
    MoreRecommendViewController* moreRecommend;
    WordsListeningViewController* wordsListening;
    SentenceListeningViewController* sentenceListening;
    WordsTestViewController* wordsTest;
    WrongNotesViewController* wrongNoteView;
    UIView* chooseBookView;
    UIView* startChooseView;
   
    //当前进行联系的课本的label
    //UILabel* practiceBook;
    //暂无学习记录
    UILabel* noRecordLabel;
    //听课文读句子等标签
    UILabel* tingkewen;
    
    NSString* selectedPublication;
    //用户信息字典
    NSDictionary* userInfo;
    //存放请求出版社列表返回数据的字典
    NSDictionary* publicationMsgDic;
    //用户成绩plist文件所用字典
    NSMutableDictionary* processDic;
    //存放出版社列表对象的数组，每个元素是一个字典
    NSArray* publicationArray;
    //存放年级列表的c数组
    NSArray* gradesArray;
    //年级tableview
    UITableView* chooseGradeTable;
    //查询结果书籍的数组
    NSArray* bookArray;
    //首页书架部分书籍展示
    NSArray* bookshelfArray;
    //title数组
    NSMutableArray* titleBtnArray;
    //最近学习情况
    NSDictionary* recentLearnMsg;
    //最近读的这本书的信息
    NSDictionary* recentBook;
    //学习进度！
    NSDictionary* learnProcess;
    //加载圈
    UIImageView* loadGifForRecentBook;
    UIImageView* loadGifForProcess;
    
    BOOL timerFlag;
}

@property (nonatomic, strong)dispatch_source_t timer;

@property (nonatomic, strong)Reachability *conn;

@end

@implementation ViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(netWorkStateChange:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    self.conn = [Reachability reachabilityForInternetConnection];
    [self.conn startNotifier];
    
    if ([self updateInterfaceWithReachability:self.conn]) {
        //初始化、分配空间
        userInfo=[DocuOperate readFromPlist:@"userInfo.plist"];
        myShelfView=[[UIView alloc]init];
        synchronousPractice=[[UIView alloc]init];
        selectedPublication=[[NSString alloc]init];
        //先为年级数组分配空间
        gradesArray=[[NSArray alloc]init];
        //为书籍数组分配空间
        bookArray=[[NSArray alloc]init];
        titleBtnArray = [[NSMutableArray alloc]init];
        processDic=[[NSMutableDictionary alloc]init];
        timerFlag=true;
        //加载加载图
        loadGifForRecentBook=[LoadGif imageViewStartAnimating];
        loadGifForProcess=[LoadGif imageViewStartAnimating];

        //开始加载界面
        [self synchronousPracticeShow];
        [self.view addSubview:myShelfView];
        
        [myShelfView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(137.93);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
        
        [self.navigationController setNavigationBarHidden:true];
        [self titleShow];
        [self titleMenu];

        [self myGradeFixed];
        [self myProgressFixed];

        //[self recommend];
        if ([userInfo valueForKey:@"userKey"]!=nil) {
            [self chooseBookinit];
            [self chooseBook];
        }

        //其他信息初始化方法
        [self initForFirstLogin];
    }
    
}
-(void)viewWillAppear:(BOOL)animated{
//每当页面出现时，
//        1.判断是否存在用户信息，不存在要求登录，存在进行下一步
//        2.判断第一个接口请求信息返回code是否是401，如果是提示账号在其他设备登录，如果不是进行下一步
//        3.加载最近学习信息和最近学习书本，

    if (![self updateInterfaceWithReachability:self.conn]) {
        return;
    }
    //用户是否登陆过
    if ([DocuOperate fileExistInPath:@"userInfo.plist"]) {

        userInfo=[DocuOperate readFromPlist:@"userInfo.plist"];

        ConnectionInstance* recentInstance=[[ConnectionInstance alloc]init];

        //判断账号是否其他设备登录
        if ([[[recentInstance recentLearnMsg:[userInfo valueForKey:@"userKey"]]valueForKey:@"code"]intValue]==401) {

            NSLog(@"账号在别处登录");

            //警告窗
            [self presentViewController:
             [WarningWindow transToLogin:@"您的账号在别处登录请重新登录！"
                              Navigation:self.navigationController]
                               animated:YES
                             completion:nil];

        }else{
            //如果没有其他设备登录则进行数据加载---------------------------------------------------------------

            //最近学习情况
            recentLearnMsg=[recentInstance recentLearnMsg:[userInfo valueForKey:@"userKey"]];

            recentBook=[[recentLearnMsg valueForKey:@"data"]valueForKey:@"book"];

            if ([recentBook isKindOfClass:[NSNull class]]||![recentBook count]) {
                NSLog(@"最近学习信息为空");
                
                [loadGifForProcess removeFromSuperview];
                [loadGifForRecentBook removeFromSuperview];

                [self presentViewController:[WarningWindow MsgWithoutTrans:@"您还没有学习记录，快去选择课本学习吧！"]
                                   animated:YES completion:nil];
                
                

            }else{

                [self myProgressUnfixed];

                //如果不是第一次下载本软件则直接加载
//                if (![[processDic valueForKey:@"picture"]isEqualToString:@"a"]) {
//
//                    [self myGradeUnfixed];
//
//                }

                [self myGradeUnfixed];

                dispatch_async(dispatch_get_global_queue(0, 0), ^{

                    [self getReq];

                });


            }

            //----------------------------------------------------------------------------------------

        }

    }else{
        [self cleanMsg];
    }


    //释放对象以便于重新创建对象
    unitMsg=nil;
    sentenceListening=nil;
    wordsTest=nil;

}

//初始化一些其他信息
-(void)initForFirstLogin{
    //打印一些基本信息
    NSLog(@"%@",NSStringFromCGSize([UIScreen mainScreen].bounds.size));
    //打印沙盒路径
    NSLog(@"沙盒路径：%@",[DocuOperate homeDirectory]);
    
    //加载gif动画
    [self->bookPicView addSubview:loadGifForRecentBook];
    
    [processDetails addSubview:loadGifForProcess];
    
    [loadGifForProcess mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self->processDetails);
        make.centerY.equalTo(self->processDetails);
        make.width.equalTo(@30);
        make.height.equalTo(@30);
    }];

    [loadGifForRecentBook mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self->bookPicView);
        make.centerY.equalTo(self->bookPicView);
        make.width.equalTo(@30);
        make.height.equalTo(@30);
    }];
    
    //写入进度文件，方便绕开接口相应时间达到实时刷新
    if([DocuOperate fileExistInPath:@"process.plist"]){
        NSDictionary* dic=[DocuOperate readFromPlist:@"process.plist"];
        for (int i=0; i<[dic allKeys].count; i++) {
            [processDic setValue:[dic valueForKey:[[dic allKeys]objectAtIndex:i]]
                          forKey:[[dic allKeys]objectAtIndex:i]];
        }
    }else{
        [processDic setValue:@"a" forKey:@"picture"];
        [processDic setValue:@"a" forKey:@"tingkewen"];
        [processDic setValue:@"a" forKey:@"dujuzi"];
        [processDic setValue:@"a" forKey:@"zhunquelv"];
        [processDic setValue:@"a" forKey:@"zongshichang"];
        [processDic setValue:@"a" forKey:@"zongpaiming"];
        [processDic setValue:@"a" forKey:@"percentage"];
        [DocuOperate writeIntoPlist:@"process.plist" dictionary:processDic];
        NSLog(@"写入文件");
    }
}

//刷新最近学习的书本信息和学习进度
-(void)getReq{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"user_bookinfo"];
    url=[url URLByAppendingPathComponent:[recentBook valueForKey:@"bookId"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession* session =[NSURLSession sharedSession];
    NSLog(@"get方法中url是：%@",url);
    //添加请求头
    NSDictionary *headers = @{@"English-user": [userInfo valueForKey:@"userKey"]};
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];

    static NSDictionary* dictionary;
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dictionary=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

        NSLog(@"错误：%@",error);
        NSString *html = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"数据为：%@",html);

        self->learnProcess=[dictionary valueForKey:@"data"];

        dispatch_async(dispatch_get_global_queue(0, 0), ^{

            [self->processDic setValue:[self->learnProcess valueForKey:@"grade"] forKey:@"zhunquelv"];

            [self->processDic setValue:[[self->learnProcess valueForKey:@"userBook"]valueForKey:@"learningRate"] forKey:@"tingkewen"];
            [self->processDic setValue:[self->learnProcess valueForKey:@"rank_rate"] forKey:@"percentage"];
            [self->processDic setValue:[[self->learnProcess valueForKey:@"userBook"]valueForKey:@"bookId"] forKey:@"picture"];
            [self->processDic setValue:[self->learnProcess valueForKey:@"sentenceRate"] forKey:@"dujuzi"];
            [self->processDic setValue:[self->learnProcess valueForKey:@"rank"] forKey:@"zongpaiming"];
            [self->processDic setValue:[[self->learnProcess valueForKey:@"userBook"]valueForKey:@"learningTime"] forKey:@"zongshichang"];

            dispatch_async(dispatch_get_main_queue(), ^{

                [DocuOperate replacePlist:@"process.plist" dictionary:self->processDic];

                [self loadGrade];

            });
        });
    }];
    [dataTask resume];
    
}

-(void)titleShow{
    //标题
    UILabel* titleShow=[[UILabel alloc]init];
    titleShow.backgroundColor=ssRGBHex(0xFF6565 );
    titleShow.text=@"小学英语同步练";
    titleShow.textColor=[UIColor whiteColor];
    titleShow.font=[UIFont systemFontOfSize:18];
    titleShow.textAlignment=NSTextAlignmentCenter;
    //显示子视图
    titleShow.clipsToBounds = YES;
    //打开button父组件的人机交互
    [titleShow setUserInteractionEnabled:YES];
    
    UILabel* touchField=[[UILabel alloc]init];
    [touchField setUserInteractionEnabled:YES];
    [titleShow addSubview:touchField];
    
    [touchField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleShow).with.offset(15);
        make.right.equalTo(titleShow).with.offset(-15);
        make.width.equalTo(@36);
        make.height.equalTo(@35);
    }];
    
    //用户button
    UIButton* userPic=[[UIButton alloc]init];
    [userPic setBackgroundImage:[UIImage imageNamed:@"icon_people"] forState:UIControlStateNormal];
    [userPic setBackgroundImage:[UIImage imageNamed:@"icon_people"] forState:UIControlStateHighlighted];
    [userPic addTarget:self action:@selector(pushToUser) forControlEvents:UIControlEventTouchUpInside];
    [touchField addSubview:userPic];
    
    [userPic mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(touchField).with.offset(5);
        make.left.equalTo(touchField).with.offset(5);
        make.width.equalTo(@23);
        make.height.equalTo(@25);
    }];
    
    UITapGestureRecognizer* touchFunc=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pushToUser)];
    [touchField addGestureRecognizer:touchFunc];
    
    [self.view addSubview:titleShow];
    
    [titleShow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(22.7);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@66);
    }];
}
-(void)titleMenu{
    NSArray *titleArray=@[@"我的书架",@"同步练习",@"选择课本"];
    for(NSString *title in titleArray ){
        UIButton* titlebtn=[[UIButton alloc]init];
        titlebtn.backgroundColor=[UIColor whiteColor];
        [titlebtn setTitle:title forState:UIControlStateNormal];
        [titlebtn setTitleColor:(ssRGBHex(0x000000)) forState:UIControlStateNormal];
        [titlebtn setTitleColor:(ssRGBHex(0xFF7474)) forState:UIControlStateSelected];
        titlebtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [titlebtn addTarget:self action:@selector(wasClicked:) forControlEvents:UIControlEventTouchDown];
        titlebtn.tag=[titleArray indexOfObject:title];
        if (titlebtn.tag == 0) {
            titlebtn.selected = YES;
        }
        [self.view addSubview:titlebtn];
        [titleBtnArray addObject:titlebtn];
        
        [titlebtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(89);
            if([titleArray indexOfObject:title] == 0)
                make.left.equalTo(self.view);
            else if([titleArray indexOfObject:title] == 1)
                make.centerX.equalTo(self.view);
            else
                make.right.equalTo(self.view);
            make.width.equalTo(self.view).multipliedBy(0.34);
            make.height.equalTo(@50);
        }];
    }
}
-(void)wasClicked:(UIButton*)btn{
    if (btn.tag==1) {
        [myShelfView removeFromSuperview];
        [chooseBookView removeFromSuperview];
        [self.view addSubview:synchronousPractice];
        
        [synchronousPractice mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(137.93);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
        
    }else if(btn.tag==0){
        [synchronousPractice removeFromSuperview];
        [chooseBookView removeFromSuperview];
        [self.view addSubview:myShelfView];
        
        [myShelfView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(137.93);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
        
    }else if(btn.tag==2){
        if (userInfo==nil) {
            [self presentViewController: [WarningWindow transToLogin:@"你尚未登录！请登录后查看" Navigation:self.navigationController]
                               animated:YES
                             completion:nil];
        }else{
            [self chooseBook];
            [self.view addSubview:chooseBookView];
            
            [chooseBookView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view).with.offset(137.93);
                make.left.equalTo(self.view);
                make.right.equalTo(self.view);
                make.bottom.equalTo(self.view);
            }];
        }
        
    }
    
    for (UIButton* button in titleBtnArray) {
        if (btn.tag == button.tag) {
            button.selected = YES;
        }else{
            button.selected = NO;
        }
    }
}

#pragma mark --myshelf

-(void)myGradeFixed{
    myProgress=[[UIView alloc]init];
    myProgress.backgroundColor=ssRGBHex(0xFCF8F7);
    [myShelfView addSubview:myProgress];
    
    [myProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->myShelfView);
        make.left.equalTo(self->myShelfView);
        make.right.equalTo(self->myShelfView);
        make.height.equalTo(@275.84);
    }];
    
    //右侧面板
    UIView* progressPanel = [UIView new];
    [myProgress addSubview:progressPanel];
    
    [progressPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->myProgress);
        make.right.equalTo(self->myProgress);
        make.width.equalTo(self->myProgress).multipliedBy(0.5);
        make.bottom.equalTo(self->myProgress);
    }];

    //右侧进度线束
    processDetails=[[UIView alloc]init];
    //processDetails.backgroundColor=[UIColor blueColor];
    processDetails.layer.borderColor=[UIColor blackColor].CGColor;
    processDetails.layer.borderWidth=1.0;
    processDetails.layer.borderColor=ssRGBHex(0x979797).CGColor;
    processDetails.layer.cornerRadius=10;
    [progressPanel addSubview:processDetails];
    
    [processDetails mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(progressPanel).with.offset(23.17);
        make.centerX.equalTo(progressPanel);
        make.width.equalTo(@172);
        make.height.equalTo(@238.34);
    }];
    
    
    UILabel* processDetailsTitle=[[UILabel alloc]init];
    processDetailsTitle.text=@"我的练习成绩";
    processDetailsTitle.textColor=ssRGBHex(0xF15252);
    processDetailsTitle.backgroundColor=ssRGBHex(0xFCF7F8);
    processDetailsTitle.textAlignment=NSTextAlignmentCenter;
    [myProgress addSubview:processDetailsTitle];
    
    [processDetailsTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(progressPanel).with.offset(11);
        make.centerX.equalTo(progressPanel);
        make.width.equalTo(@120);
        make.height.equalTo(@22);
    }];
    
    noRecordLabel=[[UILabel alloc]init];
    noRecordLabel.text=@"暂无学习记录";
    noRecordLabel.textColor=ssRGBHex(0xF5A623);
    noRecordLabel.font=[UIFont systemFontOfSize:12];
    [progressPanel addSubview:noRecordLabel];
    
    [noRecordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self->processDetails);
        make.centerX.equalTo(self->processDetails);
        make.width.equalTo(@77.27);
        make.height.equalTo(@18.75);
    }];
    
}
-(void)myGradeUnfixed{
    
    
    [noRecordLabel removeFromSuperview];
    
    [processFixView removeFromSuperview];
    
    processFixView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 171.11, 238.34)];
    
    [processDetails addSubview:processFixView];
    
    NSArray* titleArray=@[@"听课文",@"读句子",@"准确率",@"总时长",@"总排名"];
    
    for (NSString* title in titleArray) {
        
        float y=22.06+27.57*[titleArray indexOfObject:title];
        
        tingkewen=[[UILabel alloc]initWithFrame:CGRectMake(4.41, y, 59.61, 18.75)];
        
        tingkewen.text=title;
        
        tingkewen.textColor=[UIColor blackColor];
        
        tingkewen.font=[UIFont systemFontOfSize:12];
        
        tingkewen.textAlignment=NSTextAlignmentCenter;
        
        [processFixView addSubview:tingkewen];
    
    //中部横线
    UIView* lineView=[[UIView alloc]initWithFrame:CGRectMake(11.04, 164.41, 149.04, 2)];
        
    lineView.layer.borderColor=ssRGBHex(0x979797).CGColor;
        
    lineView.layer.borderWidth=1;
        
    [processDetails addSubview:lineView];
        
    }
    
    if (userInfo==nil) {
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            UIImageView* bookpic=[[UIImageView alloc]init];
            
            bookpic.layer.borderWidth=1.0;
            
            bookpic.layer.borderColor=ssRGBHex(0x979797).CGColor;
            
            bookpic.image=[UIImage imageNamed:@"group_book_1_unlogged"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self->bookPicView addSubview:bookpic];
                
                [bookpic mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self->bookPicView);
                    make.width.equalTo(@176.63);
                    make.top.equalTo(self->bookPicView);
                    make.height.equalTo(@247.18);
                }];
                
            });
        });
        
    }else{
        if (bookPicView == nil) {
            bookPicView = [UIView new];
        }
        [myProgress addSubview:bookPicView];
        
        [bookPicView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self->myProgress);
            make.width.equalTo(self->myProgress).multipliedBy(0.5);
            make.top.equalTo(self->myProgress).with.offset(14.34);
            make.bottom.equalTo(self->myProgress);
        }];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            //登录状态下才添加手势
            UITapGestureRecognizer* clickBook=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(recentBookPushToUnit)];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self->bookPicView addGestureRecognizer:clickBook];
                
            });
            
        });
        
        UIImageView* bookpic=[[UIImageView alloc]init];
        
        bookpic.layer.borderWidth=1.0;
        
        bookpic.layer.borderColor=ssRGBHex(0x979797).CGColor;
        
        //临时图片
        //bookpic.image=[UIImage imageNamed:@"group_book_1_unlogged"];
        bookpic.image=[LocalDataOperation getImage:[recentBook valueForKey:@"bookId"] httpUrl:[recentBook valueForKey:@"coverPicture"]];

        [bookPicView addSubview:bookpic];
        
        [bookpic mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self->bookPicView);
            make.width.equalTo(@176.63);
            make.top.equalTo(self->bookPicView);
            make.height.equalTo(@247.18);
        }];
    }
    
    [self loadGrade];
    
}

-(void)loadGrade{
    
    [refreshPanelProcess removeFromSuperview];
    
    refreshPanelProcess=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 171.11, 238.34)];
    
    [processDetails addSubview:refreshPanelProcess];
    
    ProcessLine* tingkewenProcess=[[ProcessLine alloc]initWithFrame:CGRectMake(64.03, 26.48, 94.94, 13.24)];
    [tingkewenProcess percentLabel:[[processDic valueForKey:@"tingkewen"]floatValue]];
    [refreshPanelProcess addSubview:tingkewenProcess];
    
    ProcessLine* dujuziProcess=[[ProcessLine alloc]initWithFrame:CGRectMake(64.03, 52.96, 94.94, 13.24)];
    [dujuziProcess percentLabel:[[processDic valueForKey:@"dujuzi"]floatValue]];
    [refreshPanelProcess addSubview:dujuziProcess];
    
    ProcessLine* zhunquelvProcess=[[ProcessLine alloc]initWithFrame:CGRectMake(64.03, 81.69, 94.94, 13.24)];
    [zhunquelvProcess percentLabel:[[processDic valueForKey:@"zhunquelv"]floatValue]];
    [refreshPanelProcess addSubview:zhunquelvProcess];
    
    UILabel* timeCount=[[UILabel alloc]initWithFrame:CGRectMake(64.03, 108, 94.94, 13.24)];
    //timeCount.text=@"1小时32分钟";
    timeCount.text= [NSString stringWithFormat:@"%@",[processDic valueForKey:@"zongshichang"]];
    timeCount.textColor=[UIColor blackColor];
    timeCount.font=[UIFont systemFontOfSize:12];
    [refreshPanelProcess addSubview:timeCount];
    
    UILabel* rankingNumber=[[UILabel alloc]initWithFrame:CGRectMake(64.03, 133.51, 30, 13.24)];
    rankingNumber.text=[NSString stringWithFormat:@"%@",[processDic valueForKey:@"zongpaiming"]];
    rankingNumber.textColor=ssRGBHex(0xFF7474);
    rankingNumber.font=[UIFont systemFontOfSize:12];
    [refreshPanelProcess addSubview:rankingNumber];
    
    UILabel* rankingMing=[[UILabel alloc]initWithFrame:CGRectMake(94.03, 133.51, 30, 13.24)];
    rankingMing.text=@"名";
    rankingMing.textColor=[UIColor blackColor];
    rankingMing.font=[UIFont systemFontOfSize:12];
    [refreshPanelProcess addSubview:rankingMing];
    
    UILabel* rankTip=[[UILabel alloc]initWithFrame:CGRectMake(14.35, 178.75, 142.41, 37.51)];
    NSString* rank=@"恭喜你！你的成绩超过了";
    rank=[rank stringByAppendingString:[NSString stringWithFormat:@"%@",[processDic valueForKey:@"percentage"]]];
    rank=[rank stringByAppendingString:@"%的同学！"];
    rankTip.text=rank;
    rankTip.numberOfLines=0;
    rankTip.font=[UIFont systemFontOfSize:12];
    [refreshPanelProcess addSubview:rankTip];
    
    
    //加载完成，取消加载圈
    [loadGifForRecentBook removeFromSuperview];
    [loadGifForProcess removeFromSuperview];
}

-(void)myProgressFixed{
    
    //书籍图片
    bookPicView=[[UIView alloc]init];
    
    [myProgress addSubview:bookPicView];
    
    [bookPicView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->myProgress);
        make.width.equalTo(self->myProgress).multipliedBy(0.5);
        make.top.equalTo(self->myProgress).with.offset(14.34);
        make.bottom.equalTo(self->myProgress);
    }];
    
    myShelfThree=[[UIView alloc]init];
    myShelfThree.backgroundColor=ssRGBHex(0xFCF8F7);
    [myShelfView addSubview:myShelfThree];
    
    [myShelfThree mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self->myShelfView);
        make.left.equalTo(self->myShelfView);
        make.top.equalTo(self->myShelfView).with.offset(275.84);
        make.height.equalTo(@225.09);
    }];
    
    UIView* myProgressTitle=[[UIView alloc]init];
    myProgressTitle.backgroundColor=[UIColor whiteColor];
    [myShelfThree addSubview:myProgressTitle];
    
    [myProgressTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self->myShelfThree);
        make.left.equalTo(self->myShelfThree);
        make.top.equalTo(self->myShelfThree);
        make.height.equalTo(@44.12);
    }];
    
    //显示子视图
    myProgressTitle.clipsToBounds = YES;
    //打开button父组件的人机交互
    [myProgressTitle setUserInteractionEnabled:YES];
    
    UIImageView* clockPic=[[UIImageView alloc]init];
    clockPic.image=[UIImage imageNamed:@"icon_rate"];
    [myProgressTitle addSubview:clockPic];
    
    [clockPic mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@19.87);
        make.left.equalTo(myProgressTitle).with.offset(13.24);
        make.top.equalTo(myProgressTitle).with.offset(11.03);
        make.height.equalTo(@22);
    }];
    
    UILabel* lianxijindu=[[UILabel alloc]init];
    lianxijindu.text=@"已选课本";
    lianxijindu.font=[UIFont systemFontOfSize:14];
    [myShelfThree addSubview:lianxijindu];
    
    [lianxijindu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@70);
        make.left.equalTo(clockPic.mas_right).with.offset(15);
        make.top.equalTo(self->myShelfThree).with.offset(11.03);
        make.height.equalTo(@22);
    }];
    
    //富文本方式设置查看我的书架标签
    UILabel* myShelf=[[UILabel alloc]init];
    NSString *str1 = @"查看我的书架 ";
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",str1]];
    [attri addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, str1.length)];
    NSTextAttachment *attch = [[NSTextAttachment alloc] init];
    attch.image = [UIImage imageNamed:@"icon_foward"];
    attch.bounds = CGRectMake(5, 0, 8, 10);
    NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attch];
    [attri insertAttributedString:string atIndex:6];
    myShelf.attributedText=attri;
    myShelf.userInteractionEnabled=YES;
    UITapGestureRecognizer* clickmyShelf=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(action)];
    [myShelf addGestureRecognizer:clickmyShelf];
    [myProgressTitle addSubview:myShelf];
    
    [myShelf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@100);
        make.right.equalTo(myProgressTitle).with.offset(-15);
        make.top.equalTo(myProgressTitle).with.offset(10);
        make.height.equalTo(@22);
    }];
    
}
-(void)myProgressUnfixed{
   
    [bookScanView removeFromSuperview];
    
    bookScanView=[[UIView alloc]init];

    [myShelfThree addSubview:bookScanView];
    
    [bookScanView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->myShelfThree).with.offset(57.36);
        make.left.equalTo(self->myShelfThree);
        make.right.equalTo(self->myShelfThree);
        make.height.equalTo(@154.49);
    }];
    
    bookshelfArray=[[ConnectionFunction getBookShelf:[userInfo valueForKey:@"userKey"]] valueForKey:@"data"];
    
    NSInteger size=bookshelfArray.count;
    
    float width=105.98*size+17.66*(size-1)+61.8;
    
    UIScrollView* shelfView=[[UIScrollView alloc]init];
    
    shelfView.contentSize=CGSizeMake(width, 154.49);
        
    [self->bookScanView addSubview:shelfView];
    
    [shelfView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self->bookScanView);
    }];
        
    for (int i=0; i<size; i++) {
        
        double x=i*105.98+(i+1)*17.66+13.24;
        
        UIButton* bookShelfScanView=[[UIButton alloc]initWithFrame:CGRectMake(x, 0, 105.98, 154.49)];
        
        bookShelfScanView.backgroundColor=[UIColor whiteColor];
        
        bookShelfScanView.layer.borderWidth=1.0;
        
        bookShelfScanView.layer.borderColor=ssRGBHex(0x979797).CGColor;
        
        NSDictionary* msgForImage=[self->bookshelfArray objectAtIndex:i];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{

            UIImage* backImage=[LocalDataOperation getImage:[[msgForImage valueForKey:@"userBook"]
                                                             valueForKey:@"bookId"]
                                                    httpUrl:[msgForImage valueForKey:@"coverPicture"]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [bookShelfScanView setBackgroundImage:backImage forState:UIControlStateNormal];
                
                bookShelfScanView.tag=i;
                
                [bookShelfScanView addTarget:self action:@selector(pushToUnit:) forControlEvents:UIControlEventTouchUpInside];
                
                [shelfView addSubview:bookShelfScanView];
            });
        });
    }
}

-(void)action{
    if (userInfo==nil) {
        [self loginWarn:@"您尚未登录！"];
    }else{
        [self pushToMyShelfView];
    }
    
}
-(void)loginWarn:(NSString*)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示信息" message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self pushToLoginView];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }];
    
    [alert addAction:action1];
    [alert addAction:action2];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)recommend{
    //加载“为您推荐”视图
    UIView* recommend=[[UIView alloc]initWithFrame:CGRectMake(0, 500.93, 414, 96.52)];
    [myShelfView addSubview:recommend];
    
    //加载“为您推荐“标题
    UILabel* recommendTitle=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 414, 22.07)];
    NSString *str1 = @"为您推荐";
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",str1]];
    [attri addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(0, str1.length)];
    NSTextAttachment *attch = [[NSTextAttachment alloc] init];
    attch.image = [UIImage imageNamed:@"icon_foward"];
    attch.bounds = CGRectMake(5, 0, 4.4, 8.8);
    NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attch];
    [attri insertAttributedString:string atIndex:4];
    recommendTitle.attributedText=attri;
    //下列添加点击事件
    recommendTitle.userInteractionEnabled=YES;
    UITapGestureRecognizer* clickrecommendTitle=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pushToMoreRecommend)];
    [recommendTitle addGestureRecognizer:clickrecommendTitle];
    [recommend addSubview:recommendTitle];
    
    //竖线左侧   小学语文同步练还有小星星
    UIView* alogo=[[UIView alloc]initWithFrame:CGRectMake(11.04, 34.2, 46.36 , 46.36)];
    alogo.layer.cornerRadius=10;
    alogo.layer.borderColor=ssRGBHex(0x9B9B9B).CGColor;
    alogo.layer.borderWidth=1;
    alogo.backgroundColor=ssRGBHex(0x9B9B9B);
    [recommend addSubview:alogo];
    UILabel* littleSchoolLabel=[[UILabel alloc]initWithFrame:CGRectMake(73.96, 38.62, 90.52, 18.75)];
    littleSchoolLabel.text=@"小学语文同步练";
    littleSchoolLabel.font=[UIFont systemFontOfSize:12];
    [recommend addSubview:littleSchoolLabel];
    
    for (int i=0; i<4; i++) {
        float x=71.76+2.20*(i+1)+13.24*i;
        UIImageView* star=[[UIImageView alloc]initWithFrame:CGRectMake(x, 61.79, 13.24, 12.13)];
        star.image=[UIImage imageNamed:@"icon_star_F5A623"];
        [recommend addSubview:star];
        
    }
    UIImageView* star=[[UIImageView alloc]initWithFrame:CGRectMake(135.79, 61.79, 13.24, 12.13)];
    star.image=[UIImage imageNamed:@"icon_star_ffffff"];
    [recommend addSubview:star];
    
    //间隔竖线
    UIView* devideLine=[[UIView alloc]initWithFrame:CGRectMake(188.78, 37.51, 2, 39.72)];
    devideLine.layer.borderColor=ssRGBHex(0x979797).CGColor;
    devideLine.layer.borderWidth=1;
    [recommend addSubview:devideLine];
    
    //竖线右侧
    UITextView* theDetail=[[UITextView alloc]initWithFrame:CGRectMake(211.96, 37.51, 140, 37.51)];
    theDetail.text=@"同步教材，同步练习！\n巩固知识，提升成绩！";
    theDetail.font=[UIFont systemFontOfSize:12];
    theDetail.editable=false;
    [recommend addSubview:theDetail];
    
    UIButton* loadBtn=[[UIButton alloc]initWithFrame:CGRectMake(351.07, 35.31, 44.16, 44.16)];
    [loadBtn setBackgroundImage:[UIImage imageNamed:@"icon_download"] forState:UIControlStateNormal];
    [recommend addSubview:loadBtn];
}


#pragma mark --synchronousPractice

-(void)synchronousPracticeShow{
    synchronousPractice.backgroundColor=ssRGBHex(0xFCF8F7);
//    practiceBook=[[UILabel alloc]initWithFrame:CGRectMake(0, 5.51, 414, 44.13)];
//    practiceBook.text=@"暂无课本";
//    practiceBook.backgroundColor=[UIColor whiteColor];
//    practiceBook.textAlignment=NSTextAlignmentLeft;
//    practiceBook.textColor=ssRGBHex(0x9B9B9B);
//    practiceBook.font=[UIFont systemFontOfSize:14];
//    practiceBook.textAlignment=NSTextAlignmentCenter;
//    [synchronousPractice addSubview:practiceBook];
    
    UIView* functionView=[[UIView alloc]init];
    functionView.backgroundColor=[UIColor whiteColor];
    [synchronousPractice addSubview:functionView];
    
    [functionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->synchronousPractice).with.offset(50);
        make.right.equalTo(self->synchronousPractice);
        make.width.equalTo(self->synchronousPractice);
        make.height.equalTo(@92.68);
    }];
    
    UIButton* wordListen=[[UIButton alloc]init];
    [wordListen setBackgroundImage:[UIImage imageNamed: @"btn_dancitingxie_logged"] forState:UIControlStateNormal];
    [wordListen addTarget:self action:@selector(pushToWordsListen) forControlEvents:UIControlEventTouchUpInside];
    [functionView addSubview:wordListen];
    
    UIButton* sentenceListen=[[UIButton alloc]init];
    [sentenceListen setBackgroundImage:[UIImage imageNamed: @"btn_juzitingxie_logged"] forState:UIControlStateNormal];
    [sentenceListen addTarget:self action:@selector(pushToSentenceListen) forControlEvents:UIControlEventTouchUpInside];
    [functionView addSubview:sentenceListen];
    
    UIButton* wordTest=[[UIButton alloc]init];
    wordTest.tag=1;
    [wordTest setBackgroundImage:[UIImage imageNamed: @"btn_danciceshi_logged"] forState:UIControlStateNormal];
    [wordTest addTarget:self action:@selector(pushToWordsTest:) forControlEvents:UIControlEventTouchUpInside];
    [functionView addSubview:wordTest];
    
    UIButton* sentenceTest=[[UIButton alloc]init];
    sentenceTest.tag=2;
    [sentenceTest setBackgroundImage:[UIImage imageNamed: @"btn_juziceshi_logged"] forState:UIControlStateNormal];
    [sentenceTest addTarget:self action:@selector(pushToWordsTest:) forControlEvents:UIControlEventTouchUpInside];
    [functionView addSubview:sentenceTest];
    
    UIButton* questionNote=[[UIButton alloc]init];
    [questionNote setBackgroundImage:[UIImage imageNamed: @"btn_cuotiben_logged"] forState:UIControlStateNormal];
    [questionNote addTarget:self action:@selector(pushToWrong) forControlEvents:UIControlEventTouchUpInside];
    [functionView addSubview:questionNote];
    
    [wordListen mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(functionView).with.offset(11);
        make.left.equalTo(functionView).with.offset(20);
        make.width.equalTo(@54);
        make.height.equalTo(@75);
    }];
    
    [sentenceListen mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(functionView).with.offset(11);
        make.centerX.equalTo(functionView).multipliedBy(0.5).with.offset(20);
        make.width.equalTo(@54);
        make.height.equalTo(@75);
    }];
    
    [wordTest mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(functionView).with.offset(11);
        make.centerX.equalTo(functionView);
        make.width.equalTo(@54);
        make.height.equalTo(@75);
    }];
    
    [sentenceTest mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(functionView).with.offset(11);
        make.centerX.equalTo(functionView).multipliedBy(1.5).with.offset(-20);
        make.width.equalTo(@54);
        make.height.equalTo(@75);
    }];
    
    [questionNote mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(functionView).with.offset(11);
        make.right.equalTo(functionView).with.offset(-20);
        make.width.equalTo(@54);
        make.height.equalTo(@75);
    }];
}


#pragma mark --chooseBook
-(void)chooseBookinit{
    //存放返回数据的字典
    NSString* tr=[userInfo valueForKey:@"userKey"];
    NSLog(@"userkey的内容是%@",tr);
    publicationMsgDic=[ConnectionFunction getLineByType:@"3" UserKey:[userInfo valueForKey:@"userKey"]];
    //存放列表对象的数组，每个元素是一个字典
    publicationArray=[publicationMsgDic valueForKey:@"data"];
    //selectedPublication=[dataDic valueForKey:@"categoryName"];
    NSLog(@"出版社列表%@",publicationArray);
}
-(void)chooseBook{
    chooseBookView=[[UIView alloc]init];
    chooseBookView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
    UITableView* choosePublishTable=[[UITableView alloc]init];
    choosePublishTable.dataSource=self;
    choosePublishTable.delegate=self;
    choosePublishTable.tag=4;
    [chooseBookView addSubview:choosePublishTable];
    
    chooseGradeTable=[[UITableView alloc]init];
    chooseGradeTable.dataSource=self;
    chooseGradeTable.delegate=self;
    chooseGradeTable.tag=3;
    [chooseBookView addSubview:chooseGradeTable];
    
    [chooseGradeTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->chooseBookView);
        make.left.equalTo(self->chooseBookView);
        make.width.equalTo(self->chooseBookView).multipliedBy(0.55);
        make.height.equalTo(@370.75);
    }];
    
    [choosePublishTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->chooseBookView);
        make.right.equalTo(self->chooseBookView);
        make.width.equalTo(self->chooseBookView).multipliedBy(0.45);
        make.height.equalTo(@370.75);
    }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag==4) {
        return publicationArray.count;
    }else{
        return gradesArray.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"flag";
    //取消分割线
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (tableView.tag==4) {
        ChoosePublishTableViewCell* cell;
        for (int i=0; i<publicationArray.count; i++) {
            if (indexPath.row==i) {
                cell=[ChoosePublishTableViewCell createCellWithTableView:tableView];
                NSDictionary* publicationMsg=publicationArray[i];
                [cell loadData:[publicationMsg valueForKey:@"categoryName"]];
                cell.tag=[[publicationMsg valueForKey:@"categoryId"]intValue];
            }
            cell.backgroundColor=[UIColor whiteColor];
            UIView *backgroundViews = [[UIView alloc]initWithFrame:cell.frame];
            backgroundViews.backgroundColor = ssRGBHex(0xFD7272);
            [cell setSelectedBackgroundView:backgroundViews];
        }
        return cell;
     }
    else{
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell==nil) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        }

        for (int i=0; i<gradesArray.count; i++) {
             if (indexPath.row==i) {
                 NSDictionary* gradeMsg=gradesArray[i];
                 cell.textLabel.text=[gradeMsg valueForKey:@"categoryName"];
                 NSLog(@"获取到的出版社id%@",[gradeMsg valueForKey:@"categoryId"]);
                 cell.tag=[[gradeMsg valueForKey:@"categoryId"]integerValue];
//                 NSLog(@"id转换成tag的值%@",[NSString stringWithFormat: @"%ld", cell.tag] );
//                 NSLog(@"id转换成tag的值%ld",(long)cell.tag);
             }
            cell.textLabel.font=[UIFont systemFontOfSize:12];
            cell.textLabel.textColor=ssRGBHex(0x4A4A4A);
            
            UIView *backgroundViews = [[UIView alloc]initWithFrame:cell.frame];
            backgroundViews.backgroundColor = [UIColor whiteColor];
            
            //cell选中颜色
            [cell setSelectedBackgroundView:backgroundViews];
            
            //cell选中字体颜色
            cell.textLabel.highlightedTextColor=ssRGBHex(0xFD7272);
         }
        return cell;
    }
 }

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 52.96;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag==4) {
        NSDictionary* dic = [ConnectionFunction getLineByParent: [[publicationArray objectAtIndex:indexPath.row]valueForKey:@"categoryId"] UserKey:[userInfo valueForKey:@"userKey"]];
        NSLog(@"年级数组是：%@",[dic valueForKey:@"data"]);

        //赋值给年级数组
        gradesArray=[dic valueForKey:@"data"];
        [chooseGradeTable reloadData];
        
    }else{
        //选择完年级和出版社之后返回的书籍信息
        NSDictionary* returnMsg=[ConnectionFunction getBookMsg:[[gradesArray objectAtIndex:indexPath.row]valueForKey:@"categoryId"] UserKey:[userInfo valueForKey:@"userKey"] UserId:[userInfo valueForKey:@"userId"]];
        //把返回信息加入到书籍数组
        //NSLog(@"returnMsg的值%@",returnMsg);
        bookArray=[returnMsg valueForKey:@"data"];
        //加载显示选择书籍的页面
        [self startChooseView];
        //清除原有页面，添加新页面
        [chooseBookView removeFromSuperview];
        [myShelfView removeFromSuperview];
        [synchronousPractice removeFromSuperview];
        [self.view addSubview:startChooseView];
    }
}

#pragma mark --startChooseView
-(void)startChooseView{

    startChooseView=[[UIView alloc]initWithFrame:CGRectMake(0, 137.93, 414, 598.06)];
    startChooseView.backgroundColor=ssRGBHex(0xFCF8F7);
    
    NSUInteger size=bookArray.count;
    float heigh=ceilf(size/3.0)*187.58+26.48;
    UIScrollView* shelfView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 414, 598.06)];
    shelfView.contentSize=CGSizeMake(414, heigh);
    [startChooseView addSubview:shelfView];
    for (int i=0;i<size; i++) {
        float y=26.48+187.58*(i/3);
        float x=11.4+133.58*(i%3);
        UIImageView* book=[[UIImageView alloc]initWithFrame:CGRectMake(x,y, 125.85, 161.1)];
        book.image=[LocalDataOperation getImage:[[bookArray[i]valueForKey:@"book"] valueForKey:@"bookId" ] httpUrl:[[bookArray[i]valueForKey:@"book"] valueForKey:@"coverPicture" ]];
        [book setUserInteractionEnabled:YES];
        [shelfView addSubview:book];
        
        if ([[bookArray[i]valueForKey:@"boughtState"]intValue]==0) {
            UIButton* loadBtn=[[UIButton alloc]initWithFrame:CGRectMake(27.6, 35.31, 70.62, 70.62)];
            [loadBtn setBackgroundImage:[UIImage imageNamed:@"icon_weitianjiadaoshujia"] forState:UIControlStateNormal];
            [loadBtn addTarget:self action:@selector(addBook:) forControlEvents:UIControlEventTouchUpInside];
            loadBtn.tag=i;
            [book addSubview:loadBtn];
        }
    }

}
-(void)addBook:(UIButton*)loadBtn{
    //NSDictionary* userInfo=[DocuOperate readFromPlist:@"userInfo.plist"];
    NSLog(@"bookarray%@",[bookArray objectAtIndex:loadBtn.tag]);
    NSLog(@"userkey%@",[userInfo valueForKey:@"userKey"]);
    NSLog(@"标号%ld",(long)loadBtn.tag);
    NSDictionary* dataDic=[ConnectionFunction addBook:[[[bookArray objectAtIndex:loadBtn.tag] valueForKey:@"book"]valueForKey:@"bookId"] BoughtState:@"2" UserKey:[userInfo valueForKey:@"userKey"]];
    NSLog(@"添加书籍返回的结果是：%@",dataDic);
    if ([[dataDic valueForKey:@"message"]isEqualToString:@"success"]) {
        if ([[dataDic valueForKey:@"data"] isKindOfClass:[NSNull class]]) {
            [self presentViewController:[WarningWindow MsgWithoutTrans:@"这本书已经在您的书架中了！!"] animated:YES completion:nil];
        }else{
            [self presentViewController:[WarningWindow MsgWithoutTrans:@"书籍添加成功!"] animated:YES completion:nil];
            [self myProgressUnfixed];
        }
    }else{
        [self presentViewController:[WarningWindow MsgWithoutTrans:@"书籍添加失败，请稍后再试!"] animated:YES completion:nil];
        
    }
}

#pragma mark --otherFunction
-(void)cleanMsg{
   
    [bookPicView removeFromSuperview];
    [processDetails addSubview:noRecordLabel];
    [noRecordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self->processDetails);
        make.centerX.equalTo(self->processDetails);
        make.width.equalTo(@77.27);
        make.height.equalTo(@18.75);
    }];
    
    [processFixView removeFromSuperview];
    [refreshPanelProcess removeFromSuperview];
    [bookScanView removeFromSuperview];
    
    //提示框
    [self presentViewController:[WarningWindow transToLogin:@"您尚未登录！" Navigation:self.navigationController]
                       animated:YES
                     completion:nil];
}

#pragma mark --push
-(void)pushToUser{
    if (userMsg==nil) {
        userMsg = [[UserMsg alloc]init];
    }
    if(![self.navigationController.topViewController isKindOfClass:[userMsg class]]) {
        [self.navigationController pushViewController:userMsg animated:true];
    }
}

-(void)pushToUnit:(UIButton*)btn{
    if (unitMsg==nil) {
        unitMsg = [[UnitViewController alloc]init];
    }
    if(![self.navigationController.topViewController isKindOfClass:[unitMsg class]]) {
        
        [self->processDic setValue:[[[self->bookshelfArray objectAtIndex:btn.tag]valueForKey:@"userBook"]valueForKey:@"bookId"] forKey:@"picture"];
        
        JobBlock myblock = ^{
            [DocuOperate replacePlist:@"process.plist" dictionary:self->processDic];
        };
        
        [MyThreadPool executeJob:myblock Main:^{NSLog(@"被点击的书架的id是%@",[[[self->bookshelfArray objectAtIndex:btn.tag]valueForKey:@"userBook"]valueForKey:@"bookId"]);}];
       
        //    NSDictionary* dic=[ConnectionFunction getBookLearnMsg:[userInfo valueForKey:@"userKey"] Id:[[[bookshelfArray objectAtIndex:btn.tag]valueForKey:@"userBook"]valueForKey:@"bookId"]];
        //    NSLog(@"新接口的信息是%@",[dic valueForKey:@"data"]);
        
        //这个接口中还没有书籍名称这一条信息，
        
        unitMsg.bookId=[[[bookshelfArray objectAtIndex:btn.tag]valueForKey:@"userBook"]valueForKey:@"bookId"];
        unitMsg.bookName=[[bookshelfArray objectAtIndex:btn.tag]valueForKey:@"bookName"];
        unitMsg.recentLesson=[[[[ConnectionFunction recentLearnMsgByBook:[userInfo valueForKey:@"userKey"] Id:unitMsg.bookId] valueForKey:@"data"] valueForKey:@"article"]valueForKey:@"articleName" ];
        NSLog(@"点击书本的最新学习信息%@",unitMsg.recentLesson);
        [self.navigationController pushViewController:unitMsg animated:true];
    }
    
   
    
    
    
}
-(void)recentBookPushToUnit{
    if (unitMsg==nil) {
        unitMsg = [[UnitViewController alloc]init];
    }
    if(![self.navigationController.topViewController isKindOfClass:[unitMsg class]]) {
    unitMsg.bookId=[recentBook valueForKey:@"bookId"];
    unitMsg.bookName=[recentBook valueForKey:@"bookName"];
    unitMsg.recentLesson=[[[recentLearnMsg valueForKey:@"data"]valueForKey:@"article"]valueForKey:@"articleName"];
    NSLog(@"书本信息%@",recentBook);
    [self.navigationController pushViewController:unitMsg animated:true];
    }
}

-(void)pushToLoginView{
    if (loginView==nil) {
        loginView = [[LoginViewController alloc]init];
    }
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]) {
        [self.navigationController pushViewController:loginView animated:true];
    }
}

-(void)pushToMyShelfView{
    if (myShelfVC==nil) {
        myShelfVC = [[MyShelfViewController alloc]init];
    }
    if(![self.navigationController.topViewController isKindOfClass:[myShelfVC class]]) {
        [self.navigationController pushViewController:myShelfVC animated:true];
    }
}

-(void)pushToMoreRecommend{
    if (moreRecommend==nil) {
        moreRecommend = [[MoreRecommendViewController alloc]init];
    }
    if(![self.navigationController.topViewController isKindOfClass:[moreRecommend class]]) {
        [self.navigationController pushViewController:moreRecommend animated:true];
    }

}

-(void)pushToWordsListen{
    if (wordsListening==nil) {
        wordsListening = [[WordsListeningViewController alloc]init];
    }
    if(![self.navigationController.topViewController isKindOfClass:[wordsListening class]]) {
        wordsListening.bookId=[recentBook valueForKey:@"bookId"];
        
        [self.navigationController pushViewController:wordsListening animated:true];
    }
}

-(void)pushToSentenceListen{
    if (sentenceListening==nil) {
        sentenceListening = [[SentenceListeningViewController alloc]init];
    }
    if(![self.navigationController.topViewController isKindOfClass:[sentenceListening class]]) {
        sentenceListening.bookId=[recentBook valueForKey:@"bookId"];;
        [self.navigationController pushViewController:sentenceListening animated:true];
    }
    
}

-(void)pushToWordsTest:(UIButton*)btn{
    if (wordsTest==nil) {
        wordsTest = [[WordsTestViewController alloc]init];
        wordsTest.recentBookId=[recentBook valueForKey:@"bookId"];
    }
    if(![self.navigationController.topViewController isKindOfClass:[wordsTest class]]) {
        if (btn.tag==1) {
            wordsTest.testType=@"word";
        }else{
            wordsTest.testType=@"sentence";
        }
        [self.navigationController pushViewController:wordsTest animated:true];
    }
    
}
-(void)pushToWrong{
    if (wrongNoteView==nil) {
        wrongNoteView = [[WrongNotesViewController alloc]init];
        wrongNoteView.recentBookId=[recentBook valueForKey:@"bookId"];
    }
    if(![self.navigationController.topViewController isKindOfClass:[wrongNoteView class]]) {
        wrongNoteView.testType=@"wrong";
        [self.navigationController pushViewController:wrongNoteView animated:true];
    }
    
}

//-(void)pushToSentencesTest{
//    if (sentencesTest==nil) {
//        sentencesTest=[[SentencesTestViewController alloc]init];
//        sentencesTest.recentBookId=[recentBook valueForKey:@"bookId"];
//    }
//    [self.navigationController pushViewController:sentencesTest animated:true];
//}

#pragma mark network

-(void)netWorkStateChange:(NSNotification*)note{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus status = [curReach currentReachabilityStatus];

    if (status == NotReachable) {
        NSLog(@"无网络连接");
         [self presentViewController:[WarningWindow ExitAPP:@"网络无连接！"]
                                                     animated:YES completion:nil];
    }else if(status == ReachableViaWiFi){
        NSLog(@"Wifi");
    }else{
        NSLog(@"3G/4G/5G");
    }
}
- (BOOL)updateInterfaceWithReachability:(Reachability *)reachability{
    BOOL flag = false;
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    switch (netStatus) {
        case NotReachable:
            NSLog(@"无网络");
            [self presentViewController:[WarningWindow ExitAPP:@"网络无连接！"]
                                                        animated:YES completion:nil];
            break;
        case ReachableViaWiFi:
            NSLog(@"WIFI");
            flag = true;
            break;
        case ReachableViaWWAN:
            NSLog(@"手机网络");
            flag = true;
            break;
        default:
            break;
    }
    return flag;
}

-(void)dealloc{
    [self.conn stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

