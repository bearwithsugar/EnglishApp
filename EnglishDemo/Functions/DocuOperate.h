//
//  GetDocPath.h
//  EnglishDemo
//
//  Created by 马一轩 on 2018/11/7.
//  Copyright © 2018 马一轩. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DocuOperate : NSObject
//沙盒路径
+(NSString*)homeDirectory;
//Document路径
+(NSString*)documentsDirectory;
//cache路径
+(NSString*)cacheDirectory;
//创建文件夹
+(BOOL)createDir:(NSString*)path directoryName:(NSString*)name;
//创建文件 暂时没用
+(BOOL)createFile:(NSString*)path fileName:(NSString*)name;
//检测文件夹以及文件是否存在
+(BOOL)fileExistInPath:(NSString*)fileName;
//检测资源是否存在指定位置中
+(BOOL)isExitInPath:(NSString*)fileUrl;
//写入plist文件
+(BOOL)writeIntoPlist:(NSString*)fileName dictionary:(NSDictionary*)dictionary;
//读plist文件
+(NSDictionary*)readFromPlist:(NSString*)fileName;
//删除Plist文件
+(BOOL)deletePlist:(NSString*)filePath;
//uiimage类型的图片存储
+ (void)saveImage:(UIImage *)tempImage WithName:(NSString *)imageName;
//删除文件夹
+(BOOL)deleteFolder:(NSString*)name;
//删除documents中的文件
+(BOOL)deleteFileInDocuments:(NSString*)name;
//替换plist文件
+(BOOL)replacePlist:(NSString*)fileName dictionary:(NSDictionary*)dictionary;
@end

NS_ASSUME_NONNULL_END
