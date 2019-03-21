//
//  DataFilter.h
//  EnglishDemo
//
//  Created by 马一轩 on 2018/11/8.
//  Copyright © 2018 马一轩. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataFilter : NSObject
//过滤字典中的空值
+(NSDictionary*)DictionaryFilter:(NSDictionary*)beforeDic;

@end

NS_ASSUME_NONNULL_END
