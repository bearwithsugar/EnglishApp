//
//  LearningViewController.h
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/19.
//  Copyright © 2018年 马一轩. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#define ssRGBHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define ssRGBHexAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]

NS_ASSUME_NONNULL_BEGIN

@interface LearningViewController : UIViewController

@property(nonatomic,copy)NSString* bookId;
@property(nonatomic,copy)NSString* unitId;
@property (nonatomic, retain)AVAudioPlayer *player;
@end

NS_ASSUME_NONNULL_END
