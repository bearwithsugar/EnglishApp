//
//  ChooseLessonView.h
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/22.
//  Copyright © 2018年 马一轩. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ssRGBHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define ssRGBHexAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]



NS_ASSUME_NONNULL_BEGIN

@interface ChooseLessonView : UIView
//每一课的教学信息
@property(nonatomic,copy)NSDictionary* dataArray;
@property(nonatomic,copy)NSString* unitName;
@property(nonatomic,copy)NSString* className;
@property(nonatomic,copy)NSString* bookId;
@property(nonatomic,copy)NSString* articleId;
//单元下的课数组
@property(nonatomic,copy)NSArray* lessonArray;

@property NSInteger defaultUnit;

typedef void (^ShowContentBlock) (NSArray* bookpicarray,NSArray* sentencearray,NSString* classid,NSString* unitname,NSString* classname);

typedef void (^JobBlock) (void);

@property ShowContentBlock showContentBlock;

-(id)initWithFrame:(CGRect)frame bookId:(NSString*)bookid DefaultUnit:(NSInteger)defaultunit ShowBlock:(ShowContentBlock)showContentBlock;

@end


NS_ASSUME_NONNULL_END
