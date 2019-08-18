//
//  ChooseLessonView.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/22.
//  Copyright © 2018年 马一轩. All rights reserved.
//

#import "ChooseLessonView.h"
#import "../Functions/ConnectionFunction.h"
#import "../Functions/DocuOperate.h"
#import "../LearningViewController.h"
#import "../Functions/DownloadAudioService.h"
#import "../Functions/MyThreadPool.h"
#import "../Functions/AgentFunction.h"
#import "../Functions/WarningWindow.h"
#import "Masonry.h"

@interface ChooseLessonView()<UITableViewDataSource,UITableViewDelegate>{
    ChooseLessonView* chooseLessonView;
    LearningViewController* learnView;
    //存储选择单元
    NSArray* unitArray;
    UITableViewCell* cell;
    //存储用户信息
    NSDictionary* userInfo;
    //课名tableview
    UITableView* lessonList;
    //图书照片数组，元素为字典
    //NSArray* bookPicArray;
    //书籍句子数组
    NSArray* sentenceArray;
}
@end

@implementation ChooseLessonView
-(id)initWithBookId:(NSString*)bookid DefaultUnit:(NSInteger)defaultunit ShowBlock:(ShowContentBlock)showContentBlock{
    self=[super init];
    if (self) {
        self.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        userInfo=[DocuOperate readFromPlist:@"userInfo.plist"];
        _bookId=bookid;
        _defaultUnit=defaultunit;
        _showContentBlock=showContentBlock;
        [self unitMsgInit];
        //初始化数组
        _lessonArray=[[NSArray alloc]init];
        _dataArray=[[NSDictionary alloc]init];
        sentenceArray=[[NSArray alloc]init];
    
        UITableView* unitsList=[[UITableView alloc]init];
        unitsList.dataSource=self;
        unitsList.delegate=self;
        unitsList.tag=1;
        [self addSubview:unitsList];
        
        [unitsList mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.left.equalTo(self);
            make.width.equalTo(self.mas_width).multipliedBy(0.4);
            make.height.equalTo(@397.24);
        }];
        
//        [unitsList reloadData];
        NSIndexPath* _lastIndex = [NSIndexPath indexPathForRow:_defaultUnit inSection:0];
        [unitsList selectRowAtIndexPath:_lastIndex animated:YES scrollPosition:UITableViewScrollPositionNone];
        NSIndexPath *path = [NSIndexPath indexPathForItem:_defaultUnit inSection:0];
        [self tableView:unitsList didSelectRowAtIndexPath:path];
        
        lessonList=[[UITableView alloc]init];
        lessonList.dataSource=self;
        lessonList.delegate=self;
        lessonList.tag=2;
        [self addSubview:lessonList];
        
        [lessonList mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.right.equalTo(self);
            make.width.equalTo(self).multipliedBy(0.6);
            make.height.equalTo(@397.24);
        }];
    }
    return self;
}
-(void)unitMsgInit{
    NSDictionary*  dataDic=[ConnectionFunction getUnitMsg:_bookId UserKey:[userInfo valueForKey:@"userKey"]];
    unitArray=[dataDic valueForKey:@"data"];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag==3){
        return 12;
    }else if(tableView.tag==1){
        return unitArray.count;
    }else if(tableView.tag==2){
        return _lessonArray.count ;
    }else{
        return 2;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"flag";
    tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    if (tableView.tag==1){
        //单元选择列表
    
        NSDictionary* unitMsg=unitArray[indexPath.row];
        
        cell.backgroundColor=ssRGBHex(0xFF7474);
        cell.selectedBackgroundView = [UIView new];
        cell.selectedBackgroundView.backgroundColor = [UIColor whiteColor];
        cell.textLabel.text=[unitMsg valueForKey:@"unitName"];
        cell.textLabel.font=[UIFont systemFontOfSize:14];
        cell.textLabel.textColor=[UIColor whiteColor];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        cell.tag=indexPath.row;
        
        if (indexPath.row == _defaultUnit) {
            cell.textLabel.textColor=[UIColor blackColor];
        }
        return cell;
    }else if (tableView.tag==2){
        //课程选择列表
        NSDictionary* lessonMsg=_lessonArray[indexPath.row];
        cell.textLabel.text=[lessonMsg valueForKey:@"articleName"];
        cell.textLabel.font=[UIFont systemFontOfSize:14];
        cell.textLabel.textColor=ssRGBHex(0x9B9B9B);
        cell.selectedBackgroundView = [UIView new];
        cell.selectedBackgroundView.backgroundColor = [UIColor whiteColor];
        cell.tag=[[lessonMsg valueForKey:@"articleId"]intValue];
        return cell;
    }
    else{
        return nil;
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView.tag==1){
        return 44.13;
    }else if(tableView.tag==2){
        return 44.13 ;
    }else{
        return 52.96;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* celltwo=[tableView cellForRowAtIndexPath:indexPath];
    if (tableView.tag==1) {
        celltwo.textLabel.textColor=[UIColor blackColor];
        NSDictionary* dataDic=[ConnectionFunction getClassMsg:[[unitArray objectAtIndex:celltwo.tag] valueForKey:@"unitId"] UserKey:[userInfo valueForKey:@"userKey"]];
        _lessonArray=[dataDic valueForKey:@"data"];
        _unitName=[[unitArray objectAtIndex:celltwo.tag] valueForKey:@"unitName"];
        [lessonList reloadData];
    }else{
        celltwo.textLabel.textColor=ssRGBHex(0xFF7474);
        _articleId=[[_lessonArray objectAtIndex:indexPath.row] valueForKey:@"articleId"];
        NSDictionary* dataDic=[ConnectionFunction getLessonMsg:_articleId UserKey:[userInfo valueForKey:@"userKey"]];
        _dataArray=[dataDic valueForKey:@"data"];
        NSDictionary* lessonMsg=_lessonArray[indexPath.row];
        _className=[lessonMsg valueForKey:@"articleName"];
        
        NSDictionary* buyState=[ConnectionFunction articleBuyState:_articleId UserKey:[userInfo valueForKey:@"userKey"]];
        //判断字典内容为空
        if ([[buyState valueForKey:@"data"] isKindOfClass:[NSNull class]]) {
            NSLog(@"您还未购买该课程");
            
            [[AgentFunction theTopviewControler]
             presentViewController:
             [self warnWindow:@"您还未购买该课程，购买该课程需要100学分！"]
             animated:YES
             completion:nil];
            
        }else{
            _showContentBlock([_dataArray valueForKey:@"bookPictures"],
                              [_dataArray valueForKey:@"bookSentences"],
                              [[[_dataArray valueForKey:@"bookSentences"]objectAtIndex:0] valueForKey:@"articleId"],
                              _unitName,_className);
        }
    }
    
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* celltwo=[tableView cellForRowAtIndexPath:indexPath];
    if (tableView.tag==1) {
        celltwo.textLabel.textColor=[UIColor whiteColor];
    }else{
        celltwo.textLabel.textColor=ssRGBHex(0x9B9B9B);
    }
}

#pragma mark 用户提示框
-(UIAlertController*)warnWindow:(NSString*)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示信息" message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"购买" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        int score=[[[ConnectionFunction getScore:[self->userInfo valueForKey:@"userKey"]]valueForKey:@"data"]intValue];
        if (score>=100) {
            self->_showContentBlock([self->_dataArray valueForKey:@"bookPictures"],
                              [self->_dataArray valueForKey:@"bookSentences"],
                              [[[self->_dataArray valueForKey:@"bookSentences"]objectAtIndex:0] valueForKey:@"articleId"],
                              self->_unitName,self->_className);
        }
        else{
            [[AgentFunction theTopviewControler] presentViewController:[WarningWindow MsgWithoutTrans:@"您的学分不足，请充值！"] animated:YES completion:nil];
        }
        
        
        
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:action1];
    [alert addAction:action2];
    
    return alert;
}
@end
