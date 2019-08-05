//
//  VoicePlayer.h
//  EnglishDemo
//
//  Created by 马一轩 on 2018/12/16.
//  Copyright © 2018 马一轩. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../FreeStreamer/FSAudioStream.h"

NS_ASSUME_NONNULL_BEGIN

@interface VoicePlayer : NSObject
@property (nonatomic,strong) FSAudioStream *audioStream;
@property (nonatomic,strong) NSString* url;
@property (nonatomic,strong) NSArray* urlArray;
@property  NSInteger startIndex;

typedef void (^VoidBlock) (void);

@property VoidBlock myblock;

//-(FSAudioStream *)audioStream:(NSString*)urlStr;

//根据l本地路径播放声音
//-(void)playAudio;
-(void)playAudio:(NSInteger)times;
-(void)interruptPlay;

@end

NS_ASSUME_NONNULL_END
