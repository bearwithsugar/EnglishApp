//
//  UUID.m
//  算法练习2
//
//  Created by 马一轩 on 2019/4/11.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import "UUID.h"
#import "GSKey.h"

#define  KEY_USERNAME_PASSWORD @"com.company.xueban.usernamepassword"
#define  KEY_USERNAME @"com.company.xueban.username"
#define  KEY_PASSWORD @"com.company.xueban.password"


@implementation UUID

+(NSString *)getUUID
{
    NSString * strUUID = (NSString *)[GSKey load:@"com.company.xueban.usernamepassword"];
    
    //首次执行该方法时，uuid为空
    if ([strUUID isEqualToString:@""] || !strUUID)
    {
        //生成一个uuid的方法
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        
        strUUID = (NSString *)CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
        
        //将该uuid保存到keychain
        [GSKey save:KEY_USERNAME_PASSWORD data:strUUID];
        
    }
    return strUUID;
}


@end
