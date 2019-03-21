//
//  UserMsgTableViewCell.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/24.
//  Copyright © 2018 马一轩. All rights reserved.
//

#import "UserMsgTableViewCell.h"
@interface UserMsgTableViewCell(){
    NSArray* saintArray;
}
@property (weak, nonatomic) IBOutlet UIImageView *jiantou;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIImageView *logoImg;
@end


@implementation UserMsgTableViewCell
@synthesize jiantou=_jiantou;
@synthesize title=_title;
@synthesize logoImg=_logoImg;

+(instancetype)createCellWithTableView:(UITableView*)tableView{
    static NSString* id=@"flag";
    UserMsgTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:id];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle]loadNibNamed:@"UserMsgTableViewCell" owner:nil options:nil]lastObject];
    }
    return cell;
}
-(void)loadData:(NSString*)label1 logoImg:(NSString*)image {
    self.title.text=label1;
    self.logoImg.image=[UIImage imageNamed:image];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.title.font=[UIFont systemFontOfSize:14];
    self.jiantou.image=[UIImage imageNamed:@"icon_foward"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
