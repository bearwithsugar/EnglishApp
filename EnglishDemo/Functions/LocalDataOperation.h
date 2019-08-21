//
//  LocalDataOperation.h
//  EnglishDemo
//
//  Created by 马一轩 on 2019/1/20.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocalDataOperation : NSObject
//获取图片（一站式创建图片文件夹、存储图片、获取图片）
+(UIImage*)getImage:(NSString*)imageId httpUrl:(NSString*)imageUrl;
//压缩图片
+ (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize;
//返回图片本地路径
+(NSURL*)getImagePath:(NSString*)imageId httpUrl:(NSString*)imageUrl;
@end

NS_ASSUME_NONNULL_END
