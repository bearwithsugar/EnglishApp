//
//  WordsListeningTableViewCell.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/21.
//  Copyright © 2018年 马一轩. All rights reserved.
//

#import "WordsListeningTableViewCell.h"
@interface WordsListeningTableViewCell(){
    
}
@property (weak, nonatomic) IBOutlet UIButton *labaBtn;
@property (weak, nonatomic) IBOutlet UILabel *description;
@property (weak, nonatomic) IBOutlet UILabel *name;
@end

@implementation WordsListeningTableViewCell
@synthesize description=_description;
@synthesize name=_name;

+(instancetype)createCellWithTableView:(UITableView*)tableView{
    static NSString* id=@"flag";
    WordsListeningTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:id];
    if (cell==nil) {
    
        cell=[[[NSBundle mainBundle]loadNibNamed:@"WordsListeningTableViewCell" owner:nil options:nil]lastObject];
    }
    return cell;
}
-(void)loadData:(NSString*)image name:(NSString*)label1 description:(NSString*)label2{
    [self.labaBtn setBackgroundImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    self.name.text=label1;
    self.name.font=[UIFont systemFontOfSize:14];
    self.description.text=label2;
    self.description.font=[UIFont systemFontOfSize:12];
    self.name.adjustsFontSizeToFitWidth =YES;
    self.description.adjustsFontSizeToFitWidth = YES;
}
- (void)awakeFromNib;{
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.backgroundColor=[UIColor whiteColor];
}

@end
