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
    
    if ([strUUID isEqualToString:@""] || !strUUID)
    {
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        
        strUUID = (NSString *)CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
        
        [GSKey save:KEY_USERNAME_PASSWORD data:strUUID];
        
    }
    return strUUID;
}


@end
