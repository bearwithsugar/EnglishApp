//
//  UnitsListDownTableViewCell.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/23.
//  Copyright © 2018 马一轩. All rights reserved.
//

#import "UnitsListDownTableViewCell.h"
@interface UnitsListDownTableViewCell(){
    
}
@property (weak, nonatomic) IBOutlet UIButton *downBtn;
@property (weak, nonatomic) IBOutlet UILabel *title;
@end
@implementation UnitsListDownTableViewCell
@synthesize downBtn=_downBtn;
@synthesize title=_title;

+(instancetype)createCellWithTableView:(UITableView*)tableView{
    static NSString* id=@"flag";
    UnitsListDownTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:id];
    if (cell==nil) {
        
        cell=[[[NSBundle mainBundle]loadNibNamed:@"UnitsListDownTableViewCell" owner:nil options:nil]lastObject];
    }
    
    return cell;
}
-(void)loadData:(NSString*)label1{
    self.title.text=label1;
    self.title.font=[UIFont systemFontOfSize:14];
    [self.downBtn setBackgroundImage:[UIImage imageNamed:@"btn_download_tingxie"] forState:UIControlStateNormal];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
