//
//  LoadGif.m
//  EnglishDemo
//
//  Created by 马一轩 on 2019/2/19.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import "LoadGif.h"

@implementation LoadGif

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+(UIImageView*)imageViewStartAnimating{
    UIImageView* imageView=[[UIImageView alloc]init];
    
    NSMutableArray *imageArr = [NSMutableArray arrayWithCapacity:3];
    for (int i = 0; i<12; i++) {
        NSString *imageStr = [NSString stringWithFormat:@"loadPic%d",i + 1];
        UIImage *image = [UIImage imageNamed:imageStr];
        [imageArr addObject:image];
    }
    
    imageView.animationImages = imageArr;
    
    imageView.animationDuration = 1;
    
    imageView.animationRepeatCount = 0;
    
    [imageView startAnimating];
    return imageView;
}

+(UIImageView*)imageViewfForPlaying{
    UIImageView* imageView=[[UIImageView alloc]init];
    NSMutableArray *imageArr = [[NSMutableArray alloc]init];
    for (int i = 0; i<=1; i++) {
        NSString *imageStr = [NSString stringWithFormat:@"icon_laba%d",i + 1];
        UIImage *image = [UIImage imageNamed:imageStr];
        [imageArr addObject:image];
    }
    imageView.animationImages = imageArr;
    
    imageView.animationDuration = 1;
    
    imageView.animationRepeatCount = 0;
    
    [imageView startAnimating];
    return imageView;
}
@end
