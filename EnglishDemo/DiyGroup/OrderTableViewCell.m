//
//  OrderTableViewCell.m
//  EnglishDemo
//
//  Created by 马一轩 on 2019/1/20.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import "OrderTableViewCell.h"
@interface OrderTableViewCell(){
    
}
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;

@property (weak, nonatomic) IBOutlet UILabel *dataLabel;
@end

@implementation OrderTableViewCell
@synthesize dataLabel=_dataLabel;
@synthesize moneyLabel=_moneyLabel;

+(instancetype)createCellWithTableView:(UITableView*)tableView{
    static NSString* id=@"flag";
    OrderTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:id];
    if (cell==nil) {
        
        cell=[[[NSBundle mainBundle]loadNibNamed:@"OrderTableViewCell" owner:nil options:nil]lastObject];
    }
    return cell;
}
-(void)loadData:(NSString*)data Score:(NSString*)score description:(NSString*)description{
    self.dataLabel.text=data;
    NSString* detailMsg=@"充值";
    detailMsg=[detailMsg stringByAppendingString:score];
    detailMsg=[detailMsg stringByAppendingString:@"元，"];
    detailMsg=[detailMsg stringByAppendingString:description];
    self.moneyLabel.text=detailMsg;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.dataLabel.textAlignment=NSTextAlignmentCenter;
    self.dataLabel.font=[UIFont systemFontOfSize:14];
    self.dataLabel.textColor=ssRGBHex(0x4A4A4A);
    self.moneyLabel.textAlignment=NSTextAlignmentCenter;
    self.moneyLabel.font=[UIFont systemFontOfSize:14];
    self.moneyLabel.textColor=ssRGBHex(0x4A4A4A);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
