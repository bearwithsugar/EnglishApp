//
//  RefreshUserInfo.m
//  EnglishDemo
//
//  Created by 马一轩 on 2019/1/19.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import "RefreshUserInfo.h"
#import "DocuOperate.h"
#import "ConnectionFunction.h"

@implementation RefreshUserInfo
//暂时没用
+(NSDictionary*)refreshUserInfo:(NSString*)username
                  Pass:(NSString*)password
               DevName:(NSString*)devNmae
                 DevId:(NSString*)devid
{
    NSDictionary* loginResult= [ConnectionFunction login_password:[username longLongValue]
                                  Pass:password
                                  Name:devNmae
                                    Id:devid];
    
    return loginResult;
    
    
}

@end
