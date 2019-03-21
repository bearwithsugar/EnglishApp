//
//  UnitsListDownTableViewCell.h
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/23.
//  Copyright © 2018 马一轩. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UnitsListDownTableViewCell : UITableViewCell
+(instancetype)createCellWithTableView:(UITableView*)tableView;
-(void)loadData:(NSString*)label1;
@end

NS_ASSUME_NONNULL_END
