//
//  GetDocPath.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/11/7.
//  Copyright © 2018 马一轩. All rights reserved.
//

#import "DocuOperate.h"

@implementation DocuOperate

#pragma mark --路径
//沙盒目录
+(NSString*)homeDirectory{
    return NSHomeDirectory();
}

//documents目录
+(NSString*)documentsDirectory{
    NSString* documentsDir=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return documentsDir;
}

//cache路径
+(NSString*)cacheDirectory{
    NSString* cacheDir=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)firstObject];
    return cacheDir;
}
#pragma mark --文件操作

//创建文件夹
+(BOOL)createDir:(NSString*)path directoryName:(NSString*)name {
    NSFileManager* fileManager=[NSFileManager defaultManager];
    NSString* newDirectory=[path stringByAppendingPathComponent:name];
    BOOL result=[fileManager createDirectoryAtPath:newDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    if (result) {
        return YES;
    }else{
        return NO;
    }
}
//创建文件 暂时没用
+(BOOL)createFile:(NSString*)path fileName:(NSString*)name{
    NSFileManager* fileManager=[NSFileManager defaultManager];
    NSString* newFilePath=[path stringByAppendingPathComponent:name];
    BOOL result=[fileManager createFileAtPath:newFilePath contents:nil attributes:nil];
    if (result) {
        return YES;
    }else{
        return NO;
    }
}
//检测文件夹以及文件是否存在
+(BOOL)fileExistInPath:(NSString*)fileName{
    NSFileManager* fileManager=[NSFileManager  defaultManager];
    BOOL exist=[fileManager fileExistsAtPath:[[self documentsDirectory] stringByAppendingPathComponent:fileName]];
    if (exist) {
        return YES;
    }else{
        if ([fileManager fileExistsAtPath:[[self cacheDirectory] stringByAppendingPathComponent:fileName]]) {
            return YES;
        }else{
            return NO;
        }
    }
}
//检测资源是否存在指定位置中
+(BOOL)isExitInPath:(NSString*)fileUrl{
    NSFileManager* fileManager=[NSFileManager  defaultManager];
    BOOL exist=[fileManager fileExistsAtPath:fileUrl];
    if (exist) {
        return YES;
    }else{
        return NO;
        
    }
}
//写入plist文件
+(BOOL)writeIntoPlist:(NSString*)fileName dictionary:(NSDictionary*)dictionary{
    //获取沙盒根根路径,每一个应用在手机当中都有一个文件夹,这个方法就是获取当前应用在手机里安装的文件.
    NSLog(@"传到这里的字典是：%@",dictionary);
    //NSLog(@"沙盒路径是：%@",[self homeDirectory]);
    NSString *filePathName = [[self documentsDirectory] stringByAppendingPathComponent:fileName];
    if ([dictionary writeToFile:filePathName atomically:YES]) {
        NSLog(@"存入文件成功");
        return YES;
    }else{
        NSLog(@"存入文件失败");
        return NO;
    }
}
//读plist文件
+(NSDictionary*)readFromPlist:(NSString*)fileName{
    NSString *filePathName = [[self documentsDirectory] stringByAppendingPathComponent:fileName];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:filePathName];
    return dict;
}
//删除Plist文件
+(BOOL)deletePlist:(NSString*)fileName{
    BOOL flag;
    NSFileManager *fileMger = [NSFileManager defaultManager];
    NSError *err;
    if ([self fileExistInPath:fileName]) {
        flag=[fileMger removeItemAtPath:[[DocuOperate documentsDirectory] stringByAppendingPathComponent:fileName] error:&err];
        NSLog(@"删除plist文件的错误信息%@",err);
        return flag;
    }else{
        return NO;
    }
    
}
//替换plist文件
+(BOOL)replacePlist:(NSString*)fileName dictionary:(NSDictionary*)dictionary{
    [self deletePlist:fileName];
    [self writeIntoPlist:fileName dictionary:dictionary];
        return true;
    
}
//uiimage类型的图片存储
+ (void)saveImage:(UIImage *)tempImage WithName:(NSString *)imageName
{
    NSData *imageData = UIImagePNGRepresentation(tempImage);
    
    //判断图像是png格式的还是jpg格式的（iOS相册里面可以保存gif格式的，可是gif格式的图片在相册中是以静态图显示的）
    if (UIImagePNGRepresentation(tempImage) == nil)
    {
        imageData = UIImageJPEGRepresentation(tempImage, 1.0);
    }
    else
    {
        imageData = UIImagePNGRepresentation(tempImage);
    }
    
    NSString* documentPath = [self documentsDirectory];
    NSString *tempDocumentPath = [documentPath stringByAppendingPathComponent:imageName];
    
    //保存到 document
    [imageData writeToFile: tempDocumentPath atomically:NO];
    
    
}
//删除文件夹
+(BOOL)deleteFolder:(NSString*)name{
    NSString *imageDir = [NSString stringWithFormat:@"%@/%@", [self cacheDirectory], name];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *err;
    BOOL flag=[fileManager removeItemAtPath:imageDir error:&err];
    NSLog(@"删除文件夹的错误信息%@",err);
    return flag;
   
}
//删除documents中的文件
+(BOOL)deleteFileInDocuments:(NSString*)name{
    NSString *imageDir = [NSString stringWithFormat:@"%@/%@", [self documentsDirectory], name];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *err;
    BOOL flag=[fileManager removeItemAtPath:imageDir error:&err];
    NSLog(@"删除文件的错误信息%@",err);
    return flag;
    
}
@end
