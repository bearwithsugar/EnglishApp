//
//  WordsListFunction.m
//  EnglishDemo
//
//  Created by 马一轩 on 2020/1/12.
//  Copyright © 2020 马一轩. All rights reserved.
//

#import "WordsListFunction.h"
#import "ConnectionFunction.h"

@implementation WordsListFunction

+(void)getWordsList:(NSString*)articleId UserKey:(NSString*)userKey{
    NSDictionary* unit = [ConnectionFunction getUnitMsg:articleId UserKey:userKey];
    NSLog(@"unit:$%@",unit);
    NSDictionary* dic = [ConnectionFunction getTestWordMsg:articleId UserKey:userKey];
    NSLog(@"dic:%@",dic);
}

+(void)getSentencesList:(NSString*)articleId UserKey:(NSString*)userKey{
    
    NSDictionary* dic = [ConnectionFunction getTestSentenceMsg:articleId UserKey:userKey];
}


@end
