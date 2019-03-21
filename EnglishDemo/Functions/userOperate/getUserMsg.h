//
//  getUserMsg.h
//  EnglishDemo
//
//  Created by 马一轩 on 2019/1/19.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface getUserMsg : NSObject

//获取学分
+(NSDictionary*)getUserScore:(NSString*)userKey;

@end

NS_ASSUME_NONNULL_END
