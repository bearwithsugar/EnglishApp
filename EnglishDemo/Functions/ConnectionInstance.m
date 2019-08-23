//
//  ConnectionInstance.m
//  EnglishDemo
//
//  Created by 马一轩 on 2019/3/27.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import "ConnectionInstance.h"
#import "AgentFunction.h"
#import "FixValues.h"
#import "RequestInstance.h"


@implementation ConnectionInstance

//直接获取最近学习信息
-(NSDictionary*)recentLearnMsg:(NSString*)userkey{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"recent"];
    RequestInstance* getReq=[[RequestInstance alloc]init];
    NSDictionary* dataDic=[getReq getRequestWithHead:url Head:userkey];
    return dataDic;
}

//书本单元信息
-(NSDictionary*)getUnitMsg:(NSString*)bookId UserKey:(NSString*)userkey{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"books/units"];
    url=[url URLByAppendingPathComponent:bookId];
    RequestInstance* getReq=[[RequestInstance alloc]init];
    NSDictionary* dataDic=[getReq getRequestWithHead:url Head:userkey];
    return dataDic;
}

//查询单元学习进度
-(NSDictionary*)unitProcess:(NSString*)bookId UserKey:(NSString*)userkey{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"user_unit"];
    url=[url URLByAppendingPathComponent:bookId];
    RequestInstance* getReq=[[RequestInstance alloc]init];
    NSDictionary* dataDic=[getReq getRequestWithHead:url Head:userkey];
    return dataDic;
}

//根据书籍获取最近学习信息
-(NSDictionary*)recentLearnMsgByBook:(NSString*)userkey Id:(NSString*)bookId{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"recent"];
    url=[url URLByAppendingPathComponent:bookId];
    RequestInstance* getReq=[[RequestInstance alloc]init];
    NSDictionary* dataDic=[getReq getRequestWithHead:url Head:userkey];
    return dataDic;
}

#pragma mark --书本信息接口
//获取选取书籍的出版社列表(根据书本分类type查询分类信息) 参数是分类的级别
-(NSDictionary*)getLineByType:(NSString*)menuType UserKey:(NSString*)userkey{
    NSURL* url=[FixValues getUrl];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    NSString* str2=[str stringByAppendingString:@"/category/type/"];
    str=[str2 stringByAppendingString:menuType];
    str=[str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    url=[NSURL URLWithString:str];
    RequestInstance* getReq=[[RequestInstance alloc]init];
    NSDictionary* dataDic=[getReq getRequestWithHead:url Head:userkey];
    return dataDic;
}
@end
