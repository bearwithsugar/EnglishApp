//
//  OrderTableViewCell.h
//  EnglishDemo
//
//  Created by 马一轩 on 2019/1/20.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ssRGBHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define ssRGBHexAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]

NS_ASSUME_NONNULL_BEGIN

@interface OrderTableViewCell : UITableViewCell
+(instancetype)createCellWithTableView:(UITableView*)tableView;
-(void)loadData:(NSString*)data Score:(NSString*)score description:(NSString*)description;

@end

NS_ASSUME_NONNULL_END
