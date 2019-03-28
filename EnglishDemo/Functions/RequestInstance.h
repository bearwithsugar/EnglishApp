//
//  RequestInstance.h
//  EnglishDemo
//
//  Created by 马一轩 on 2019/3/28.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RequestInstance : NSObject

-(NSDictionary*)getRequest:(NSURL*)url;

-(NSDictionary*)getRequestWithHead:(NSURL*)url Head:(NSString*)headMsg;

-(NSDictionary*)postRequest:(NSURL*)url;

-(NSDictionary*)postRequestWithHead:(NSURL*)url Head:(NSString*)headMsg;


@end

NS_ASSUME_NONNULL_END
