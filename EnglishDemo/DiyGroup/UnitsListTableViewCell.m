//
//  UnitsListTableViewCell.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/22.
//  Copyright © 2018 马一轩. All rights reserved.
//

#import "UnitsListTableViewCell.h"
@interface UnitsListTableViewCell(){
    
    
}
@property (weak, nonatomic) IBOutlet UILabel *process;
@property (weak, nonatomic) IBOutlet UILabel *title;

@end

@implementation UnitsListTableViewCell
@synthesize process=_process;
@synthesize title=_title;

+(instancetype)createCellWithTableView:(UITableView*)tableView{
    static NSString* id=@"flag";
    UnitsListTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:id];
    if (cell==nil) {
        
        cell=[[[NSBundle mainBundle]loadNibNamed:@"UnitsListTableViewCell" owner:nil options:nil]lastObject];
    }
    
    return cell;
}
-(void)loadData:(NSString*)label1 description:(NSString*)label2{
    self.title.text=label1;
    self.title.font=[UIFont systemFontOfSize:14];
    self.title.textColor=ssRGBHex(0xFF7474);
    self.process.text=label2;
    self.process.textColor=ssRGBHex(0xFF7474);
    self.process.textAlignment=NSTextAlignmentCenter;
    self.process.font=[UIFont systemFontOfSize:12];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
}

@end
