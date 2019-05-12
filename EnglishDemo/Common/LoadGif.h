//
//  LoadGif.h
//  EnglishDemo
//
//  Created by 马一轩 on 2019/2/19.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoadGif : UIView

+(UIImageView*)imageViewStartAnimating:(CGRect)cgrect;

//喇叭循环动画
+(UIImageView*)imageViewfForPlaying:(CGRect)cgrect;

@end

NS_ASSUME_NONNULL_END
