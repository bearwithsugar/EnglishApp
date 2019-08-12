//
//  WordsListeningTableViewCell.h
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/21.
//  Copyright © 2018年 马一轩. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WordsListeningTableViewCell : UITableViewCell
+(instancetype)createCellWithTableView:(UITableView*)tableView;
-(void)loadData:(UIImageView*)image name:(NSString*)label1 description:(NSString*)label2;
-(void)clearLaba;

@property (weak, nonatomic) IBOutlet UIView *labaView;

@end

NS_ASSUME_NONNULL_END
