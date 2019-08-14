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
#import "Masonry.h"

@interface MyShelfViewController (){
   // NSDictionary* shelf
    NSArray* bookArray;
    //用户信息字典
    NSDictionary* userInfo;
    //请求书架返回信息字典
    NSDictionary* shelfDic;
    //跳转单元的界面
    UnitViewController* unitMsg;
    
    NSMutableDictionary* processDic;
}

@end

@implementation MyShelfViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    [self titleShow];
    userInfo=[[NSDictionary alloc]initWithDictionary:[DocuOperate readFromPlist:@"userInfo.plist"]];
    shelfDic=[ConnectionFunction getBookShelf:[userInfo valueForKey:@"userKey"]];
    bookArray=[shelfDic valueForKey:@"data"];
    NSLog(@"这个书架共有%lu本书",(unsigned long)bookArray.count);
    
    //加载gif动画
    UIImageView* loadGif=[LoadGif imageViewStartAnimating];
    [self.view addSubview:loadGif];
    
    [loadGif mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view);
        make.centerX.equalTo(self.view);
        make.width.equalTo(@60);
        make.height.equalTo(@60);
    }];
    
    [self bookView];
    
    //k加载完成，取消动画
    [loadGif removeFromSuperview];

    if([DocuOperate fileExistInPath:@"process.plist"]){
        NSDictionary* dic=[DocuOperate readFromPlist:@"process.plist"];
        for (int i=0; i<[dic allKeys].count; i++) {
            [processDic setValue:[dic valueForKey:[[dic allKeys]objectAtIndex:i]]
                          forKey:[[dic allKeys]objectAtIndex:i]];
        }
    }
}
-(void)viewWillAppear:(BOOL)animated{
    bookArray=[shelfDic valueForKey:@"data"];
//    NSLog(@"打印bookarray：%@",bookArray);
    
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
    UIScrollView* shelfView=[[UIScrollView alloc]init];
    shelfView.contentSize=CGSizeMake(414, heigh);
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
    [self presentViewController:[WarningWindow MsgWithoutTrans:@"请返回主页点击选择课本进行选课！"]
                       animated:YES
                     completion:nil];
}
-(void)popBack{
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
