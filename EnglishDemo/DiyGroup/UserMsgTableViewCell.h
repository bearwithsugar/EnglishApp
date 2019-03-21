//
//  UserMsgTableViewCell.h
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/24.
//  Copyright © 2018 马一轩. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserMsgTableViewCell : UITableViewCell
+(instancetype)createCellWithTableView:(UITableView*)tableView;
-(void)loadData:(NSString*)label1 logoImg:(NSString*)image;
@end

NS_ASSUME_NONNULL_END
