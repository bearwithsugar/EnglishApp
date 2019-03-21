//
//  XuefenTableViewCell.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/24.
//  Copyright © 2018 马一轩. All rights reserved.
//

#import "XuefenTableViewCell.h"
@interface XuefenTableViewCell(){
    
}
@property (weak, nonatomic) IBOutlet UILabel *goDischarge;
@property (weak, nonatomic) IBOutlet UILabel *fen;
@property (weak, nonatomic) IBOutlet UILabel *xuefenNumber;
@property (weak, nonatomic) IBOutlet UIImageView *logo;
@property (weak, nonatomic) IBOutlet UIImageView *jiantou;
@property (weak, nonatomic) IBOutlet UILabel *title;
@end
@implementation XuefenTableViewCell
@synthesize fen=_fen;
@synthesize xuefenNumber=_xuefenNumber;
@synthesize logo=_logo;
@synthesize jiantou=_jiantou;
@synthesize title=_title;
@synthesize goDischarge=_goDischarge;

+(instancetype)createCellWithTableView:(UITableView*)tableView{
    static NSString* id=@"flag";
    XuefenTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:id];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle]loadNibNamed:@"XuefenTableViewCell" owner:nil options:nil]lastObject];
    }
    return cell;
}
-(void)loadData:(NSString*)label1{
    self.xuefenNumber.text=label1;
    self.xuefenNumber.textColor=ssRGBHex(0xFF7474);
    self.xuefenNumber.textAlignment=NSTextAlignmentCenter;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.logo.image=[UIImage imageNamed:@"icon_qianbao"];
    self.title.text=@"剩余学分";
    self.title.font=[UIFont systemFontOfSize:14];
    self.goDischarge.text=@"去充值";
    self.goDischarge.textColor=ssRGBHex(0xFF7474);
    self.goDischarge.font=[UIFont systemFontOfSize:14];
    self.jiantou.image=[UIImage imageNamed:@"icon_foward"];
    self.fen.text=@"分";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
