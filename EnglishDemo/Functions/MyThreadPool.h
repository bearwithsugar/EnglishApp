//
//  MyThreadPool.h
//  EnglishDemo
//
//  Created by 马一轩 on 2019/7/25.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyThreadPool : NSObject

typedef void (^JobBlock) (void);

@property JobBlock jobBlock;

@property JobBlock mainThreadBlock;

+(void)executeJob:(JobBlock)block Main:(JobBlock)mainThreadBlock;

@end

NS_ASSUME_NONNULL_END
