//
//  TestFunctions.h
//  EnglishDemo
//
//  Created by 马一轩 on 2019/1/14.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ssRGBHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define ssRGBHexAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]

NS_ASSUME_NONNULL_BEGIN

@interface TestFunctions : UIView
@property(nonatomic,copy)NSString* testType;
@property(nonatomic,copy)NSArray* testArray;
@property int testFlag;
@property BOOL clickable;
@property(nonatomic,copy)NSDictionary* userInfo;

//对于错题本
@property int wordNum;

-(id)initWithFlag:(int)testFlag
         TestArray:(NSArray*)testArray
          TestType:(NSString*)testType
          UserInfo:(NSDictionary*)userInfo;
@end

NS_ASSUME_NONNULL_END
