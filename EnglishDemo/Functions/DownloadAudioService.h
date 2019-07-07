//
//  DownloadAudioService.h
//  EnglishDemo
//
//  Created by 马一轩 on 2019/7/7.
//  Copyright © 2019 马一轩. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadAudioService : NSObject

+(void)toLoadAudio:(NSString*)url FileName:(NSString*)name;
+(NSString*)getAudioPath:(NSString*)name;

@end
