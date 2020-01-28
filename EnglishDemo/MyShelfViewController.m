//
//  myShelfViewController.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/18.
//  Copyright © 2018年 马一轩. All rights reserved.
//

#import "MyShelfViewController.h"
#import "Functions/DocuOperate.h"
#import "Functions/ConnectionFunction.h"
#import "UnitViewController.h"
#import "Functions/LocalDataOperation.h"
#import "Functions/WarningWindow.h"
#import "Common/LoadGif.h"
#import "Common/HeadView.h"
#import "Functions/ConnectionInstance.h"
#import "Functions/MyThreadPool.h"
#import "DiyGroup/UnloginMsgView.h"
#import "DiyGroup/ChooseBookView.h"
#import "AgentFunction.h"
#import "Masonry.h"

@interface MyShelfViewController (){
   // NSDictionary* shelf
    NSArray* bookArray;
    NSArray* chooseBookArray;
    //用户信息字典
    NSDictionary* userInfo;
    //请求书架返回信息字典
    NSDictionary* shelfDic;
    //跳转单元的界面
    UnitViewController* unitMsg;
    
    UIImageView* loadGif;
    UIView* chooseBookView;
    UIView* startChooseView;
    UIButton* cancelBtn;
    
    NSMutableDictionary* processDic;
    
    UIScrollView* shelfView;
}

@end

@implementation MyShelfViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    [self titleShow];
    
    //加载gif动画
    loadGif=[LoadGif imageViewStartAnimating];
    [self.view addSubview:loadGif];
    
    [loadGif mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view);
        make.centerX.equalTo(self.view);
        make.width.equalTo(@60);
        make.height.equalTo(@60);
    }];

    if([DocuOperate fileExistInPath:@"process.plist"]){
        NSDictionary* dic=[DocuOperate readFromPlist:@"process.plist"];
        for (int i=0; i<[dic allKeys].count; i++) {
            [processDic setValue:[dic valueForKey:[[dic allKeys]objectAtIndex:i]]
                          forKey:[[dic allKeys]objectAtIndex:i]];
        }
    }else{
        processDic = [NSMutableDictionary new];
    }
}
-(void)viewWillAppear:(BOOL)animated{
  
    [MyThreadPool executeJob:^{
        self->userInfo=[[NSDictionary alloc]initWithDictionary:[DocuOperate readFromPlist:@"userInfo.plist"]];
    } Main:^{
        if (!self->userInfo || self->userInfo.count == 0) {
              [self->shelfView removeFromSuperview];
              UnloginMsgView* unloginView=[[UnloginMsgView alloc]init];
              [self.view addSubview:unloginView];
              [unloginView mas_makeConstraints:^(MASConstraintMaker *make) {
                  make.top.equalTo(self.view).with.offset(88.27);
                  make.left.equalTo(self.view);
                  make.right.equalTo(self.view);
                  make.bottom.equalTo(self.view);
              }];
              return;
           }else{
               JobBlock initBookBlock = ^{
                      self->shelfDic=[ConnectionFunction getBookShelf:[self->userInfo valueForKey:@"userKey"]];
                      self->bookArray=[self->shelfDic valueForKey:@"data"];
                  };
                  
                  [MyThreadPool executeJob:initBookBlock Main:^{
                      [self->shelfView removeFromSuperview];
                      [self bookView];
                      //k加载完成，取消动画
                      [self->loadGif removeFromSuperview];
                  }];
           }
    }];
    
}
-(void)titleShow{
    [HeadView titleShow:@"我的书架" Color:ssRGBHex(0xFF7474) UIView:self.view UINavigationController:self.navigationController];
}

