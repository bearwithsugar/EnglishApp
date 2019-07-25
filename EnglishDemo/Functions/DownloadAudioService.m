//
//  DownloadAudioService.m
//  EnglishDemo
//
//  Created by 马一轩 on 2019/7/7.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import "DownloadAudioService.h"
#import "DocuOperate.h"


@implementation DownloadAudioService

+(void)toLoadAudio:(NSString*)url FileName:(NSString*)name{
    
    NSData * mp3Data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
    NSString *filePath = [[[DocuOperate cacheDirectory] stringByAppendingPathComponent:@"audioFile"]
                          stringByAppendingPathComponent:
                          [name stringByAppendingString:@".mp3"]];
    if ([DocuOperate isExitInPath:filePath]) {
        return;
    }
    [mp3Data writeToFile:filePath options:NSDataWritingAtomic error:nil];
}
+(NSString*)getAudioPath:(NSString*)name{
    return [[[DocuOperate cacheDirectory] stringByAppendingPathComponent:@"audioFile"]
                          stringByAppendingPathComponent:
                          [name stringByAppendingString:@".mp3"]];
}


@end
