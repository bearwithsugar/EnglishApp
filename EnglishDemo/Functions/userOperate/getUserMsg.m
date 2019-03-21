//
//  getUserMsg.m
//  EnglishDemo
//
//  Created by 马一轩 on 2019/1/19.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import "getUserMsg.h"
#import "../ConnectionFunction.h"

@implementation getUserMsg
//获取学分
+(NSDictionary*)getUserScore:(NSString*)userKey{
    return [ConnectionFunction getScore:userKey];
}

@end
