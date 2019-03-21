//
//  DataFilter.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/11/8.
//  Copyright © 2018 马一轩. All rights reserved.
//

#import "DataFilter.h"

@implementation DataFilter
//过滤字典中的空值
+(NSDictionary*)DictionaryFilter:(NSDictionary*)beforeDic{
    //在使用数组或字典的同时修改他们的值会报错，所以我定义两个字典，在操作一个字典的时候，修改另一个字典的值，
    NSMutableDictionary* afterDic=[[NSMutableDictionary alloc]initWithDictionary:beforeDic];
    for (NSString* item in beforeDic) {
        if ([[beforeDic valueForKey:item] isKindOfClass:[NSNull class]]) {
            //删除key
            // [dictionaryTwo removeObjectForKey:item];
            //修改value
            [afterDic setObject:@"" forKey:item];
        }
    }
    return afterDic;
}
@end
