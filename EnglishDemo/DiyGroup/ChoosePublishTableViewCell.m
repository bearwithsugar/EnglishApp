//
//  ChoosePublishTableViewCell.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/24.
//  Copyright © 2018 马一轩. All rights reserved.
//

#import "ChoosePublishTableViewCell.h"
@interface ChoosePublishTableViewCell(){
    
}
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIImageView *jiantou;
@end
@implementation ChoosePublishTableViewCell
@synthesize title=_title;
@synthesize jiantou=_jiantou;

+(instancetype)createCellWithTableView:(UITableView*)tableView{
    static NSString* id=@"flag";
    ChoosePublishTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:id];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle]loadNibNamed:@"ChoosePublishTableViewCell" owner:nil options:nil]lastObject];
    }
    return cell;
}
-(void)loadData:(NSString*)label1{
    self.title.text=label1;
    self.title.textAlignment=NSTextAlignmentRight;
    
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.jiantou.image=[UIImage imageNamed:@"icon_return_ffffff"];
    self.title.font=[UIFont systemFontOfSize:12];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    //self.title.textColor=[UIColor blackColor];
    self.title.textColor = selected?[UIColor whiteColor]:ssRGBHex(0x9B9B9B)  ;
}

@end
