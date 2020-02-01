//
//  ChooseBookView.m
//  EnglishDemo
//
//  Created by 马一轩 on 2020/1/28.
//  Copyright © 2020 马一轩. All rights reserved.
//

#import "ChooseBookView.h"
#import "ChoosePublishTableViewCell.h"
#import "../Functions/netOperate/ConnectionFunction.h"
#import "../Functions/netOperate/NetSenderFunction.h"
#import "Masonry.h"

@interface ChooseBookView()<UITableViewDelegate,UITableViewDataSource>{
    UITableView* choosePublishTable;
    UITableView* chooseGradeTable;
    NSDictionary* publicationMsgDic;
}

@end

@implementation ChooseBookView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(id)initWithBlock:(NSIntegerBlock)block User:(NSString*)user PublicationArray:(NSArray*)array{
    self = [super init];
    if(self){
        _jobBlock = block;
        _userKey = user;
//
//        publicationMsgDic=[ConnectionFunction getLineByType:@"3" UserKey:user];
//           //存放列表对象的数组，每个元素是一个字典
//        _publicationArray=[publicationMsgDic valueForKey:@"data"];
        _publicationArray = array;
        choosePublishTable=[[UITableView alloc]init];
        choosePublishTable.dataSource=self;
        choosePublishTable.delegate=self;
        choosePublishTable.tag=4;
        [self addSubview:choosePublishTable];

        chooseGradeTable=[[UITableView alloc]init];
        chooseGradeTable.dataSource=self;
        chooseGradeTable.delegate=self;
        chooseGradeTable.tag=3;
        [self addSubview:chooseGradeTable];
        
        //无内容时不显示下划线
        UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
        [chooseGradeTable setTableFooterView:v];

        [chooseGradeTable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.left.equalTo(self);
            make.width.equalTo(self).multipliedBy(0.55);
            make.height.equalTo(@250);
        }];

        [choosePublishTable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.right.equalTo(self);
            make.width.equalTo(self).multipliedBy(0.45);
            make.height.equalTo(@250);
        }];

    }
    return self;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag==4) {
        return _publicationArray.count;
    }else{
        return _gradesArray.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"flag";
    //取消分割线
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (tableView.tag==4) {
        ChoosePublishTableViewCell* cell;
        for (int i=0; i<_publicationArray.count; i++) {
            if (indexPath.row==i) {
                cell=[ChoosePublishTableViewCell createCellWithTableView:tableView];
                NSDictionary* publicationMsg=_publicationArray[i];
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

        for (int i=0; i<_gradesArray.count; i++) {
             if (indexPath.row==i) {
                 NSDictionary* gradeMsg=_gradesArray[i];
                 cell.textLabel.text=[gradeMsg valueForKey:@"categoryName"];
                 NSLog(@"获取到的出版社id%@",[gradeMsg valueForKey:@"categoryId"]);
                 cell.tag=[[gradeMsg valueForKey:@"categoryId"]integerValue];

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
        ConBlock conBlk = ^(NSDictionary* dic){
            NSLog(@"年级数组是：%@",[dic valueForKey:@"data"]);
            //赋值给年级数组
            dispatch_async(dispatch_get_main_queue(), ^{
                self->_gradesArray=[dic valueForKey:@"data"];
                [self->chooseGradeTable reloadData];
            });
        };
        NetSenderFunction* sender = [[NetSenderFunction alloc]init];
        [sender getRequest:[[ConnectionFunction getInstance]getLineByParent_Get_H:[[_publicationArray objectAtIndex:indexPath.row]valueForKey:@"categoryId"]]
                             Block:conBlk];
        
    }else{
        _jobBlock(indexPath.row,_gradesArray);
    }
}


@end
