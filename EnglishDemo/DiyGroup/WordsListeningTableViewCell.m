//
//  WordsListeningTableViewCell.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/21.
//  Copyright © 2018年 马一轩. All rights reserved.
//

#import "WordsListeningTableViewCell.h"
#import "../Common/LoadGif.h"
#import "Masonry.h"
@interface WordsListeningTableViewCell(){
    
    UIImageView* laba;
    
}
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
-(void)loadData:(UIImageView*)image name:(NSString*)label1 description:(NSString*)label2{
    [_labaView addSubview:image];
    _labaView.backgroundColor = [UIColor clearColor];
    [image mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(image);
    }];
    self.name.text=label1;
    self.name.font=[UIFont systemFontOfSize:14];
    self.description.text=label2;
    self.description.font=[UIFont systemFontOfSize:12];
    self.name.adjustsFontSizeToFitWidth =YES;
    self.description.adjustsFontSizeToFitWidth = YES;
    laba = image;
}
- (void)awakeFromNib;{
    [super awakeFromNib];
}

-(void)clearLaba{
    [laba removeFromSuperview];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
