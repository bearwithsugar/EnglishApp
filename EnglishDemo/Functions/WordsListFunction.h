//
//  WordsListFunction.h
//  EnglishDemo
//
//  Created by 马一轩 on 2020/1/12.
//  Copyright © 2020 马一轩. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WordsListFunction : NSObject

//根据课程id获取单词列表
+(void)getWordsList:(NSString*)articleId UserKey:(NSString*)userKey;

//根据课程id获取句子列表
+(void)getSentencesList:(NSString*)articleId UserKey:(NSString*)userKey;

@end

NS_ASSUME_NONNULL_END
