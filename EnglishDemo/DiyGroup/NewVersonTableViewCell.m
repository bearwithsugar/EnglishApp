//
//  NewVersonTableViewCell.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/24.
//  Copyright © 2018 马一轩. All rights reserved.
//

#import "NewVersonTableViewCell.h"
@interface NewVersonTableViewCell(){
    
}
@property (weak, nonatomic) IBOutlet UILabel *version;
@property (weak, nonatomic) IBOutlet UILabel *haveNew;
@property (weak, nonatomic) IBOutlet UIImageView *logo;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIImageView *jiantou;
@end
@implementation NewVersonTableViewCell
@synthesize version=_version;
@synthesize haveNew=_haveNew;
@synthesize logo=_logo;
@synthesize title=_title;
@synthesize jiantou=_jiantou;

+(instancetype)createCellWithTableView:(UITableView*)tableView{
    static NSString* id=@"flag";
    NewVersonTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:id];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle]loadNibNamed:@"NewVersonTableViewCell" owner:nil options:nil]lastObject];
    }
    return cell;
}

-(void)loadData:(NSString*)label1{
    self.version.text=label1;
    self.version.textColor=ssRGBHex(0x9B9B9B);
}

-(void)setNoVersion{
    self.haveNew.text=@"当前是最新版本";
    self.haveNew.textColor=ssRGBHex(0x9B9B9B);
}

-(void)setNewVersion{
    self.haveNew.text=@"有新版本，请前往APP store下载";
    self.haveNew.textColor=ssRGBHex(0xFF7474);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.logo.image=[UIImage imageNamed:@"icon_banben"];
    self.title.text=@"软件版本";
    self.title.font=[UIFont systemFontOfSize:14];
    self.haveNew.font=[UIFont systemFontOfSize:14];
    self.jiantou.image=[UIImage imageNamed:@"icon_foward"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
