//
//  GSKey.h
//  算法练习2
//
//  Created by 马一轩 on 2019/4/10.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSKey : NSObject

+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)deleteKeyData:(NSString *)service;


@end

NS_ASSUME_NONNULL_END
