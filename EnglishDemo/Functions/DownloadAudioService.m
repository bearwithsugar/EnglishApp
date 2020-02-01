//
//  DownloadAudioService.m
//  EnglishDemo
//
//  Created by 马一轩 on 2019/7/7.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import "DownloadAudioService.h"
#import "DocuOperate.h"

DownloadAudioService* downInstance;
@implementation DownloadAudioService
+(id)getInstance{
    if (downInstance == nil) {
        downInstance = [[DownloadAudioService alloc]init];
        
        if (![DocuOperate fileExistInPath:@"audioFile"]) {
            [DocuOperate createDir:[DocuOperate cacheDirectory] directoryName:@"audioFile"];
        }

    }
    return downInstance;
}

-(void)toLoadAudio:(NSString*)url FileName:(NSString*)name{
    
    NSString *filePath = [self getAudioPath:name];
    if ([DocuOperate isExitInPath:filePath]) {
        return;
    }
    NSData * mp3Data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
    [mp3Data writeToFile:filePath options:NSDataWritingAtomic error:nil];
}
-(NSString*)getAudioPath:(NSString*)name{
    return [[[DocuOperate cacheDirectory] stringByAppendingPathComponent:@"audioFile"]
                          stringByAppendingPathComponent:
                          [name stringByAppendingString:@".mp3"]];
}


@end
