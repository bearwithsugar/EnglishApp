//
//  ConnectionInstance.h
//  EnglishDemo
//
//  Created by 马一轩 on 2019/3/27.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConnectionInstance : NSObject

//直接获取最近学习信息
-(NSDictionary*)recentLearnMsg:(NSString*)userkey;

//书本单元信息
-(NSDictionary*)getUnitMsg:(NSString*)bookId UserKey:(NSString*)userkey;

//查询单元学习进度
-(NSDictionary*)unitProcess:(NSString*)bookId UserKey:(NSString*)userkey;

//根据书籍获取最近学习信息
-(NSDictionary*)recentLearnMsgByBook:(NSString*)userkey Id:(NSString*)bookId;

#pragma mark --书本信息接口
//获取选取书籍的出版社列表(根据书本分类type查询分类信息) 参数是分类的级别
-(NSDictionary*)getLineByType:(NSString*)menuType UserKey:(NSString*)userkey;

@end

NS_ASSUME_NONNULL_END
