//
//  BackgroundImageWithColor.h
//  EnglishDemo
//
//  Created by 马一轩 on 2019/1/19.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BackgroundImageWithColor : UIView
//  颜色转换为背景图片
+ (UIImage *)imageWithColor:(UIColor *)color;

//图片透明度
+ (UIImage *)imageByApplyingAlpha:(CGFloat)alpha  image:(UIImage*)image;

@end

NS_ASSUME_NONNULL_END