-(void)bookView{
    
    CGRect rect_screen = [[UIScreen mainScreen]bounds];
    
    CGSize size_screen = rect_screen.size;
    
    NSInteger totalWidth = size_screen.width;
    
    float picWidth = (totalWidth - (4*12))/3;
    
    float picHeight = picWidth * 1.28;
    
    NSUInteger size=bookArray.count;
    float heigh=ceilf(size/3.0)*187.58+26.48;
    shelfView=[[UIScrollView alloc]init];
    shelfView.contentSize=CGSizeMake(totalWidth, heigh);
    [self.view addSubview:shelfView];
    
    [shelfView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(88.27);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    for (int i=0;i<size; i++) {
        float y=26 + (picHeight+26)*(i/3);
        float x=12 + (picWidth+12)*(i%3);
        UIButton* theBook=[[UIButton alloc]initWithFrame:CGRectMake(x,y, picWidth, picHeight)];
        
        theBook.layer.borderWidth=1.0;
        
        theBook.layer.borderColor=ssRGBHex(0x979797).CGColor;

        [theBook setBackgroundImage:
         [LocalDataOperation getImage:[[[bookArray objectAtIndex:i]
                                        valueForKey:@"userBook"]
                                       valueForKey:@"bookId"]
                              httpUrl:[[bookArray objectAtIndex:i]
                                       valueForKey:@"coverPicture"]]
                           forState:UIControlStateNormal];
        theBook.tag=i;
        [theBook addTarget:self action:@selector(clickBook:) forControlEvents:UIControlEventTouchUpInside];
        [shelfView addSubview:theBook];
        

    }
    
    //'添加课本'图标
    float y=26 +(picHeight+26)*((size)/3);
    float x=12 +(picWidth+12)*((size)%3);
    UIButton* addBook=[[UIButton alloc]initWithFrame:CGRectMake(x, y, picWidth, picHeight)];
    [addBook setBackgroundImage:[UIImage imageNamed:@"btn_tianjiakeben"] forState:UIControlStateNormal];
    [addBook addTarget:self action:@selector(addBook) forControlEvents:UIControlEventTouchUpInside];
    [shelfView addSubview:addBook];
}
-(void)clickBook:(UIButton*)theBook{
    NSDictionary* dic=[bookArray objectAtIndex:theBook.tag];
    [self pushToUnit:[[dic valueForKey:@"userBook"]valueForKey:@"bookId"] Name:[dic valueForKey:@"bookName"]];
    
}
-(void)addBook{
    [self chooseBook];
}
-(void)chooseBook{
    if (cancelBtn == nil) {
        cancelBtn = [[UIButton alloc]init];
        [cancelBtn setTitle:@"取消选择" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:ssRGBHex(0xFD7272) forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelChoose) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.view addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(90);
        make.left.equalTo(self.view).with.offset(100);
        make.right.equalTo(self.view).with.offset(-100);
        make.height.equalTo(@40);
    }];

    
    NSIntegerBlock myBlock = ^(NSInteger row,NSArray* gradesArr){
        //选择完年级和出版社之后返回的书籍信息y
        NSDictionary* returnMsg=[ConnectionFunction getBookMsg:[[gradesArr objectAtIndex:row]valueForKey:@"categoryId"] UserKey:[self->userInfo valueForKey:@"userKey"] UserId:[self->userInfo valueForKey:@"userId"]];
        //把返回信息加入到书籍数组
        self->chooseBookArray=[returnMsg valueForKey:@"data"];
        //加载显示选择书籍的页面
        [self startChooseView];
        //清除原有页面，添加新页面
        [self.view addSubview:self->startChooseView];
        [self->startChooseView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self->chooseBookView.mas_bottom);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
    };;
    
    [shelfView removeFromSuperview];
    
    if (chooseBookView==nil) {
        chooseBookView=[[ChooseBookView alloc]initWithBlock:myBlock UserKey:[userInfo valueForKey:@"userKey"]];
    }
    [self.view addSubview:chooseBookView];
    [chooseBookView mas_makeConstraints:^(MASConstraintMaker *make) {
       make.top.equalTo(self.view).with.offset(140);
       make.left.equalTo(self.view);
       make.right.equalTo(self.view);
       make.height.equalTo(@250);
    }];
}

