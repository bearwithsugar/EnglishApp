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

//使控制台打印完整信息
//#ifdef DEBUG
//#define NSLog(FORMAT, ...) fprintf(stderr, "%s:%zd\t%s\n", [[[NSString stringWithUTF8String: __FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat: FORMAT, ## __VA_ARGS__] UTF8String]);
//#else
//#define NSLog(FORMAT, ...) nil
//#endif


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
    //课程数组
    //NSArray* c
}
@end

@implementation ChooseLessonView
-(id)initWithFrame:(CGRect)frame bookId:(NSString*)bookid DefaultUnit:(NSInteger)defaultunit ShowBlock:(ShowContentBlock)showContentBlock{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        userInfo=[DocuOperate readFromPlist:@"userInfo.plist"];
        _bookId=bookid;
        _defaultUnit=defaultunit;
        _showContentBlock=showContentBlock;
        [self unitMsgInit];
        //初始化数组
        _lessonArray=[[NSArray alloc]init];
        _dataArray=[[NSArray alloc]init];
        sentenceArray=[[NSArray alloc]init];
    
        UITableView* unitsList=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, 150, 397.24)];
        unitsList.dataSource=self;
        unitsList.delegate=self;
        unitsList.tag=1;
//        [self tableView:unitsList didSelectRowAtIndexPath:[NSIndexPath indexPathForItem:3 inSection:0]];
        [self addSubview:unitsList];
//        [unitsList reloadData];
        NSIndexPath* _lastIndex = [NSIndexPath indexPathForRow:_defaultUnit inSection:0];
        [unitsList selectRowAtIndexPath:_lastIndex animated:YES scrollPosition:UITableViewScrollPositionNone];
        NSIndexPath *path = [NSIndexPath indexPathForItem:_defaultUnit inSection:0];
        [self tableView:unitsList didSelectRowAtIndexPath:path];
        
        lessonList=[[UITableView alloc]initWithFrame:CGRectMake(150, 0, 264, 397.24)];
        lessonList.dataSource=self;
        lessonList.delegate=self;
        lessonList.tag=2;
        [self addSubview:lessonList];
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
    
        //NSString* title=[chooseLessonArray objectAtIndex:indexPath.row];
        
        NSDictionary* unitMsg=unitArray[indexPath.row];
        
        cell.backgroundColor=ssRGBHex(0xFF7474);
        cell.selectedBackgroundView = [UIView new];
        cell.selectedBackgroundView.backgroundColor = [UIColor whiteColor];
        cell.textLabel.text=[unitMsg valueForKey:@"unitName"];
        cell.textLabel.font=[UIFont systemFontOfSize:14];
        cell.textLabel.textColor=[UIColor whiteColor];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        //cell.tag=[[unitMsg valueForKey:@"unitId"]intValue];
        cell.tag=indexPath.row;
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
//        NSLog(@"点击的cell的tag是%ld",(long)celltwo.tag);
//        NSLog(@"点击的cell的tag是%@",[unitArray objectAtIndex:celltwo.tag]);
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
        
        _showContentBlock([_dataArray valueForKey:@"bookPictures"],[_dataArray valueForKey:@"bookSentences"],[[[_dataArray valueForKey:@"bookSentences"]objectAtIndex:0] valueForKey:@"articleId"],_unitName,_className);
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
@end
