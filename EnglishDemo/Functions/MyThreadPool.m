//
//  MyThreadPool.m
//  EnglishDemo
//
//  Created by 马一轩 on 2019/7/25.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import "MyThreadPool.h"

@implementation MyThreadPool


+(void)executeJob:(JobBlock)block Main:(JobBlock)mainThreadBlock{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        block();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            mainThreadBlock();

        });
    });
}

@end