-(void)startChooseView{
    startChooseView=[[UIView alloc]init];
    startChooseView.backgroundColor=ssRGBHex(0xFCF8F7);
    NSUInteger size=chooseBookArray.count;
    float heigh=ceilf(size/3.0)*187.58+26.48;
    UIScrollView* shelfView=[[UIScrollView alloc]init];
    shelfView.contentSize=CGSizeMake(414, heigh);
    [startChooseView addSubview:shelfView];
    [shelfView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(startChooseView);
       }];
    
    for (int i=0;i<size; i++) {
        float y=26.48+187.58*(i/3);
        float x=11.4+133.58*(i%3);
        UIImageView* book=[[UIImageView alloc]initWithFrame:CGRectMake(x,y, 125.85, 161.1)];
        book.image=[LocalDataOperation getImage:[[chooseBookArray[i]valueForKey:@"book"] valueForKey:@"bookId" ] httpUrl:[[chooseBookArray[i]valueForKey:@"book"] valueForKey:@"coverPicture" ]];
        [book setUserInteractionEnabled:YES];
        [shelfView addSubview:book];
        
        UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(haveAdd)];
        
        if ([[chooseBookArray[i]valueForKey:@"boughtState"]intValue]==0&&
            userInfo) {
            UIButton* loadBtn=[[UIButton alloc]initWithFrame:CGRectMake(27.6, 35.31, 70.62, 70.62)];
            [loadBtn setBackgroundImage:[UIImage imageNamed:@"icon_weitianjiadaoshujia"] forState:UIControlStateNormal];
            [loadBtn addTarget:self action:@selector(addBook:) forControlEvents:UIControlEventTouchUpInside];
            loadBtn.tag=i;
            [book addSubview:loadBtn];
        }else{
            [book addGestureRecognizer:gesture];
        }
    }

}
-(void)cancelChoose{
    [cancelBtn removeFromSuperview];
    [chooseBookView removeFromSuperview];
    [startChooseView removeFromSuperview];
    [self bookView];
}

-(void)addBook:(UIButton*)loadBtn{
    //NSDictionary* userInfo=[DocuOperate readFromPlist:@"userInfo.plist"];
    NSLog(@"bookarray%@",[chooseBookArray objectAtIndex:loadBtn.tag]);
    NSLog(@"userkey%@",[userInfo valueForKey:@"userKey"]);
    NSLog(@"标号%ld",(long)loadBtn.tag);
    NSDictionary* dataDic=[ConnectionFunction addBook:[[[chooseBookArray objectAtIndex:loadBtn.tag] valueForKey:@"book"]valueForKey:@"bookId"] BoughtState:@"2" UserKey:[userInfo valueForKey:@"userKey"]];
    NSLog(@"添加书籍返回的结果是：%@",dataDic);
    if ([[dataDic valueForKey:@"message"]isEqualToString:@"success"]) {
        if ([[dataDic valueForKey:@"data"] isKindOfClass:[NSNull class]]) {
            [self presentViewController:[WarningWindow MsgWithoutTrans:@"这本书已经在您的书架中了！!"] animated:YES completion:nil];
        }else{
            [[AgentFunction theTopviewControler] presentViewController:[WarningWindow MsgWithoutTrans:@"书籍添加成功!"] animated:YES completion:nil];
        }
    }else{
        [self presentViewController:[WarningWindow MsgWithoutTrans:@"书籍添加失败，请稍后再试!"] animated:YES completion:nil];
    }
}

-(void)haveAdd{
    [self presentViewController:[WarningWindow MsgWithoutTrans:@"这本书已经在您的书架中了！!"] animated:YES completion:nil];
}

-(void)popBack{
    [cancelBtn removeFromSuperview];
    [chooseBookView removeFromSuperview];
    [startChooseView removeFromSuperview];
    [self.navigationController popViewControllerAnimated:true];
}

-(void)pushToUnit:(NSString*)bookid Name:(NSString*)bookname{
//    if (unitMsg==nil) {
//        unitMsg = [[UnitViewController alloc]init];
//    }
    unitMsg = [[UnitViewController alloc]init];
    
    if(![self.navigationController.topViewController isKindOfClass:[unitMsg class]]) {
        NSLog(@"被点击的书架的id是%@",bookid);
        [processDic setValue:bookid forKey:@"picture"];
        [DocuOperate replacePlist:@"process.plist" dictionary:processDic];
        
        unitMsg.bookId=bookid;
        unitMsg.bookName=bookname;
        ConnectionInstance* con = [[ConnectionInstance alloc]init];
        unitMsg.recentLesson=[[[[con recentLearnMsgByBook:[userInfo valueForKey:@"userKey"] Id:bookid] valueForKey:@"data"] valueForKey:@"article"]valueForKey:@"articleName" ];
        NSLog(@"点击书本的最新学习信息%@",unitMsg.recentLesson);
        [self.navigationController pushViewController:unitMsg animated:true];
    }

}


@end
