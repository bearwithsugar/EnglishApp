//
//  LocalDataOperation.m
//  EnglishDemo
//
//  Created by 马一轩 on 2019/1/20.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import "LocalDataOperation.h"
#import "DocuOperate.h"

@implementation LocalDataOperation

+(void)saveImage:(NSString*)imageUrl Name:(NSString*)picName{
    if (![DocuOperate fileExistInPath:[self getImageDirName]]) {
        [self createDirectoryForImage];
    }
    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
    UIImage* image=[UIImage imageWithData:imgData];
    
    NSString* cachePath=[DocuOperate cacheDirectory];
    NSString* imagePath=[cachePath stringByAppendingString:@"/"];
    imagePath=[imagePath stringByAppendingString:[self getImageDirName]];
    imagePath=[imagePath stringByAppendingString:@"/"];
    imagePath=[imagePath stringByAppendingString:picName];
    imagePath=[imagePath stringByAppendingString:@".png"];
    NSLog(@"图片存储路径%@",imagePath);
    if ([UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES]) {
        NSLog(@"图片保存成功");
    }else{
        NSLog(@"图片保存失败");
    }
}
+(void)createDirectoryForImage{
    if ([DocuOperate createDir:[DocuOperate cacheDirectory] directoryName:[self getImageDirName]]) {
        NSLog(@"创建图片文件夹成功");
    }else{
        NSLog(@"创建图片文件夹失败");
    }
}
+(NSString*)getImageDirName{
    return @"imageFile";
}
+(UIImage*)getImage:(NSString*)imageId httpUrl:(NSString*)imageUrl{
    NSString *filePath = [[DocuOperate cacheDirectory]stringByAppendingString:@"/"];
    filePath=[filePath stringByAppendingString:[self getImageDirName]];
    filePath=[filePath stringByAppendingString:@"/"];
    filePath=[filePath stringByAppendingString:imageId];
    //filePath=[filePath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    filePath=[filePath stringByAppendingString:@".png"];
    
    if (![DocuOperate isExitInPath:filePath]) {
        [self saveImage:imageUrl Name:imageId];
    }
    // 保存文件的名称
    UIImage *img = [UIImage imageWithContentsOfFile:filePath];
    return img;
}

//压缩图片
+ (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}


@end
